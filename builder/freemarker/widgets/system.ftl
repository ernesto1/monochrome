<#import "/lib/panel-square.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',
  gap_x = 88,         -- gap between border of the screen and the conky window, same as passing -x at command line
  gap_y = 5,

  -- window settings
  minimum_width = 367,
  minimum_height = 131,
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
# :::::::::::: o/s
<#assign y = 0,
         header = 69,
         width = 180 - header
         height = 53,
         gap = 5>     <#-- empty space between windows -->
<@panel.verticalTable x=0 y=y header=header body=width height=height/>
<#assign y += height + gap>
${voffset 3}${offset 5}${color1}kernel${goto 75}${color}${lua truncate_string ${kernel} 17}
${voffset 3}${offset 5}${color1}uptime${goto 75}${color}${uptime}
${voffset 3}${offset 5}${color1}compositor${goto 75}${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset [= 7 + gap]}\
# :::::::::::: applications
<@panel.verticalTable x=0 y=y header=header body=52 height=19/>
${offset 5}${color1}zoom${goto 75}${color}${if_running zoom}running${else}off${endif}
<#assign x = header + width + gap,
         y = 0,
         header = 19,
         width = 183,
         body = 70>
# :::::::::::: fans
<@panel.table x=x y=0 widths=[width] header=header body=body/>
<#assign y += header + body + gap>
${voffset -71}${goto [=x+6]}${color1}fan${alignr 4}revolutions${voffset 5}
${voffset 3}${goto [=x+6]}${color}chasis front intake${alignr 4}${template1 atk0110 fan 3 2400} rpm
${voffset 3}${goto [=x+6]}${color}cpu fan${alignr 4}${template1 atk0110 fan 1 2500} rpm
${voffset 3}${goto [=x+6]}${color}case top exhaust${alignr 4}${template1 atk0110 fan 2 2500} rpm
${voffset 3}${goto [=x+6]}${color}case back exhaust${alignr 4}${template1 atk0110 fan 4 2500} rpm
${voffset [= 7 + gap]}\
# :::::::::::: temperatures
<#assign body = 20>
<@panel.table x=x y=y widths=[width] header=header body=body/>
${goto [=x+6]}${color1}device${alignr 4}temperature
${voffset 6}${goto [=x+6]}${color}AMD Radeon HD7570${alignr}${template1 radeon temp 1 75}°C
]];
