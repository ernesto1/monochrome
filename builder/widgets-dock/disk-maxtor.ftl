# :::::::::::::::::::: maxtor external hard drive
${if_mounted /run/media/ernesto/MAXTOR}\
# disk io
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-1.png -p 0,0}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-2.png -p 0,0}${endif}\
${if_updatenr 3}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-3.png -p 0,0}${endif}\
${if_updatenr 4}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-4.png -p 0,0}${endif}\
${template5 sdg1 6000 52000}
# filesystem
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-disk-usbdrive.png -p 0,66}\
${template6 maxtor /run/media/ernesto/MAXTOR}
${else}\
${image ~/conky/monochrome/images/widgets-dock/[=image.secondaryColor]-disk-usbdrive-disconnected.png -p 0,0}\
${voffset 60}${goto 67}external disk
${voffset 3}${goto 67}is not connected 
${voffset 28}
${endif}\
