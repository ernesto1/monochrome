# :::::::::::::::::::: network
${if_up enp0s25}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-ethernet.png -p 0,0}\
# ethernet details printed on the system conky
${voffset 48}
# :: upload/download speeds
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-internet.png -p 0,64}\
${template4 enp0s25 3000 60000}
${else}\
${image ~/conky/monochrome/images/widgets-dock/[=image.secondaryColor]-ethernet-disconnected.png -p 0,0}
${image ~/conky/monochrome/images/widgets-dock/[=image.secondaryColor]-internet-offline.png -p 0,64}\
${voffset 117}
${endif}\
