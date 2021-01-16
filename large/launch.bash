#!/bin/bash

killall conky
sleep 2

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
conky -c ${directory}/sdCard &              # sd card
