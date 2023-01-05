################### network
${if_up enp0s25}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-network-ethernet.png -p 0,0}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-network-internet.png -p 0,57}\
${template3 enp0s25}
${template4 enp0s25 3000 60000}
${else}\
# no network/internet
${image ~/conky/monochrome/images/glass/[=image.secondaryColor]-network-internet-disconnected-desktop.png -p 0,0}\
${voffset 12}${offset 5}${color}${font0}network
${voffset 143}${alignc}${color}${font4}no ethernet
${alignc}connection
${voffset -10}
${endif}\
