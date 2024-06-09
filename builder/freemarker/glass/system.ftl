<#import "/lib/panel-square.ftl" as panel>
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
  lua_load = '~/conky/monochrome/common.lua',
  lua_draw_hook_pre = 'reset_state',

  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- number of times conky will update before quitting, set to 0 to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',     -- top|middle|bottom_left|middle|right
  gap_x = 123,                -- same as passing -x at command line
  gap_y = 158,

  -- window settings
  <#assign width = 159>
  minimum_width = [=width],
  maximum_width = [=width],
  <#if system == "desktop"><#assign windowHeight=397><#else><#assign windowHeight=342></#if>
  minimum_height = [=windowHeight?c],
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
  top_name_verbose = true,    -- show full command in ${top ...}
  top_name_width = 16,        -- how many characters to print
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  
  -- colors
  default_color = '[=colors.systemText]',  -- regular text
  color1 = '[=colors.systemLabels]',         -- text labels
  color2 = '[=colors.highlight]',         -- highlight important packages
  
  -- templates
  -- top cpu process
  template0 = [[${voffset 3}${offset 5}${color}${top name \1}${alignr 4}${top cpu \1}%]],
  -- top mem process
  template1 = [[${voffset 3}${offset 5}${color}${top_mem name \1}${alignr 4}${top_mem mem_res \1}]]
};

conky.text = [[
<#assign y = 0,
         header = 19, <#-- table header height -->
         gap = 3>     <#-- empty space between windows -->
# ::::::::::::::::: top cpu
<#assign processes = 6, width = width>
<#assign body = 5 + 16 * processes, smallCol = 45, colGap = 1>
<@panel.table x=0 y=y widths=[width-smallCol-colGap, smallCol] gap=colGap header=header body=body/>
<#assign y += header + body + gap>
${voffset 2}${offset 5}${color1}process${alignr 4}cpu${voffset 4}
<#list 1..processes as i>
${template0 [=i]}
</#list>
${voffset [= 7 + gap]}\
# ::::::::::::::::: top memory
<#assign body = 5 + 16 * processes>
<@panel.table x=0 y=y widths=[width-smallCol-colGap, smallCol] gap=colGap header=header body=body/>
${offset 5}${color1}process${alignr 4}mem${voffset 4}
<#list 1..processes as i>
${template1 [=i]}
</#list>
${voffset [= 7 + gap]}${lua increment_offsets 0 [=y + header + body + gap]}\
<#if system == "laptop">
# ::::::::::::::::: wifi network
<#-- TODO iterate through network devices and build the conditional tree for wifi devices -->
${if_up [=networkDevices[system]?first.name]}\
<#assign header = 57, height = 39>
<@panel.verticalTable x=0 y=0 header=header body=width-header height=height isFixed=false/>
<#assign y += height + 2>
${voffset 3}${offset 5}${color1}network${goto 62}${color}${wireless_essid [=networkDevices[system]?first.name]}
${voffset 3}${offset 5}${color1}local ip${goto 62}${color}${addr [=networkDevices[system]?first.name]}${voffset [=5 + gap]}
${lua increment_offsets 0 [=height+gap]}\
${endif}\
</#if>
# ::::::::::::::::: system
<#assign header = 57, height = 53>
<@panel.verticalTable x=0 y=0 header=header body=width-header height=height isFixed=false/>
${voffset 2}${offset 5}${color1}kernel${goto 62}${color}${kernel}
${voffset 3}${offset 5}${color1}uptime${goto 62}${color}${uptime}
${voffset 3}${offset 5}${color1}composit${goto 62}${color}${execi 3600 echo $XDG_SESSION_TYPE}${voffset [=5 + gap]}
${lua increment_offsets 0 [=height+gap]}\
<#assign height = 22>
<@panel.verticalTable x=0 y=0 header=header body=width-header height=height isFixed=false/>
${voffset 2}${offset 5}${color1}zoom${goto 62}${color}${if_running zoom}running${else}off${endif}
]];
