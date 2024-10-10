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

<#function sum values>
  <#local total = 0>
  <#list values as v>
    <#local total = total + v>
  </#list>
  <#return total>
</#function>

<#macro drawContinuosPanel x y width color theme="light" isFixed=true>
<#if color != "blank">
<#local image = color + "-panel-" + theme + ".png">
<#else>
<#local image = "blank-panel.png">
</#if>
<#-- simulates an infinite loop, will break once the desired width is reached -->
<#list 0..20 as i>
<#if width gt 0>
<@drawImage filePath="~/conky/monochrome/images/common/"+image x=x y=y isFixed=isFixed/>
<#local x += panelWidth,
        width -= panelWidth>
<#else>
<#break>
</#if>
</#list>
</#macro>
