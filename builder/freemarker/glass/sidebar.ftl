conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',    -- top|middle|bottom_left|middle|right
  gap_x = 0,                 -- same as passing -x at command line
  gap_y = -16,

  -- window settings
  minimum_width = 160,
  minimum_height = 1380,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)

  -- transparency configuration
  draw_blended = false,
  own_window_transparent = true,
  own_window_argb_visual = true,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 1,         -- width of border window in pixels
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
  use_xft = true,
  xftalpha = 0,
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  font = 'Nimbus Mono PS Regular:size=8',     -- text
  font0 = 'font URW Gothic Demi:size=8',      -- title
  font1 = 'font URW Gothic Demi:size=19',     -- big value
  font2 = 'font URW Gothic Demi:size=12',     -- mid value
  font3 = 'font URW Gothic Demi:size=9',      -- small value
  
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',        -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]',        -- bar critical
  
  -- :::::::::::::::::::::::::::::::: templates ::::::::::::::::::::::::::::::::
  --  n.b. the line break escape character '\' is not supported in templates :(

  -- cpu/mem/download/disk write graph color
  template1 = [[[=colors.writeGraph]]],
  -- upload/disk read graph
  template2 = [[[=colors.readGraph]]],  
  <#assign tso = 32,    <#-- vertical offset to account for background sidebar image's top shadow -->
           lso = 15,    <#-- horizontal offset to account for background sidebar image's left shadow -->
           iborder = 5, <#-- inner horizontal border -->
           rso = 32>    <#-- horizontal offset to account for background sidebar image's right shadow -->
  -- network device bandwith: ${template4 deviceName maxUpSpeed maxDownSpeed}
  template4 = [[
# upload
${voffset -4}${offset [=lso]}${upspeedgraph \1 48,112 ${template2} \2}
${voffset -54}${offset [=lso + iborder]}${color1}${font0}upload${font}
${voffset 1}${alignr [=rso + 6]}${color}${font2}${upspeed \1}${font}
${voffset 8}${alignr [=rso + 6]}${color}${font}${totalup \1} total
# download
${voffset -1}${offset [=lso]}${downspeedgraph \1 48,112 ${template1} \3}
${voffset -54}${offset [=lso + iborder]}${color1}${font0}download${font}
${voffset 1}${alignr [=rso + 6]}${color}${font2}${downspeed \1}${font}
${voffset 8}${alignr [=rso + 6]}${color}${font}${totaldown \1} total${font}${voffset 3}]],
  
  -- hard disk: ${template5 device readSpeed writeSpeed}
  template5 = [[
# disk read
${voffset -4}${offset [=lso]}${diskiograph_read /dev/\1 48,112 ${template2} \2}
${voffset -56}${offset [=lso + iborder]}${color1}${font0}disk read${alignr [=rso + 6]}${color}\1${font}
${voffset 3}${alignr [=rso + 6]}${color}${font2}${diskio_read /dev/\1}${font}
# disk write
${voffset -1}${offset [=lso]}${diskiograph_write /dev/\1 48,112 ${template1} \3}
${voffset -56}${offset [=lso + iborder]}${color1}${font0}disk write${font}
${voffset 3}${alignr [=rso + 6]}${color}${font2}${diskio_write /dev/\1}${font}${voffset 6}]],

  -- filesystem: ${template6 filesystemName fileSystemPath}
  template6 = [[
${voffset 3}${offset [=lso + iborder]}${color1}${font0}\1${font}
${voffset -14}${alignr [=rso + 6]}${color}${font2}${fs_used_perc \2}${font3}%${font}
${voffset -2}${offset [=lso + 19]}${color2}${if_match ${fs_used_perc \2} > 90}${color3}${endif}${fs_bar 3,89 \2}
${voffset -4}${alignr [=rso + 6]}${color}${font}${fs_used \2} / ${fs_size \2}${voffset 3}]],

  -- filesystem usb device: ${template7 filesystemName fileSystemPath}
  template7 = [[
${voffset 7}${offset [=lso + iborder]}${color1}${font0}\1
${if_mounted \2}${voffset -13}${alignr [=rso + 6]}${font2}${fs_used_perc \2}${font3}%
${voffset -2}${offset 13}${color2}${if_match ${fs_used_perc \2} > 90}${color3}${endif}${fs_bar 3,89 \2}
${voffset -4}${alignr [=rso + 6]}${color}${font}${fs_used \2} / ${fs_size \2}${voffset -8}
${else}${voffset 4}${alignr [=rso + 6]}${color}${font}device is not
${alignr [=rso + 6]}${color}connected${voffset 4}${endif}]],

  -- hwmon entry: ${template9 index/device type index threshold}
  template8 = [[${if_match ${hwmon \1 \2 \3} > \4}${color3}${else}${color}${endif}${hwmon \1 \2 \3}]]
};

