# :::::::::::::::::::: cpu temperature
# laptop only reports cpu core temperatures, displaying the hottest of the two cores
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-cpu-laptop.png -p 0,0}\
${voffset 8}${if_match ${hwmon coretemp temp 2} > ${hwmon coretemp temp 3}}${template8 coretemp temp 2 [=threshold.tempCpuCore]}${else}${template8 coretemp temp 3 [=threshold.tempCpuCore]}${endif}
