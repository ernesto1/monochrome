<#import "/lib/panel-square.ftl" as panel>
conky.config = {  
  update_interval = 1.5,    -- update interval in seconds
  xinerama_head = 0,        -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,     -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- top|middle|bottom_left|right
  gap_x = 0,
  gap_y = 32,

  -- window settings
  <#assign width = 209            <#-- conky will add 1px, so the final width is 210 (210/6=35) --> >
  minimum_width = [=width?c],   -- conky will add an extra pixel to this
  maximum_width = [=width?c],
  minimum_height = [=768-32-23-1],<#-- screen height - gnome top bar - bottom panel - 1 for extra conky pixel -->
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)

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
  
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  
  -- ::: templates
  -- highlight value if resource usage is high
  template1 = [[${if_match ${\1} >= \2}${color2}${endif}]],
  -- highlight value if resource usage is low
  template2 = [[${if_match ${\1} <= \2}${color2}${endif}]],
  
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.warning]'  
};

conky.text = [[
${image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png -p 0,0}\
${voffset 5}\
<#-- char width is 6px, use single space for borders -->
<#assign iborder = 6,
         processes = 5>
# :::::: top cpu
${color1}${offset [=iborder]}process${alignr [=iborder-1]}cpu      mem
<#list 1..processes as x>
${voffset 3}${color}${offset [=iborder]}${top name [=x]}${alignr [=iborder-1]}${top cpu [=x]}%  ${top mem [=x]}%
</#list>
# :::::: top memory
${voffset 8}\
${offset [=iborder]}${color1}process${alignr [=iborder-1]}memory     perc
<#list 1..processes as x>
${voffset 3}${color}${offset [=iborder]}${top_mem name [=x]}${alignr [=iborder-1]}${top_mem mem_res [=x]}  ${top_mem mem [=x]}%
</#list>
# :::::: top disk i/o
${voffset 8}\
<#-- there seems to be a bug in the goto variable, adding 1px to get the proper length of 6px per char -->
${color1}${offset [=iborder]}process${goto [=1+6+16*6+6]}read${goto [=1+6+16*6+6+7*6+6*2]}write
<#list 1..processes as x>
${voffset 3}${color}${offset [=iborder]}${top_io name [=x]} ${top_io io_read [=x]}${goto [=1+6+16*6+6+7*6+6*2]}${top_io io_write [=x]}
</#list>
]];
