#!/bin/bash
# script to periodically check for new dnf package updates when the system is "deemed iddle"
# ie. less than half of the cores are in use in the 5 min load average

echo "$(date +'%D %r') - starting dnf repo package lookup" | tee /tmp/conkyDnf.log
totalCores=$(grep -c processor /proc/cpuinfo)
halfCores=$(( totalCores / 2 ))
echo "$(date +'%D %r') - system is deemed iddle if the 5 min cpu load average is less than ${halfCores}" | tee /tmp/conkyDnf.log

while [ true ]; do
    # the output format of `uptime` changes if the machine runs for longer than a day
    #
    #  within a day
    #                                                                      1m    5m    15m
    #  after a day:     22:54:03 up 2 days,  2:12,  1 user,  load average: 0.53, 1.16, 1.40
    loadAvg=$(uptime)
    loadAvg=$(echo ${loadAvg#*load average: } | cut -d, -f2)
    echo "$(date +'%D %r') - 5 min load avg = $loadAvg" | tee -a /tmp/conkyDnf.log
    
    # perform dnf lookup if the system is iddle
    if [[ $loadAvg < $halfCores ]]; then
        # sample dnf output to parse:
        #
        # Last metadata expiration check: 0:15:45 ago on Mon 16 Aug 2021 10:29:07 AM EDT.
        # Available Upgrades
        # code.x86_64                      1.59.0-1628120127.el8              code        
        # skypeforlinux.x86_64             8.75.0.140-1                       skype-stable
        newPackages=$(dnf list updates  | grep -cE '.+\..+')
        echo -n "$(date +'%D %r') - " | tee -a /tmp/conkyDnf.log 
        
        if [[ $newPackages > 0 ]]; then
            echo "$newPackages new update(s)" | tee /tmp/conkyDnf | tee -a /tmp/conkyDnf.log
        else
            echo 'no updates available' | tee /tmp/conkyDnf | tee -a /tmp/conkyDnf.log
        fi
    else
        echo "$(date +'%D %r') - load average too high, trying again later" | tee -a /tmp/conkyDnf.log
    fi
    
    sleep 10m    
done
