# :::::::::::::::::::: ati video card temperature
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-videocard.png -p 0,0}\
${template8 radeon temp 1 75}
# :::::::::::::::::::: hard disk temperatures
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-disk.png -p 0,64}\
${template8 1 temp 1 42}
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-disk.png -p 0,128}\
${template8 2 temp 1 42}
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-temp-disk.png -p 0,192}\
${template8 3 temp 1 42}
# :::::::::::::::::::: fans
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-fan-1.png -p 0,256}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-fan-2.png -p 0,256}${endif}\
${if_updatenr 3}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-fan-1.png -p 0,256}${endif}\
${if_updatenr 4}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-fan-2.png -p 0,256}${endif}\
${voffset 7}${offset 7}${font2}${template7 atk0110 fan 1 2400}
