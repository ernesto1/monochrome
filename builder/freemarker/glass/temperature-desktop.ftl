# ::::::::::::::::: temperatures
${if_updatenr 1}${image ~/conky/monochrome/images/glass/[=image.primaryColor]-temperature-desktop-1.png -p 0,0}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/glass/[=image.primaryColor]-temperature-desktop-2.png -p 0,0}${endif}\
# :::: cpu
${voffset 4}${offset 5}${color1}${font0}cpu${font}
${voffset -13}${alignr 6}${color}${font2}${template8 atk0110 temp 1 [=threshold.tempCPU]}°C${font}
${alignr 7}${color}${font}cores ${template8 coretemp temp 5 [=threshold.tempCPUCore]}°C
# :::: video card
${voffset 6}${offset 5}${color1}${font0}video card${font}
${voffset -13}${alignr 6}${color}${font2}${template8 radeon temp 1 [=threshold.tempVideo]}°C${font}
# :::: hard disks
${voffset 6}${offset 5}${color1}${font0}hard disks${font}
${voffset -13}${alignr 6}${color}${font2}${template8 1 temp 1 [=threshold.tempDisk]}°C${font}
# :::: fans
${voffset 7}${offset 5}${color1}${font0}fans${font}
${voffset -8}${alignr 6}${color}${font2}${template8 atk0110 fan 1 [=(threshold.fanSpeed)?c]}${font}
${voffset -4}${alignr 6}${font}rpm${font}${voffset 10}
