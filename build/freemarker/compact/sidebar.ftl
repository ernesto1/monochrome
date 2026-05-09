--[[
this conky requires the 'system.bash' script running in the background,
output files from this script are read from /tmp/conky
]]
conky.config = {
  update_interval = 1.5,  -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',    -- top|middle|bottom_left|middle|right
  gap_x = 0,                    -- same as passing -x at command line
  gap_y = 0,

  -- window settings
  minimum_width = 238,
  <#assign processes     = isVerbose?then(6,4),   <#-- number of top processes to display -->
           optionalDisks = isVerbose?then(0,1),   <#-- number of hard disks that can be ommitted to save height -->
           height        = 1221+(processes*16*3)-optionalDisks*103>
  minimum_height = [=height?c],
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

  imlib_cache_flush_interval = 250, -- use the parameter -n on ${image ..} to never cache and always update 
                                    -- the image upon a change
  
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
  color3 = '[=colors.warning]'         -- bar critical
};

conky.text = [[
<#assign y = 0,
         tso = 32,      <#-- vertical offset to account for background sidebar image's top shadow -->
         lso = 15,      <#-- horizontal offset to account for background sidebar image's left shadow -->
         iborder = 6,   <#-- inner horizontal border -->
         rso = 32>      <#-- horizontal offset to account for background sidebar image's right shadow -->
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-sidebar.png -p 0,[=y]}\
# -------------- cpu
<#assign y += tso+7>
${if_match ${cpu cpu0} < [=threshold.cpu]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu.png -p [=lso+5],[=y]}\
${else}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu-high.png -p [=lso+5],[=y]}\
${endif}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph.png -p [=lso+45],[=y]}\
<#assign y += 36+23>
${voffset [=tso+2]}${offset [=lso+45]}${cpugraph cpu0 35,139 [=colors.writeGraph]}
${voffset -2}${offset [=lso+iborder]}${color1}load${goto [=lso+iborder+6 * 6]}${color}${loadavg}${alignr [=rso+iborder]}${color}${cpu cpu0}%
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=lso+3],[=y]}\
<#assign y += 18>
${voffset 6}${color1}${offset [=lso+iborder]}process${alignr [=rso+iborder]}cpu    mem${voffset 5}
<#list 1..processes as x>
${voffset 3}${color}${offset [=lso+iborder]}${top name [=x]}${alignr [=rso+iborder]}${top cpu [=x]}%${top mem [=x]}%
</#list>
<#assign y += 13+processes*16>
# -------------- memory
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-mem.png -p [=lso+5],[=y]}\
${if_match ${memperc} > [=threshold.mem]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-mem-high.png -p [=lso+5],[=y]}\
${endif}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph.png -p [=lso+45],[=y]}\
<#assign y += 36>
# memory graph and usage are displayed on a separate conky due to a bug with these memory variables computing bad data if other variables like ${top ...} and one of the network upload/download exists in the same conky
${voffset 69}${offset [=lso+iborder]}${color1}buff${goto [=lso+iborder+6 * 6]}${color}${buffers}${alignr [=rso+iborder]}${color}${cached}${color1} cache
${voffset 3}${offset [=lso+iborder]}${color1}free${goto [=lso+iborder+6 * 6]}${color}${memfree}${alignr [=rso+iborder]}${color}${swap}${color1}  swap
<#assign inputDir = "/tmp/conky",
         swapRead = inputDir+"/system.swap.read",
         swapWrite = inputDir+"/system.swap.write">
