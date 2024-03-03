#!/bin/bash
# script to retrieve and parse torrent details from the transmission bittorrent client.
# torrent data is saved as individual files in the /tmp/conky directory for conky to read.

. ~/conky/monochrome/logging.bash

function usage {
  echo $(basename $0) [--name-width n] [--offset n]
  echo "where 'name width' is the number of characters to print for the active torrent names"
  echo "      'offset' is the number of pixels between the columns"
}

function onExitSignal {
  log 'received shutdown signal, deleting output files'
  rm -f ${outputDir}/transmission.*
  kill $(jobs -p)     # kill any child processes, ie. the sleep command
  exit 0
}

trap onExitSignal SIGINT SIGTERM

if ! type transmission-remote > /dev/null 2>&1; then
  msg="the transmission bittorrent client is not installed on this system\n"
  msg="${msg}      the transmission conky will not be operational"
  logError "$msg"
  exit 1
fi

offset=10
nameWidth=30          # number of characters for the active torrent names

while (( "$#" )); do
  case $1 in
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

if [[ $nameWidth -lt 1 ]]; then
  echo 'name width should have at least 1 character' >&2
  exit 1
fi

if [[ $offset -lt 1 ]]; then
  echo 'offset should be at least 1 pixel' >&2
  exit 1
fi

log 'starting transmission torrent info service'
log "torrent listing format will be ${nameWidth} | offset ${offset} | up | offset ${offset} | down"
outputDir=/tmp/conky
mkdir -p ${outputDir}
seedingFile=${outputDir}/transmission.seeding
downloadingFile=${outputDir}/transmission.downloading
idleFile=${outputDir}/transmission.idle
status=${outputDir}/transmission.status
active=${outputDir}/transmission.active.raw
activeFile=${outputDir}/transmission.active
activeFlippedFile=${outputDir}/transmission.active.flipped
peers=${outputDir}/transmission.peers.raw
peersFile=${outputDir}/transmission.peers
peersFlippedFile=${outputDir}/transmission.peers.flipped

while [ true ]; do
  # ::: statistics
  # $ transmission-remote -F u -l
  #     ID   Done       Have  ETA           Up    Down  Ratio  Status       Name
  #     87   100%    2.96 GB  15 days      0.0     0.0   96.5  Seeding      fedora 37.iso
  #    126   100%   16.99 GB  590 days     0.0     0.0   98.1  Seeding      1. Books
  # Sum:            19.95 GB               0.0     0.0  
  transmission-remote -F u -l | grep -E '^[[:space:]]+[[:digit:]]' > ${seedingFile}.$$
  transmission-remote -F d -l | grep -E '^[[:space:]]+[[:digit:]]' > ${downloadingFile}.$$
  transmission-remote -F i -l | grep -E '^[[:space:]]+[[:digit:]]' > ${idleFile}.$$
  
  # ::: active torrents
  # $ transmission-remote -t active -l
  #     ID   Done       Have  ETA           Up    Down  Ratio  Status       Name
  #    168   100%   11.74 GB  17 days      0.0     0.0   2.47  Seeding      fedora 37.iso
  #    320    35%   989.0 MB  8 min     1538.0  3620.0   0.14  Up & Down    photo gallery
  #    126*  100%   114.0 MB  Done      1189.0     0.0    107  Seeding      books
  #    127   100%   16.99 GB  230 days     0.0     0.0   97.7  Idle         magazines   << iddle entries are ignored
  # Sum:            31.69 GB              12.0     0.0
  transmission-remote -t active -l \
    | grep -E '(Seeding|Downloading|Up & Down)' \
    | sed 's/\.0  /  /g' \
    | \sed 's/  \+/:/g' \
    | cut -d ':' -f 6,7,10 \
    | sort -t ':' -k 3 > ${active}
  awk -F ':' "{printf \"%-${nameWidth}.${nameWidth}s\${offset ${offset}}\${color4}%5.5s\${offset ${offset}}\${color}%5.5s\n\", \$3, \$1, \$2}" ${active} > ${activeFile}.$$
  # flipped version
  echo '# components currently downloading data' > ${status}.$$
  numDownloads=$(cut -d ':' -f 2 ${active} | grep -cvE '^0$')
  
  if (( numDownloads == 0 )); then
    awk -F ':' "{printf \"\${color4}%5.5s\${offset ${offset}}\${color}%-${nameWidth}.${nameWidth}s\n\", \$1, \$3}" ${active} > ${activeFlippedFile}.$$
  else
    echo 'torrents' > ${status}.$$
    awk -F ':' "{printf \"\${color}%5.5s\${offset ${offset}}\${color4}%5.5s\${offset ${offset}}\${color}%-${nameWidth}.${nameWidth}s\n\", \$2, \$1, \$3}" ${active} > ${activeFlippedFile}.$$
  fi
  
  # ::: connected peers
  # Address                                   Flags         Done  Down    Up      Client
  # 72.178.162.10                             ?E            0.0      0.0     0.0  µTorrent 1.8.3
  # 95.168.162.205                            DE            100.0 5349.0     0.0  libTorrent (Rakshasa) 0.13.8
  # 116.121.146.69                            UKEI          42.8     0.0     0.0  qBittorrent 4.4.2
  transmission-remote -t active -pi \
    | grep -e '^[0-9]' \
    | sed -r 's/ ([0-9]+)\.0 /\1  /g' \
    | sed 's/  \+/:/g' \
    | sed 's/µ/u/' \
    | cut -d ':' -f 1,4,5,6 \
    | grep -vE ':0:0:' \
    | sort -t . -k 1n -k 2n -k 3n -k 4n > ${peers}
  awk -F ':' "{printf \"%-15s\${offset 12}%-13.13s\${offset ${offset}}\${color4}%5.5s\${offset ${offset}}\${color}%5.5s\n\", \$1, \$4, \$3, \$2}" ${peers} > ${peersFile}.$$
  # flipped version
  numDownloads=$(cut -d ':' -f 2 ${peers} | grep -cvE '^0$')
  
  if (( numDownloads == 0 )); then
    awk -F ':' "{printf \"\${color4}%5.5s\${offset ${offset}}\${color}%-15s\${offset ${offset}}%-13.13s\n\", \$3, \$1, \$4}" ${peers} > ${peersFlippedFile}.$$
  else
    echo 'peers' >> ${status}.$$
    awk -F ':' "{printf \"\${color}%5.5s\${offset ${offset}}\${color4}%5.5s\${offset ${offset}}\${color}%-15s\${offset ${offset}}%-13.13s\n\", \$2, \$3, \$1, \$4}" ${peers} > ${peersFlippedFile}.$$
  fi
  
  # rename temporary files into the official ones, this prevents race conditions from the conky reading these files
  mv ${seedingFile}.$$ ${seedingFile}
  mv ${downloadingFile}.$$ ${downloadingFile}
  mv ${idleFile}.$$ ${idleFile}
  mv ${status}.$$ ${status}
  mv ${activeFile}.$$ ${activeFile}
  mv ${activeFlippedFile}.$$ ${activeFlippedFile}
  mv ${peersFile}.$$ ${peersFile}
  mv ${peersFlippedFile}.$$ ${peersFlippedFile}  
  
  sleep 3s &  # run sleep in the background so we can kill it if we get a termination signal
  wait        # wait for the sleep process to complete
done
