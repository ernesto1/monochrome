# :::::::::::::::::::: network
# if both wifi and ethernet are connected, we give priority to the wifi
# :::::: wifi
${if_up wlp4s0}\
${if_match ${wireless_link_qual_perc wlp4s0} == 100}${image ~/conky/monochrome/images/widgets-dock/text-box-100.png -p 117,24}${endif}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-wifi.png -p 0,0}\
${voffset 49}${offset 6}${color2}${if_match ${wireless_link_qual_perc wlp4s0} < 30}${color3}${endif}${wireless_link_bar 3,45 wlp4s0}
#${wireless_essid wlp4s0}
${voffset -46}${goto 67}${color}${font}
${voffset 4}${goto 67}${color}${font1}${wireless_link_qual_perc wlp4s0}${font0}%${font}${voffset 1}
# :: upload/download speeds
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-internet.png -p 0,64}\
${template4 wlp4s0 8200 55100}
${else}\
# :::::: ethernet
${if_up enp6s0}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-ethernet.png -p 0,0}\
# ethernet details printed on the system conky
${voffset 48}
# :: upload/download speeds
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-internet.png -p 0,64}\
${template4 enp6s0 3000 60000}
${else}\
${image ~/conky/monochrome/images/widgets-dock/[=image.secondaryColor]-wifi-disconnected.png -p 0,0}
${image ~/conky/monochrome/images/widgets-dock/[=image.secondaryColor]-internet-offline.png -p 0,64}\
${voffset 117}
${endif}\
${endif}\
