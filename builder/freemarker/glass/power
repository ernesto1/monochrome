################### power
# on power plug
${if_match "${acpiacadapter}"=="on-line"}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-power-plug.png -p 5,0}\
${voffset 4}${offset 10}${color1}${font0}power${alignr 38}battery${font}
${voffset 2}${alignr 38}${color}${font1}${battery_percent BAT0}${font2}%${font}
# on battery
${else}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-power-battery.png -p 5,0}\
${voffset 4}${offset 10}${color1}${font0}battery${font}
${voffset -7}${alignr 38}${color}${font1}${battery_percent BAT0}${font2}%${font}
${voffset -3}${offset 19}${color2}${if_match ${battery_percent BAT0} < 30}${color3}${endif}${battery_bar 3,93 BAT0}
${endif}\
