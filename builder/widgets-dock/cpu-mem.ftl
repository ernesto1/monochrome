# :::::::::::::::::::: cpu
${if_match ${cpu cpu0} < [=threshold.cpu]}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-cpu.png -p 0,0}\
${else}\
${if_match ${cpu cpu0} == 100}${image ~/conky/monochrome/images/widgets-dock/text-box-100.png -p 117,54}${endif}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-cpu-high.png -p 0,0}\
${endif}\
${voffset 44}${offset 12}${cpugraph cpu0 33,33 ${template1}}
${voffset -31}${goto 67}${color}${font1}${cpu cpu0}${font0}%
# :::::::::::::::::::: memory
${if_match ${memperc} < [=threshold.mem]}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-mem.png -p 0,98}\
${else}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-mem-high.png -p 0,98}\
${endif}\
${voffset 17}${offset 18}${memgraph 43,21 ${template1}}
${voffset -33}${goto 67}${color}${font1}${memperc}${font0}%
${voffset 4}${offset 6}${color2}${if_match ${swapperc} >= [=threshold.swap]}${color3}${endif}${swapbar 3, 45}${voffset -2}${goto 67}${font}${color}${swapperc}%
