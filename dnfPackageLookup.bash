#!/bin/bash
# script to periodically check for new dnf package updates when the system is "deemed iddle"
# ie. less than half of the cores are in use in the 5 min load average
#
# the list of new package updates are written to the output file: /tmp/conky/dnf.packages.formatted
# conky ${color} variables are added in order to highlight packages of interest to the user

. ~/conky/monochrome/logging.bash

function usage {
  cat <<-END
	$(basename $0) [--package-width n] [--version-width n] [--offset n] [--interval x]
	
	where package width is the number of characters to print for the pacakge name
	      version width is the number of characters to print for the version number
	      offset is the number of pixels between the package name and its version number
	      interval is the wait time between queries, use a time range compatible with the sleep command, ex. 1h
	END
}

function onExitSignal {
  log 'received shutdown signal, deleting output file'
  rm -f ${outputDir}/dnf.packages.formatted    # file read by conky, other files are left for debugging
  [[ $pid ]] && kill $pid
  exit 0
}

trap onExitSignal EXIT

if ! type dnf > /dev/null 2>&1; then
  msg="your linux distro does not use the 'dnf' package manager\n"
  msg="${msg}the package updates conky will not be operational\n"
  msg="${msg}you will have to update this script to work with your distro's package manager"
  logError "$msg"
  exit 1
fi

packageWidth=21   # number of characters to print for the package name
versionWidth=7    # number of characters to print for the version number
offset=11         # number of pixels between the package name and its version number
interval=15m      # wait time between queries to the package repository

while (( "$#" )); do
  case $1 in
    --offset)
      [[ -z $2 ]] && { logError "provide a value for the $1 flag"; exit 1; }
      offset=$2
      shift 2
      ;;
    --package-width)
      [[ -z $2 ]] && { logError "provide a value for the $1 flag"; exit 1; }
      packageWidth=$2
      shift 2
      ;;
    --version-width)
      [[ -z $2 ]] && { logError "provide a value for the $1 flag"; exit 1; }
      versionWidth=$2
      shift 2
      ;;
    --interval)
      [[ -z $2 ]] && { logError "provide a value for the $1 flag"; exit 1; }
      interval=$2
      shift 2
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

[[ ${offset} -lt 1 ]] && { logError 'offset should be greater than 0'; exit 1; }
[[ ${packageWidth} -lt 1 ]] && { logError 'package name width should greater than 0'; exit 1; }
[[ ${versionWidth} -lt 1 ]] && { logError 'version width (--version-width) should greater than 0'; exit 1; }

log 'starting dnf repo package lookup'
log "checking for package updates every ${interval}"
log "new package updates format will be ${packageWidth} | offset ${offset} | ${versionWidth}"
outputDir=/tmp/conky
mkdir -p ${outputDir}
totalCores=$(grep -c processor /proc/cpuinfo)
halfCores=$(( totalCores / 2 ))
log "system will be deemed iddle if the 5 min cpu load average is less than ${halfCores}"

while [ true ]; do
  # the output format of `uptime` changes if the machine runs for longer than a day
  #                                                               1m    5m    15m
  #  within a day:    12:20:31 up 37 min,  1 user,  load average: 0.86, 0.73, 0.66
  #  more than a day: 22:54:03 up 2 days,  2:12,  1 user,  load average: 0.53, 1.16, 1.40
  loadAvg=$(uptime)loa
  loadAvg=$(cut -d, -f2 <<< "${loadAvg#*load average: }" | tr -d ' ')
  log "5 min load avg = $loadAvg"
  
  # perform dnf lookup if the system is iddle
  if [[ $loadAvg < $halfCores ]]; then
    packagesRawFile=${outputDir}/dnf.updates.source    # raw output from the dnf command
    # sample dnf output to parse:
    #
    # PM Fusion for Fedora 32 - Free - Updates        5.8 kB/s | 2.9 kB     02:00
    # RPM Fusion for Fedora 32 - Nonfree - Updates    0.0  B/s |   0  B     02:00
    # Last metadata expiration check: 0:15:45 ago on Mon 16 Aug 2021 10:29:07 AM EDT.
    # Available Upgrades
    # code.x86_64                      1.59.0-1628120127.el8        code        
    # containers-common.noarch         4:1-82.fc37                  updates
    dnf list updates > ${packagesRawFile}
    regex='^(([[:alnum:]]|\.|_|:|-)+[[:blank:]]+){2}([[:alnum:]]|\.|_|-|[[:blank:]])+$'
    packages=$(grep -cE $regex ${packagesRawFile})
    
    if (( packages > 0 )); then
        log "$packages new package update(s)"
        packagesFile=${outputDir}/dnf.packages    # file to list the new packages
        # extract the actual packages from the raw dnf data
        grep -E $regex ${packagesRawFile} > ${packagesFile}
        # formatting done to the new package list for conky to display it nicely
        # - package name and version is converted into a tabular layout
        # - packages of interest are surrounded by a ${color} variable in order to have them highlighted
        highlightRegex='kernel\|firefox\|transmission'
        cat ${packagesFile} \
          | sort --ignore-case \
          | awk "{ printf \"%-${packageWidth}.${packageWidth}s\${offset ${offset}}%${versionWidth}.${versionWidth}s\n\", \$1, \$2 }" \
          | sed "s:\($highlightRegex\):$\{color2\}\1$\{color\}:" > ${outputDir}/dnf.packages.formatted
    else
        log 'no updates available'
        rm -f ${outputDir}/dnf.packages*
    fi
  else
    log 'load average too high, trying again later'
  fi
  
  log "checking for updates again in ${interval}"
  sleep ${interval} & pid=$!
  wait
  unset pid
done
