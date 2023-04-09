#!/bin/bash
# script to periodically check for new dnf package updates when the system is "deemed iddle"
# ie. less than half of the cores are in use in the 5 min load average
#
# the list of new package updates are written to the output file: dnf.packages.formatted
# conky variables are introduced in order for the data to be properly formatted for conky to display

function usage {
  echo $(basename $0) [--width n]
  echo 'where width is the maximun number of characters per row, default is 35'
}

function onExitSignal {
  echo 'received shutdown signal, deleting output file and killing child processes'
  rm -f ${outputDir}/dnf.packages.formatted    # file read by conky
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

if [[ $width -lt 20 ]]; then
  echo 'width should not be less than 20 characters, not much meaningfull info can be displayed othwerise' >&2
  exit 1
fi

width=$(( width - 6 - 1 ))      # column width for package name
outputDir=/tmp/conky
mkdir -p ${outputDir}
echo "$(date +'%D %r') - starting dnf repo package lookup"
echo "$(date +'%D %r') - output list of new packages will be of ${width} caracters"
totalCores=$(grep -c processor /proc/cpuinfo)
halfCores=$(( totalCores / 2 ))
echo "$(date +'%D %r') - system is deemed iddle if the 5 min cpu load average is less than ${halfCores}"

while [ true ]; do
    # the output format of `uptime` changes if the machine runs for longer than a day
    #                                                               1m    5m    15m
    #  within a day:    12:20:31 up 37 min,  1 user,  load average: 0.86, 0.73, 0.66
    #  more than a day: 22:54:03 up 2 days,  2:12,  1 user,  load average: 0.53, 1.16, 1.40
    loadAvg=$(uptime)
    loadAvg=$(echo ${loadAvg#*load average: } | cut -d, -f2)
    echo "$(date +'%D %r') - 5 min load avg = $loadAvg"
    
    # perform dnf lookup if the system is iddle
    if [[ $loadAvg < $halfCores ]]; then
        packagesRawFile=${outputDir}/dnf.updates.source    # raw output from the dnf command
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
        echo -n "$(date +'%D %r') - " 
        
        if [[ $packages > 0 ]]; then
            echo "$packages new update(s)"
            packagesFile=${outputDir}/dnf.packages    # file to list the new packages
            # extract the actual packages from the raw dnf data
            grep -E $regex ${packagesRawFile} > ${packagesFile}
            # formatting done to the new package list for conky to display it nicely
            # - package name and version is converted into a tabular layout
            # - a ${voffset} is added for the text to not appear "squished"
            # - an ${offset} is added to each line in order for the package list to be printed with a left border
            # - packages of interest are surrounded by a ${color} variable in order to have them highlighted
            highlightRegex='kernel\|firefox\|transmission'
            cat ${packagesFile} | awk "{ printf \"%-${width}.${width}s %6.6s\n\", \$1, \$2 }" \
            | sed 's/^/${voffset 2}${offset 5}/' \
            | sed "s:\($highlightRegex\):$\{color2\}\1$\{color\}:" > ${outputDir}/dnf.packages.formatted
        else
            echo 'no updates available'
            rm -f ${outputDir}/dnf.packages*
        fi
    else
        echo "$(date +'%D %r') - load average too high, trying again later"
    fi
    
    sleep 5m &   # run the sleep process in the background so we can kill it if we get a terminate signal
    wait         # wait for the sleep process to complete
done
