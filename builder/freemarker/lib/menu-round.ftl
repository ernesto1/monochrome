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
<#macro table x y width header body bottomEdges=true>
# ----------- table image ------------
<@menuHeader x=x y=y width=width/>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-light.png -p [=x?c],[=(y+header)?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p [=(x+width)?c],[=y?c]}\
<#local y += header + body>
<#if bottomEdges>
<@menuBottom x=x y=y width=width/>
</#if>
# -------- end of table image ---------
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
<#macro menu x y width height isDark=false>
# ----------- menu image ------------
<#local theme = getTheme(isDark)>
<@menuHeader x=x y=y width=width theme=theme/>
${image ~/conky/monochrome/images/menu-blank.png -p [=(x+width)?c],[=y?c]}\
<#local y += height>
<@menuBottom x=x y=y width=width theme=theme/>
# -------- end of menu image ---------
</#macro>


<#function getTheme isDark>
  <#return isDark?then("dark", "light")>
</#function>


<#macro menuHeader x y width theme="dark">
<#-- edge images are 7x7px -->
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-[=theme].png -p [=x?c],[=y?c]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-[=theme]-edge-top-left.png -p [=x?c],[=y?c]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-[=theme]-edge-top-right.png -p [=(x+width-7)?c],[=y?c]}\
</#macro>


<#macro menuBottom x y width theme="light">
<#local y -= 7><#-- edge images are 7x7px -->
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-[=theme]-edge-bottom-left.png -p [=x?c],[=y?c]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-[=theme]-edge-bottom-right.png -p [=(x+width-7)?c],[=y?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p [=x?c],[=(y + 7)?c]}\
</#macro>


<#-- table that combines both vertical and horizontal table layouts -->
<#macro compositeTable x y width vheader hbody vheight=19 hheader=19>
<#local startingy = y>
# ------- composite table image -------
<@verticalMenuHeader x=x y=y header=vheader body=width-vheader/>
<#local yCoordinate = y + vheight + 1>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-dark.png -p [=x?c],[=yCoordinate?c]}\
<#local yCoordinate += hheader>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-light.png -p [=x?c],[=yCoordinate?c]}\
<#local yCoordinate += hbody>
<@menuBottom x=x y=yCoordinate  width=width/>
${image ~/conky/monochrome/images/menu-blank.png -p [=(x+width)?c],[=y?c]}\
# -------- end of table image ---------
</#macro>


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
