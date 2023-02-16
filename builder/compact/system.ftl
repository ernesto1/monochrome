# -------------- system
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-system-1.png -p 0,0}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-system-2.png -p 0,0}${endif}\
${voffset 15}${goto 47}${color1}uptime ${color}${uptime}
${voffset 3}${goto 47}${color1}compositor ${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset 10}${offset 5}${color1}kernel ${color}${kernel}
${voffset 8}${offset 5}${color1}device${alignr 59}temperature
${voffset 5}${offset 5}${color}cpu${alignr 53}${template9 atk0110 temp 1 [=threshold.tempCPU]}°C
${voffset 4}${offset 5}${color}cpu core 1${alignr 53}${template9 coretemp temp 2 [=threshold.tempCPUCore]}°C
${voffset 3}${offset 5}${color}cpu core 2${alignr 53}${template9 coretemp temp 3 [=threshold.tempCPUCore]}°C
${voffset 3}${offset 5}${color}cpu core 3${alignr 53}${template9 coretemp temp 4 [=threshold.tempCPUCore]}°C
${voffset 3}${offset 5}${color}cpu core 4${alignr 53}${template9 coretemp temp 5 [=threshold.tempCPUCore]}°C
${voffset 3}${offset 5}${color}AMD Radeon HD7570${alignr 53}${template9 radeon temp 1 [=threshold.tempVideo]}°C
${voffset 3}${offset 5}${color}samsung SSD HD${alignr 53}${template9 0 temp 1 [=threshold.tempDisk]}°C
${voffset 3}${offset 5}${color}seagate HD${alignr 53}${template9 1 temp 1 [=threshold.tempDisk]}°C
${voffset 3}${offset 5}${color}seagate HD${alignr 53}${template9 2 temp 1 [=threshold.tempDisk]}°C
${voffset 8}${offset 5}${color1}fan${alignr 59}revolutions
${voffset 5}${offset 5}${color}chasis front intake${alignr 59}${template9 atk0110 fan 3 [=(threshold.fanSpeed)?c]} rpm
${voffset 3}${offset 5}${color}cpu fan${alignr 59}${template9 atk0110 fan 1 [=(threshold.fanSpeed)?c]} rpm
${voffset 3}${offset 5}${color}chasis top exhaust${alignr 59}${template9 atk0110 fan 2 [=(threshold.fanSpeed)?c]} rpm
${voffset 3}${offset 5}${color}chasis back exhaust${alignr 59}${template9 atk0110 fan 4 [=(threshold.fanSpeed)?c]} rpm
