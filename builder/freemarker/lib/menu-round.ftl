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

  fixed         'true' if the given x,y coordinates are final, 'false' if you want to consider the current x,y offsets
                default is 'true'
  color         color scheme to use, default is the conky's primary color scheme
 -->
<#macro table x y width header body=0 isFixed=true color=image.primaryColor>
# -------  table | [=color] 1 column | top edge    -------
<@panelTopCorners x=x y=y width=width isFixed=isFixed color=color isEdge=false/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-light.png" x=x y=y+header isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+width y=y isFixed=isFixed/>
<#if body gt 0>
<#local y += header + body>
<@panelBottomCorners x=x y=y width=width isFixed=isFixed color=color/>
</#if>
# -------  table | [=color] 1 column | bottom edge -------
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
<#macro panelTopCorners x y width theme="dark" isFixed=true color=image.primaryColor isEdge=true>
<#-- edge images are 7x7px -->
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme].png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-top-left.png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-top-right.png" x=x+width-7 y=y isFixed=isFixed/>
<#if isEdge>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+width y=y isFixed=isFixed/>
</#if>
</#macro>


<#-- creates the rounded top corners of a panel
 (x,y)
 
    │             │
    ╰─────────────╯
       width (px)

  y             y coordinate where the panel ends
  fixed         'true' if the given x,y coordinates are final, 'false' if you want to consider the current x,y offsets
                default is 'true'
  color         color scheme to use, default is the conky's primary color scheme
  theme         use the 'light' or 'dark' hue of the color
  isEdge        if 'true' a transparent image will be placed right below the left rounded corner
                default is 'true'
-->
<#macro panelBottomCorners x y width isFixed=true color=image.primaryColor theme="light" isEdge=true>
<#local y -= 7><#-- edge images are 7x7px -->
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-bottom-left.png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-bottom-right.png" x=x+width-7 y=y isFixed=isFixed/>
<#if isEdge>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y+7 isFixed=isFixed/>
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

  isFixed       'true' if the given x,y coordinates are final, 'false' if you want to consider the current x,y offsets
                default is 'true'
  color         color scheme to use, default is the conky's primary color scheme
 -->
<#macro panel x y width height=0 isDark=false isFixed=true color=image.primaryColor>
<#local theme = cmn.getTheme(isDark)>
# ------- [=theme] panel top edge    -------
<@panelTopCorners x=x y=y width=width theme=theme isFixed=isFixed color=color/>
<#if height gt 0>
<#local y += height>
<@panelBottomCorners x=x y=y width=width theme=theme isFixed=isFixed color=color/>
# ------- [=theme] panel bottom edge -------
</#if>
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

  fixed         'true' if the given x,y coordinates are final, 'false' if you want to consider the current x,y offsets
                default is 'true'
 -->
<#macro verticalTable x y header body height isFixed=true>
# -------  vertical table image -------
<@verticalMenuHeader x=x y=y header=header body=body isFixed=isFixed/>
<#local y += height - 7>
<@verticalMenuBottom x=x y=y header=header body=body isFixed=isFixed/>
# --------- end of table image ---------
</#macro>


<#macro verticalMenuHeader x y header body isFixed=true>
<#-- edge images are 7x7px -->
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-dark.png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-dark-edge-top-left.png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-light.png" x=x+header y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-light-edge-top-right.png" x=x+header+body-7 y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+header+body y=y isFixed=isFixed/>
</#macro>

<#macro verticalMenuBottom x y header body isFixed=true>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-dark-edge-bottom-left.png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-light-edge-bottom-right.png" x=x+header+body-7 y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y+7 isFixed=isFixed/>
</#macro>


<#macro noLeftEdgePanel x y width height color=image.primaryColor isDark=false isFixed=true>
<#local theme = cmn.getTheme(isDark)>
# ------- panel | [=theme] [=color] no left round edges | top -------
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme].png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-top-right.png" x=x+width-7 y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+width y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme]-edge-bottom-right.png" x=x+width-7 y=y+height-7 isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y+height isFixed=isFixed/>
# ------- panel | [=theme] [=color] no left round edges | bottom -------
</#macro>


<#-- creates a table with multiple columns

        column 1     column 2
      ╭──────────╮ ╭──────────╮
      │          │ │          │
      │          │ │          │
      │          │ │          │
                 gap

  widths      list of column widths in pixels
  higlight    list of columns positions to highlight by using the conky theme's secondary color
              first column starts at 1
 -->
<#macro panels x y widths gap=3 isFixed=true theme="light" highlight=[]>
# ------- [=widths?size] column(s) panel | top edges    -------
<#list widths as width>
  <#if highlight?seq_contains(width?counter)>
    <#local color=image.secondaryColor>
  <#else>
  </#if>
  <@panelTopCorners x=x y=y width=width isFixed=isFixed theme=theme color=color/>
  <#local x = x + width + gap, color=image.primaryColor>
</#list>
</#macro>

<#-- 
  y           y coordinate where the panel ends
  widths      list of column widths in pixels
-->
<#macro panelsBottom x y widths gap=3 isFixed=true theme="light" highlight=[], color=image.primaryColor>
<#local xCoordinate = x>
<#list widths as width>
  <#if highlight?seq_contains(width?counter)>
    <#local color=image.secondaryColor>
  </#if>
  <@panelBottomCorners x=xCoordinate y=y width=width isFixed=false isEdge=false color=color/>
  <#local xCoordinate = xCoordinate + width + gap, color=image.primaryColor>
</#list>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y isFixed=false/>
# ------- [=widths?size] column(s) panel | bottom edges -------
</#macro>
