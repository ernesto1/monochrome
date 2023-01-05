################### disk - sda
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-disk.png -p 0,0}\
# speeds | read: 140MiB  write: 151MiB
${template5 sda 280000 302000}
${template6 fedora /}
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-filesystem.png -p 0,154}\
${template6 home /home}
