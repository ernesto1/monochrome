# :::::::::::::::::::: temperatures
# :::::::: cpu
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-cpu-[=system].png -p 0,0}\
<#if system == "laptop" >
# laptop only reports cpu core temperatures, displaying the hottest of the two cores
${voffset 8}${if_match ${hwmon coretemp temp 2} > ${hwmon coretemp temp 3}}${template8 coretemp temp 2 [=threshold.tempCPUCore]}${else}${template8 coretemp temp 3 [=threshold.tempCPUCore]}${endif}
<#else>
# cpu temp on sidebar while cpu core temperatures are printed on the side
${voffset 8}${template8 atk0110 temp 1 [=threshold.tempCPU]}${voffset -35}${goto 67}${hwmon coretemp temp 2}°C${offset 9}${hwmon coretemp temp 3}°C
${voffset 8}${goto 67}${hwmon coretemp temp 4}°C${offset 9}${hwmon coretemp temp 5}°C${color4}${voffset 14}
# :::::::: ati video card
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-videocard.png -p 0,64}\
${template8 radeon temp 1 [=threshold.tempVideo]}
# :::::::: hard disks
<#assign y = 128>
<#list hardDisks[system] as hardDisk>
<#if hardDisk.hwmonIndex??>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-disk.png -p 0,[=y]}\
${template8 [=hardDisk.hwmonIndex] temp 1 [=threshold.tempDisk]}
<#assign y += 64>
</#if>
</#list>
# :::::::: fans
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-fan-1.png -p 0,320}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-fan-2.png -p 0,320}${endif}\
${voffset 7}${offset 7}${font2}${template7 atk0110 fan 1 [=(threshold.fanSpeed)?c]}
</#if>
