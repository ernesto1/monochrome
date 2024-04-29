<#import "/lib/menu-common.ftl" as cmn>

<#-- creates a composite table image with the given dimensions
 (x,y)
    +-------------+                          -+-
    |-------------| < header height (px)      |
    |             |                           |
    |             | body height (px)        height = header + body
    |             |                           |
    |             |                           |
    +-------------+                          -+-
       width (px)
       
  fixed   'true' if the given x,y coordinates are final, 'false' if you want to consider the current x,y offsets
          default is 'true'
  color   color scheme to use, default is the conky primary color scheme
 -->
<#macro table x y widths header body=0 gap=3 isFixed=true highlight=[]>
<#local color = image.primaryColor, xCoordinate = x>
# ------- table | [=widths?size] column(s) | top    -------
# ------- header
<#list widths as width>
  <#if highlight?seq_contains(width?counter)>
    <#local color=image.secondaryColor>
  </#if>
  <@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-dark.png" x=xCoordinate y=y isFixed=isFixed/>
  <@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=xCoordinate+width y=y isFixed=isFixed/>
  <#local xCoordinate = xCoordinate + width + gap, color=image.primaryColor>
</#list>
# ------- body
<#local xCoordinate = x, y = y + header>
<#list widths as width>
  <#if highlight?seq_contains(width?counter)>
    <#local color=image.secondaryColor>
  </#if>
  <@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-light.png" x=xCoordinate y=y isFixed=isFixed/>
  <@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=xCoordinate+width y=y isFixed=isFixed/>
  <#local xCoordinate = xCoordinate + width + gap, color=image.primaryColor>
</#list>
<#if body gt 0>
# ------- bottom blank image(s)
<#local xCoordinate = x, y = y + body, widthToCover = cmn.sum(widths)>
<#-- the blank image is repeated as many times as necessary in order to cover the table's width -->
<#list 0..widths?size as widths>
<#if widthToCover gt 0>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=xCoordinate y=y isFixed=isFixed/>
<#local xCoordinate = xCoordinate + blankImageWidth, widthToCover = widthToCover - blankImageWidth>
<#else>
<#break>
</#if>
</#list>
# ------- table | [=widths?size] column(s) | bottom -------
</#if>
</#macro>


<#-- creates a composite vertical table image with the given dimensions
 (x,y)
    +---------+--------------------+
    |         |                    |
    |         |                    |
    |         |                    |  height
    |         |                    |
    |         |                    |
    +---------+--------------------+
     header       body width (px)
     width (px)
 -->
<#macro verticalTable x y header body height isFixed=true>
# ------- vertical table | top    -------
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-dark.png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-light.png" x=x+header y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+header+body y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y+height isFixed=isFixed/>
# ------- vertical table | bottom -------
</#macro>


<#-- creates a composite panel image with the given dimensions
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
<#macro panel x y width height=0 isDark=false isFixed=true color=image.primaryColor>
<#local theme=cmn.getTheme(isDark)>
# ------- panel | [=theme] [=color] | top     -------
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-[=theme].png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+width y=y isFixed=isFixed/>
<#if height gt 0>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y+height isFixed=isFixed/>
# ------- panel | [=theme] [=color] | bottom  -------
</#if>
</#macro>
