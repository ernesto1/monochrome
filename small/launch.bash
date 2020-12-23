#!/bin/bash

killall conky
sleep 5

# prepare dnf package file
echo ':: stand by ::' > /tmp/conkyDnf

# launch conky
directory=~/scripts/conky/monochrome/small
conky -c ${directory}/leftPanel &
conky -c ${directory}/rightPanel &

# checking for new package updates
# --------------------------------
# The dnf lookup to check for new available packages is delayed by 3 minutes upon boot.
# On slow machines, running dnf at startup will slow up the boot up time.
echo "$(date +'%D %r') - starting dnf package lookup" > /tmp/conkyDnf.log
sleep 3m

while [ true ]; do
    # the dnf lookup is only done if the system is relatively iddle,
    # ie. the 5 min load average is below 1 core (i have a dual core machine)
    loadAvg=$(uptime | cut -d , -f 4)       # get the 5 min load average
    echo "$(date +'%D %r') - 5 min load avg = $loadAvg" >> /tmp/conkyDnf.log
    
    if [[ $loadAvg < 1 ]]; then
        # not counting the conky package due to a bug in v.1.11.6-1.fc32
        newPackages=$(dnf list updates | grep -v conky | grep -cE '(updates|code)')
        
        if [[ $newPackages > 0 ]]; then
            echo "$newPackages new update(s)" > /tmp/conkyDnf
        else
            echo 'no updates available' > /tmp/conkyDnf
        fi
        
        cat /tmp/conkyDnf >> /tmp/conkyDnf.log
        echo "$(date +'%D %r') - downloaded package list, sleeping for 1 hour" >> /tmp/conkyDnf.log
        sleep 1h
    else
        echo "$(date +'%D %r') - load average too high, trying again in 10 minutes" >> /tmp/conkyDnf.log
        sleep 10m
    fi
    
done
