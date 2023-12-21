# ::::::::::::::::: cpu
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-cpu.png -p 5,37}\
${voffset 29}${color}${offset 5}${cpugraph cpu0 48,112 ${template1}}
${voffset -56}${offset 10}${color1}${font0}cpu${font}
${voffset -7}${alignr 38}${color}${font1}${cpu cpu0}${font2}%${font}
${voffset 12}${alignr 38}${color}${font}${loadavg}
<#if system == "laptop" >
<#-- the laptop cpu section adds core frequency and temp, therefore the memory image has to be shifted
     in order for this data to fit -->
${voffset 2}${offset 10}${font}${color1}core 1 ${color}${freq_g 1}GHz ${color1}|${color}${alignr 38}${hwmon coretemp temp 2}°
${voffset 3}${offset 10}${font}${color1}core 2 ${color}${freq_g 2}GHz ${color1}|${color}${alignr 38}${hwmon coretemp temp 3}°
</#if>
# ::::::::::::::::: memory
<#assign y = 110>
<#if system == "laptop" ><#assign y += 37></#if>
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-mem.png -p 5,[=y]}\
${voffset -1}${offset 5}${memgraph 48,112 ${template1}}
${voffset -56}${offset 10}${color1}${font0}memory${font}
${voffset -7}${alignr 38}${color}${font1}${memperc}${font2}%${font}
${voffset 9}${alignr 38}${color}${font}${mem} / ${memmax}
# ::::::::::::::::: swap
${voffset 5}${offset 10}${color1}${font0}swap${font}
${voffset -6}${alignr 38}${color}${font1}${swapperc}${font2}%${font}
${voffset -3}${offset 19}${color2}${if_match ${swapperc} > 75}${color3}${endif}${swapbar 3,94}
${voffset -5}${alignr 38}${color}${font}${swap} / ${swapmax}
