# ::::::::::::::::: network
<#list networkDevices[system] as device>
${if_up [=device.name]}\
<#if device.type == "wifi">
# :::::: wifi
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-network-wifi.png -p 0,0}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-network-internet.png -p 0,57}\
${voffset 7}${offset 5}${color1}${font0}wifi${font}
${voffset -14}${alignr 6}${color}${font2}${wireless_link_qual_perc [=device.name]}${font3}%${font}
${voffset -2}${offset 16}${color2}${if_match ${wireless_link_qual_perc [=device.name]} < 30}${color3}${endif}${wireless_link_bar 3,93 [=device.name]}${font}
${voffset -4}${offset 5}${color}${font}ch. ${wireless_channel [=device.name]}${alignr 6}${wireless_bitrate [=device.name]}${font}${voffset -4}
<#else>
# :::::: ethernet
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-network-ethernet.png -p 0,0}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-network-internet.png -p 0,57}\
${voffset 7}${offset 5}${color1}${font0}ethernet${font}
${voffset 1}${alignr 6}${color}${execi 180 ethtool [=device.name] 2>/dev/null | grep -i speed | cut -d ' ' -f 2}
${alignr 6}${color}${addr [=device.name]}
</#if>
${template4 [=device.name] [=device.maxUp?c] [=device.maxDown?c]}
<#if device?has_next>
${else}\
<#else>
${else}\
# :::::: no network/internet
<#assign type = networkDevices[system]?first.type>
${image ~/conky/monochrome/images/glass/[=image.secondaryColor]-network-internet-disconnected-[=type].png -p 0,0}\
${voffset 7}${offset 5}${color}${font0}network
${voffset 143}${alignc}${color}${font}no [=type]
${alignc}connection
${voffset -10}
</#if>
</#list>
<#list 1..networkDevices[system]?size as x>
${endif}
</#list>
