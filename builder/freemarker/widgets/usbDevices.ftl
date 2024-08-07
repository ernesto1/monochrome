conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 1998,               -- same as passing -x at command line
  gap_y = 141,

  -- window settings
  minimum_width = 150,
  minimum_height = 106,
  own_window = true,
  own_window_type = 'desktop',              -- values: desktop (background), panel (bar)

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
  color4 = '[=colors.offlineText]',         -- text for disconnected device
  
  -- :::::::::::::::: templates  
  -- usb memory device file system: ${template1 devicePath}
  template1 = [[${voffset 37}${offset 1}${color2}${if_match ${fs_used_perc \1} > 90}${color3}${endif}${fs_bar 3, 45 \1}
${offset 53}${voffset -47}${color1}fs type${goto 103}${color}${fs_type \1}
${offset 53}${voffset 3}${color1}size${goto 103}${color}${fs_size \1}
${offset 53}${voffset 3}${color1}free${goto 103}${color}${fs_free \1}${voffset 7}]],

  template2 = [[${voffset 12}\${alignr}${color4}\1  
${alignr}not connected  ${voffset 17}]]
};

conky.text = [[
# sandisk usb memory stick
${if_mounted /run/media/ernesto/sandisk}\
${image ~/conky/monochrome/images/widgets/[=image.primaryColor]-usb-slot-memory.png -p 0,0}\
${template1 /run/media/ernesto/sandisk}
${else}\
${image ~/conky/monochrome/images/widgets/[=image.secondaryColor]-usb-slot-disconnected.png -p 0,0}\
${template2 sandisk\ usb\ drive}
${endif}\
# sandisk sd card
${if_mounted /run/media/ernesto/disk}\
${image ~/conky/monochrome/images/widgets/[=image.primaryColor]-usb-slot-sdcard.png -p 0,55}\
${template1 /run/media/ernesto/disk}
${else}\
${image ~/conky/monochrome/images/widgets/[=image.secondaryColor]-usb-slot-disconnected.png -p 0,55}\
${template2 sandisk\ sd\ card}
${endif}\
${voffset -20}\
]];