${voffset 3}${offset [=lso+iborder]}${color1}si${goto [=lso+iborder+6 * 6]}${color}${cat [=swapRead]}${alignr [=rso+iborder]}${cat [=swapWrite]}${color1}    so
<#assign y += 71>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=lso+3],[=y]}\
<#assign y += 18>
${voffset 6}${offset [=lso+iborder]}${color1}process${alignr [=rso+iborder]}memory   perc${voffset 5}
<#list 1..processes as x>
${voffset 3}${color}${offset [=lso+iborder]}${top_mem name [=x]}${alignr [=rso+iborder]}${top_mem mem_res [=x]}${top_mem mem [=x]}%
</#list>
<#assign y += 13+processes*16, ySection = y>
# -------------- network
<#assign device = networkDevices?first>
${if_up [=device.name]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-ethernet.png -p [=lso+5],[=y]}\
<#assign y += 36>
${voffset 15}${goto [=lso+iborder+7 * 6]}${color1}local ip ${color}${addr [=device.name]}
${voffset 3}${goto [=lso+iborder+7 * 6]}${color1}speed    ${color}${execi 180 ethtool [=device.name] 2>/dev/null | grep -i speed | cut -d ' ' -f 2}
# :: upload/download speeds
<#assign y += 9>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-internet.png -p [=lso+5],[=y]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph-io.png -p [=lso+45],[=y]}\
<#assign y += 36+46>
${voffset 8}${offset [=lso+45]}${color}${upspeedgraph [=device.name] 35,68 [=colors.readGraph] [=device.maxUp?c]}${offset 3}${downspeedgraph [=device.name] 35,68 [=colors.writeGraph] [=device.maxDown?c]}
${voffset -2}${offset [=lso+iborder]}${color1}up    ${color}${upspeed [=device.name]}${alignr [=rso+iborder]}${color}${downspeed [=device.name]}  ${color1}down
${voffset 3}${offset [=lso+iborder]}${color1}total ${color}${totalup [=device.name]}${alignr [=rso+iborder]}${color}${totaldown [=device.name]} ${color1}total
${else}\
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-no-network.png -p [=lso+3],[=ySection-7]}\
${voffset 12}${offset [=lso+iborder+2]}${color1}no network
${voffset 3}${offset [=lso+iborder+2]}connection
${voffset 73}
${endif}\
# -------------- disks
<#assign hardDisks = isVerbose?then(hardDisks, hardDisks?filter(d -> d.required!true))>
<#list hardDisks as disk>
# :::: [=disk.device]
<#assign ySection = y>
<#if disk.partitions?size == 1><#-- for disk with single partition add connected/disconnected state -->
${if_existing /dev/[=disk.device]}\
</#if>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-disk.png -p [=lso+5],[=y]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph-io.png -p [=lso+45],[=y]}\
<#assign y += 36+36>
${voffset 7}${offset [=lso+45]}${color}${diskiograph_read /dev/[=disk.device] 35,68 [=colors.readGraph] [=disk.readSpeed?c]}${offset 3}${diskiograph_write /dev/[=disk.device] 35,68 [=colors.writeGraph] [=disk.writeSpeed?c]}
${voffset -2}${offset [=lso+iborder]}${color1}read  ${color}${diskio_read /dev/[=disk.device]}${alignr [=rso+iborder]}${color}${diskio_write /dev/[=disk.device]} ${color1}write
<#list disk.partitions>
${voffset 6}\
<#items as partition>
<#assign y += 31>
${voffset 2}${offset [=lso+iborder]}${color}[=partition.name]${alignr [=rso+iborder+2]}${voffset 1}${color2}${if_match ${fs_used_perc [=partition.path]} > [=threshold.filesystem]}${color3}${endif}${fs_bar 3,97 [=partition.path]}
${voffset 2}${alignr [=rso+iborder]}${color}${fs_used [=partition.path]} / ${fs_size [=partition.path]}
</#items>
</#list>
<#if disk.partitions?size == 1>
${else}\
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-no-disk.png -p [=lso+3],[=ySection - 6]}\
${voffset 13}${offset [=lso+iborder+2]}${color1}[=disk.device] device
${voffset 3}${offset [=lso+iborder+2]}${color1}${font4}is not connected
${voffset 48}
${endif}\
</#if>
</#list>
# --- disk processes i/o
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=lso+3],[=y?c]}\
<#assign y += 18>
${voffset 13}${color1}${offset [=lso+iborder]}process${alignr [=rso+iborder+1]}read    write${voffset 5}
<#list 1..processes as x>
${voffset 3}${color}${offset [=lso+iborder]}${top_io name [=x]} ${top_io io_read [=x]}${goto 170}${top_io io_write [=x]}
</#list>
<#assign y += 13+processes*16>
# -------------- system
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-system.png -p [=lso+5],[=y?c]}\
<#assign y += 36>
${voffset 15}${goto [=lso+iborder+7 * 6]}${color1}uptime     ${color}${uptime}
${voffset 3}${goto [=lso+iborder+7 * 6]}${color1}compositor ${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset 9}${offset [=lso+iborder]}${color1}kernel ${color}${kernel}
# due to a conky/lua bug the temperature items had to be moved to their own conky
<#assign y += 23>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=lso+3],[=y?c]}\
<#assign y += 18+32>
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer1.png -p [=lso+115],[=y?c]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer2.png -p [=lso+115],[=y?c]}${endif}\
<#assign y += 90+31>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=lso+3],[=y?c]}\
<#assign y += 18>
<#-- place the bottom edge of the sidebar so that the fan animation can be overlayed on top of it -->
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-sidebar-bottom.png -p 0,[=(y+53)?c]}\
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan1.png -p [=lso+64],[=(y+4)?c]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan2.png -p [=lso+64],[=(y+4)?c]}${endif}\
]]
