<#macro drawImage filePath x y isFixed=true>
<#if isFixed>
${image [=filePath] -p [=x?c],[=y?c]}\
<#else>
${lua_parse draw_image [=filePath] [=x?c] [=y?c]}\
</#if>
</#macro>

<#function getTheme isDark>
  <#return isDark?then("dark", "light")>
</#function>
