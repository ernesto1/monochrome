<#import "lib/network.ftl" as net>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua',

  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 1,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',     -- top|middle|bottom_left|middle|right
  gap_x = 0,                     -- same as passing -x at command line
  <#if system == "desktop"><#assign yOffset = 0><#else><#assign yOffset = -15></#if>
  gap_y = [=yOffset],

  -- window settings
  <#assign tso = 32,    <#-- vertical offset to account for background sidebar image's top shadow -->
           lso = 27,    <#-- horizontal offset to account for background sidebar image's left shadow -->
           iborder = 6, <#-- inner horizontal border -->
           rso = 32>    <#-- horizontal offset to account for background sidebar image's right shadow -->
  minimum_width = [=lso + 143],
  minimum_height = 1335,
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
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address
  -- font settings
  use_xft = true,
  xftalpha = 1,
  uppercase = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)

  font = 'URW Gothic:size=9',    -- default: small
  font0 = 'URW Gothic:size=12',  -- medium
  font1 = 'URW Gothic:size=23',  -- big
  font2 = 'Promenade de la Croisette:size=40',   -- device temperature reading

  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',         -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]',        -- bar critical
  color4 = '[=colors.widgetText]',        -- temperature text
  
  -- :::::::::::::::::::::::::::::::: templates ::::::::::::::::::::::::::::::::
  --  n.b. the line break escape character '\' is not supported in templates :(
  
  -- cpu/mem/download/disk write graph color
  template1 = [[[=colors.writeGraph]]],
  -- upload/disk read graph
  template2 = [[[=colors.readGraph]]],  
  -- network bandwith: ${template3 device uploadSpeed downloadSpeed}
  template3 = [[
${voffset 9}${offset [=lso + 5]}${upspeedgraph \1 29,47 ${template2} \2}
${voffset -8}${offset [=lso + 5]}${downspeedgraph \1 29,47 ${template1} \3}
${voffset -56}${goto [=lso + 72]}${color}${font}${upspeed \1}
${voffset 21}${goto [=lso + 72]}${color}${font}${downspeed \1}${voffset 10}]],

  -- hard disk io: ${template4 device readSpeed writeSpeed}
  template4 = [[
${voffset 5}${offset [=lso + 5]}${color}${diskiograph_read /dev/\1 21,47 ${template2} \2}
${voffset -8}${offset [=lso + 5]}${diskiograph_write /dev/\1 21,47 ${template1} \3}
${voffset -48}${goto [=lso + 72]}${color}${font}${diskio_read /dev/\1}
${voffset 13}${goto [=lso + 72]}${color}${font}${diskio_write /dev/\1}${voffset 10}]],

  -- filesystem: ${template6 filesystemName fileSystemPath}
  template6 = [[
${voffset 45}${offset [=lso + 6]}${color2}${if_match ${fs_used_perc \2} > 90}${color3}${endif}${fs_bar 3, 45 \2}
${voffset -46}${goto [=lso + 72]}${color}${font}\1
${voffset 4}${goto [=lso + 72]}${color}${font1}${fs_used_perc \2}${font0}%${font}${voffset 8}]],

<#if system == "laptop" >
  -- color coded hwmon entry: index/device type index threshold
  template7 = [[${if_match ${hwmon \1 \2 \3} > \4}${color3}${else}${color4}${endif}${hwmon \1 \2 \3}]], 
    
  -- temperature: ${template8 index/device type index threshold}
  template8 = [[${voffset 7}${offset [=lso + 12]}${font2}${template7 \1 \2 \3 \4}${voffset -28}${font0}°${offset 4}${voffset -4}${font2}C${font}${color}${voffset 9}]]
</#if>
};

