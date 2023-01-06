# -------------- desktop internal disks
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-disk.png -p 0,0}\
${template5 sdb 6500 200000}
${voffset 6}${template6 veronica /media/veronica}
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-disk.png -p 0,103}\
${template5 sdd 6500 200000}
${voffset 6}${template6 betty /media/betty}
