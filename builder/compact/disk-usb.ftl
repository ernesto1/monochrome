# -------------- usb external disk
${if_mounted /run/media/ernesto/MAXTOR}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-disk.png -p 0,0}\
${template5 sde1 6000 52000}
${voffset 6}${template6 maxtor /run/media/ernesto/MAXTOR}
${else}\
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-disk-disconnected.png -p 0,0}\
${voffset 13}${offset 5}${color1}usb maxtor HD
${voffset 3}${offset 5}${color1}${font4}is not connected
${voffset 48}
${endif}\
