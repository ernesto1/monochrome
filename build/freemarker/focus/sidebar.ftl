--[[
this conky requires the 'system.bash' script running in the background,
output files from this script are read from /tmp/conky
]]
conky.config = {
  update_interval = 1.5,  -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',    -- top|middle|bottom_left|middle|right
  gap_x = 0,                 -- same as passing -x at command line
  gap_y = 32,

  -- window settings
  <#assign width = 204>
  minimum_width = [=width],
  maximum_width = [=width],
  <#assign processes     = isVerbose?then(6,4),   <#-- number of top processes to display -->
           optionalDisks = isVerbose?then(0,1)>   <#-- number of hard disks that can be ommitted to save height -->
  minimum_height = 1568,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)

  -- transparency configuration
  draw_blended = true,
  own_window_transparent = false,
  own_window_argb_visual = false,  -- turn on transparency
  own_window_colour = '[=colors.panelColor]',

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
  color2 = '[=colors.warning]',         -- resource usage too high
  color3 = '[=colors.bar]',        -- bar
  
  -- hwmon entry: ${template9 index/device type index threshold}
  template1 = [[${if_match ${hwmon \1 \2 \3} > \4}${color2}${endif}${hwmon \1 \2 \3}]]
};

conky.text = [[
<#assign y = 0,
         tso = 0,      <#-- vertical offset to account for background sidebar image's top shadow -->
         iborder = 6>  <#-- inner horizontal border -->
# -------------- cpu
<#assign y += tso+7>
${if_match ${cpu cpu0} < [=threshold.cpu]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu.png -p [=5],[=y]}\
${else}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu-high.png -p [=5],[=y]}\
${endif}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph.png -p [=45],[=y]}\
<#assign y += 36+23>
${voffset [=tso+2]}${offset [=45]}${cpugraph cpu0 35,151 [=colors.writeGraph]}
${voffset -2}${offset [=iborder]}${color1}load${goto [=iborder+6 * 6]}${color}${loadavg}${alignr [=iborder]}${color}${cpu cpu0}%
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=3],[=y]}\
<#assign y += 18>
${voffset 6}${color1}${offset [=iborder]}process${alignr [=iborder]}cpu    mem${voffset 5}
<#list 1..processes as x>
${voffset 3}${color}${offset [=iborder]}${top name [=x]}${alignr [=iborder]}${top cpu [=x]}%${top mem [=x]}%
</#list>
<#assign y += 13+processes*16>
# -------------- memory
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-mem.png -p [=5],[=y]}\
${if_match ${memperc} > [=threshold.mem]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-mem-high.png -p [=5],[=y]}\
${endif}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph.png -p [=45],[=y]}\
<#assign y += 36>
# memory graph and usage are displayed on a separate conky due to a bug with these memory variables computing bad data if other variables like ${top ...} and one of the network upload/download exists in the same conky
${voffset 69}${offset [=iborder]}${color1}free${goto [=iborder+6 * 6]}${color}${memfree}${alignr [=iborder]}${color}${swap}${color1} swap    
<#assign inputDir = "/tmp/conky",
         swapRead = inputDir+"/system.swap.read",
         swapWrite = inputDir+"/system.swap.write">
