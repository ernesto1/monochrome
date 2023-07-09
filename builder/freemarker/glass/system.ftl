<#import "/lib/menu-square.ftl" as menu>
<#-- the system conky is substantially different between the 'desktop' and 'laptop' editions
     the laptop version was designed to occupy a smaller footprint (width x height) than its desktop counterpart

      desktop             laptop
      ----------          -------
      o/s
      top cpu             top cpu
      top mem             top mem
      zoom                wifi
                          dnf

     hence the pletora of conditional statements in this config -->
conky.config = {
  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',     -- top|middle|bottom_left|middle|right
  gap_x = 123,                    -- same as passing -x at command line
  gap_y = 39,

  -- window settings
  <#if system == "desktop"><#assign windowWidth = 246><#else><#assign windowWidth = 159></#if>
  minimum_width = [=windowWidth],
  maximum_width = [=windowWidth],
  <#if system == "desktop"><#assign windowHeight=397><#else><#assign windowHeight=309></#if>
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
  top_name_width = 24,        -- how many characters to print
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
  <#if system == "desktop">
  template0 = [[${voffset 3}${offset 5}${color}${top name \1}${offset 4}${top cpu \1}%${offset 10}${top pid \1}]],
  <#else>
  template0 = [[${voffset 3}${offset 5}${color}${top name \1}${alignr 5}${top cpu \1}%]],
  </#if>
  -- top mem process
  <#if system == "desktop">
  template1 = [[${voffset 3}${offset 5}${color}${top_mem name \1}${offset 10}${top_mem mem_res \1}${offset 10}${top_mem pid \1}]]
  <#else>
  template1 = [[${voffset 3}${offset 5}${color}${top_mem name \1}${alignr 5}${top_mem mem_res \1}]]
  </#if>
};

conky.text = [[
<#assign y = 0,
         header = 19, <#-- table header height -->
         gap = 3>     <#-- empty space between windows -->
<#if system == "desktop">
# ::::::::::::::::: system
<#assign height = 53> 
<@menu.verticalTable x=0 y=y header=69 body=136 height=height/>
<#assign y += height + gap>
${voffset 3}${offset 29}${color1}kernel${goto 74}${color}${kernel}
${voffset 3}${offset 29}${color1}uptime${goto 74}${color}${uptime}
${voffset 3}${offset 5}${color1}compositor${goto 74}${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset [=5 + gap]}\
</#if>
# ::::::::::::::::: top cpu
<#if system == "desktop"><#assign processes = 8, width = 159, smallCol = 45, colGap = 1>
<#else><#assign processes = 6, width = windowWidth></#if>
<#assign body = 5 + 16 * processes>
<@menu.table x=0 y=y width=width header=header body=body/>
<#if system == "desktop">
<@menu.table x=width+colGap y=y width=smallCol header=header body=body/>
<@menu.table x=width+colGap+smallCol+colGap y=y width=smallCol-6 header=header body=body/>
</#if>
<#assign y += header + body + gap>
<#if system == "desktop">
${voffset 2}${offset 5}${color1}process${goto 183}cpu${goto 223}pid${voffset 4}
<#else>
${voffset 2}${offset 5}${color1}process${alignr 5}cpu${voffset 4}
</#if>
<#list 1..processes as i>
${template0 [=i]}
</#list>
# ::::::::::::::::: top memory
<#assign body = 5 + 16 * processes>
<@menu.table x=0 y=y width=width header=header body=body/>
<#if system == "desktop">
<@menu.table x=width+colGap y=y width=smallCol header=header body=body/>
<@menu.table x=width+colGap+smallCol+colGap y=y width=smallCol-6 header=header body=body/>
</#if>
<#assign y += header + body + gap>
<#if system == "desktop">
${voffset [=7 + gap]}${offset 5}${color1}process${goto 183}mem${goto 223}pid${voffset 4}
<#else>
${voffset [=7 + gap]}${offset 5}${color1}process${alignr 5}mem${voffset 4}
</#if>
<#list 1..processes as i>
${template1 [=i]}
</#list>
${voffset [= 7 + gap]}\
<#if system == "desktop">
<#assign header = 75, height = 22>
<@menu.verticalTable x=0 y=y header=header body=159-header height=height/>
${voffset 2}${offset 5}${color1}zoom${goto 81}${color}${if_running zoom}running${else}off${endif}
<#else>
# ::::::::::::::::: wifi network
<#-- TODO only show network details when wifi is online -->
<#assign header = 57, height = 39>
<@menu.verticalTable x=0 y=y header=header body=windowWidth-header height=height/>
<#assign y += height + 2>
${voffset 3}${offset 5}${color1}network${goto 62}${color}${wireless_essid [=networkDevices[system]?first.name]}
${voffset 3}${offset 5}${color1}local ip${goto 62}${color}${addr [=networkDevices[system]?first.name]}${voffset [=8 + gap]}
# ::::::::::::::::: package updates
${if_existing /tmp/conky/dnf.packages.formatted}\
<#assign height = 22>
<@menu.verticalTable x=0 y=y header=header body=windowWidth-header height=height/>
${offset 5}${color1}dnf${goto 62}${color}${lines /tmp/conky/dnf.packages.formatted} update(s)${voffset 4}
${endif}\
</#if>
]];
