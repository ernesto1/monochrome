# :::: sandisk memory stick
${if_mounted /run/media/ernesto/sandisk}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-usbStick.png -p 1,125}
${voffset 41}${offset 1}${color2}${if_match ${fs_used_perc /run/media/ernesto/sandisk} > 90}${color3}${endif}${fs_bar 3, 45 /run/media/ernesto/sandisk}
${voffset -49}${goto 58}${color}sandisk usb
${voffset 4}${goto 58}memory stick (${fs_type /run/media/ernesto/sandisk})
${voffset 4}${goto 58}${color}${fs_used /run/media/ernesto/sandisk} / ${fs_size /run/media/ernesto/sandisk}
${endif}\