${voffset 3}${offset [=iborder]}${color1}buff${goto [=iborder+6 * 6]}${color}${buffers}${alignr [=iborder]}${color}${cat [=swapRead]}${color1} swap in 
${voffset 3}${offset [=iborder]}${color1}cache${goto [=iborder+6 * 6]}${color}${cached}${alignr [=iborder]}${cat [=swapWrite]}${color1} swap out
<#assign y += 71>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=3],[=y]}\
<#assign y += 18>
${voffset 6}${offset [=iborder]}${color1}process${alignr [=iborder]}memory   perc${voffset 5}
<#list 1..processes as x>
${voffset 3}${color}${offset [=iborder]}${top_mem name [=x]}${alignr [=iborder]}${top_mem mem_res [=x]}${top_mem mem [=x]}%
</#list>
<#assign y += 13+processes*16, ySection = y>
# -------------- network
<#assign device = networkDevices?first>
${if_up [=device.name]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-ethernet.png -p [=5],[=y]}\
<#assign y += 36>
${voffset 15}${goto [=iborder+7*6]}${color1}local ip ${color}${addr [=device.name]}
${voffset 3}${goto [=iborder+7*6]}${color1}speed    ${color}${execi 180 ethtool [=device.name] 2>/dev/null | grep -i speed | cut -d ' ' -f 2}
# :: upload/download speeds
<#assign y += 9>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-internet.png -p [=5],[=y]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph-io.png -p [=45],[=y]}\
<#assign y += 36+46>
${voffset 8}${offset [=45]}${color}${upspeedgraph [=device.name] 35,74 [=colors.readGraph] [=device.maxUp?c]}${offset 3}${downspeedgraph [=device.name] 35,74 [=colors.writeGraph] [=device.maxDown?c]}
${voffset -2}${offset [=iborder]}${color1}up    ${color}${upspeed [=device.name]}${alignr [=iborder]}${color}${downspeed [=device.name]}  ${color1}down
${voffset 3}${offset [=iborder]}${color1}total ${color}${totalup [=device.name]}${alignr [=iborder]}${color}${totaldown [=device.name]} ${color1}total
${else}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-no-network.png -p [=3],[=ySection-7]}\
${voffset 12}${offset [=iborder+2]}${color1}no network
${voffset 3}${offset [=iborder+2]}connection
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
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-disk.png -p [=5],[=y]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph-io.png -p [=45],[=y]}\
<#assign y += 36+36>
${voffset 7}${offset [=45]}${color}${diskiograph_read /dev/[=disk.device] 35,74 [=colors.readGraph] [=disk.readSpeed?c]}${offset 3}${diskiograph_write /dev/[=disk.device] 35,74 [=colors.writeGraph] [=disk.writeSpeed?c]}
${voffset -2}${offset [=iborder]}${color1}read  ${color}${diskio_read /dev/[=disk.device]}${alignr [=iborder]}${color}${diskio_write /dev/[=disk.device]} ${color1}write
<#list disk.partitions>
${voffset 6}\
<#items as partition>
<#assign y += 31>
${voffset 2}${offset [=iborder]}${color}[=partition.name]${alignr [=iborder+1]}${voffset 1}${color3}${if_match ${fs_used_perc [=partition.path]} > [=threshold.filesystem]}${color2}${endif}${fs_bar 3,100 [=partition.path]}
${voffset 2}${alignr [=iborder]}${color}${fs_used [=partition.path]} / ${fs_size [=partition.path]}
</#items>
</#list>
<#if disk.partitions?size == 1>
${else}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-no-disk.png -p [=3],[=ySection - 6]}\
${voffset 13}${offset [=iborder+2]}${color1}[=disk.device] device
${voffset 3}${offset [=iborder+2]}${color1}${font4}is not connected
${voffset 48}
${endif}\
</#if>
</#list>
# --- disk processes i/o
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=3],[=y?c]}\
<#assign y += 18>
${voffset 13}${offset [=iborder]}${color1}process${alignr [=iborder]}read    write${voffset 5}
<#list 1..processes as x>
${voffset 3}${offset [=iborder]}${color}${top_io name [=x]}${alignr [=iborder+9*6]}${top_io io_read [=x]}
${voffset -13}${alignr [=iborder]}${top_io io_write [=x]}
</#list>
<#assign y += 13+processes*16>
# -------------- system
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-system.png -p [=5],[=y?c]}\
<#assign y += 36>
${voffset 15}${goto [=iborder+7*6]}${color1}uptime     ${color}${uptime}
${voffset 3}${goto [=iborder+7*6]}${color1}compositor ${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset 9}${offset [=iborder]}${color1}kernel ${color}${kernel}
${voffset 3}${offset [=iborder]}${color1}dnf    ${color}${lines /tmp/conky/dnf.packages.formatted} package updates
# due to a conky/lua bug the temperature items had to be moved to their own conky
<#assign y += 23+16>
# ::: device temperature
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=3],[=y?c]}\
<#assign y += 18+32>
${voffset 6}${offset [=iborder]}${color1}device${alignr [=iborder]}temperature${voffset 5}
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer1.png -p [=115],[=y?c]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer2.png -p [=115],[=y?c]}${endif}\
${if_updatenr 3}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer3.png -p [=115],[=y?c]}${endif}\
${if_updatenr 4}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer2.png -p [=115],[=y?c]}${endif}\
<#list temperatures + hardDisks as device>
<#if device.module?? || device.hwmonIndex??>
${voffset 3}${offset [=iborder]}${color}[=device.name]${alignr}${template1 [=device.module!device.hwmonIndex] temp [=device.number!1] [=threshold[device.thresholdType]]}°C
</#if>
</#list>
<#assign y += 90+31>
# ::: fan revolutions
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=3],[=y?c]}\
<#assign y += 18>
${voffset 9}${offset [=iborder]}${color1}fan${alignr [=iborder]}revolutions${voffset 5}
<#assign y += 4>
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan1.png -p [=64],[=y?c]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan2.png -p [=64],[=y?c]}${endif}\
${if_updatenr 3}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan1.png -p [=64],[=y?c]}${endif}\
${if_updatenr 4}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan2.png -p [=64],[=y?c]}${endif}\
<#assign y += 60>
<#list fans as fan>
${voffset 3}${offset [=iborder]}${color}[=fan.name]${alignr [=iborder]}${template1 [=fan.module] fan [=fan.number] [=threshold.fanSpeed?c]} rpm
</#list>
# -------------- now playing
<#assign y += 13>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-disk.png -p [=5],[=y?c]}\
<#assign y += 36>
${if_existing /tmp/conky/musicplayer.status off}\
${voffset 15}${goto [=iborder+7*6]}${color1}now playing
${voffset 3}${goto [=iborder+7*6]}${color}no music player running${voffset 6}
${else}\
${voffset 15}${goto [=iborder+7*6]}${color1}${cat /tmp/conky/musicplayer.name}
${voffset 3}${goto [=iborder+7*6]}${color}${cat /tmp/conky/musicplayer.playbackStatus}${voffset 6}
<#assign y += 6
         albumArtFile = "/tmp/conky/musicplayer.track.art">
${if_existing [=albumArtFile]}\
${image [=albumArtFile] -p [=iborder],[=y?c] -s [=width-iborder*2]x[=width-iborder*2] -n}\
${voffset [=width-6]}\
${endif}\
<#assign y += width-iborder*2>
${voffset 3}${offset [=iborder]}${color1}title${goto 48}${color}${scroll wait 24 4 1 ${cat /tmp/conky/musicplayer.track.title}}
${voffset 3}${offset [=iborder]}${color1}album${goto 48}${color}${scroll wait 24 4 1 ${cat /tmp/conky/musicplayer.track.album}}
${voffset 3}${offset [=iborder]}${color1}artist${goto 48}${color}${scroll wait 24 4 1 ${cat /tmp/conky/musicplayer.track.artist}}
${voffset 3}${offset [=iborder]}${color1}genre${goto 48}${color}${cat /tmp/conky/musicplayer.track.genre}
${endif}\
]]
