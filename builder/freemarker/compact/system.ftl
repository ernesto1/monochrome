# -------------- system
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-system-1.png -p 0,0}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-system-2.png -p 0,0}${endif}\
${voffset 15}${goto 47}${color1}uptime ${goto 113}${color}${uptime}
${voffset 3}${goto 47}${color1}compositor ${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset 10}${offset 5}${color1}kernel ${color}${kernel}
# due to a conky/lua bug the temperature items had to be moved to their own conky
