conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 794,                -- same as passing -x at command line
  gap_y = 5,

  -- window settings
  minimum_width = 310,
  minimum_height = 151,
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
<#assign voffset = 20><#-- offset to account for border added by the background image -->
${voffset [=voffset]]}${color}${offset 29}${memgraph 78, 42 [=colors.writeGraph]}
${voffset 7}${goto 98}${color1}mem${goto 131}${color}${memperc}%${goto 163}${mem} / ${memmax}
${voffset 4}${goto 98}${color1}swap${goto 131}${color}${swapperc}%${goto 163}${color2}${if_match ${swapperc} >= 70}${color3}${endif}${swapbar 3, 100}
]];
