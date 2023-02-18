conky.config = {
  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',     -- top|middle|bottom_left|middle|right
  gap_x = 125,                    -- same as passing -x at command line
  gap_y = 82,

  -- window settings
  minimum_width = 223,
  minimum_height = 520,
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
  color2 = '[=colors.highlight]',         -- highlight important packages
  
  -- templates
  -- top cpu process
  template0 = [[${voffset 3}${offset 5}${color}${top name \1}${offset 3}${top cpu \1}% ${top pid \1}]],
  -- top mem process
  template1 = [[${voffset 3}${offset 5}${color}${top_mem name \1}${alignr 5}${top_mem mem_res \1} ${top_mem pid \1}]],
  -- torrent peer ip/port: ${template3 #}
  template2 = [[${voffset 3}${offset 5}${color}${tcp_portmon 51413 51413 rip \1}${alignr 5}${tcp_portmon 51413 51413 rport \1}]]
};

conky.text = [[
# ::::::::::::::::: system
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-table-horizontal.png -p 0,0}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-table-horizontal.png -p 0,16}\
${voffset 4}${color1}${goto 30}kernel${goto 74}${color}${kernel}
${voffset 3}${goto 30}${color1}uptime${goto 74}${color}${uptime}
${voffset 3}${offset 5}${color1}compositor${goto 74}${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset 8}\
# ::::::::::::::::: top cpu
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-table.png -p 0,60}\
${voffset 6}${offset 5}${color1}process${goto 164}cpu   pid${voffset 3}
<#list 1..7 as x>
${template0 [=x]}
</#list>
# ::::::::::::::::: top memory
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-table.png -p 0,201}\
${voffset 13}${offset 5}${color1}process${alignr 5}mem   pid${voffset 3}
<#list 1..7 as x>
${template1 [=x]}
</#list>
${voffset -2}
# ::::::::::::::::: network
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-table-horizontal.png -p 0,342}\
<#if system == "laptop">
# if on wifi
<#-- TODO update layout for laptop, you will have to use a variable for the package update image height -->
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-table-horizontal.png -p 0,372}\
${voffset 3}${goto 24}${color1}network${goto 74}${color}${wireless_essid [=networkDevices[system]?first.name]}
${voffset 3}${color1}${goto 18}local ip${goto 74}${color}${addr [=networkDevices[system]?first.name]}
</#if>
${voffset 3}${color1}${goto 42}zoom${goto 74}${color}${if_running zoom}running${else}off${endif}
${voffset 3}${offset 5}${color1}bittorrent${goto 74}${color}${tcp_portmon 51413 51413 count} peer(s)
# :::: bittorrent connections
${if_running transmission-gt}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-table.png -p 0,383}\
${voffset 11}${offset 5}${color1}ip address${alignr 5}remote port${voffset 3}
${if_match ${tcp_portmon 51413 51413 count} > 0}\
<#list 0..6 as x>
${template2 [=x]}
</#list>
${else}\
${voffset 42}${alignc}${color}no peer connections
${voffset 3}${alignc}established${voffset 41}
${endif}\
${else}\
${voffset 138}\
${endif}\
# ::::::::::::::::: package updates
${if_existing /tmp/dnf.packages.preview}\
<#assign y = 524>
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu.png -p 0,[=y?c]}\
<#assign height = 38, y += height>
<#list 1..2 as x>
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-transparent.png -p 0,[=y?c]}\
<#assign height = 800, y += height>
</#list>
${voffset 14}${alignc}${color1}dnf package management
${voffset 3}${alignc}${color}${lines /tmp/dnf.packages.preview} package update(s) available
${voffset 5}${offset 5}${color1}package${alignr 9}version
# the dnf package lookup script refreshes the package list every 10m
<#if system == "desktop"><#assign lines = 57><#else><#assign lines = 28></#if>
${voffset 2}${color}${execpi 30 head -n [=lines] /tmp/dnf.packages.preview}
${endif}\
${voffset -8}
]];
