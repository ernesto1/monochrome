# -------------- memory
${if_match ${memperc} < [=threshold.mem]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-mem.png -p 0,0}\
${else}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-mem-high.png -p 0,0}\
${endif}\
# memory graph and usage are displayed on a separate conky due to a bug with these memory variables computing bad data if other variables like ${top ...} and one of the network upload/download exists in the same conky
${voffset 67}${offset 5}${color1}swap${goto 41}${voffset 1}${color2}${swapbar 3,97}${alignr 59}${voffset -1}${color}${swapperc}%
<#assign inputDir = "/tmp/conky",
         swapRead = inputDir + "/system.swap.read",
         swapWrite = inputDir + "/system.swap.write">
${voffset 3}${offset 5}${color1}read${goto 41}${color}${cat [=swapRead]}${alignr 59}${cat [=swapWrite]} ${color1}write
${voffset 8}${offset 5}${color1}process${alignr 59}memory   perc${voffset 3}
<#list 1..7 as x>
${template8 [=x]}
</#list>
