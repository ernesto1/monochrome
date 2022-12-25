# :::::::::::::::::::: disk sdb
# disk io | read 250000
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-2.png -p 0,0}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-3.png -p 0,0}${endif}\
${if_updatenr 3}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-4.png -p 0,0}${endif}\
${if_updatenr 4}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-1.png -p 0,0}${endif}\
${template5 sdb 6500 200000}
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-disk-partition.png -p 0,66}\
${template6 veronica /media/veronica}
# :::::::::::::::::::: disk sdc
# disk io | read 250000
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-3.png -p 0,130}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-4.png -p 0,130}${endif}\
${if_updatenr 3}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-1.png -p 0,130}${endif}\
${if_updatenr 4}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-2.png -p 0,130}${endif}\
${template5 sdc 6500 200000}
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-disk-partition.png -p 0,196}\
${template6 betty /media/betty}
