################### power
${if_match "${acpiacadapter}"=="on-line"}\
# on power plug
${if_match ${battery_percent BAT0} > 80}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-power-plug.png -p 0,0}\
${voffset 4}${offset 5}${color1}${font0}power${font}
${voffset -4}${alignr 6}${color}${font}laptop is${font}
${voffset 3}${alignr 6}${color}plugged in${font}
# on power plug | charging battery
${else}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-power-battery.png -p 0,0}\
${voffset 4}${offset 5}${color1}${font0}charging${font}
${voffset -19}${alignr 6}${color}${font1}${battery_percent BAT0}${font3}%${font}
${voffset -2}${offset 16}${color2}${if_match ${battery_percent BAT0} < 70}${color3}${endif}${battery_bar 3,93 BAT0}
${voffset -4}${alignr 6}${color}${font}eta ${battery_time BAT0}${font}
${endif}\
# on battery
${else}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-power-battery.png -p 0,0}\
${voffset 4}${offset 5}${color1}${font0}battery${font}
${voffset -19}${alignr 6}${color}${font1}${battery_percent BAT0}${font3}%${font}
${voffset -2}${offset 16}${color2}${if_match ${battery_percent BAT0} < 30}${color3}${endif}${battery_bar 3,93 BAT0}
${voffset -4}${alignr 6}${color}${font}${battery_time BAT0} left${font}
${endif}\
