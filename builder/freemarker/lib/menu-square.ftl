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
<#macro table x y width header body=0 isFixed=true color=image.primaryColor>
# ------- single column table | top edge    -------
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-dark.png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=color]-menu-light.png" x=x y=y+header isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+width y=y isFixed=isFixed/>
<#if body gt 0>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y+header+body isFixed=isFixed/>
</#if>
# ------- single column table | bottom edge -------
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
# --- composite vertical table image ---
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-dark.png" x=x y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/[=image.primaryColor]-menu-light.png" x=x+header y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x+header+body y=y isFixed=isFixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/common/menu-blank.png" x=x y=y+height isFixed=isFixed/>
# --------- end of table image ---------
</#macro>


<#-- creates a composite menu image with the given dimensions
 (x,y)
    ╭─────────────╮      -+-
    │             │       |
    │             │       |
    │             │     height (px)
    │             │       |
    │             │       |
    ╰─────────────╯      -+-      TODO implement isDark & fixed functionalities
       width (px)
 -->
<#macro panel x y width height=0 isDark=false isFixed=true>
# ------- [=cmn.getTheme(isDark)] panel top edge    -------
${image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-light.png -p [=x?c],[=y?c]}\
${image ~/conky/monochrome/images/common/menu-blank.png -p [=(x+width)?c],[=y?c]}\
<#if height gt 0>
${image ~/conky/monochrome/images/common/menu-blank.png -p [=x?c],[=(y + height)?c]}\
</#if>
# ------- [=cmn.getTheme(isDark)] panel bottom edge -------
</#macro>
