#!/bin/bash

killall conky
sleep 2

# prepare dnf package lookup file
# this file is read by conky to get the number of package updates, see dnfPackageLookup.bash
echo ':: stand by ::' > /tmp/conkyDnf

directory=~/scripts/conky/monochrome/large
conky -c ${directory}/time &
conky -c ${directory}/cpuGraph &
conky -c ${directory}/cpuProcesses &
conky -c ${directory}/cpu &                 # cpu usage
conky -c ${directory}/memoryProcesses &
conky -c ${directory}/memory &              # memory usage
conky -c ${directory}/network-down &        # network download speed
conky -c ${directory}/network-up &          # network upload speed
conky -c ${directory}/disk &                # main hard drive
conky -c ${directory}/disk-space &          # main hard drive partitions
conky -c ${directory}/hardDisk-betty &	    # additional hard drive
conky -c ${directory}/hardDisk-veronica &   # additional hard drive
conky -c ${directory}/usbStick &            # usb memory stick
conky -c ${directory}/usbDrive &            # usb hard disk
conky -c ${directory}/sdCard &              # usb sd card
conky -c ${directory}/system &

# launch dnf package lookup script
# on slow machines, running dnf at startup will slow up the boot up time.  Hence delaying the lookup by 3 min.
~/scripts/conky/monochrome/dnfPackageLookup.bash 7 &
