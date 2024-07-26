conky.config = {
  lua_load = '~/conky/monochrome/common.lua',

  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 1,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',     -- top|middle|bottom_left|middle|right
  gap_x = 0,                     -- same as passing -x at command line
  <#if system == "desktop"><#assign yOffset = 0><#else><#assign yOffset = -15></#if>
  gap_y = [=yOffset],

  -- window settings
  minimum_width = 146,
  minimum_height = 632,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)

  -- transparency configuration
  draw_blended = false,
  own_window_transparent = true,
  own_window_argb_visual = true,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 0,         -- width of border window in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels

  -- graph settings
  draw_graph_borders = false, -- borders around the graph, ex. cpu graph, network down speed grah
                              -- does not include bars, ie. wifi strength bar, cpu bar

  imlib_cache_flush_interval = 250,  
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address
  -- font settings
  use_xft = true,
  xftalpha = 1,
  uppercase = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)

  font = 'URW Gothic:size=9',    -- default: small
  font0 = 'URW Gothic:size=12',  -- medium
  font1 = 'URW Gothic:size=23',  -- big
  font2 = 'Promenade de la Croisette:size=40',   -- device temperature reading

  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',         -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]',        -- bar critical
  color4 = '[=colors.widgetText]',        -- temperature text
  
  -- :::::::::::::::::::::::::::::::: templates ::::::::::::::::::::::::::::::::
  --  n.b. the line break escape character '\' is not supported in templates :(
  
  -- cpu/mem/download/disk write graph color
  template1 = [[[=colors.writeGraph]]],
  -- upload/disk read graph
  template2 = [[[=colors.readGraph]]],

  -- network bandwith: ${template4 device uploadSpeed downloadSpeed}
  template4 = [[
${voffset 12}${offset 5}${upspeedgraph \1 29,47 ${template2} \2}
${voffset -8}${offset 5}${downspeedgraph \1 29,47 ${template1} \3}
${voffset -56}${goto 67}${color}${font}${upspeed \1}
${voffset 21}${goto 67}${color}${font}${downspeed \1}${voffset 3}]],

  -- hard disk io: ${template5 device readSpeed writeSpeed}
  template5 = [[
${voffset 11}${offset 5}${color}${diskiograph_read /dev/\1 21,47 ${template2} \2}
${voffset -8}${offset 5}${diskiograph_write /dev/\1 21,47 ${template1} \3}
${voffset -48}${goto 67}${color}${font}${diskio_read /dev/\1}
${voffset 13}${goto 67}${color}${font}${diskio_write /dev/\1}${voffset 2}]],

  -- filesystem: ${template6 filesystemName fileSystemPath}
  template6 = [[
${voffset 52}${offset 6}${color2}${if_match ${fs_used_perc \2} > 90}${color3}${endif}${fs_bar 3, 45 \2}
${voffset -46}${goto 67}${color}${font}\1
${voffset 4}${goto 67}${color}${font1}${fs_used_perc \2}${font0}%${font}${voffset 1}]],

<#if system == "laptop" >
  -- color coded hwmon entry: index/device type index threshold
  template7 = [[${if_match ${hwmon \1 \2 \3} > \4}${color3}${else}${color4}${endif}${hwmon \1 \2 \3}]], 
    
  -- temperature: ${template8 index/device type index threshold}
  template8 = [[${voffset 7}${offset 12}${font2}${template7 \1 \2 \3 \4}${voffset -28}${font0}°${offset 4}${voffset -4}${font2}C${font}${color}${voffset 9}]]
</#if>
};

conky.text = [[
