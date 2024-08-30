--[[
this conky requires the 'system.bash' script running in the background,
output files from this script are read from /tmp/conky
]]
conky.config = {
  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',       -- top|middle|bottom_left|middle|right
  gap_x = 0,                    -- same as passing -x at command line
  gap_y = 0,

  -- window settings
  minimum_width = 236,
  minimum_height = 1398,
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
  -- use the parameter -n on ${image ..} to never cache and always update the image upon a change
  
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',         -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]',        -- bar critical
  
  -- ::::::::::::::::::::::::::::::: templates ::::::::::::::::::::::::::::::::
  --  n.b. the line break escape character '\' is not supported in templates :(

  -- cpu/mem/download/disk write graph color
  template1 = [[[=colors.writeGraph]]],
  -- upload/disk read graph
  template2 = [[[=colors.readGraph]]],
  <#assign tso = 32,    <#-- vertical offset to account for background sidebar image's top shadow -->
           lso = 15,    <#-- horizontal offset to account for background sidebar image's left shadow -->
           iborder = 6, <#-- inner horizontal border -->
           rso = 32>    <#-- horizontal offset to account for background sidebar image's right shadow -->
  -- top cpu process: ${template3 processNumber}
  template3 = [[${voffset 3}${color}${offset [=lso + iborder]}${top name \1}${alignr [=rso + iborder]}${top cpu \1}%${top mem \1}%]],
  -- top mem process: ${template4 processNumber}
  template4 = [[${voffset 3}${color}${offset [=lso + iborder]}${top_mem name \1}${alignr [=rso + iborder]}${top_mem mem_res \1}${top_mem mem \1}%]],
  -- ethernet speed: ${template5 ethernetDevice}
  template5 = [[${execi 180 ethtool \1 2>/dev/null | grep -i speed | cut -d ' ' -f 2}]],
  -- network bandwith: ${template4 device uploadSpeed downloadSpeed}
  template6 = [[${voffset 8}${offset [=lso + 44]}${color}${upspeedgraph \1 35,68 ${template2} \2}${offset 3}${downspeedgraph \1 35,68 ${template1} \3}
${voffset -2}${offset [=lso + iborder]}${color1}up    ${color}${upspeed \1}${alignr [=rso + iborder]}${color}${downspeed \1}  ${color1}down
${voffset 3}${offset [=lso + iborder]}${color1}total ${color}${totalup \1}${alignr [=rso + iborder]}${color}${totaldown \1} ${color1}total]],
  -- hard disk: ${template7 device readSpeed writeSpeed}
  template7 = [[${voffset 7}${offset [=lso + 44]}${color}${diskiograph_read /dev/\1 35,68 ${template2} \2}${offset 3}${diskiograph_write /dev/\1 35,68 ${template1} \3}
${voffset -2}${offset [=lso + iborder]}${color1}read  ${color}${diskio_read /dev/\1}${alignr [=rso + iborder]}${color}${diskio_write /dev/\1} ${color1}write]],
  -- filesystem: ${template8 filesystemName fileSystemPath}
  template8 = [[${voffset 2}${offset [=lso + iborder]}${color}\1${alignr [=rso + iborder]}${voffset 1}${color2}${if_match ${fs_used_perc \2} > 90}${color3}${endif}${fs_bar 3,97 \2}
${voffset 2}${alignr [=rso + iborder]}${color}${fs_used \2} / ${fs_size \2}]]
};

conky.text = [[
<#assign y = 0>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-sidebar.png -p 0,[=y]}\
# -------------- cpu
<#assign y += tso + 7>
${if_match ${cpu cpu0} < [=threshold.cpu]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu.png -p [=lso + 5],[=y]}\
${else}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu-high.png -p [=lso + 5],[=y]}\
${endif}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph.png -p [=lso + 44],[=y]}\
<#assign y += 36 + 23>
${voffset [=tso + 2]}${offset [=lso + 44]}${cpugraph cpu0 35,139 ${template1}}
${voffset -2}${offset [=lso + iborder]}${color1}load ${color}${loadavg}${alignr [=rso + iborder]}${color}${cpu cpu0}%
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=lso + 3],[=y]}\
<#assign y += 18>
${voffset 6}${color1}${offset [=lso + iborder]}process${alignr [=rso + iborder]}cpu    mem${voffset 5}
<#list 1..7 as x>
${template3 [=x]}
</#list>
<#assign y += 125>
# -------------- memory
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-mem.png -p [=lso + 5],[=y]}\
${if_match ${memperc} > [=threshold.mem]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-mem-high.png -p [=lso + 5],[=y]}\
${endif}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph.png -p [=lso + 44],[=y]}\
<#assign y += 36 + 55>
# memory graph and usage are displayed on a separate conky due to a bug with these memory variables computing bad data if other variables like ${top ...} and one of the network upload/download exists in the same conky
${voffset 69}${offset [=lso + iborder]}${color1}swap${goto [=lso + iborder + 36]}${voffset 1}${color2}${swapbar 3,97}${alignr [=rso + iborder]}${voffset -1}${color}${swapperc}%
<#assign inputDir = "/tmp/conky",
         swapRead = inputDir + "/system.swap.read",
         swapWrite = inputDir + "/system.swap.write">
