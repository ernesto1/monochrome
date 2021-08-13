#!/bin/bash
# script to periodically check for new dnf package updates when the system is deemed iddle
# system is considered iddle if less than 50% of the cores are in use in the 5 min load average

echo "$(date +'%D %r') - starting dnf repo package lookup" | tee /tmp/conkyDnf.log
totalCores=$(grep -c processor /proc/cpuinfo)
halfCores=$(( totalCores / 2 ))
echo "$(date +'%D %r') - system is deemed iddle if the 5 min cpu load average is less than ${halfCores}" | tee /tmp/conkyDnf.log

while [ true ]; do
    loadAvg=$(uptime | cut -d , -f 4)       # get the 5 min load average
    echo "$(date +'%D %r') - 5 min load avg = $loadAvg" | tee -a /tmp/conkyDnf.log
    
    # the dnf lookup is only done if the system is relatively iddle,
    # ie. the 5 min load average is below 1 core (i have a dual core machine)
    if [[ $loadAvg < $halfCores ]]; then
        # not counting the conky package due to a bug in v.1.11.6-1.fc32
        newPackages=$(dnf list updates | grep -v conky | grep -cE '(updates|code)')
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
