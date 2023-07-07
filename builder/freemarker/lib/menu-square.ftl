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
 -->
<#macro table x y width header body=200 bottomEdges=true fixed=true>
# ------- composite table image -------
<@cmn.drawImage filePath="~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-dark.png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-light.png" x=x y=y+header fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/menu-blank.png" x=x+width y=y fixed=fixed/>
<#if bottomEdges>
<@cmn.drawImage filePath="~/conky/monochrome/images/menu-blank.png" x=x y=y+header+body fixed=fixed/>
</#if>
# --------- end of table image --------
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
<#macro verticalTable x y header body height fixed=true>
# --- composite vertical table image ---
<@cmn.drawImage filePath="~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-dark.png" x=x y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-light.png" x=x+header y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/menu-blank.png" x=x+header+body y=y fixed=fixed/>
<@cmn.drawImage filePath="~/conky/monochrome/images/menu-blank.png" x=x y=y+height fixed=fixed/>
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
<#macro menu x y width height isDark=false bottomEdges=true fixed=true>
# ----------- menu image ------------
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-light.png -p [=x?c],[=y?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p [=(x+width)?c],[=y?c]}\
<#if bottomEdges>
${image ~/conky/monochrome/images/menu-blank.png -p [=x?c],[=(y + height)?c]}\
</#if>
# -------- end of menu image ---------
</#macro>
