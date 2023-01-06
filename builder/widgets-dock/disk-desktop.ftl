# :::::::::::::::::::: disk sdb
# disk io | read 250000
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-2.png -p 0,0}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-1.png -p 0,0}${endif}\
${template5 sdb 6500 200000}
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-disk-partition.png -p 0,66}\
${template6 veronica /media/veronica}
# :::::::::::::::::::: disk sdd
# disk io | read 250000
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-1.png -p 0,130}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-2.png -p 0,130}${endif}\
${template5 sdd 6500 200000}
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-disk-partition.png -p 0,196}\
${template6 betty /media/betty}
