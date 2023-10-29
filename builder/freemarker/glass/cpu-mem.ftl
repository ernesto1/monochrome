# ::::::::::::::::: cpu
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-cpu-mem.png -p 5,37}\
${voffset 29}${color}${offset 5}${cpugraph cpu0 48,112 ${template1}}
${voffset -56}${offset 10}${color1}${font0}cpu${font}
${voffset -7}${alignr 38}${color}${font1}${cpu cpu0}${font2}%${font}
${voffset 12}${alignr 38}${color}${font}${loadavg}
# ::::::::::::::::: memory
${voffset -1}${offset 5}${memgraph 48,112 ${template1}}
${voffset -56}${offset 10}${color1}${font0}memory${font}
${voffset -7}${alignr 38}${color}${font1}${memperc}${font2}%${font}
${voffset 9}${alignr 38}${color}${font}${mem} / ${memmax}
# ::::::::::::::::: swap
${voffset 5}${offset 10}${color1}${font0}swap${font}
${voffset -6}${alignr 38}${color}${font1}${swapperc}${font2}%${font}
${voffset -3}${offset 19}${color2}${if_match ${swapperc} > 75}${color3}${endif}${swapbar 3,94}
${voffset -5}${alignr 38}${color}${font}${swap} / ${swapmax}
