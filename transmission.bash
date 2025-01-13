#!/bin/bash
# script to retrieve and parse torrent details from the transmission bittorrent client.
# torrent data is saved as individual files in the /tmp/conky directory for conky to read.

. ~/conky/monochrome/logging.bash

function usage {
  echo $(basename $0) [--format type] [--name-width n] [--offset n]
  echo "where 'format is default|flipped|vertical"
  echo "      'name width' is the number of characters to print for the active torrent names"
  echo "      'offset' is the number of pixels between the columns"
}

function onExitSignal {
  log 'received shutdown signal, deleting output files'
  rm -f ${outputDir}/transmission.*
  [[ $pid ]] && kill $pid
  exit 0
}

function getUploadTorrents {
  grep -E '(Seeding|Uploading|Up & Down)' ${torrents}.$$ \
    | cut -d ':' -f 1,4 \
    | sort -t ':' -k 2
}

function getDownloadTorrents {
  grep -E '(Downloading|Up & Down)' ${torrents}.$$ \
    | cut -d ':' -f 2,4 \
    | sort -t ':' -k 2
}

function renameTempFile {
  for f in "$@"
  do [[ -f ${f}.$$ ]] && mv ${f}.$$ ${f}
  done
}

# ---------- script begins
trap onExitSignal EXIT

if ! type transmission-remote > /dev/null 2>&1; then
  msg="the transmission bittorrent client is not installed on this system\n"
  msg="${msg}the transmission conky will not be operational"
  logError "$msg"
  exit 1
fi

offset=10
nameWidth=30      # number of characters for the active torrent names
format=default    # uploads and downloads on the same row

while (( "$#" )); do
  case $1 in
    --format)
      format=$2
      shift 2
      ;;
    --offset)
      offset=$2
      shift 2
      ;;
    --name-width)
      nameWidth=$2
      shift 2
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

[[ $nameWidth -lt 15 ]] && { logError 'torrent name width should have at least 15 characters'; exit 1; }

log 'starting transmission torrent info service'
log "formatting style: ${format}"
log "                  ${nameWidth} characters for torrent names"
log "                  ${offset} px offset between columns"
outputDir=/tmp/conky
mkdir -p ${outputDir}
# torrents overview
speedUploadFile=${outputDir}/transmission.speed.up
speedDownloadFile=${outputDir}/transmission.speed.down
# active torrents
torrentsRaw=${outputDir}/transmission.torrents.raw
torrents=${outputDir}/transmission.torrents
activeFile=${outputDir}/transmission.active
torrentsUpFile=${outputDir}/transmission.torrents.up
torrentsDownFile=${outputDir}/transmission.torrents.down
# peers
peers=${outputDir}/transmission.peers.raw
peersFile=${outputDir}/transmission.peers
peersUploadsFile=${outputDir}/transmission.peers.up
peersDownloadsFile=${outputDir}/transmission.peers.down

