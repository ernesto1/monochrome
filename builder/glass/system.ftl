conky.config = {
  lua_load = '~/conky/monochrome/musicPlayer.lua',

  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',     -- top|middle|bottom_left|middle|right
  gap_x = 125,                    -- same as passing -x at command line
  gap_y = 42,

  -- window settings
  minimum_width = 219,
  maximum_width = 219,
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

  imlib_cache_flush_interval = 2,
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
  template0 = [[${voffset 3}${offset 5}${color}${top name \1}${top cpu \1}% ${top pid \1}]],
  -- top mem process
  template1 = [[${voffset 3}${offset 5}${color}${top_mem name \1}${alignr 5}${top_mem mem_res \1} ${top_mem pid \1}]],
  -- torrent peer ip/port: ${template3 #}
  template2 = [[${voffset 3}${offset 5}${color}${tcp_portmon 51413 51413 rip \1}${alignr 64}${tcp_portmon 51413 51413 rport \1}]]
};

conky.text = [[
<#assign y = 0,
         top = 19,   <#-- table header height -->
         space = 5>  <#-- empty space between windows -->
<#if system == "desktop">
# ::::::::::::::::: system
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-solid.png -p 0,[=y?c]}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-transparent.png -p 69,[=y?c]}\
<#assign body = 55, y += body><#-- size of the menu's data section -->
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
<#assign y += space>
${voffset 4}${offset 29}${color1}kernel${goto 74}${color}${kernel}
${voffset 3}${offset 29}${color1}uptime${goto 74}${color}${uptime}
${voffset 3}${offset 5}${color1}compositor${goto 74}${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset 11}\
</#if>
# ::::::::::::::::: top cpu
<#if system == "desktop"><#assign processes = 8><#else><#assign processes = 6></#if>
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-solid.png -p 0,[=y?c]}\
<#assign y+= top>
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-transparent.png -p 0,[=y?c]}\
<#assign body = 5 + 16 * processes, y+= body>
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
<#assign y += space>
${voffset 3}${offset 5}${color1}process${goto 161}cpu   pid${voffset 3}
<#list 1..processes as x>
${template0 [=x]}
</#list>
# ::::::::::::::::: top memory
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-solid.png -p 0,[=y?c]}\
<#assign y+= top>
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-transparent.png -p 0,[=y?c]}\
<#assign body = 5 + 16 * processes, y+= body>
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
<#assign y += space>
${voffset 13}${offset 5}${color1}process${alignr 5}mem   pid${voffset 3}
<#list 1..processes as x>
${template1 [=x]}
</#list>
<#if system == "laptop">
# ::::::::::::::::: wifi network
<#-- TODO only show network details when wifi is online -->
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-solid.png -p 0,[=y?c]}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-transparent.png -p 60,[=y?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p 160,[=y?c]}\
<#assign body = 38, y+= body>
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
${voffset 13}${offset 5}${color1}network${goto 65}${color}${lua_parse truncate_string ${wireless_essid [=networkDevices[system]?first.name]} 15}
${voffset 3}${offset 5}${color1}local ip${goto 65}${color}${addr [=networkDevices[system]?first.name]}
</#if>
<#if system == "desktop">
# ::::::::::::::::: internet applications
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-solid.png -p 0,[=y?c]}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-transparent.png -p 69,[=y?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p 160,[=y?c]}\
<#assign body = 54, y+= body>
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
<#assign y+= 2><#-- a 2px mini gap between these two tables -->
${voffset 13}${offset 41}${color1}zoom${goto 74}${color}${if_running zoom}running${else}off${endif}
${voffset 3}${offset 5}${color1}bittorrent${goto 74}${color}${tcp_portmon 51413 51413 count} peer(s)
${voffset 3}${offset 22}${color1}seeding${goto 74}${color}${exec lsof -c transmission -n | grep -v deleted | grep -cE '[0-9]+[a-z|A-Z] +REG +[0-9]+,[0-9]+ +[0-9]{6,}'} file(s)
# :::::::: bittorrent connections
${if_running transmission-gt}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-solid.png -p 0,[=y?c]}\
<#assign y+= top>
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-transparent.png -p 0,[=y?c]}\
${image ~/conky/monochrome/images/menu-blank.png -p 160,[=(y - top)?c]}\
<#assign body = 165, y+= body>
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
<#assign y += space>
${voffset 11}${offset 5}${color1}ip address${alignr 64}remote port${voffset 3}
${if_match ${tcp_portmon 51413 51413 count} > 0}\
<#list 0..9 as x>
${template2 [=x]}
</#list>
${else}\
${voffset 66}${offset 23}${color}no peer connections
${voffset 3}${offset 47}established${voffset 65}
${endif}\
${else}\
${voffset 187}\
${endif}\
# ::::::::::::::::: package updates
${if_existing /tmp/conky/dnf.packages.formatted}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-solid.png -p 0,[=y?c]}\
<#assign body = 38, y += body>
<#list 1..2 as x>
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-transparent.png -p 0,[=y?c]}\
<#assign body = 800, y += body>
</#list>
${voffset 14}${alignc}${color1}dnf package management
${voffset 3}${alignc}${color}${lines /tmp/conky/dnf.packages.formatted} package update(s) available
${voffset 5}${offset 5}${color1}package${alignr 5}version
# the dnf package lookup script refreshes the package list every 10m
<#if system == "desktop"><#assign lines = 47><#else><#assign lines = 28></#if>
${voffset 2}${color}${execpi 30 head -n [=lines] /tmp/conky/dnf.packages.formatted}
${endif}\
${voffset -8}
</#if>
]];
