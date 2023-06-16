<#-- creates a composite table image with the given dimensions
 (x,y)
    ╭─────────────╮                          -+-
    │─────────────│ < header height (px)      |
    │             │                           |
    │             │ body height (px)        height
    │             │                           |
    │             │                           |
    ╰─────────────╯                          -+-
       width (px)
 -->
<#macro table x y width header body=200 bottomEdges=true fixed=true>
# ----------- table image ------------
<@menuHeader x=x y=y width=width fixed=fixed/>
<@drawImage filePath="~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-light.png" x=x y=y+header fixed=fixed/>
<@drawImage filePath="~/conky/monochrome/images/menu-blank.png" x=x+width y=y fixed=fixed/>
<#local y += header + body>
<#if bottomEdges>
<@menuBottom x=x y=y width=width/>
</#if>
# -------- end of table image ---------
</#macro>


<#macro menuHeader x y width theme="dark" fixed=true>
<#-- edge images are 7x7px -->
<@drawImage filePath="~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-[=theme].png" x=x y=y fixed=fixed/>
<@drawImage filePath="~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-[=theme]-edge-top-left.png" x=x y=y fixed=fixed/>
<@drawImage filePath="~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-[=theme]-edge-top-right.png" x=x+width-7 y=y fixed=fixed/>
</#macro>


<#macro menuBottom x y width theme="light" fixed=true>
<#local y -= 7><#-- edge images are 7x7px -->
<@drawImage filePath="~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-[=theme]-edge-bottom-left.png" x=x y=y fixed=fixed/>
<@drawImage filePath="~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-[=theme]-edge-bottom-right.png" x=x+width-7 y=y fixed=fixed/>
<@drawImage filePath="~/conky/monochrome/images/menu-blank.png" x=x y=y + 7 fixed=fixed/>
</#macro>


<#macro drawImage filePath x y fixed=true>
<#if fixed>
${image [=filePath] -p [=x?c],[=y?c]}\
<#else>
${lua_parse draw_image [=filePath] [=x?c] [=y?c]}\
</#if>
</#macro>


<#-- creates a composite menu image with the given dimensions
 (x,y)
    ╭─────────────╮      -+-
    │             │       |
    │             │       |
    │             │     height (px)
    │             │       |
    │             │       |
    ╰─────────────╯      -+-
       width (px)
 -->
<#macro menu x y width height isDark=false bottomEdges=true fixed=true>
# ----------- menu image ------------
<#local theme = getTheme(isDark)>
<@menuHeader x=x y=y width=width theme=theme fixed=fixed/>
<@drawImage filePath="~/conky/monochrome/images/menu-blank.png" x=x+width y=y fixed=fixed/>
<#local y += height>
<#if bottomEdges>
<@menuBottom x=x y=y width=width theme=theme fixed=fixed/>
</#if>
# -------- end of menu image ---------
</#macro>


<#function getTheme isDark>
  <#return isDark?then("dark", "light")>
</#function>


<#-- creates a composite vertical table image with the given dimensions
 (x,y)
    ╭─────────+──────────────────╮
    │         │                  │
    │         │                  │
    │         │                  │  height
    │         │                  │
    │         │                  │
    ╰─────────+──────────────────╯
     header       body width (px)
     width (px)
 -->
<#macro verticalTable x y header body height>
# -------  vertical table image -------
<@verticalMenuHeader x=x y=y header=header body=body/>
<#local yCoordinate = y + height - 7>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-dark-edge-bottom-left.png -p [=x?c],[=yCoordinate?c]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-light-edge-bottom-right.png -p [=(x+header+body-7)?c],[=yCoordinate?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p [=(x+header+body)?c],[=y?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p [=x?c],[=(yCoordinate+7)?c]}\
# --------- end of table image ---------
</#macro>


<#macro verticalMenuHeader x y header body>
<#-- edge images are 7x7px -->
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-dark.png -p [=x?c],[=y?c]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-dark-edge-top-left.png -p [=x?c],[=y?c]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-light.png -p [=(x+header)?c],[=y?c]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-light-edge-top-right.png -p [=(x+header+body-7)?c],[=y?c]}\
</#macro>


<#-- table that combines both vertical and horizontal table layouts
 (x,y)
           vertical
           header
           width (px)
          ╭─────────+──────────────────╮
          │         │                  │  vetical table height
          ╰─────────+──────────────────╯
 
 -->
<#macro compositeTable x y width vheader hbody vheight=19 hheader=19 bottomEdges=true>
<#local startingy = y>
# ------- composite table image -------
<@verticalMenuHeader x=x y=y header=vheader body=width-vheader/>
<#local yCoordinate = y + vheight + 1>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-dark.png -p [=x?c],[=yCoordinate?c]}\
<#local yCoordinate += hheader>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-light.png -p [=x?c],[=yCoordinate?c]}\
<#local yCoordinate += hbody>
<#if bottomEdges>
<@menuBottom x=x y=yCoordinate  width=width/>
</#if>
${image ~/conky/monochrome/images/menu-blank.png -p [=(x+width)?c],[=y?c]}\
# -------- end of table image ---------
</#macro>
