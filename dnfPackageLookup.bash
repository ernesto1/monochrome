#!/bin/bash
# script to periodically check for new dnf package updates

# on slow machines, running dnf at startup will slow up the boot up time.  Hence delaying the lookup by 3 min.
echo "$(date +'%D %r') - performing dnf package lookup after 3 min delay" > /tmp/conkyDnf.log
sleep 3m

while [ true ]; do
    loadAvg=$(uptime | cut -d , -f 4)       # get the 5 min load average
    echo "$(date +'%D %r') - 5 min load avg = $loadAvg" >> /tmp/conkyDnf.log
    
    # the dnf lookup is only done if the system is relatively iddle,
    # ie. the 5 min load average is below 1 core (i have a dual core machine)
    if [[ $loadAvg < 1 ]]; then
        # not counting the conky package due to a bug in v.1.11.6-1.fc32
        newPackages=$(dnf list updates | grep -v conky | grep -cE '(updates|code)')
        
        if [[ $newPackages > 0 ]]; then
            echo "$newPackages new update(s)" > /tmp/conkyDnf
        else
            echo 'no updates available' > /tmp/conkyDnf
        fi
        
        cat /tmp/conkyDnf >> /tmp/conkyDnf.log
        echo "$(date +'%D %r') - downloaded new package list" >> /tmp/conkyDnf.log
    else
        echo "$(date +'%D %r') - load average too high, trying again later" >> /tmp/conkyDnf.log
    fi
    
    sleep 10m    
done
