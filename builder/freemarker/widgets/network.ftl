conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 1104,               -- same as passing -x at command line
  gap_y = 3,

  -- window settings
  minimum_width = 220,
  maximum_width = 220,
  minimum_height = 188,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)

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
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  
  -- colors
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]',        -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]',        -- bar critical
};

conky.text = [[
<#assign device = networkDevices?first>
${if_up [=device.name]}\
${image ~/conky/monochrome/images/widgets/[=image.primaryColor]-network.png -p 0,0}\
${voffset 3}${offset 22}${color1}local ip${goto 80}${color}${addr [=device.name]}
${voffset 3}${offset 22}${color1}torrents${goto 80}${color}${lines /tmp/conky/transmission.active} active
${voffset 3}${offset 22}${color1}swarm${goto 80}${color}${lines /tmp/conky/transmission.peers} peers
${voffset 6}${offset 79}${upspeedgraph [=device.name] 37,97 [=colors.readGraph] [=device.maxUp?c]}
${voffset -7}${offset 79}${downspeedgraph [=device.name] 37,97 [=colors.writeGraph] [=device.maxDown?c]}
${voffset 6}${offset 18}${color1}up${alignr 128}${color}${upspeed [=device.name]}
${voffset 4}${offset 18}${color1}down${alignr 128}${color}${downspeed [=device.name]}
${voffset -30}${goto 101}${color1}total${alignr 43}${color}${totalup [=device.name]}
${voffset 4}${goto 101}${color1}total${alignr 43}${color}${totaldown [=device.name]}
# we need to remove the trailing spacing added the moment we voffset'ed the upload graph 
${voffset -20}
${else}\
${image ~/conky/monochrome/images/widgets/[=image.secondaryColor]-ethernet-offline.png -p 11,30}
${endif}\
]];
