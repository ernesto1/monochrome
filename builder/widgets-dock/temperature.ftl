# :::::::::::::::::::: temperatures
# :::::::: cpu
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-cpu-[=system].png -p 0,0}\
<#if system == "laptop" >
# laptop only reports cpu core temperatures, displaying the hottest of the two cores
${voffset 8}${if_match ${hwmon coretemp temp 2} > ${hwmon coretemp temp 3}}${template8 coretemp temp 2 [=threshold.tempCPUCore]}${else}${template8 coretemp temp 3 [=threshold.tempCPUCore]}${endif}
<#else>
# due to a conky/lua bug the temperature items had to be moved to the sidebarPanel conky :(
# the complementary temperature/fan speeds displayed to the right of the sidebar will remain on this conky 
${voffset 24}${goto 67}${font}${color}${hwmon coretemp temp 2}°C${offset 9}${hwmon coretemp temp 3}°C
${voffset 8}${goto 67}${color}${hwmon coretemp temp 4}°C${offset 9}${hwmon coretemp temp 5}°C
# :::::::: ati video card
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-videocard.png -p 0,64}\
# :::::::: hard disks
<#assign y = 128>
<#list hardDisks[system] as hardDisk>
<#if hardDisk.hwmonIndex??>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-disk.png -p 0,[=y]}\
<#assign y += 64>
</#if>
</#list>
# :::::::: fans
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-fan-1.png -p 0,320}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-fan-2.png -p 0,320}${endif}\
${voffset 274}${goto 67}${color}${hwmon atk0110 fan 3} rpm
${voffset 9}${goto 67}${color}${hwmon atk0110 fan 2} rpm
${voffset 9}${goto 67}${color}${hwmon atk0110 fan 4} rpm
</#if>
