conky.config = {
  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',       -- top|middle|bottom_left|middle|right
  gap_x = 0,                    -- same as passing -x at command line
  gap_y = -32,

  -- window settings
  minimum_width = 241,
  minimum_height = 1193,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)
  own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',

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

  imlib_cache_flush_interval = 300,
  -- use the parameter -n on ${image ..} to never cache and always update the image upon a change
  
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',         -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=(colors.warning)?c]',        -- bar critical
  
  -- ::::::::::::::::::::::::::::::: templates ::::::::::::::::::::::::::::::::
  --  n.b. the line break escape character '\' is not supported in templates :(

  -- cpu/mem/download/disk write graph color
  template1 = [[[=colors.writeGraph]]],
  -- upload/disk read graph
  template2 = [[[=colors.readGraph]]],
  
  -- ethernet speed: ${template3 ethernetDevice}
  template3 = [[${execi 180 ethtool \1 2>/dev/null | grep -i speed | cut -d ' ' -f 2}]],
    
    -- network bandwith: ${template4 device uploadSpeed downloadSpeed}
  template4 = [[${voffset 7}${offset 43}${color}${upspeedgraph \1 35,68 ${template2} \2}${offset 3}${downspeedgraph \1 35,68 ${template1} \3}
${voffset -2}${offset 5}${color1}up    ${color}${upspeed \1}${alignr 59}${color}${downspeed \1}  ${color1}down
${voffset 3}${offset 5}${color1}total ${color}${totalup \1}${alignr 59}${color}${totaldown \1} ${color1}total
${voffset 8}${offset 5}${color1}bittorrent ${color}${tcp_portmon 51413 51413 count} peer(s)
${voffset 3}${offset 5}${color1}zoom  ${color}${if_running zoom}running${else}off${endif}]],

  -- hard disk: ${template5 device readSpeed writeSpeed}
  template5 = [[${voffset 7}${offset 43}${color}${diskiograph_read /dev/\1 35,68 ${template2} \2}${offset 3}${diskiograph_write /dev/\1 35,68 ${template1} \3}
${voffset -2}${offset 5}${color1}read  ${color}${diskio_read /dev/\1}${alignr 59}${color}${diskio_write /dev/\1} ${color1}write]],

  -- filesystem: ${template6 filesystemName fileSystemPath}
  template6 = [[${voffset 2}${offset 5}${color}\1${alignr 59}${voffset 1}${color2}${if_match ${fs_used_perc \2} > 90}${color3}${endif}${fs_bar 3,97 \2}
${voffset 2}${alignr 59}${color}${fs_used \2} / ${fs_size \2}]],

  -- top cpu process: ${template7 processNumber}
  template7 = [[${voffset 3}${color}${offset 5}${top name \1}${alignr 59}${top cpu \1}% ${top pid \1}]],
  
  -- top mem process: ${template8 processNumber}
  template8 = [[${voffset 3}${color}${offset 5}${top_mem name \1}${alignr 59}${top_mem mem_res \1} ${top_mem pid \1}]],

  -- hwmon entry: ${template9 index/device type index threshold}
  template9 = [[${if_match ${hwmon \1 \2 \3} > \4}${color3}${else}${color}${endif}${hwmon \1 \2 \3}]]
};

conky.text = [[
