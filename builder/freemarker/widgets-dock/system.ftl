<#import "/lib/menu-round.ftl" as menu>
<#import "lib/network.ftl" as net>
conky.config = {  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',  -- top|middle|bottom_left|right
  gap_x = 142,
  gap_y = 664,

  -- window settings
  <#assign width = 169>
  minimum_width = [=width],      -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = 351,
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
  own_window_argb_visual = true,    -- turn on transparency
  own_window_argb_value = 255,      -- range from 0 (transparent) to 255 (opaque)
  
  -- miscellanous settings
  imlib_cache_flush_interval = 250,
  top_name_verbose = true,          -- show full command in ${top ...}
  top_name_width = 18,              -- how many characters to print
  text_buffer_size = 2048,
  if_up_strictness = 'address',     -- network device must be up, having link and an assigned IP address
                                    -- to be considered "up" by ${if_up}
                                    -- values are: up, link or address
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.menuText]',  -- regular text
  color1 = '[=colors.labels]',
  
  -- templates
  -- top cpu process: ${template0 processNumber}
  template0 = [[${voffset 3}${offset 5}${color}${top name \1}${alignr 4}${top cpu \1}%]],
  -- top mem process: ${template1 processNumber}
  template1 = [[${voffset 3}${offset 5}${color}${top_mem name \1}${alignr 4}${top_mem mem_res \1}]]
};

conky.text = [[
# :::::::::::: top cpu processes
<#assign y = 0, 
         header = 19, <#-- menu header -->
         body = 116,  <#-- size of the current window without the header -->
         gap = 5>     <#-- empty space between windows -->
<@menu.table x=0 y=y width=width header=header body=body/>
<#assign y += header + body + gap>
${voffset 2}${offset 5}${color1}process${alignr 4}cpu${voffset 3}
<#list 1..7 as x>
${template0 [=x]}
</#list>
# :::::::::::: top mem processes
<@menu.table x=0 y=y width=width header=header body=body/>
<#assign y += header + body + gap>
${voffset 12}${offset 5}${color1}process${alignr 4}memory${voffset 3}
<#list 1..7 as x>
${template1 [=x]}
</#list>
# :::::::::::: network
# assumption: only one network device will be connected to the internet at a time
<@net.networkDetails devices=networkDevices[system] y=y width=width gap=gap/>
<#assign y += 71 + gap>
]];
