# -------------- network
<#assign device = networkDevices[system]?first>
${if_up [=device.name]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-network-desktop.png -p 0,0}\
${voffset 14}${goto 45}${color1}local ip${goto 99}${color}${addr [=device.name]}
${voffset 3}${goto 45}${color1}speed${goto 99}${color}${template3 [=device.name]}
# :: upload/download speeds
${template4 [=device.name] [=device.maxUp?c] [=device.maxDown?c]}
${else}\
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-network-no-internet.png -p 0,0}\
${voffset 12}${offset 5}${color1}no network
${voffset 3}${offset 5}connection
${voffset 92}
${endif}\
