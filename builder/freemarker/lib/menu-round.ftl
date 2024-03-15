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
  color         color scheme to use, default is the conky's primary color scheme
 -->
<#macro table x y width header body=200 bottomEdges=true fixed=true color=image.primaryColor>
# ----------- table image ------------
<@panelTopCorners x=x y=y width=width fixed=fixed color=color isEdge=false/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-light.png" x=x y=y+header fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+width y=y fixed=fixed/>
<#local y += header + body>
<#if bottomEdges>
<@panelBottomCorners x=x y=y width=width/>
</#if>
# -------- end of table image ---------
</#macro>


<#-- creates the rounded top corners of a panel
 (x,y)
    ╭─────────────╮
    │             │
    
       width (px)

  fixed         'true' if the given x,y coordinates are final, 'false' if you want to consider the current x,y offsets
                default is 'true'
  color         color scheme to use, default is the conky's primary color scheme
  isEdge        if 'true' a transparent image will be placed right after the right corner
                enable when creating multiples panels horizontally
                default is 'true'
-->
<#macro panelTopCorners x y width theme="dark" fixed=true color=image.primaryColor isEdge=true>
<#-- edge images are 7x7px -->
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme].png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-top-left.png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-top-right.png" x=x+width-7 y=y fixed=fixed/>
<#if isEdge>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+width y=y fixed=fixed/>
</#if>
</#macro>


<#-- creates the rounded top corners of a panel
 (x,y)
 
    │             │
    ╰─────────────╯
       width (px)

  fixed         'true' if the given x,y coordinates are final, 'false' if you want to consider the current x,y offsets
                default is 'true'
  color         color scheme to use, default is the conky's primary color scheme
  theme         use the 'light' or 'dark' hue of the color
-->
<#macro panelBottomCorners x y width fixed=true color=image.primaryColor theme="light">
<#local y -= 7><#-- edge images are 7x7px -->
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-bottom-left.png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-bottom-right.png" x=x+width-7 y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y+7 fixed=fixed/>
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
  color         color scheme to use, default is the conky's primary color scheme
 -->
<#macro menu x y width height=100 isDark=false bottomEdges=true fixed=true color=image.primaryColor>
# -------- [=getTheme(isDark)] menu top edge    -------
<#local theme = getTheme(isDark)>
<@panelTopCorners x=x y=y width=width theme=theme fixed=fixed color=color/>
<#local y += height>
<#if bottomEdges>
<@panelBottomCorners x=x y=y width=width theme=theme fixed=fixed color=color/>
# -------- [=getTheme(isDark)] menu bottom edge -------
</#if>
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

<#-- creates a table with multiple columns

        column 1       column 2
      ╭──────────╮   ╭──────────╮
      │──────────│   │──────────│
      │          │   │          │
      │          │   │          │

 -->
<#macro columns x y widths height=100 gap=3 fixed=true theme="light" highlight=[]>
# ------- [=widths?size] columns table | top edges    -------
<#list widths as width>
  <#if highlight?seq_contains(width?counter)>
    <@panelTopCorners x=x y=y width=width fixed=fixed theme=theme color=image.secondaryColor/>
  <#else>
    <@panelTopCorners x=x y=y width=width fixed=fixed theme=theme color=image.primaryColor/>
  </#if>
  <#local x = x + width + gap>
</#list>
</#macro>

<#macro columnsBottom x y widths height=100 gap=3 fixed=true theme="light" highlight=[], color=image.primaryColor>
<#local xCoordinate = x>
<#list widths as width>
  <#if highlight?seq_contains(width?counter)>
    <#local color=image.secondaryColor>
  </#if>
  <@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-bottom-left.png" x=xCoordinate y=y fixed=false/>
  <@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-bottom-right.png" x=xCoordinate+width-7 y=y fixed=false/>
  <#local xCoordinate = xCoordinate + width + gap, color=image.primaryColor>
</#list>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y+7 fixed=false/>
# ------- [=widths?size] columns table | bottom edges -------
</#macro>
