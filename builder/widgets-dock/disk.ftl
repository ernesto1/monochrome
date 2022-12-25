# :::::::::::::::::::: disk sda
# disk io
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-1.png -p 0,0}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-2.png -p 0,0}${endif}\
${if_updatenr 3}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-3.png -p 0,0}${endif}\
${if_updatenr 4}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-4.png -p 0,0}${endif}\
${template5 sda 140000 140000}
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-disk-root.png -p 0,66}\
${template6 \  /}
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-disk-home.png -p 0,130}\
${template6 \  /home}
