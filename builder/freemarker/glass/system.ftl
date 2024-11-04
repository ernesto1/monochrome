<#import "/lib/panel-round.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua',
  lua_draw_hook_pre = 'reset_state',

  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- number of times conky will update before quitting, set to 0 to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',     -- top|middle|bottom_left|middle|right
  gap_x = 139,                -- same as passing -x at command line
  gap_y = 530,

  -- window settings
  <#assign width = 94>
  minimum_width = [=width],
  maximum_width = [=width],  
  minimum_height = 222,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)

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

  imlib_cache_flush_interval = 250,

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  
  -- colors
  default_color = '[=colors.systemText]',  -- regular text
  color1 = '[=colors.systemLabels]',         -- text labels
  color2 = '[=colors.bar]',        -- bar
};

conky.text = [[
<#assign y = 12>
# ::::::::::::::::: cpu
<@panel.panel x=0 y=y width=width height=57/>
<#assign y += 57 + 9 + 1>
${voffset [=12+2]}${offset 7}${color2}${cpubar cpu1 3,37}${offset 5}${cpubar cpu2 3,37}
${offset 7}${color2}${cpubar cpu3 3,37}${offset 5}${cpubar cpu4 3,37}
${offset 7}${color2}${cpubar cpu5 3,37}${offset 5}${cpubar cpu6 3,37}
${offset 7}${color2}${cpubar cpu7 3,37}${offset 5}${cpubar cpu8 3,37}
${voffset [=27-12]}\
# ::::::::::::::::: memory
${voffset 15}\
<#assign y += 15>
<@panel.panel x=0 y=y width=width height=87/>
${voffset 3}${offset 7}${color1}free${alignr 6}${color}${memfree}
${voffset 3}${offset 7}${color1}buff${alignr 6}${color}${buffers}
${voffset 3}${offset 7}${color1}cache${alignr 6}${color}${cached}
${voffset 3}${offset 7}${color1}si${alignr 6}${color}${cat /tmp/conky/system.swap.read}
${voffset 3}${offset 7}${color1}so${alignr 6}${color}${cat /tmp/conky/system.swap.write}
]];
