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
  <#if system == "desktop"><#assign yOffset = 100><#else><#assign yOffset = -15></#if>
  gap_y = [=yOffset],

  -- window settings
  <#-- offsets are used to account for the image's shadows on the left, top and right side -->
  <#assign tso = 32,    <#-- top shadow offset -->
           lso = 27,    <#-- left shadow offset -->
           iborder = 6, <#-- inner sidebar horizontal border -->
           rso = 32,    <#-- right shadow offset -->
           width = lso + 90>  <#-- width of the sidebar image -->
  <#if isVerbose><#assign width += 53></#if>
  minimum_width = [=width],
  <#if system == "desktop"><#assign height = 1135><#else><#assign height = 681></#if>
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
<#if isVerbose>
${voffset -56}${goto [=lso + 72]}${color}${font}${upspeed \1}
${voffset 21}${goto [=lso + 72]}${color}${font}${downspeed \1}${voffset 10}<#rt>
<#else>
${font}${voffset -12}\<#rt>
</#if>
]],

  -- hard disk io: ${template4 device readSpeed writeSpeed}
  template4 = [[
${voffset 5}${offset [=lso + 5]}${color}${diskiograph_read /dev/\1 21,47 ${template2} \2}
${voffset -8}${offset [=lso + 5]}${diskiograph_write /dev/\1 21,47 ${template1} \3}
<#if isVerbose>
${voffset -48}${goto [=lso + 72]}${color}${font}${diskio_read /dev/\1}
${voffset 13}${goto [=lso + 72]}${color}${font}${diskio_write /dev/\1}${voffset 10}<#rt>
<#else>
${font}${voffset -12}\<#rt>
</#if>
]],

  -- filesystem: ${template6 filesystemName fileSystemPath}
  template6 = [[
${voffset 45}${offset [=lso + 6]}${color2}${if_match ${fs_used_perc \2} > 90}${color3}${endif}${fs_bar 3, 45 \2}
<#if isVerbose>
${voffset -46}${goto [=lso + 72]}${color}${font}\1
${voffset 4}${goto [=lso + 72]}${color}${font1}${fs_used_perc \2}${font0}%${font}${voffset 8}<#rt>
<#else>
${font}${voffset -7}\<#rt>
</#if>
]],

<#if system == "laptop" >
  -- color coded hwmon entry: index/device type index threshold
  template7 = [[${if_match ${hwmon \1 \2 \3} > \4}${color3}${else}${color4}${endif}${hwmon \1 \2 \3}]], 
    
  -- temperature: ${template8 index/device type index threshold}
  template8 = [[${voffset 7}${offset [=lso + 12]}${font2}${template7 \1 \2 \3 \4}${voffset -28}${font0}°${offset 4}${voffset -4}${font2}C${font}${color}${voffset 9}]]
</#if>
};

conky.text = [[
<#assign y = 0>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sidebar-[=system].png -p 0,[=y]}\
<#assign y += tso>
# :::::::::::::::::::: cpu
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-cpu.png -p [=lso + 5],[=y]}\
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box-99p.png -p [=lso + 68],[=y + 13]}\
</#if>
${if_match ${cpu cpu0} >= [=threshold.cpu]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-cpu-high.png -p [=lso + 5],[=y]}\
<#if isVerbose>
${if_match ${cpu cpu0} == 100}${image ~/conky/monochrome/images/[=conky]/text-box-100p.png -p [=lso + 110],[=y + 13]}${endif}\
</#if>
${endif}\
<#assign y += 48 + 9>
${voffset [=tso + 12]}${offset [=lso + 12]}${cpugraph cpu0 33,33 ${template1}}
<#if isVerbose>
${voffset -31}${goto [=lso + 72]}${color}${font1}${cpu cpu0}${font0}%
<#else>
${font0}${voffset -3}\
</#if>
# :::::::::::::::::::: memory
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-mem.png -p [=lso + 5],[=y]}\
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box-mem.png -p [=lso + 68],[=y + 19]}\
</#if>
${if_match ${memperc} >= [=threshold.mem]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-mem-high.png -p [=lso + 5],[=y]}\
${endif}\
<#assign y += 48 + 26>
${voffset 17}${offset [=lso + 18]}${memgraph 43,21 ${template1}}
<#if isVerbose>
${voffset -33}${goto [=lso + 72]}${color}${font1}${memperc}${font0}%
<#else>
${font}${voffset -5}\
</#if>
${voffset 4}${offset [=lso + 6]}${color2}${if_match ${swapperc} >= [=threshold.swap]}${color3}${endif}${swapbar 3, 45}<#if isVerbose>${voffset -2}${goto [=lso + 72]}${font}${color}${swapperc}%<#else>${font}${voffset -2}</#if>
# :::::::::::::::::::: network
<#-- TODO handle multiple network devices, for now only the main device (wifi) in a laptop is used -->
<#assign device = networkDevices?first>
<#if system == "laptop">
${if_up [=device.name]}\
<#assign ySection = y,
         y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-[=device.type].png -p [=lso + 5],[=y]}\
