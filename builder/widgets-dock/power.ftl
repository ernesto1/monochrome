# :::::::::::::::::::: power
${voffset 52}\
${if_match "${acpiacadapter}"=="on-line"}\
${if_match ${battery_percent BAT0} == 100}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-power-plugged-in.png -p 0,0}${voffset -1}
${else}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-power-charging.png -p 0,0}\
${offset 6}${color2}${if_match ${battery_percent BAT0} < 80}${color3}${endif}${battery_bar 3, 45 BAT0}
#${battery_time BAT0}
${voffset -46}${goto 67}${color}${font}
${voffset 4}${goto 67}${color}${font1}${battery_percent BAT0}${font0}%${font}${voffset -6}
${endif}\
${else}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-power-battery.png -p 0,0}\
${if_match ${battery_percent BAT0} == 100}${image ~/conky/monochrome/images/widgets-dock/text-box-100.png -p 114,24}${endif}\
${offset 6}${color2}${if_match ${battery_percent BAT0} < 20}${color3}${endif}${battery_bar 3, 45 BAT0}
#${battery_time BAT0}
${voffset -46}${goto 67}${color}${font}
${voffset 4}${goto 67}${color}${font1}${battery_percent BAT0}${font0}%${font}${voffset -6}
${endif}\
