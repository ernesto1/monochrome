conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',
  gap_x = 4,         -- gap between border of the screen and the conky window, same as passing -x at command line
  gap_y = 0,

  -- window settings
  minimum_width = 200,
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
# :::::::::::: package updates
${if_existing /tmp/dnf.packages.preview}\
${image ~/conky/monochrome/images/widgets/green-packages.png -p 0,0}\
${voffset 3}${alignc}${color1}dnf package management
${voffset 5}${alignc}${color}${lines /tmp/dnf.packages.preview} package update(s) available
${voffset 5}${offset 5}${color1}package${alignr 4}version
# the dnf package lookup script refreshes the package list every 10m
${voffset 1}${color}${execpi 30 head -n 100 /tmp/dnf.packages.preview}${voffset 4}
${endif}\
]];
