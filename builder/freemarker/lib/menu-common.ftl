<#macro drawImage filePath x y fixed=true>
<#if fixed>
${image [=filePath] -p [=x?c],[=y?c]}\
<#else>
${lua_parse draw_image [=filePath] [=x?c] [=y?c]}\
</#if>
</#macro>
