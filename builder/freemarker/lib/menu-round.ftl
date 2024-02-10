<#import "/lib/menu-common.ftl" as cmn>

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

  bottomEdges   draw the round bottom edges, default is 'true'
  fixed         'true' if the given x,y coordinates are final, 'false' if you want to consider the current x,y offsets
                default is 'true'
  color         color scheme to use, default is the conky primary color scheme
 -->
<#macro table x y width header body=200 bottomEdges=true fixed=true color=image.primaryColor>
# ----------- table image ------------
<@menuHeader x=x y=y width=width fixed=fixed color=color/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-light.png" x=x y=y+header fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+width y=y fixed=fixed/>
<#local y += header + body>
<#if bottomEdges>
<@menuBottom x=x y=y width=width/>
</#if>
# -------- end of table image ---------
</#macro>


<#macro menuHeader x y width theme="dark" fixed=true color=image.primaryColor>
<#-- edge images are 7x7px -->
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme].png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-top-left.png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-top-right.png" x=x+width-7 y=y fixed=fixed/>
</#macro>


<#macro menuBottom x y width theme="light" fixed=true color=image.primaryColor>
<#local y -= 7><#-- edge images are 7x7px -->
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-bottom-left.png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-bottom-right.png" x=x+width-7 y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y + 7 fixed=fixed/>
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

  bottomEdges   draw the round bottom edges, default is 'true'
  fixed         'true' if the given x,y coordinates are final, 'false' if you want to consider the current x,y offsets
                default is 'true'
  color         color scheme to use, default is the conky primary color scheme
 -->
<#macro menu x y width height isDark=false bottomEdges=true fixed=true color=image.primaryColor>
# ----------- menu image ------------
<#local theme = getTheme(isDark)>
<@menuHeader x=x y=y width=width theme=theme fixed=fixed color=color/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+width y=y fixed=fixed/>
<#local y += height>
<#if bottomEdges>
<@menuBottom x=x y=y width=width theme=theme fixed=fixed color=color/>
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

  fixed         'true' if the given x,y coordinates are final, 'false' if you want to consider the current x,y offsets
                default is 'true'
 -->
<#macro verticalTable x y header body height fixed=true>
# -------  vertical table image -------
<@verticalMenuHeader x=x y=y header=header body=body fixed=fixed/>
<#local y += height - 7>
<@verticalMenuBottom x=x y=y header=header body=body fixed=fixed/>
# --------- end of table image ---------
</#macro>


<#macro verticalMenuHeader x y header body fixed=true>
<#-- edge images are 7x7px -->
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-dark.png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-dark-edge-top-left.png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-light.png" x=x+header y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-light-edge-top-right.png" x=x+header+body-7 y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+header+body y=y fixed=fixed/>
</#macro>

<#macro verticalMenuBottom x y header body fixed=true>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-dark-edge-bottom-left.png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-light-edge-bottom-right.png" x=x+header+body-7 y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y+7 fixed=fixed/>
</#macro>


<#-- table that combines both vertical and horizontal table layouts
 (x,y)
           vertical
           header
           width (px)
           (vheader)
          ╭─────────+───────────────╮
          │ title   │ value         │   vetical table height (vheight)
          │ title 2 │ value         │  
          +─────────+───────────────+
          │         title 3         │   horizontal header height (px)
          │─────────────────────────│ < hheader                           -+-
          │ value                   │                                      |          
          │ value                   │                                      |
          │ value                   │ body height (px)               horizontal table height (hheight)
          │                         │                                      |
          │                         │                                      |
          ╰─────────────────────────╯                                     -+-
                    width (px)

  bottomEdges   draw the round bottom edges, default is 'true'
-->
<#macro compositeTable x y width vheader hheight vheight=19 hheader=19 bottomEdges=true>
<#local startingy = y>
# ------- composite table image -------
<@verticalMenuHeader x=x y=y header=vheader body=width-vheader/>
<#local yCoordinate = y + vheight + 1>
${image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-dark.png -p [=x?c],[=yCoordinate?c]}\
<#local yCoordinate += hheader>
${image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-light.png -p [=x?c],[=yCoordinate?c]}\
<#local yCoordinate += hheight>
<#if bottomEdges>
<@menuBottom x=x y=yCoordinate  width=width/>
</#if>
${image ~/conky/monochrome/images/common/menu-blank.png -p [=(x+width)?c],[=y?c]}\
# -------- end of table image ---------
</#macro>
