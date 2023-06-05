<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/menu.lua',
  
  update_interval = 300,  -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- top|middle|bottom_left|right
  gap_x = 142,
  gap_y = 740,

  -- window settings
  <#assign width = 189>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  minimum_height = 20,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)
  own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 1,         -- width of border window in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels
  
  -- transparency configuration
  draw_blended = false,
  own_window_transparent = true,
  own_window_argb_visual = true,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)
  
  -- images
  imlib_cache_flush_interval = 250,
  
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.menuText]',  -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.highlight]'         -- highlight important packages
};

<#-- packages logic had to be moved to its own conky due to a ${execpi} bug where the command was being
     executed on every iteration instead of each interval, neglecting the whole point 
     
     additionally the data is parsed on each iteration regardless, this may be increasing the already
     high cpu usage of the 'system' conky-->
conky.text = [[
# :::::::::::: package updates
<#assign y = 0, 
         header = 19, <#-- menu header -->
         body = 1000,  <#-- size of the current window without the header -->
         gap = 5>     <#-- empty space between windows -->
${if_existing /tmp/conky/dnf.packages.formatted}\
<@menu.table x=0 y=y width=width header=header body=body bottomEdges=false/>
<#assign y += header>
# optional dnf branding, can be removed or won't matter if the image does not exist
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-dnf.png -p 114,[=(y+2)?c]}\
<#if system == "desktop"><#assign maxLines = 51><#else><#assign maxLines = 46></#if>
${lua_parse bottom_edge_parse [=conky] [=image.primaryColor]-menu-light-edge-bottom 0 [=y?c] [=width?c] 2 ${lines /tmp/conky/dnf.packages.formatted} [=maxLines]}\
${voffset 2}${offset 5}${color1}package${alignr 5}version${voffset 4}
${color}${execp head -n [=maxLines] /tmp/conky/dnf.packages.formatted}${voffset 5}
${endif}\
]]