${voffset 3}${offset [=lso + iborder]}${color1}read${goto [=lso + iborder + 36]}${color}${cat [=swapRead]}${alignr [=rso + iborder]}${cat [=swapWrite]} ${color1}write
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=lso + 3],[=y]}\
<#assign y += 18>
${voffset 6}${offset [=lso + iborder]}${color1}process${alignr [=rso + iborder]}memory   perc${voffset 5}
<#list 1..7 as x>
${template4 [=x]}
</#list>
<#assign y += 125, ySection = y>
# -------------- network
<#assign device = networkDevices?first>
${if_up [=device.name]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-ethernet.png -p [=lso + 5],[=y]}\
<#assign y += 36>
${voffset 15}${goto [=lso + 45]}${color1}local ip${goto [=lso + 99]}${color}${addr [=device.name]}
${voffset 3}${goto [=lso + 45]}${color1}speed${goto [=lso + 99]}${color}${template5 [=device.name]}
# :: upload/download speeds
<#assign y += 9>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-internet.png -p [=lso + 5],[=y]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph-io.png -p [=lso + 44],[=y]}\
<#assign y += 36 + 46>
${template6 [=device.name] [=device.maxUp?c] [=device.maxDown?c]}
${else}\
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-no-network.png -p [=lso],[=ySection-7]}\
${voffset 12}${offset [=lso + iborder + 2]}${color1}no network
${voffset 3}${offset [=lso + iborder + 2]}connection
${voffset 73}
${endif}\
# -------------- disks
<#list hardDisks as disk>
# :::: [=disk.device]
<#assign ySection = y>
<#if disk.partitions?size == 1><#-- for disk with single partition add connected/disconnected state -->
${if_existing /dev/[=disk.device]}\
</#if>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-disk.png -p [=lso + 5],[=y]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph-io.png -p [=lso + 44],[=y]}\
<#assign y += 36 + 36>
${template7 [=disk.device] [=disk.readSpeed?c] [=disk.writeSpeed?c]}
<#list disk.partitions>
${voffset 6}\
<#items as partition>
<#assign y += 31>
${template8 [=partition.name] [=partition.path]}
</#items>
</#list>
<#if disk.partitions?size == 1>
${else}\
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-no-disk.png -p [=lso],[=ySection - 6]}\
${voffset 13}${offset [=lso + iborder + 2]}${color1}[=disk.device] device
${voffset 3}${offset [=lso + iborder + 2]}${color1}${font4}is not connected
${voffset 48}
${endif}\
</#if>
</#list>
# -------------- system
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-system.png -p [=lso + 5],[=y?c]}\
<#assign y += 36>
${voffset 15}${goto [=lso + 45]}${color1}uptime ${goto [=lso + 113]}${color}${uptime}
${voffset 3}${goto [=lso + 45]}${color1}compositor ${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset 9}${offset [=lso + iborder]}${color1}kernel${goto [=lso + 45]}${color}${kernel}
# due to a conky/lua bug the temperature items had to be moved to their own conky
<#assign y += 23>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=lso + 3],[=y?c]}\
<#assign y += 18 + 32>
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer1.png -p [=lso + 115],[=y?c]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer2.png -p [=lso + 115],[=y?c]}${endif}\
<#assign y += 90 + 31>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=lso + 3],[=y?c]}\
<#assign y += 18 + 4>
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan1.png -p [=lso + 64],[=y?c]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan2.png -p [=lso + 64],[=y?c]}${endif}\
]]
