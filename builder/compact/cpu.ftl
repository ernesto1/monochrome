# -------------- cpu
${if_match ${cpu cpu0} < 85}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu.png -p 0,0}
${else}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu-high.png -p 0,0}
${endif}\
${voffset -11}${offset 43}${cpugraph cpu0 35,139 ${template1}}
${voffset -2}${offset 5}${color1}load ${color}${loadavg}${alignr 59}${color}${cpu cpu0}%
${voffset 8}${color1}${offset 5}process${alignr 59}cpu   pid${voffset 1}
<#list 1..7 as x>
${template7 [=x]}
</#list>
