#!/bin/bash

killall conky
sleep 5

directory=~/scripts/conky/monochrome/small
conky -c ${directory}/cpu &
conky -c ${directory}/memory &
conky -c ${directory}/wifi &
conky -c ${directory}/network-up &
conky -c ${directory}/network-down &
conky -c ${directory}/diskio-write &
conky -c ${directory}/diskio-read &
conky -c ${directory}/power &
conky -c ${directory}/cpuProcesses &
conky -c ${directory}/memoryProcesses &
conky -c ${directory}/diskSpace &
conky -c ${directory}/usbStick &
conky -c ${directory}/usbDrive &
