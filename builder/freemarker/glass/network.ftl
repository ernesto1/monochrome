# ::::::::::::::::: network
<#list networkDevices[system] as device>
${if_up [=device.name]}\
<#if device.type == "wifi">
# :::::: wifi
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-network-wifi.png -p 5,0}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-network-internet.png -p 5,54}\
${voffset 7}${offset 10}${color1}${font0}wifi${font}
${voffset -14}${alignr 38}${color}${font2}${wireless_link_qual_perc [=device.name]}${font3}%${font}
${voffset -2}${offset 19}${color2}${if_match ${wireless_link_qual_perc [=device.name]} < 30}${color3}${endif}${wireless_link_bar 3,94 [=device.name]}${font}
${voffset -4}${offset 10}${color}${font}ch. ${wireless_channel [=device.name]}${alignr 38}${wireless_bitrate [=device.name]}${font}${voffset -1}
<#else>
# :::::: ethernet
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-network-ethernet.png -p 5,0}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-network-internet.png -p 5,54}\
${voffset 7}${offset 10}${color1}${font0}ethernet${font}
${voffset 1}${alignr 38}${color}${execi 180 ethtool [=device.name] 2>/dev/null | grep -i speed | cut -d ' ' -f 2}
${alignr 38}${color}${addr [=device.name]}
</#if>
${template4 [=device.name] [=device.maxUp?c] [=device.maxDown?c]}
<#if device?has_next>
${else}\
<#else>
${else}\
# :::::: no network/internet
<#assign type = networkDevices[system]?first.type>
${image ~/conky/monochrome/images/glass/[=image.secondaryColor]-network-disconnected-[=type].png -p 5,0}\
${voffset 7}${offset 10}${color}${font0}network${font}
${voffset 142}${offset 46}${color}no [=type]
${offset 34}connection${voffset 3}
</#if>
</#list>
<#list 1..networkDevices[system]?size as x>
${endif}\
</#list>
