<#assign y = 0>
<#assign diskioHeight = 99>
<#assign partitionHeight = 56>
<#list hardDisks[system] as hardDisk>
# ::::::::::::::::: disk [=hardDisk.name!hardDisk.device]
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-disk.png -p 5,[=y?c]}\
${template5 [=hardDisk.device] [=hardDisk.readSpeed?c] [=hardDisk.writeSpeed?c]}
<#assign y += diskioHeight>
# :::::: partitions
<#list hardDisk.partitions as partition>
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-block-small.png -p 5,[=y?c]}\
${template6 [=partition.name] [=partition.path]}
<#assign y += partitionHeight>
</#list>
</#list>
