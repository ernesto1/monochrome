conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',    -- top|middle|bottom_left|middle|right
  gap_x = 0,                 -- same as passing -x at command line
  gap_y = -16,

  -- window settings
  minimum_width = 150,
  minimum_height = 1380,
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
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels

  -- graph settings
  draw_graph_borders = false, -- borders around the graph, ex. cpu graph, network down speed grah
                              -- does not include bars, ie. wifi strength bar, cpu bar

  imlib_cache_flush_interval = 250,
  -- use the parameter -n on ${image ..} to never cache and always update the image upon a change
  
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address
  -- font settings
  use_xft = true,
  xftalpha = 0,
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  font = 'Nimbus Mono PS Regular:size=8',     -- text
  font0 = 'font URW Gothic Demi:size=8',      -- title
  font1 = 'font URW Gothic Demi:size=19',     -- big value
  font2 = 'font URW Gothic Demi:size=12',     -- mid value
  font3 = 'font URW Gothic Demi:size=9',      -- small value
  
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',        -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]',        -- bar critical
  
  -- :::::::::::::::::::::::::::::::: templates ::::::::::::::::::::::::::::::::
  --  n.b. the line break escape character '\' is not supported in templates :(

  -- cpu/mem/download/disk write graph color
  template1 = [[[=colors.writeGraph]]],
  -- upload/disk read graph
  template2 = [[[=colors.readGraph]]],  

  -- network device bandwith: ${template4 deviceName maxUpSpeed maxDownSpeed}
  template4 = [[
# upload
${voffset -4}${offset 5}${upspeedgraph \1 48,112 ${template2} \2}
${voffset -54}${offset 10}${color1}${font0}upload${font}
${voffset 1}${alignr 38}${color}${font2}${upspeed \1}${font}
${voffset 8}${alignr 38}${color}${font}${totalup \1} total
# download
${voffset -1}${offset 5}${downspeedgraph \1 48,112 ${template1} \3}
${voffset -54}${offset 10}${color1}${font0}download${font}
${voffset 1}${alignr 38}${color}${font2}${downspeed \1}${font}
${voffset 8}${alignr 38}${color}${font}${totaldown \1} total${font}${voffset 3}]],
  
  -- hard disk: ${template5 device readSpeed writeSpeed}
  template5 = [[
# disk read
${voffset -4}${offset 5}${diskiograph_read /dev/\1 48,112 ${template2} \2}
${voffset -56}${offset 10}${color1}${font0}disk read${alignr 38}${color}\1${font}
${voffset 3}${alignr 38}${color}${font2}${diskio_read /dev/\1}${font}
# disk write
${voffset -1}${offset 5}${diskiograph_write /dev/\1 48,112 ${template1} \3}
${voffset -56}${offset 10}${color1}${font0}disk write${font}
${voffset 3}${alignr 38}${color}${font2}${diskio_write /dev/\1}${font}${voffset 6}]],

  -- filesystem: ${template6 filesystemName fileSystemPath}
  template6 = [[
${voffset 3}${offset 10}${color1}${font0}\1${font}
${voffset -14}${alignr 38}${color}${font2}${fs_used_perc \2}${font3}%${font}
${voffset -2}${offset 19}${color2}${if_match ${fs_used_perc \2} > 90}${color3}${endif}${fs_bar 3,94 \2}
${voffset -4}${alignr 38}${color}${font}${fs_used \2} / ${fs_size \2}${voffset 3}]],

  -- filesystem usb device: ${template7 filesystemName fileSystemPath}
  template7 = [[
${voffset 7}${offset 10}${color1}${font0}\1
${if_mounted \2}${voffset -13}${alignr 38}${font2}${fs_used_perc \2}${font3}%
${voffset -2}${offset 13}${color2}${if_match ${fs_used_perc \2} > 90}${color3}${endif}${fs_bar 3,94 \2}
${voffset -4}${alignr 38}${color}${font}${fs_used \2} / ${fs_size \2}${voffset -8}
${else}${voffset 4}${alignr 38}${color}${font}device is not
${alignr 38}${color}connected${voffset 4}${endif}]],

  -- hwmon entry: ${template9 index/device type index threshold}
  template8 = [[${if_match ${hwmon \1 \2 \3} > \4}${color3}${else}${color}${endif}${hwmon \1 \2 \3}]]
};

conky.text = [[
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-sidebar<#if system == "laptop">-laptop</#if>.png -p 0,0}\
