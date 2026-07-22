--[[
this conky requires the 'system.bash' script running in the background,
output files from this script are read from /tmp/conky
]]
conky.config = {
  update_interval = 1.5,  -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',    -- top|middle|bottom_left|middle|right
  gap_x = 0,                 -- same as passing -x at command line
  gap_y = 0,

  <#assign width = 2560,
           height = 128>
  -- window settings
  minimum_width = [=width?c],
  maximum_width = [=width?c],
  minimum_height = [=height],
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
  color2 = '[=colors.warning]',        -- resource usage too high
  
  -- ::: templates
  -- highlight value if resource usage is high
  template1 = [[${if_match ${\1} >= \2}${color2}${endif}]],
  -- hwmon entry: ${template9 index/device type index threshold}
  template2 = [[${if_match ${hwmon \1 \2 \3} > \4}${color2}${endif}${hwmon \1 \2 \3}]]
};

conky.text = [[
<#assign x = 0,
         tso = 0,       <#-- vertical offset to account for background bar image's top shadow -->
         y = tso+6,
         waste = 112,   <#-- TODO either distribute this width or come up with a skinny section -->
         rsection = 0,
         lsection = 11,
         block = 204,
         iborder = 6>   <#-- inner horizontal border -->
# -------------- cpu
${if_match ${cpu cpu0} < [=threshold.cpu]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu.png -p [=5],[=y]}\
${else}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-cpu-high.png -p [=5],[=y]}\
${endif}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph.png -p [=45],[=y]}\
${voffset [=tso+1]}${offset [=rsection*block+iborder+39]}${cpugraph cpu0 35,151 [=colors.writeGraph]}
${voffset -2}${offset [=rsection*block+iborder]}${color1}load${goto [=rsection*block+iborder+6*6]}${color}${loadavg}${alignr [=(lsection*block+waste+iborder)?c]}${color}${cpu cpu0}%
<#assign inputDir = "/tmp/conky/",
         us = inputDir + "system.cpu.us",
         sy = inputDir + "system.cpu.sy",
         id = inputDir + "system.cpu.id",
         wa = inputDir + "system.cpu.wa",
         column = 2*6+6+3*6+6*2>
${voffset 3}${offset [=rsection*block+iborder]}${color1}us ${color}${cat [=us]}%${goto [=rsection*block+iborder+column]}${color1}sy ${color}${cat [=sy]}%${goto [=rsection*block+iborder+column*2]}${color1}id ${color}${cat [=id]}%${goto [=rsection*block+iborder+column*3+6]}${color1}wa${alignr [=(lsection*block+waste+iborder)?c]}${color}${template1 cat\ [=wa] 40}${cat [=wa]}%
${voffset 3}${offset [=rsection*block+iborder]}${color1}processes ${color}${running_processes}${alignr [=(lsection*block+waste+iborder)?c]}${color}${running_threads} ${color1}threads
${voffset 3}${offset [=rsection*block+iborder]}${color1}uptime    ${color}${uptime}
${voffset 3}${offset [=rsection*block+iborder]}${color1}kernel    ${color}${kernel}
<#assign x += block, rsection += 1, lsection -= 1>
${voffset [=-(9*13)]}\
# -------------- cpu processes
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=x+3],[=y]}\
${offset [=block*rsection+iborder]}${color1}process${alignr [=(lsection*block+waste+iborder)?c]}cpu    mem${voffset [=5+3]}
<#assign processes = 6>
<#list 1..processes as x>
${voffset 3}${color}${offset [=block*rsection+iborder]}${top name [=x]}${alignr [=(lsection*block+waste+iborder)?c]}${top cpu [=x]}%${top mem [=x]}%
</#list>
${voffset [=-(10*13)]}\
<#assign x += block, rsection += 1, lsection -= 1>
# -------------- memory
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-mem.png -p [=x+5],[=y]}\
${if_match ${memperc} > [=threshold.mem]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-mem-high.png -p [=x+5],[=y]}\
${endif}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph.png -p [=x+45],[=y]}\
# memory graph and usage are displayed on a separate conky due to a bug with these memory variables computing bad data if other variables like ${top ...} and one of the network upload/download exists in the same conky
${voffset 69}${offset [=rsection*block+iborder]}${color1}free${goto [=rsection*block+iborder+6*6]}${color}${memfree}${alignr [=(lsection*block+waste+iborder)?c]}${color}${swap}${color1} swap    
<#assign inputDir = "/tmp/conky",
         swapRead = inputDir+"/system.swap.read",
         swapWrite = inputDir+"/system.swap.write">
