#!/bin/bash

killall conky
sleep 5

directory=~/scripts/conky/monochrome/small
conky -c ${directory}/leftPanel &
conky -c ${directory}/rightPanel &
