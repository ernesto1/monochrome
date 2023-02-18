conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',
  gap_x = 240,         -- gap between border of the screen and the conky window, same as passing -x at command line
  gap_y = 56,

  -- window settings
  minimum_width = 209,
  own_window = true,
  own_window_type = 'desktop',              -- values: desktop (background), panel (bar)
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
  
  -- :::::::: templates
  -- hwmon entry: index/device type index threshold
  template1 = [[${if_match ${hwmon \1 \2 \3} > \4}${color3}${else}${color}${endif}${hwmon \1 \2 \3}]]
};

conky.text = [[
${image ~/conky/monochrome/images/widgets/green-system.png -p 0,0}\
${voffset 3}${offset 5}${color1}kernel${goto 76}${color}${kernel}
${voffset 3}${offset 5}${color1}uptime${goto 76}${color}${uptime}
${voffset 3}${offset 5}${color1}compositor${goto 76}${color}${execi 3600 echo $XDG_SESSION_TYPE}
# :::::::::::: temperatures
${voffset 11}${offset 5}${color1}device${alignr 4}temperature
${voffset 8}${offset 5}${color}AMD Radeon HD7570${alignr 4}${template1 radeon temp 1 75}°C
# :::::::::::: fans
${voffset 11}${offset 5}${color1}fan${alignr 4}revolutions
${voffset 8}${offset 5}${color}chasis front intake${alignr 4}${template1 atk0110 fan 3 2400} rpm
${voffset 3}${offset 5}${color}cpu fan${alignr 4}${template1 atk0110 fan 1 2500} rpm
${voffset 3}${offset 5}${color}case top exhaust fan${alignr 4}${template1 atk0110 fan 2 2500} rpm
${voffset 3}${offset 5}${color}case back exhaust fan${alignr 4}${template1 atk0110 fan 4 2500} rpm${voffset 4}
]];
