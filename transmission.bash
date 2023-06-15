#!/bin/bash
# script to retrieve and parse torrent details from the transmission bittorrent client.
# torrent data is saved as files in the /tmp folder for conky to read.

function onExitSignal {
  log 'received shutdown signal, deleting output files'
  rm -f ${outputDir}/transmission.*
  exit 0
}

# prints the message using logback compatible formatting
# arguments:
#    message  string to print
function log {
  local NOCOLOR='\033[0m'
  local BLUE='\033[0;34m'
  local ORANGE='\033[0;33m'
  printf "$(date +'%T.%3N') ${BLUE}INFO  ${ORANGE}$(basename $0)${NOCOLOR} - $1\n"
}

trap onExitSignal SIGINT SIGTERM

log 'starting transmission torrent info service'
outputDir=/tmp/conky
mkdir -p ${outputDir}
peersFile=${outputDir}/transmission.peers
seedingFile=${outputDir}/transmission.seeding
downloadingFile=${outputDir}/transmission.downloading
idleFile=${outputDir}/transmission.idle
activeFile=${outputDir}/transmission.active

while [ true ]; do
  # $ transmission-remote -F u -l
  #     ID   Done       Have  ETA           Up    Down  Ratio  Status       Name
  #     87   100%    2.96 GB  15 days      0.0     0.0   96.5  Seeding      fedora 37.iso
  #    126   100%   16.99 GB  590 days     0.0     0.0   98.1  Seeding      1. Books
  # Sum:            19.95 GB               0.0     0.0  
  transmission-remote -F u -l | grep -E '^[[:space:]]+[[:digit:]]' > ${seedingFile}.$$
  transmission-remote -F d -l | grep -E '^[[:space:]]+[[:digit:]]' > ${downloadingFile}.$$
  transmission-remote -F i -l | grep -E '^[[:space:]]+[[:digit:]]' > ${idleFile}.$$
  # $ transmission-remote -t active -l
  #     ID   Done       Have  ETA           Up    Down  Ratio  Status       Name
  #    168   100%   11.74 GB  17 days      0.0     0.0   2.47  Seeding      fedora 37.iso
  #     87   100%    2.96 GB  4 days      12.0     0.0   95.8  Seeding      photo gallery
  #    126*  100%   16.99 GB  230 days     0.0     0.0   97.7  Seeding      books
  #    127   100%   16.99 GB  230 days     0.0     0.0   97.7  Idle         magazines   << iddle entries are ignored
  # Sum:            31.69 GB              12.0     0.0
  #
  # the final 'sed' cmd in the pipeline is to escape torrents with '#' in the name,
  # conky will interpret them as comments messing up the formatting
  transmission-remote -t active -l | grep -E '(Seeding|Downloading)' | sed 's/.\+\(Seeding\|Downloading\) \+//' | sed 's/^/${voffset 3}${offset 5}/' | sed 's/#/\\#/g' | sort > ${activeFile}.$$
  transmission-remote -t active -pi | grep -e '^[0-9]' | cut -c 1-15,78-100 --output-delimiter=' ' | sort -t . -k 1n -k 2n -k 3n -k 4n | sed 's/^/${voffset 3}${offset 5}/' > ${peersFile}.$$
  
  mv ${seedingFile}.$$ ${seedingFile}
  mv ${downloadingFile}.$$ ${downloadingFile}
  mv ${idleFile}.$$ ${idleFile}
  mv ${activeFile}.$$ ${activeFile}
  mv ${peersFile}.$$ ${peersFile}
  
  sleep 3s
done
