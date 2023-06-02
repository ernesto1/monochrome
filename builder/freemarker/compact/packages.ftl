<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/menu.lua',
  
  update_interval = 30,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_right',  -- top|middle|bottom_left|right
  gap_x = 5,
  gap_y = 125,

  -- window settings
  <#assign width = 189>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
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
  color2 = '[=colors.highlight]'          -- highlight important packages
};

conky.text = [[
# :::::::::::: package updates
${if_existing /tmp/conky/dnf.packages.formatted}\
<#assign y = 0, 
         header = 19, <#-- menu header -->
         body = 1400,  <#-- menu window without the header -->
         gap = 3>     <#-- empty space between windows -->
<@menu.compositeTable x=0 y=y width=width vheader=51 hbody=body/>
# optional dnf branding, can be removed or won't matter if the image does not exist
<#assign y += header + 1 + header>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-dnf.png -p 114,[=(y+2)?c]}\
${voffset 2}${offset 5}${color1}dnf${goto 57}${color}${lua compute_and_save packages ${lines /tmp/conky/dnf.packages.formatted}} package updates
${voffset -5}${color2}${hr 1}${voffset -8}
${voffset 7}${offset 5}${color1}package${alignr 5}version${voffset 4}
<#if system == "desktop"><#assign maxLines = 82><#else><#assign maxLines = 15></#if>
${color}${execp head -n [=maxLines] /tmp/conky/dnf.packages.formatted}${voffset 4}
${lua_parse bottom_edge_load_value [=conky] [=image.primaryColor]-menu-light-edge-bottom 0 [=y?c] [=width?c] 2 packages [=maxLines]}\
${endif}\
]];
