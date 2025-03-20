<#import "/lib/panel-round.ftl" as panel>
-- this conky will show the top 3 cpu or memory intensive processes whenever the corresponding resource usage
-- is too high, otherwise the conky will remain invisible

conky.config = {  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  <#if device == "desktop"><#assign alignment = "middle_left"><#else><#assign alignment = "middle_right"></#if>
  alignment = '[=alignment]',  -- top|middle|bottom_left|right
  gap_x = 97,
  <#if device == "desktop"><#assign yOffset = 569><#else><#assign yOffset = 227></#if>
  gap_y = [=yOffset],

  -- window settings
  <#assign width = 6+(15+8)*6+6-1>
  minimum_width = [=width],      -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = 120,
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
  -- colors
  default_color = '[=colors.secondary.text]',  -- regular text
  color1 = '[=colors.secondary.labels]',
  
  -- templates
  -- top cpu process: ${template0 processNumber}
  template0 = [[${voffset 3}${offset 6}${color}${top name \1}${top cpu \1}%]],
  -- top mem process: ${template1 processNumber}
  template1 = [[${voffset 3}${offset 6}${color}${top_mem name \1}${alignr 5}${top_mem mem_res \1}]]
};

conky.text = [[
# :::::::::::: cpu
<#assign y = 0,
         height = 3+16*3+3>
${if_match ${cpu cpu0} >= [=threshold.cpu - 3]}\
<@panel.panel x=0 y=y height=height width=width color=image.secondaryColor/>
<#assign y = height + 12>
${voffset 1}\
<#list 1..3 as x>
${template0 [=x]}
</#list>
${else}\
${voffset 49}\
${endif}\
# :::::::::::: memory
# unable to use ${memperc} or ${mem} due to bug where the value flickers due to the use of top mem variables
<#-- original code ${memperc} >= [=threshold.mem - 3] -->
${if_match ${to_bytes ${cached}} <= 320000000}\
<@panel.panel x=0 y=y height=height width=width color=image.secondaryColor/>
${voffset 18}\
<#list 1..3 as x>
${template1 [=x]}
</#list>
${endif}\
]];