${voffset 3}${offset [=rsection*block+iborder]}${color1}buff${goto [=rsection*block+iborder+6*6]}${color}${buffers}${alignr [=(lsection*block+waste+iborder)?c]}${color}${cat [=swapRead]}${color1} swap in 
${voffset 3}${offset [=rsection*block+iborder]}${color1}cache${goto [=rsection*block+iborder+6*6]}${color}${cached}${alignr [=(lsection*block+waste+iborder)?c]}${cat [=swapWrite]}${color1} swap out

${voffset [=-(9*13)]}\
<#assign x += block, rsection += 1, lsection -= 1>
# -------------- memory processes
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=x+3],[=y]}\
${voffset 3}${offset [=block*rsection+iborder]}${color1}process${alignr [=(lsection*block+waste+iborder)?c]}memory   perc${voffset [=5+3]}
<#list 1..processes as x>
${voffset 3}${color}${offset [=block*rsection+iborder]}${top_mem name [=x]}${alignr [=(lsection*block+waste+iborder)?c]}${top_mem mem_res [=x]}${top_mem mem [=x]}%
</#list>
${voffset [=-(10*13)]}\
<#assign x += block, rsection += 1, lsection -= 1>
# -------------- disks
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-disk.png -p [=x+5],[=y]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph-io.png -p [=x+45],[=y]}\
<#assign disk = hardDisks?first>
${voffset 7}${offset [=(rsection*block+iborder+39)?c]}${color}${diskiograph_read /dev/[=disk.device] 35,74 [=colors.readGraph] [=disk.readSpeed?c]}${offset 3}${diskiograph_write /dev/[=disk.device] 35,74 [=colors.writeGraph] [=disk.writeSpeed?c]}
${voffset -2}${offset [=rsection*block+iborder]}${color1}device${goto [=rsection*block+iborder+14*6+6]}read${alignr [=(lsection*block+waste+iborder)?c]}write
<#list hardDisks as disk>
${voffset 3}${offset [=rsection*block+iborder]}${color}[=disk.device]${alignr [=(lsection*block+waste+iborder+9*6+4*6)?c]}${diskio_read /dev/[=disk.device]}
${voffset -13}${alignr [=(lsection*block+waste+iborder)?c]}${diskio_write /dev/[=disk.device]}
</#list>
${voffset [=-(9*13)]}\
<#assign x += block, rsection += 1, lsection -= 1>
# -------------- disk i/o processes
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=(x+3)?c],[=y]}\
${offset [=(rsection*block+iborder)?c]}${color1}process${alignr [=(lsection*block+waste+iborder)?c]}read    write${voffset [=5+3]}
<#list 1..processes as x>
${voffset 3}${offset [=(rsection*block+iborder)?c]}${color}${top_io name [=x]}${alignr [=(lsection*block+waste+iborder+9*6)?c]}${top_io io_read [=x]}
${voffset -13}${alignr [=(lsection*block+waste+iborder)?c]}${top_io io_write [=x]}
</#list>
${voffset [=-(9*13)]}\
<#assign x += block, rsection += 1, lsection -= 1>
# -------------- filesystems
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=(x+3)?c],[=y]}\
${offset [=(rsection*block+iborder)?c]}${color1}filesystem %${alignr [=(lsection*block+waste+iborder)?c]}total     free${voffset [=5+3]}
<#-- TODO dynamic sizing of list: cap at 6, what if you have less than 5? how would you calculate the trailing voffset -->
<#list hardDisks as disk>
<#list disk.partitions as partition><#-- longest partition name is 8 characters -->
${voffset 3}${offset [=(rsection*block+iborder)?c]}${color}[=partition.name]${goto [=(rsection*block+iborder+10*6+6)?c]}${template1 fs_used_perc\ [=partition.path] [=threshold.filesystem]}${fs_used_perc [=partition.path]}%${alignr [=(lsection*block+waste+iborder+9*6)?c]}${fs_size [=partition.path]}
${voffset -13}${alignr [=(lsection*block+waste+iborder)?c]}${fs_free [=partition.path]}
</#list>
</#list>
${voffset 3}
${voffset [=-(10*13)]}\
<#assign x += block, rsection += 1, lsection -= 1>
# -------------- network
<#assign device = networkDevices?first>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-ethernet.png -p [=(x+5)?c],[=y]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-graph-io.png -p [=(x+45)?c],[=y]}\
${voffset 7}${offset [=(rsection*block+iborder+39)?c]}${color}${upspeedgraph [=device.name] 35,68 [=colors.readGraph] [=device.maxUp?c]}${offset 3}${downspeedgraph [=device.name] 35,68 [=colors.writeGraph] [=device.maxDown?c]}
${voffset -2}${offset [=(rsection*block+iborder)?c]}${color1}up    ${color}${upspeed [=device.name]}${alignr [=(lsection*block+waste+iborder)?c]}${color}${downspeed [=device.name]}  ${color1}down
${voffset 3}${offset [=(rsection*block+iborder)?c]}${color1}total ${color}${totalup [=device.name]}${alignr [=(lsection*block+waste+iborder)?c]}${color}${totaldown [=device.name]} ${color1}total
${voffset 3}
${voffset 3}${offset [=(rsection*block+iborder)?c]}${color1}local ip ${color}${addr [=device.name]}
${voffset 3}${offset [=(rsection*block+iborder)?c]}${color1}speed    ${color}${execi 180 ethtool [=device.name] 2>/dev/null | grep -i speed | cut -d ' ' -f 2}
${voffset [=-(9*13)]}\
<#assign x += block, rsection += 1, lsection -= 1>
# -------------- temperature 1
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=(x+3)?c],[=y]}\
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer1.png -p [=(x+118)?c],[=y+18+8]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer2.png -p [=(x+118)?c],[=y+18+8]}${endif}\
${if_updatenr 3}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer3.png -p [=(x+118)?c],[=y+18+8]}${endif}\
${if_updatenr 4}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer2.png -p [=(x+118)?c],[=y+18+8]}${endif}\
${offset [=(rsection*block+iborder)?c]}${color1}device${alignr [=(lsection*block+waste+iborder)?c]}temperature${voffset [=5+3]}
<#list temperatures as device>
${voffset 3}${offset [=(rsection*block+iborder)?c]}${color}[=device.name]${alignr [=(lsection*block+waste+iborder)?c]}${template2 [=device.module!device.hwmonIndex] temp [=device.number!1] [=threshold[device.thresholdType]]}°C
</#list>
${voffset [=-(9*13)]}\
<#assign x += block, rsection += 1, lsection -= 1>
# -------------- temperature 2
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=(x+3)?c],[=y]}\
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer2.png -p [=(x+118)?c],[=y+18+8]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer3.png -p [=(x+118)?c],[=y+18+8]}${endif}\
${if_updatenr 3}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer2.png -p [=(x+118)?c],[=y+18+8]}${endif}\
${if_updatenr 4}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-thermometer1.png -p [=(x+118)?c],[=y+18+8]}${endif}\
${offset [=(rsection*block+iborder)?c]}${color1}device${alignr [=(lsection*block+waste+iborder)?c]}temperature${voffset [=5+3]}
<#-- TODO dynamic sizing of list: cap at 6, what if you have less than 5? what is the formula for the trailing voffset? here i have hardcoded a vertical offset -->
<#list hardDisks as device>
<#if device.hwmonIndex??>
${voffset 3}${offset [=(rsection*block+iborder)?c]}${color}[=device.name]${alignr [=(lsection*block+waste+iborder)?c]}${template2 [=device.module!device.hwmonIndex] temp [=device.number!1] [=threshold[device.thresholdType]]}°C
</#if>
</#list>
${voffset [=-(5*13+4)]}\
<#assign x += block, rsection += 1, lsection -= 1>
# -------------- fans
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-table-fields.png -p [=(x+3)?c],[=y]}\
${if_updatenr 1}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan1.png -p [=(x+64)?c],[=y+18+25]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan2.png -p [=(x+64)?c],[=y+18+25]}${endif}\
${if_updatenr 3}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan1.png -p [=(x+64)?c],[=y+18+25]}${endif}\
${if_updatenr 4}${image ~/conky/monochrome/images/compact/[=image.primaryColor]-fan2.png -p [=(x+64)?c],[=y+18+25]}${endif}\
${offset [=(rsection*block+iborder)?c]}${color1}fan${alignr [=(lsection*block+waste+iborder)?c]}revolutions${voffset [=5+3]}
<#list fans as fan>
${voffset 3}${offset [=(rsection*block+iborder)?c]}${color}[=fan.name]${alignr [=(lsection*block+waste+iborder)?c]}${template2 [=fan.module] fan [=fan.number] [=threshold.fanSpeed?c]} rpm
</#list>
${voffset [=-(4*13+9)]}\
<#assign x += block, rsection += 1, lsection -= 1>
# -------------- now playing
<#assign albumArtFile = "/tmp/conky/musicplayer.track.art">
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-album-cover.png -p [=(x+iborder+(height-iborder*2-60)/2)?c],[=(y+(height-iborder*2-60)/2)?c]}\
${if_existing [=albumArtFile]}\
${image [=albumArtFile] -p [=(x+iborder)?c],[=y?c] -s [=height-iborder*2]x[=height-iborder*2] -n}\
${endif}\
${if_existing /tmp/conky/musicplayer.status on}\
${offset [=(rsection*block+height+iborder)?c]}${color1}${cat /tmp/conky/musicplayer.name} ${color}::: ${cat /tmp/conky/musicplayer.playbackStatus}
${voffset 3}${offset [=(rsection*block+height+iborder)?c]}${color1}title${goto [=(rsection*block+height+iborder+6*6+6)?c]}${color}${scroll wait 24 4 1 ${cat /tmp/conky/musicplayer.track.title}}
${voffset 3}${offset [=(rsection*block+height+iborder)?c]}${color1}album${goto [=(rsection*block+height+iborder+6*6+6)?c]}${color}${scroll wait 24 4 1 ${cat /tmp/conky/musicplayer.track.album}}
${voffset 3}${offset [=(rsection*block+height+iborder)?c]}${color1}artist${goto [=(rsection*block+height+iborder+6*6+6)?c]}${color}${scroll wait 24 4 1 ${cat /tmp/conky/musicplayer.track.artist}}
${voffset 3}${offset [=(rsection*block+height+iborder)?c]}${color1}genre${goto [=(rsection*block+height+iborder+6*6+6)?c]}${color}${cat /tmp/conky/musicplayer.track.genre}
${else}\
${voffset [=2*13+6]}${offset [=(rsection*block+height+iborder)?c]}${color1}now playing
${voffset 3}${offset [=(rsection*block+height+iborder)?c]}${color}no media player running
${endif}\
# -------------- ?
${voffset [=-(19*13)]}\
]]
