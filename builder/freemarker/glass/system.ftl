<#import "/lib/menu-square.ftl" as menu>
<#-- the system conky is substantially different between the 'desktop' and 'laptop' editions
     the laptop version was designed to occupy a smaller footprint (width x height) than its desktop counterpart

      desktop             laptop
      ----------          -------
      o/s
      top cpu             top cpu
      top mem             top mem
                          wifi

     hence the pletora of conditional statements in this config -->
conky.config = {
  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',     -- top|middle|bottom_left|middle|right
  gap_x = 121,                    -- same as passing -x at command line
  gap_y = 39,

  -- window settings
  <#if system == "desktop"><#assign windowWidth = 219><#else><#assign windowWidth = 159></#if>
  minimum_width = [=windowWidth],
  maximum_width = [=windowWidth],
  <#if system == "desktop"><#assign windowHeight=363><#else><#assign windowHeight=309></#if>
  minimum_height = [=windowHeight?c],
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
         header = 19, <#-- table header height -->
         gap = 3>     <#-- empty space between windows -->
<#if system == "desktop">
# ::::::::::::::::: system
<#assign body = 53>
<@menu.verticalTable x=0 y=y header=69 body=150 height=body/>
<#assign y += body + gap>
${voffset 3}${offset 29}${color1}kernel${goto 74}${color}${kernel}
${voffset 3}${offset 29}${color1}uptime${goto 74}${color}${uptime}
${voffset 3}${offset 5}${color1}compositor${goto 74}${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset [=5 + gap]}\
</#if>
# ::::::::::::::::: top cpu
<#if system == "desktop"><#assign processes = 8><#else><#assign processes = 6></#if>
<#assign body = 5 + 16 * processes>
<@menu.table x=0 y=y width=windowWidth header=header body=body/>
<#assign y += header + body + gap>
${voffset 2}${offset 5}${color1}process${alignr 5}cpu<#if system == "desktop">   pid</#if>${voffset 4}
<#list 1..processes as i>
${template0 [=i]}
</#list>
# ::::::::::::::::: top memory
<#assign body = 5 + 16 * processes>
<@menu.table x=0 y=y width=windowWidth header=header body=body/>
<#assign y += header + body + gap>
${voffset [=7 + gap]}${offset 5}${color1}process${alignr 5}mem<#if system == "desktop">   pid</#if>${voffset 4}
<#list 1..processes as i>
${template1 [=i]}
</#list>
<#if system == "laptop">
# ::::::::::::::::: wifi network
<#-- TODO only show network details when wifi is online -->
<#assign body = 39>
<@menu.verticalTable x=0 y=y header=57 body=103 height=body/>
<#assign y += body + 2>
${voffset [=10 + gap]}${offset 5}${color1}network${goto 62}${color}${wireless_essid [=networkDevices[system]?first.name]}
${voffset 3}${offset 5}${color1}local ip${goto 62}${color}${addr [=networkDevices[system]?first.name]}${voffset 5}<#-- since the next table is optional, add the voffset in order to display the table bottom border properly -->
# ::::::::::::::::: package updates
${if_existing /tmp/conky/dnf.packages.formatted}\
<#assign body = 22>
<@menu.verticalTable x=0 y=y header=57 body=103 height=body/>
${voffset [=3 + gap]}${offset 5}${color1}dnf${goto 62}${color}${lines /tmp/conky/dnf.packages.formatted} update(s)${voffset 4}
${endif}\
</#if>
]];
