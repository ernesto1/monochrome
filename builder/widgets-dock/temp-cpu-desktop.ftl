# :::::::::::::::::::: cpu temperature 
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-cpu-desktop.png -p 0,0}\
${voffset 8}${template8 atk0110 temp 1 [=threshold.tempCpu]}${voffset -32}${goto 67}${hwmon coretemp temp 2}°C${offset 10}${hwmon coretemp temp 3}°C
${voffset 4}${goto 67}${hwmon coretemp temp 4}°C${offset 10}${hwmon coretemp temp 5}°C${color4}${voffset 15}
