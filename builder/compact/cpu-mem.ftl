# -------------- cpu
${if_match ${cpu cpu0} < 85}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu-mem.png -p 0,0}
${else}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu-mem-high.png -p 0,0}
${endif}\
${voffset -11}${offset 43}${cpugraph cpu0 35,139 ${template1}}
${voffset -2}${offset 5}${color1}load ${color}${loadavg}${alignr 59}${color}${cpu cpu0}%
${voffset 8}${color1}${offset 5}process${alignr 59}cpu   pid${voffset 1}
${template7 1}
${template7 2}
${template7 3}
${template7 4}
# -------------- memory
# memory graph and usage are displayed on a separate conky due to a bug with these memory variables computing bad data if other variables like ${top ...} and one of the network upload/download exists in the same conky
${voffset 67}\
${voffset 3}${offset 5}${color1}swap${goto 38}${voffset 1}${color2}${swapbar 3,97}${alignr 59}${voffset -1}${color}${swapperc}%
${voffset 8}${color1}${offset 5}process${alignr 59}mem   pid${voffset 1}
${template8 1}
${template8 2}
${template8 3}
${template8 4}
