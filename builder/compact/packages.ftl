conky.config = {
  lua_load = '~/conky/monochrome/library.lua',
  
  update_interval = 30,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- top|middle|bottom_left|right
  gap_x = 404,
  gap_y = 557,

  -- window settings
  minimum_width = 189,      -- conky will add an extra pixel to this  
  maximum_width = 189,
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
  color2 = '[=colors.highlight]',         -- highlight important packages
};

conky.text = [[
# :::::::::::: package updates
${if_existing /tmp/dnf.packages.preview}\
<#assign y = 0, 
         top = 19,    <#-- menu header -->
         body = 990,  <#-- size of the current window without the top and bottom edges -->
         bottom = 7,  <#-- window bottom edge -->
         space = 5,   <#-- empty space between windows -->
         windowYcoordinate = y> <#-- starting y coordinate of the current window -->
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-horizontal.png -p 0,[=y?c]}\
${voffset 2}${offset 5}${color1}dnf${goto 75}${color}${lua compute_and_save packages ${lines /tmp/dnf.packages.preview}} package updates
<#assign y += top>
${image ~/conky/monochrome/images/widgets-dock/menu-blank.png -p 0,[=y?c]}\
<#assign y += 1>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-top-flat.png -p 0,[=y?c]}\
<#assign y += top>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-dnf.png -p 0,[=y?c]}\
${lua_parse bottom_edge_load_value compact [=image.primaryColor]-menu-bottom.png 0 [=y?c] 2 packages}\
${voffset 7}${offset 5}${color1}package${alignr 5}version${voffset 4}
<#if system == "desktop"><#assign lines = 66><#else><#assign lines = 15></#if>
${color}${execp head -n [=lines] /tmp/dnf.packages.preview}${voffset 4}
${endif}\
]];
