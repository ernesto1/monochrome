#!/bin/bash
# script to periodically check for new dnf package updates when the system is "deemed iddle"
# ie. less than half of the cores are in use in the 5 min load average

function usage {
  echo $(basename $0) [--width n] >&2
}

function onExitSignal {
  echo "$(basename $0) | received shutdown signal, cleaning up temporary files and exiting script" | tee -a ${logFile}
  rm -f /tmp/dnf.*    # delete temp files
  kill $(jobs -p)     # kill any child processes, ie. the sleep command
  exit 0
}

trap onExitSignal SIGINT SIGTERM

if [[ $# -gt 0 && $# -ne 2 ]]; then
  usage
  exit 1
fi

width=35

while (( "$#" )); do
  case $1 in
    --width)
      width=$2
      shift 2
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

scriptName=$(basename $0 .bash)
logFile=/tmp/${scriptName}.log
echo "$(date +'%D %r') - starting dnf repo package lookup" | tee ${logFile}
echo "$(date +'%D %r') - output list of new packages will be of ${width} caracters" | tee ${logFile}
totalCores=$(grep -c processor /proc/cpuinfo)
halfCores=$(( totalCores / 2 ))
echo "$(date +'%D %r') - system is deemed iddle if the 5 min cpu load average is less than ${halfCores}" | tee ${logFile}

while [ true ]; do
    # the output format of `uptime` changes if the machine runs for longer than a day
    #                                                               1m    5m    15m
    #  within a day:    12:20:31 up 37 min,  1 user,  load average: 0.86, 0.73, 0.66
    #  more than a day: 22:54:03 up 2 days,  2:12,  1 user,  load average: 0.53, 1.16, 1.40
    loadAvg=$(uptime)
    loadAvg=$(echo ${loadAvg#*load average: } | cut -d, -f2)
    echo "$(date +'%D %r') - 5 min load avg = $loadAvg" | tee -a ${logFile}
    
    # perform dnf lookup if the system is iddle
    if [[ $loadAvg < $halfCores ]]; then
        packagesRawFile=/tmp/dnf.updates.source    # raw output from the dnf command
        # sample dnf output to parse:
        #
        # PM Fusion for Fedora 32 - Free - Updates        5.8 kB/s | 2.9 kB     02:00
        # RPM Fusion for Fedora 32 - Nonfree - Updates    0.0  B/s |   0  B     02:00
        # Last metadata expiration check: 0:15:45 ago on Mon 16 Aug 2021 10:29:07 AM EDT.
        # Available Upgrades
        # code.x86_64                      1.59.0-1628120127.el8              code        
        # skypeforlinux.x86_64             8.75.0.140-1                       skype-stable        
        dnf list updates > ${packagesRawFile}
        regex='^(([[:alnum:]]|\.|_|-)+[[:blank:]]+){2}([[:alnum:]]|\.|_|-|[[:blank:]])+$'
        packages=$(grep -cE $regex ${packagesRawFile})
        echo -n "$(date +'%D %r') - " | tee -a ${logFile} 
        
        if [[ $packages > 0 ]]; then
            echo "$packages new update(s)" | tee -a ${logFile}
            packagesFile=/tmp/dnf.packages    # file to list the new packages
            # extract the actual packages from the raw dnf data
            grep -E $regex ${packagesRawFile} > ${packagesFile}
            # package name and version is formatted into a tabular layout of 35 characters for conky to print
            column --table --table-right 2 --table-truncate 1,2 --table-hide 3 --output-width ${width} ${packagesFile} > /tmp/dnf.packages.preview
        else
            echo 'no updates available' | tee -a ${logFile}
            rm -f /tmp/dnf.packages*
        fi
    else
        echo "$(date +'%D %r') - load average too high, trying again later" | tee -a ${logFile}
    fi
    
    sleep 5m &   # run the sleep process in the background so we can kill it if we get a terminate signal
    wait          # wait for the sleep process to complete
done
