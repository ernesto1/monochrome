<#assign y = 0>
<#assign diskioHeight = 66>
<#assign partitionHeight = 64>
<#list hardDisks[system] as hardDisk>
# :::::::::::::::::::: disk [=hardDisk.name!hardDisk.device]
<#-- special handling for the main disk 'sda'
     > partitions do not print their name since their icons are self explanatory
     > no disconnected image used since it does not have any -->
<#if hardDisk.device != "sda">${if_existing /dev/[=hardDisk.device]}\<#else># main disk</#if>
# disk io
<#assign diskBlockStart = y>  <#-- need to store the starting y position of the disk for the disk disconnected image -->
${if_updatenr 1}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-1.png -p 0,[=y]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-diskio-2.png -p 0,[=y]}${endif}\
${template5 [=hardDisk.device] [=hardDisk.readSpeed?c] [=hardDisk.writeSpeed?c]}
# partitions
<#assign y += diskioHeight>
<#list hardDisk.partitions as partition>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-disk-[=partition.icon].png -p 0,[=y]}\
${template6 <#if hardDisk.device == "sda">\ <#else>[=partition.name]</#if> [=partition.path]}
<#assign y += partitionHeight>
</#list>
<#if hardDisk.device != "sda">
${else}\
${image ~/conky/monochrome/images/widgets-dock/[=image.secondaryColor]-disk-disconnected.png -p 0,[=diskBlockStart]}\
${voffset 60}${goto 67}[=hardDisk.device] not
${voffset 3}${goto 67}available
${voffset 28}
${endif}\
</#if>
</#list>
