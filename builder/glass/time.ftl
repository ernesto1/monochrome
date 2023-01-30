# ::::::::::::::::: time
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-divider.png -p 0,0}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-block-small.png -p 0,1}\
${voffset 1}${offset 5}${color1}${font Promenade de la Croisette:size=40}${time %I}${font Promenade de la Croisette:size=37}:${time %M}${font}${voffset -30}${alignr 6}${color}${time %A}
${voffset -1}${alignr 6}${time %B}
${voffset -1}${alignr 6}${time %d}
