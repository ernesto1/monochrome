################### disk - sdb
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-disk.png -p 0,0}\
# speeds | read: 151MiB  write: 100MiB
${template5 sdb 6000 200000}
${template6 veronica /media/veronica}
################### disk - sdd
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-disk.png -p 0,154}\
# speeds | read: 151MiB  write: 100MiB
${template5 sdd 6000 200000}
${template6 betty /media/betty}
