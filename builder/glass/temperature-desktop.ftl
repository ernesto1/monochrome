################### temperatures
${if_updatenr 1}${image ~/conky/monochrome/images/glass/[=image.primaryColor]-temperature-desktop-1.png -p 0,0}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/glass/[=image.primaryColor]-temperature-desktop-2.png -p 0,0}${endif}\
# :::: cpu
${voffset 6}${voffset 7}${offset 5}${color1}${font0}cpu
${voffset -9}${alignr}${color}${font2}${template8 atk0110 temp 1 [=threshold.tempCpu]}°C 
${alignr 7}${color}${font4}cores ${template8 coretemp temp 5 [=threshold.tempCpuCore]}°C
# :::: video card
${voffset 6}${voffset 7}${offset 5}${color1}${font0}video card
${voffset -9}${alignr}${color}${font2}${template8 radeon temp 1 [=threshold.tempVideo]}°C 
# :::: hard disks
${voffset 7}${offset 5}${color1}${font0}hard disks
${voffset -9}${alignr}${color}${font2}${template8 1 temp 1 [=threshold.tempDisk]}°C 
# :::: fans
${voffset 7}${offset 5}${color1}${font0}fans
${voffset -8}${alignr}${color}${font2}${template8 atk0110 fan 1 [=(threshold.fanSpeed)?c]} 
${voffset -4}${alignr 7}${font4}rpm
