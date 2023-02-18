conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for eveoryone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 800,                -- same as passing -x at command line
  gap_y = 4,

  -- window settings
  minimum_width = 296,
  minimum_height = 132,
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
  -- use the parameter -n on ${image ..} to never cache and always update the image upon a change

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  
  -- colors
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]',        -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]',        -- bar critical
};

conky.text = [[
${if_match ${memperc} < [=threshold.mem]}\
${image ~/conky/monochrome/images/widgets/[=image.primaryColor]-memory.png -p 0,0}\
${else}\
${image ~/conky/monochrome/images/widgets/[=image.primaryColor]-memory-high.png -p 0,0}\
${endif}\
${voffset 0}${color}${offset 15}${memgraph 78, 42 [=colors.writeGraph]}
${voffset 7}${goto 84}${color1}mem${goto 117}${color}${memperc}%${goto 149}${mem} / ${memmax}
${voffset 4}${goto 84}${color1}swap${goto 117}${color}${swapperc}%${goto 149}${color2}${if_match ${swapperc} >= 70}${color3}${endif}${swapbar 3, 100}
]];