${voffset 49}${offset [=lso + 6]}${color2}${if_match ${wireless_link_qual_perc [=device.name]} < 30}${color3}${endif}${wireless_link_bar 3,45 [=device.name]}
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box-99p.png -p [=lso + 68],[=y + 15]}\
${if_match ${wireless_link_qual_perc [=device.name]} == 100}${image ~/conky/monochrome/images/[=conky]/text-box-100p.png -p [=lso + 110],[=y + 15]}${endif}\
${voffset -29}${goto [=lso + 72]}${color}${font1}${wireless_link_qual_perc [=device.name]}${font0}%${font}${voffset 4}
<#else>
${font}${voffset 2}\
</#if>
${else}\
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-no-[=device.type].png -p [=lso + 2],[=ySection + 1]}\
${font}${voffset 64}\
${endif}\
<#assign y += 46 + 9>
</#if>
${if_up [=device.name]}\
# :: upload/download bandwith
<#assign ySection = y,
         y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-internet.png -p [=lso + 5],[=y]}\
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box.png -p [=lso + 68],[=y + 11]}\
${image ~/conky/monochrome/images/[=conky]/text-box.png -p [=lso + 68],[=y + 45]}\
</#if>
<#assign device = networkDevices?first>
${template3 [=device.name] [=device.maxUp?c] [=device.maxDown?c]}
${else}\
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-no-internet.png -p [=lso + 2],[=ySection + 1]}\
${voffset 86}\
${endif}\
<#assign y += 64 + 9>
<#list hardDisks as hardDisk>
# :::::::::::::::::::: disk [=hardDisk.name!hardDisk.device]
<#-- special handling for the main 'sda' disk
     > partitions do not print their name since their icons are self explanatory
     > no disconnected image used since it does not have any -->
<#if hardDisk.device != "sda">${if_existing /dev/[=hardDisk.device]}\<#else># main disk</#if>
# disk io
<#assign ySection = y,
         y += 9>
${if_updatenr 1}${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-diskio-1.png -p [=lso + 5],[=y]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-diskio-2.png -p [=lso + 5],[=y]}${endif}\
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box.png -p [=lso + 68],[=y + 3]}\
${image ~/conky/monochrome/images/[=conky]/text-box.png -p [=lso + 68],[=y + 29]}\
</#if>
<#assign y += 48 + 9>
${template4 [=hardDisk.device] [=hardDisk.readSpeed?c] [=hardDisk.writeSpeed?c]}
# partitions
<#list hardDisk.partitions as partition>
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-disk-[=partition.icon].png -p [=lso + 5],[=y]}\
<#if hardDisk.device == "sda">
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box-99p.png -p [=lso + 68],[=y + 15]}\
</#if>
${template6 \  [=partition.path]}
<#else>
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box-partition.png -p [=lso + 68],[=y - 2]}\
</#if>
${template6 [=partition.name] [=partition.path]}
</#if>
<#assign y += 46 + 9>
</#list>
<#if hardDisk.device != "sda">
${else}\
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-no-disk.png -p [=lso + 2],[=ySection]}\
${voffset 9}${offset [=lso + 8 + 10]}${color1}[=hardDisk.device]${voffset 108}
${endif}\
</#if>
</#list>
# :::::::::::::::::::: temperatures
# use of lua variables corrupt the values for the network up/down variables, hence temp details shown in the separate 'temperature' conky
<#assign y += 9>
# :::::::: cpu
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-temp-cpu.png -p [=lso + 5],[=y]}\
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box-99p.png -p [=lso + 68],[=y + 15]}\
${image ~/conky/monochrome/images/[=conky]/text-box-100p.png -p [=lso + 68 + 31],[=y + 15]}\
</#if>
<#assign y += 46 + 9>
<#if system == "desktop" >
# :::::::: ati video card
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-temp-videocard.png -p [=lso + 5],[=y]}\
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box-99p.png -p [=lso + 68],[=y + 15]}\
${image ~/conky/monochrome/images/[=conky]/text-box-100p.png -p [=lso + 68 + 31],[=y + 15]}\
</#if>
<#assign y += 46 + 9>
# :::::::: hard disks
<#assign y += 9>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-temp-disk.png -p [=lso + 5],[=y]}\
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box-99p.png -p [=lso + 68],[=y + 15]}\
${image ~/conky/monochrome/images/[=conky]/text-box-100p.png -p [=lso + 68 + 31],[=y + 15]}\
</#if>
<#assign y += 46 + 9>
# :::::::: fans
<#assign y += 9>
${if_updatenr 1}${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-fan-1.png -p [=lso+5],[=y?c]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-fan-2.png -p [=lso+5],[=y?c]}${endif}\
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box-fan.png -p [=lso + 68],[=(y + 29)?c]}\
</#if>
<#assign y += 46 + 9>
</#if>
<#if system == "laptop" >
# :::::::::::::::::::: power
<#assign y += 9>
${voffset 64}\<#-- account for the cpu temperature widget being empty, its temp bar is printed by another conky -->
${if_match "${acpiacadapter}"=="on-line"}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-power-plugged-in.png -p [=lso + 5],[=y]}\
${else}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-power-battery.png -p [=lso + 5],[=y]}\
${endif}\
${voffset 45}${offset [=lso + 6]}${color2}${if_match ${battery_percent BAT0} < 20}${color3}${endif}${battery_bar 3, 45 BAT0}
<#if isVerbose>
${image ~/conky/monochrome/images/[=conky]/text-box-99p.png -p [=lso + 68],[=y + 15]}\
${if_match ${battery_percent BAT0} == 100}${image ~/conky/monochrome/images/[=conky]/text-box-100p.png -p [=lso + 110],[=y + 15]}${endif}\
${voffset -29}${goto [=lso + 72]}${color}${font1}${battery_percent BAT0}${font0}%${font}${voffset -6}
</#if>
<#assign y += 46 + 9>
</#if>
${voffset -420}\
]]