conky.text = [[
<#assign y = 0>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sidebar<#if device == "laptop">-laptop</#if>.png -p 0,[=y]}\
# ::::::::::::::::: cpu
<#assign y += tso + 5>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-cpu.png -p [=lso],[=y]}\
<#assign y += 73>
${voffset [=tso - 3]}${color}${offset [=lso]}${cpugraph cpu0 48,112 ${template1}}
${voffset -56}${offset [=lso + iborder]}${color1}${font0}cpu${font}
${voffset -7}${alignr [=rso + 6]}${color}${font1}${cpu cpu0}${font2}%${font}
${voffset 12}${alignr [=rso + 6]}${color}${font}${loadavg}
<#if device == "laptop" >
<#-- the laptop cpu section adds core frequency and temp, therefore the memory image has to be shifted
     in order for this data to fit -->
${voffset 2}${offset [=lso + iborder]}${font}${color1}core 1 ${color}${freq_g 1}GHz ${color1}|${color}${alignr [=rso + 6]}${hwmon coretemp temp 2}°
${voffset 3}${offset [=lso + iborder]}${font}${color1}core 2 ${color}${freq_g 2}GHz ${color1}|${color}${alignr [=rso + 6]}${hwmon coretemp temp 3}°
</#if>
# ::::::::::::::::: memory
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-divider.png -p [=lso],[=y]}\
<#assign y += 1 + 44>
<#if device == "laptop" ><#assign y += 37></#if>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-mem.png -p [=lso+13],[=y]}\
<#assign y += 71 + 28>
${voffset -1}${offset [=lso]}${memgraph 48,112 ${template1}}
${voffset -56}${offset [=lso + iborder]}${color1}${font0}memory${font}
${voffset -7}${alignr [=rso + 6]}${color}${font1}${memperc}${font2}%${font}
${voffset 9}${alignr [=rso + 6]}${color}${font}${mem} / ${memmax}
# ::::::::::::::::: swap
${voffset 5}${offset [=lso + iborder]}${color1}${font0}swap${font}
${voffset -6}${alignr [=rso + 6]}${color}${font1}${swapperc}${font2}%${font}
${voffset -3}${offset [=lso + 19]}${color2}${if_match ${swapperc} > 75}${color3}${endif}${swapbar 3,89}
${voffset -5}${alignr [=rso + 6]}${color}${font}${swap} / ${swapmax}
# ::::::::::::::::: network
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-divider.png -p [=lso],[=y]}\
<#assign y += 1, ySection = y>
<#list networkDevices as device>
${if_up [=device.name]}\
<#if device.type == "wifi">
# :::::: wifi
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-wifi.png -p [=lso],[=y]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-internet.png -p [=lso + 18],[=y]}\
${voffset 7}${offset [=lso + iborder]}${color1}${font0}wifi${font}
${voffset -14}${alignr [=rso + 6]}${color}${font2}${wireless_link_qual_perc [=device.name]}${font3}%${font}
${voffset -2}${offset [=lso + 19]}${color2}${if_match ${wireless_link_qual_perc [=device.name]} < 30}${color3}${endif}${wireless_link_bar 3,89 [=device.name]}${font}
${voffset -4}${offset [=lso + iborder]}${color}${font}ch. ${wireless_channel [=device.name]}${alignr [=rso + 6]}${wireless_bitrate [=device.name]}${font}${voffset -1}
<#else>
# :::::: ethernet
<#assign y += 13>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-ethernet.png -p [=lso + 4],[=y]}\
<#assign y += 40 + 33>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-internet.png -p [=lso + 18],[=y]}\
<#assign y += 76 + 34>
${voffset 7}${offset [=lso + iborder]}${color1}${font0}ethernet${font}
${voffset 1}${alignr [=rso + 6]}${color}${execi 180 ethtool [=device.name] 2>/dev/null | grep -i speed | cut -d ' ' -f 2}
${alignr [=rso + 6]}${color}${addr [=device.name]}
</#if>
${template4 [=device.name] [=device.maxUp?c] [=device.maxDown?c]}
<#if device?has_next>
${else}\
<#else>
${else}\
# :::::: no network/internet
<#assign type = networkDevices?first.type>
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-no-[=type].png -p [=lso + 2],[=ySection + 2]}\
${voffset 7}${offset [=lso + iborder + 2]}${color}${font0}network${font}
${voffset 142}<#if device.type == "wifi">${offset [=lso + 39]}<#else>${offset [=lso + 27]}</#if>no [=type]
${offset [=lso + 29]}connection${voffset 3}
</#if>
</#list>
<#list 1..networkDevices?size as x>
${endif}\
</#list>
<#list hardDisks as disk>
<#assign ySection = y>
# ::::::::::::::::: disk [=disk.name!disk.device]
<#if disk.partitions?size == 1><#-- for disk with single partition add connected/disconnected state -->
${if_existing /dev/[=disk.device]}\
</#if>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-divider.png -p [=lso],[=y]}\
<#assign y += 1 + 5>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-disk.png -p [=lso + 2],[=y?c]}\
<#assign y += 93>
${template5 [=disk.device] [=disk.readSpeed?c] [=disk.writeSpeed?c]}
# :::::: partitions
<#list disk.partitions as partition>
${template6 [=partition.name] [=partition.path]}
<#assign y += 56>
<#if disk.partitions?size == 1>
${else}\
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-no-disk.png -p [=lso + 2],[=ySection + 2]}\
${voffset 7}${offset [=lso + iborder + 2]}${color}[=disk.device] disk
${offset [=lso + iborder + 2]}${color}${font4}not available
${voffset 100}
${endif}\
</#if>
</#list>
</#list>
<#if device == "desktop">
# ::::::::::::::::: temperatures
<#-- TODO use lua function to determine hottest core, disk -->
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-divider.png -p [=lso],[=y?c]}\
<#assign y += 1 + 10>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-thermometer.png -p [=lso + 4],[=y?c]}\
<#assign y += 89 + 10>
# :::: cpu
${voffset 4}${offset [=lso + iborder]}${color1}${font0}cpu${font}
${voffset -13}${alignr [=rso + 6]}${color}${font2}${template8 atk0110 temp 1 [=threshold.tempCPU]}°C${font}
${voffset 2}${alignr [=rso + 6]}${color}${font}${font}${template8 coretemp temp 2 [=threshold.tempCPUCore]}° ${template8 coretemp temp 3 [=threshold.tempCPUCore]}° ${font}${template8 coretemp temp 4 [=threshold.tempCPUCore]}° ${template8 coretemp temp 5 [=threshold.tempCPUCore]}°C${voffset -2}
# :::: video card
${voffset 6}${offset [=lso + iborder]}${color1}${font0}video card${font}
${voffset -13}${alignr [=rso + 6]}${color}${font2}${template8 radeon temp 1 [=threshold.tempVideo]}°C${font}
# :::: hard disks
<#assign disk = hardDisks?first>
${voffset 6}${offset [=lso + iborder]}${color1}${font0}hard disks${font}
${voffset -13}${alignr [=rso + 6]}${color}${font2}${template8 [=disk.hwmonIndex] temp 1 [=threshold.tempDisk]}°C${font}
# :::: fans
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-divider.png -p [=lso],[=y?c]}\
<#assign y += 1 + 6>
${if_updatenr 1}${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-fan1.png -p [=lso + 4],[=y?c]}${endif}\
${if_updatenr 2}${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-fan2.png -p [=lso + 4],[=y?c]}${endif}\
<#assign y += 41 + 6>
${voffset 7}${offset [=lso + iborder]}${color1}${font0}fans${font}
${voffset -8}${alignr [=rso + 6]}${color}${font2}${template8 atk0110 fan 1 [=(threshold.fanSpeed)?c]}${font}
${voffset -4}${alignr [=rso + 6]}${font}rpm${font}${voffset 10}
# ::::::::::::::::: time
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-divider.png -p [=lso],[=y?c]}\
<#assign y += 1 + 55>
${voffset 1}${offset [=lso + iborder]}${color1}${font Promenade de la Croisette:size=40}${time %I}${font Promenade de la Croisette:size=37}:${time %M}${font}${voffset -30}${alignr [=rso + 6]}${color}${time %A}
${voffset -1}${alignr [=rso + 6]}${time %B}
${voffset -1}${alignr [=rso + 6]}${time %d}
</#if>
${voffset -900}\]]
