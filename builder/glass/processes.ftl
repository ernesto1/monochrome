conky.config = {
  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',     -- top|middle|bottom_left|middle|right
  gap_x = 142,                    -- same as passing -x at command line
  gap_y = 606,

  -- window settings
  minimum_width = 465,
  minimum_height = 144,
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
  
  top_name_verbose = true,    -- show full command in ${top ...}
  top_name_width = 21,        -- how many characters to print

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  
  -- colors
  default_color = '[=colors.systemText]',  -- regular text
  color1 = '[=colors.systemLabels]',         -- text labels
  
  -- template
  template0 = [[
${voffset 3}${offset 5}${color}${top name \1}${offset 3}${top cpu \1}% ${top pid \1}${offset 21}${top_mem name \1}${alignr 5}${top_mem mem_res \1} ${top_mem pid \1}]]
};

conky.text = [[
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-processes.png -p 0,0}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-processes.png -p 233,0}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-processes.png -p 250,0}\
${voffset 2}${offset 5}${color1}process${goto 164}cpu   pid${offset 21}${color1}process${alignr 5}mem   pid${voffset 3}
<#list 1..7 as x>
${template0 [=x]}
</#list>
]];
