conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 1119,               -- same as passing -x at command line
  gap_y = 10,

  -- window settings
  minimum_width = 209,
  minimum_height = 188,
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
  border_width = 1,         -- width of border window in pixels
  stippled_borders = 0,     -- border stippling (dashing) in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels

  -- graph settings
  draw_graph_borders = false, -- borders around the graph, ex. cpu graph, network down speed grah
                              -- does not include bars, ie. wifi strength bar, cpu bar

  imlib_cache_flush_interval = 250,

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  
  -- colors
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]',        -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]',        -- bar critical
};

conky.text = [[
${if_up enp0s25}\
${image ~/conky/monochrome/images/widgets/green-internet.png -p 0,0}\
${voffset 3}${offset 11}${color1}local ip${goto 77}${color}${addr enp0s25}
${voffset 3}${offset 11}${color1}bittorrent${goto 77}${color}${tcp_portmon 51413 51413 count} peer(s)
${voffset 3}${offset 11}${color1}zoom${goto 77}${color}${if_running zoom}running${else}off${endif}
${voffset 6}${offset 68}${upspeedgraph enp0s25 37,97 [=colors.readGraph] 3000}
${voffset -7}${offset 68}${downspeedgraph enp0s25 37,97 [=colors.writeGraph] 55000}
${voffset 6}${offset 7}${color1}up${alignr 93}${color}${upspeed enp0s25} ${color1}total
${voffset 4}${offset 7}${color1}down${alignr 93}${color}${downspeed enp0s25} ${color1}total
${voffset -30}${alignr 43}${color}${totalup enp0s25}
${voffset 4}${alignr 43}${color}${totaldown enp0s25}
# we need to remove the trailing spacing added the moment we voffset'ed the upload graph 
${voffset -20}
${else}\
${image ~/conky/monochrome/images/widgets/orange-ethernet-offline.png -p 20,54}
${endif}\
]];
