# :::::::::::::::::::: temperatures
# :::::::: cpu
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-cpu-[=system].png -p 0,0}\
<#if system == "laptop" >
# laptop only reports cpu core temperatures, displaying the hottest of the two cores
${voffset 8}${if_match ${hwmon coretemp temp 2} > ${hwmon coretemp temp 3}}${template7 coretemp temp 2 [=threshold.tempCPUCore]}${else}${template7 coretemp temp 3 [=threshold.tempCPUCore]}${endif}
<#else>
# cpu temp on sidebar while cpu core temperatures are printed on the side
${voffset 8}${template7 ${lua_parse\ print_resource_usage\ ${hwmon\ atk0110\ temp\ 1}\ [=threshold.tempCPU]\ ${color3}}}${voffset -35}${goto 67}${hwmon coretemp temp 2}°C${offset 9}${hwmon coretemp temp 3}°C
${voffset 8}${goto 67}${hwmon coretemp temp 4}°C${offset 9}${hwmon coretemp temp 5}°C${color4}${voffset 14}
# :::::::: ati video card
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-videocard.png -p 0,64}\
${template7 ${lua_parse\ print_resource_usage\ ${hwmon\ radeon\ temp\ 1}\ [=threshold.tempVideo]\ ${color3}}}
# :::::::: hard disks
<#assign y = 128>
<#list hardDisks[system] as hardDisk>
<#if hardDisk.hwmonIndex??>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-disk.png -p 0,[=y]}\
${template7 ${lua_parse\ print_resource_usage\ ${hwmon\ [=hardDisk.hwmonIndex]\ temp\ 1}\ [=threshold.tempDisk]\ ${color3}}}
<#assign y += 64>
</#if>
</#list>
# :::::::: fans
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-fan-1.png -p 0,320}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-fan-2.png -p 0,320}${endif}\
${voffset 7}${offset 7}${font2}${color4}${lua_parse print_resource_usage ${hwmon atk0110 fan 1} [=(threshold.fanSpeed)?c] ${color3}}${font}${color}${voffset -38}${goto 67}${hwmon atk0110 fan 3} rpm
${voffset 9}${goto 67}${hwmon atk0110 fan 2} rpm
${voffset 9}${goto 67}${hwmon atk0110 fan 4} rpm
</#if>
