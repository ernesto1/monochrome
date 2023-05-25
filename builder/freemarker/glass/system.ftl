<#import "/lib/menu-square.ftl" as menu>
<#-- the system conky is substantially different between the 'desktop' and 'laptop' editions
     the laptop version was designed to occupy a smaller footprint (width x height) than its desktop counterpart

      desktop             laptop
      ----------          -------
      o/s
      top cpu             top cpu
      top mem             top mem
                          wifi
      bittorrent
      packages            packages (just the package update count)

     hence the pletora of conditional statements in this config -->
conky.config = {
  lua_load = '~/conky/monochrome/common.lua',

  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',     -- top|middle|bottom_left|middle|right
  gap_x = 125,                    -- same as passing -x at command line
  gap_y = 42,

  -- window settings
  <#if system == "desktop"><#assign windowWidth = 219><#else><#assign windowWidth = 159></#if>
  minimum_width = [=windowWidth],
  maximum_width = [=windowWidth],
  minimum_height = 245,
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

  imlib_cache_flush_interval = 250,
  <#if system == "desktop">
  top_name_verbose = true,    -- show full command in ${top ...}
  top_name_width = 20,        -- how many characters to print
  </#if>

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  
  -- colors
  default_color = '[=colors.systemText]',  -- regular text
  color1 = '[=colors.systemLabels]',         -- text labels
  color2 = '[=colors.highlight]',         -- highlight important packages
  
  -- templates
  -- top cpu process
  template0 = [[${voffset 3}${offset 5}${color}${top name \1}${alignr 5}${top cpu \1}%<#if system == "desktop"> ${top pid \1}</#if>]],
  -- top mem process
  template1 = [[${voffset 3}${offset 5}${color}${top_mem name \1}${alignr 5}${top_mem mem_res \1}<#if system == "desktop"> ${top_mem pid \1}</#if>]],
  -- torrent peer ip/port: ${template3 #}
  template2 = [[${voffset 3}${offset 5}${color}${tcp_portmon 51413 51413 rip \1}${alignr 64}${tcp_portmon 51413 51413 rport \1}]]
};

conky.text = [[
<#assign y = 0,
         header = 19>   <#-- table header height -->
<#if system == "desktop"><#assign space = 5><#else><#assign space = 3></#if><#-- empty space between windows -->
<#if system == "desktop">
# ::::::::::::::::: system :::::::::::::::::
<#assign body = 53>
<@menu.verticaltable theme=conky x=0 y=y header=69 body=150 height=body/>
<#assign y += body + space>
${voffset 3}${offset 29}${color1}kernel${goto 74}${color}${kernel}
${voffset 3}${offset 29}${color1}uptime${goto 74}${color}${uptime}
${voffset 3}${offset 5}${color1}compositor${goto 74}${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset [=5 + space]}\
</#if>
# ::::::::::::::::: top cpu :::::::::::::::::
<#if system == "desktop"><#assign processes = 8><#else><#assign processes = 6></#if>
<#assign body = 5 + 16 * processes>
<@menu.table theme=conky x=0 y=y width=windowWidth header=header body=body/>
<#assign y += header + body + space>
${voffset 2}${offset 5}${color1}process${alignr 5}cpu<#if system == "desktop">   pid</#if>${voffset 4}
<#list 1..processes as i>
${template0 [=i]}
</#list>
# ::::::::::::::::: top memory :::::::::::::::::
<#assign body = 5 + 16 * processes>
<@menu.table theme=conky x=0 y=y width=windowWidth header=header body=body/>
<#assign y += header + body + space>
${voffset [=7 + space]}${offset 5}${color1}process${alignr 5}mem<#if system == "desktop">   pid</#if>${voffset 4}
<#list 1..processes as i>
${template1 [=i]}
</#list>
<#if system == "laptop">
# ::::::::::::::::: wifi network :::::::::::::::::
<#-- TODO only show network details when wifi is online -->
<#assign body = 38>
<@menu.verticaltable theme=conky x=0 y=y header=57 body=103 height=body/>
<#assign y += body + 2>
${voffset [=8 + space]}${offset 5}${color1}network${goto 62}${color}${lua_parse truncate_string ${wireless_essid [=networkDevices[system]?first.name]} 15}
${voffset 3}${offset 5}${color1}local ip${goto 62}${color}${addr [=networkDevices[system]?first.name]}
</#if>
<#if system == "desktop">
# ::::::::::::::::: bittorrent & zoom :::::::::::::::::
<#assign body = 53>
<@menu.verticaltable theme=conky x=0 y=y header=69 body=91 height=body/>
<#assign y += body + 2><#-- a 2px mini gap between this table and the next -->
${voffset [=8 + space]}${offset 41}${color1}zoom${goto 74}${color}${if_running zoom}running${else}off${endif}
${voffset 3}${offset 5}${color1}bittorrent${goto 74}${color}${tcp_portmon 51413 51413 count} peer(s)
${voffset 3}${offset 22}${color1}seeding${goto 74}${color}${exec lsof -c transmission -n | grep -v deleted | grep -cE '[0-9]+[a-z|A-Z] +REG +[0-9]+,[0-9]+ +[0-9]{6,}'} file(s)
# :::::::: bittorrent connection peers :::::::::::::::::
${if_running transmission-gt}\
<#assign body = 166>
<@menu.table theme=conky x=0 y=y width=160 header=header body=body/>
<#assign y += header + body + space>
${voffset 9}${offset 5}${color1}ip address${alignr 64}remote port${voffset 5}
${if_match ${tcp_portmon 51413 51413 count} > 0}\
<#list 0..9 as x>
${template2 [=x]}
</#list>
${voffset 5}\
${else}\
${voffset 66}${offset 23}${color}no peer connections
${voffset 3}${offset 47}established${voffset 70}
${endif}\
${else}\
${voffset 192}\
${endif}\
</#if>
# ::::::::::::::::: package updates :::::::::::::::::
${if_existing /tmp/conky/dnf.packages.formatted}\
<#if system == "desktop">
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-solid.png -p 0,[=y?c]}\
<#assign body = 38, y += body>
<#list 1..2 as x>
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-transparent.png -p 0,[=y?c]}\
<#assign body = 800, y += body>
</#list>
${voffset [=3 + space]}${alignc}${color1}dnf package management
${voffset 3}${alignc}${color}${lines /tmp/conky/dnf.packages.formatted} package update(s) available
${voffset 8}${offset 5}${color1}package${alignr 5}version
# the dnf package lookup script refreshes the package list every 10m
<#assign lines = 47>
${voffset 2}${color}${execpi 30 head -n [=lines] /tmp/conky/dnf.packages.formatted}${voffset 5}
<#else>
<#assign body = 20>
<@menu.verticaltable theme=conky x=0 y=y header=57 body=103 height=body/>
${voffset [=6 + space]}${offset 5}${color1}dnf${goto 62}${color}${lines /tmp/conky/dnf.packages.formatted} update(s)${voffset 4}
</#if>
${endif}\
]];
