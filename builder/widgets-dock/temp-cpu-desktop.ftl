# :::::::::::::::::::: cpu temperature 
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-cpu-desktop.png -p 0,0}\
${voffset 8}${template8 atk0110 temp 1 78}${voffset -35}${goto 67}${hwmon coretemp temp 2}°C${offset 9}${hwmon coretemp temp 3}°C
${voffset 8}${goto 67}${hwmon coretemp temp 4}°C${offset 9}${hwmon coretemp temp 5}°C${color4}${voffset 14}
