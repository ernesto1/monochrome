# -------------- disk(s)
<#assign height = 0, diskioHeight = 72, partitionHeight = 31>
<#list hardDisks[system] as disk>
# ---------- [=disk.device]
<#assign discBlockHeight = height>
<#if disk.partitions?size == 1><#-- for disk with single partition add connected/disconnected state -->
${if_existing /dev/[=disk.device]}\
</#if>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-disk.png -p 0,[=height]}\
${template5 [=disk.device] [=disk.readSpeed?c] [=disk.writeSpeed?c]}
<#list disk.partitions>
${voffset 6}\
<#assign height += diskioHeight>
<#items as partition>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-filesystem.png -p 0,[=height]}\
<#assign height += partitionHeight>
${template6 [=partition.name] [=partition.path]}
</#items>
</#list>
<#if disk.partitions?size == 1>
${else}\
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-disk-disconnected.png -p 0,[=discBlockHeight]}\
${voffset 13}${offset 5}${color1}[=disk.device] device
${voffset 3}${offset 5}${color1}${font4}is not connected
${voffset 48}
${endif}\
</#if>
</#list>
