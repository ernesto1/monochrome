#!/bin/bash

killall conky
sleep 5

# prepare dnf package lookup file
# this file is read by conky to get the number of package updates, see dnfPackageLookup.bash
echo ':: stand by ::' > /tmp/conkyDnf

# launch conky
directory=~/scripts/conky/monochrome/small
conky -c ${directory}/leftPanel &
conky -c ${directory}/rightPanel &

# launch dnf package lookup script
# on slow machines, running dnf at startup will slow up the boot up time.  Hence delaying the lookup by 3 min.
sleep 3m
~/scripts/conky/monochrome/dnfPackageLookup.bash &
