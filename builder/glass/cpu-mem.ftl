################### cpu
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-cpu-mem.png -p 0,0}\
${voffset -6}${color}${cpugraph cpu0 48,112 ${template1}}
${voffset -58}${offset 5}${color1}${font0}cpu
${voffset 2}${alignr}${color}${font1}${cpu cpu0}${font2}% 
${voffset 5}${alignr 6}${color}${font4}${loadavg}
################### memory
${voffset 4}${memgraph 48,112 ${template1}}
${voffset -52}${offset 5}${color1}${font0}memory
${voffset 2}${alignr}${color}${font1}${memperc}${font2}% 
${voffset 5}${alignr 6}${color}${font4}${mem} / ${memmax}
################### swap
${voffset 12}${offset 5}${color1}${font0}swap
${voffset -2}${alignr}${color}${font1}${swapperc}${font2}% 
${voffset -5}${offset 13}${color2}${if_match ${swapperc} > 75}${color3}${endif}${swapbar 3,94}
${voffset -9}${alignr 6}${color}${font4}${swap} / ${swapmax}