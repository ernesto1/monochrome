# -------------- network
${if_up enp0s25}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-network-desktop.png -p 0,0}\
${voffset 14}${goto 47}${color1}local ip${goto 102}${color}${addr enp0s25}
${voffset 3}${goto 47}${color1}speed${goto 102}${color}${template3 enp0s25}
# :: upload/download speeds
${template4 enp0s25 3000 60000}
${else}\
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-network-no-internet.png -p 0,0}\
${voffset 12}${offset 5}${color1}no internet
${voffset 3}${offset 5}connection
${voffset 108}
${endif}\
