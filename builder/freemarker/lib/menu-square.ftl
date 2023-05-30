<#-- creates a composite table image with the given dimensions
 theme = conky theme to source images from

 (x,y)
    +-------------+                          -+-
    |-------------| < header height (px)      |
    |             |                           |
    |             | body height (px)        height
    |             |                           |
    |             |                           |
    +-------------+                          -+-
       width (px)
 -->
<#macro table theme x y width header body>
# ------- composite table image -------
${image ~/conky/monochrome/images/[=theme]/[=image.primaryColor]-menu-dark.png -p [=x?c],[=y?c]}\
${image ~/conky/monochrome/images/[=theme]/[=image.primaryColor]-menu-light.png -p [=x?c],[=(y+header)?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p [=(x+width)?c],[=y?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p [=x?c],[=(y + header + body)?c]}\
# --------- end of table image --------
</#macro>


<#-- creates a composite vertical table image with the given dimensions
 theme = conky theme to source images from

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
<#macro verticaltable theme x y header body height>
# --- composite vertical table image ---
${image ~/conky/monochrome/images/[=theme]/[=image.primaryColor]-menu-dark.png -p [=x?c],[=y?c]}\
${image ~/conky/monochrome/images/[=theme]/[=image.primaryColor]-menu-light.png -p [=(x+header)?c],[=y?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p [=(x+header+body)?c],[=y?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p [=x?c],[=(y+height)?c]}\
# --------- end of table image ---------
</#macro>