while [ true ]; do 
  # ::: active torrents
  # $ transmission-remote -t active -l
  # 1   2    3          4     5             6     7     8      9            10
  #     ID   Done       Have  ETA           Up    Down  Ratio  Status       Name
  #    168   100%   11.74 GB  17 days      0.0     0.0   2.47  Seeding      fedora 37.iso
  #    320    35%   989.0 MB  8 min     1538.0  3620.0   0.14  Up & Down    photo gallery
  #    126*  100%   114.0 MB  Done      1189.0     0.0    107  Seeding      books
  #    127   100%   16.99 GB  230 days     0.0     0.0   97.7  Idle         magazines   << iddle entries are ignored
  # Sum:            31.69 GB            2727.0  3620.0
  transmission-remote -t active -l > ${torrentsRaw}
  awk 'END{printf "%'\''d KiB", $4}' ${torrentsRaw} > ${speedUploadFile}.$$
  awk 'END{printf "%'\''d KiB", $5}' ${torrentsRaw} > ${speedDownloadFile}.$$
  # text manipulations done to the active torrents file:
  #   - replace the space separator with colon ':'
  #   - remove the '#' character, it messes up how conky prints a file (it gets interpreted as a comment)
  #   - UTF characters replaced with a dot, the default conky font only supports ascii
  #     japanese characters would yield multiple giberish characters
  #     utf characters get replaced with 3 dots, then the 3 dots get replaced with a single dot
  grep -E '(Seeding|Downloading|Uploading|Up & Down)' ${torrentsRaw} \
    | LANG=C sed -e 's/  \+/:/g' -e 's/#//g' -e 's/[\x80-\xFF]/./g' -e 's/\.\.\././g' \
    | cut -d ':' -f 6,7,9,10 \
    | sort -t ':' -k 3 > ${torrents}.$$
    
  case $format in
    default)
      awk -F ':' "{printf \"%-${nameWidth}.${nameWidth}s\${offset ${offset}}%5d\${offset ${offset}}\${color}%5d\n\", \$4, \$1, \$2}" ${torrents}.$$ > ${activeFile}.$$
      ;;
    flipped)
      getUploadTorrents | awk -F ':' "{printf \"\${color4}%5d\${offset ${offset}}\${color}%-${nameWidth}.${nameWidth}s\n\", \$1, \$2}" > ${torrentsUpFile}.$$
      getDownloadTorrents | awk -F ':' "{printf \"\${color}%5d\${offset ${offset}}\${color}%-${nameWidth}.${nameWidth}s\n\", \$1, \$2}" > ${torrentsDownFile}.$$
      ;;
    vertical)
      getUploadTorrents | awk -F ':' "{printf \"\${color}%-${nameWidth}.${nameWidth}s\${offset ${offset}}\${color4}%5d\n\", \$2, \$1}" > ${torrentsUpFile}.$$
      getDownloadTorrents | awk -F ':' "{printf \"\${color}%-${nameWidth}.${nameWidth}s\${offset ${offset}}\${color}%5d\n\", \$2, \$1}" > ${torrentsDownFile}.$$
      ;;
  esac
  
  # ::: connected peers
  # Address          Flags     Done  Down    Up      Client
  # 72.178.162.10    ?E        0.0      0.0     0.0  µTorrent 1.8.3
  # 95.168.162.205   DE        100.0 5349.0     0.0  libTorrent (Rakshasa) 0.13.8  # spacing between done/down required
  # 116.121.146.69   UKEI      42.8     0.0     0.0  qBittorrent 4.4.2
  #
  # peers with no traffic (0.0 up/down) are removed
  transmission-remote -t active -pi \
    | grep -e '^[0-9]' \
    | sed -r -e 's/.0 ([0-9])/.0  \1/' -e 's/  +/:/g' -e 's/µ/u/' \
    | grep -vF ':0.0:0.0:' \
    | sort -t . -k 1n -k 2n -k 3n -k 4n > ${peers}.$$
  
  case $format in
    default)
      cut -d ':' -f 1,4,5,6 ${peers}.$$ \
        | awk -F ':' "{printf \"%-15s\${offset 12}%-13.13s\${offset ${offset}}%5d\${offset ${offset}}\${color}%5d\n\", \$1, \$4, \$3, \$2}" > ${peersFile}.$$
      ;;
    flipped)
      cut -d ':' -f 1,3,5 ${peers}.$$ \
        | grep -vF ':0.0' \
        | awk -F ':' "{printf \"\${color4}%5d\${offset ${offset}}\${color}%-15s\${offset ${offset}}%5.1f%%\n\", \$3, \$1, \$2}" > ${peersUploadsFile}.$$
      cut -d ':' -f 1,3,4 ${peers}.$$ \
        | grep -vF ':0.0' \
        | awk -F ':' "{printf \"%5d\${offset ${offset}}\${color}%-15s\${offset ${offset}}%5.1f%%\n\", \$3, \$1, \$2}" > ${peersDownloadsFile}.$$
      ;;
  esac
  
  # rename temporary files into the official ones, this prevents race conditions with conky reading these files
  # general details
  renameTempFile ${torrents} ${speedUploadFile} ${speedDownloadFile} ${peers}
  # default format
  renameTempFile ${activeFile} ${peersFile}
  # vertical/flipped format
  renameTempFile ${torrentsUpFile} ${torrentsDownFile} ${peersUploadsFile} ${peersDownloadsFile}
  
  sleep 2s & pid=$!
  wait
  unset pid
done