conky.text = [[
<#assign y = 0>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sidebar.png -p 0,[=y]}\
<#assign y += tso>
# :::::::::::::::::::: cpu
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-cpu.png -p [=lso + 5],[=y]}\
${image ~/conky/monochrome/images/[=conky]/text-box-99p.png -p [=lso + 68],[=y + 13]}\
${if_match ${cpu cpu0} > [=threshold.cpu]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-cpu-high.png -p [=lso + 5],[=y]}\
${if_match ${cpu cpu0} == 100}${image ~/conky/monochrome/images/[=conky]/text-box-100p.png -p [=lso + 68 + 25],[=y + 13]}${endif}\
${endif}\
<#assign y += 48 + 9>
${voffset [=tso + 12]}${offset [=lso + 12]}${cpugraph cpu0 33,33 ${template1}}
${voffset -31}${goto [=lso + 72]}${color}${font1}${cpu cpu0}${font0}%
# :::::::::::::::::::: memory
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-mem.png -p [=lso + 5],[=y]}\
${image ~/conky/monochrome/images/[=conky]/text-box-mem.png -p [=lso + 68],[=y + 19]}\
${if_match ${memperc} > [=threshold.mem]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-mem-high.png -p [=lso + 5],[=y]}\
${endif}\
<#assign y += 48 + 26>
${voffset 17}${offset [=lso + 18]}${memgraph 43,21 ${template1}}
${voffset -33}${goto [=lso + 72]}${color}${font1}${memperc}${font0}%
${voffset 4}${offset [=lso + 6]}${color2}${if_match ${swapperc} >= [=threshold.swap]}${color3}${endif}${swapbar 3, 45}${voffset -2}${goto [=lso + 72]}${font}${color}${swapperc}%
# :::::::::::::::::::: network
<#assign device = networkDevices[system]?first>
${if_up [=device.name]}\
# :: upload/download speeds
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-internet.png -p [=lso],[=y]}\
${image ~/conky/monochrome/images/[=conky]/text-box.png -p [=lso + 68],[=y + 20]}\
${image ~/conky/monochrome/images/[=conky]/text-box.png -p [=lso + 68],[=y + 54]}\
<#assign device = networkDevices[system]?first>
${template3 [=device.name] [=device.maxUp?c] [=device.maxDown?c]}
${else}\
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-internet-offline.png -p [=lso],[=y]}\
${voffset 117}
${endif}\
<#assign y += 9 + 64 + 9><#-- internet image contains the top and bottom border -->
<#list hardDisks[system] as hardDisk>
# :::::::::::::::::::: disk [=hardDisk.name!hardDisk.device]
<#-- special handling for the main 'sda' disk
     > partitions do not print their name since their icons are self explanatory
     > no disconnected image used since it does not have any -->
<#if hardDisk.device != "sda">${if_existing /dev/[=hardDisk.device]}\<#else># main disk</#if>
# disk io
<#assign y += 9,
         diskBlockStart = y><#-- need to store the starting y position of the disk for the disk disconnected image -->
${if_updatenr 1}${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-diskio-1.png -p [=lso + 5],[=y]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-diskio-2.png -p [=lso + 5],[=y]}${endif}\
${image ~/conky/monochrome/images/[=conky]/text-box.png -p [=lso + 68],[=y + 3]}\
${image ~/conky/monochrome/images/[=conky]/text-box.png -p [=lso + 68],[=y + 29]}\
<#assign y += 48 + 9>
${template4 [=hardDisk.device] [=hardDisk.readSpeed?c] [=hardDisk.writeSpeed?c]}
# partitions
<#list hardDisk.partitions as partition>
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-disk-[=partition.icon].png -p [=lso + 5],[=y]}\
<#if hardDisk.device == "sda">
${image ~/conky/monochrome/images/[=conky]/text-box-99p.png -p [=lso + 68],[=y + 15]}\
${template6 \  [=partition.path]}
<#else>
${image ~/conky/monochrome/images/[=conky]/text-box-partition.png -p [=lso + 68],[=y - 2]}\
${template6 [=partition.name] [=partition.path]}
</#if>
<#assign y += 46 + 9>
</#list>
<#if hardDisk.device != "sda">
${else}\
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-disk-disconnected.png -p [=lso],[=diskBlockStart]}\
${voffset 59}${goto [=lso + 67]}[=hardDisk.device] not
${voffset 3}${goto [=lso + 67]}available
${voffset 27}
${endif}\
</#if>
</#list>
# :::::::::::::::::::: temperatures
<#assign y += 9>
# :::::::: cpu
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-temp-cpu.png -p [=lso + 5],[=y]}\
<#if system == "desktop" >
<#assign y += 46 + 9>
# :::::::: ati video card
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-temp-videocard.png -p [=lso + 5],[=y]}\
<#assign y += 46 + 9>
# :::::::: hard disks
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-temp-disk.png -p [=lso + 5],[=y]}\
<#assign y += 46 + 9>
# :::::::: fans
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-fan-1.png -p [=lso],[=y?c]}\
<#else>
# laptop only reports cpu core temperatures, displaying the hottest of the two cores
${voffset 15}${if_match ${hwmon coretemp temp 2} > ${hwmon coretemp temp 3}}${template8 coretemp temp 2 [=threshold.tempCPUCore]}${else}${template8 coretemp temp 3 [=threshold.tempCPUCore]}${endif}
</#if>
${voffset -360}\
]]
