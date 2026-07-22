<#if device == "laptop">
<@outputFileDirective filename="sidebar">
conky.config = {  
  update_interval = 1.5,    -- update interval in seconds
  xinerama_head = 0,        -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,     -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- top|middle|bottom_left|right
  gap_x = 0,
  gap_y = 32,

  -- window settings
  <#assign width = 203><#-- conky will add 1px, so the final width is 204 (204/6=34) -->
  minimum_width = [=width?c],   -- conky will add an extra pixel to this
  maximum_width = [=width?c],
  minimum_height = [=768-32-23-1],<#-- screen height - gnome top bar - bottom panel - 1 for extra conky pixel -->
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 1,         -- width of border window in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels
  
  -- transparency configuration
  draw_blended = false,
  own_window_transparent = true,
  own_window_argb_visual = true,    -- turn on transparency
  own_window_argb_value = 255,      -- range from 0 (transparent) to 255 (opaque)
  
  -- miscellanous settings
  imlib_cache_flush_interval = 250,
  if_up_strictness = 'address',
  
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  
  -- ::: templates
  -- highlight value if resource usage is high
  template1 = [[${if_match ${\1} >= \2}${color2}${endif}]],
  -- highlight value if resource usage is low
  template2 = [[${if_match ${\1} <= \2}${color2}${endif}]],
  
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.warning]',
  
  -- ::: templates
  -- highlight value if resource usage is high
  template1 = [[${if_match ${\1} >= \2}${color2}${endif}]]
};

conky.text = [[
${image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png -p 0,0}\
<#-- char width is 6px, use single space for borders -->
<#assign iborder = 6,
         inputDir = "/tmp/conky/",
         us = inputDir + "system.cpu.us",
         sy = inputDir + "system.cpu.sy",
         id = inputDir + "system.cpu.id",
         wa = inputDir + "system.cpu.wa",
         column = 2*6+6+3*6+6*2>
${voffset 3}${offset [=iborder]}${color1}cpu ${hr}
${voffset 3}\
${voffset 3}${offset [=iborder]}${color1}us ${color}${cat [=us]}%${goto [=1+iborder+column+6]}${color1}sy ${color}${cat [=sy]}%${goto [=1+iborder+column*2+6]}${color1}id ${color}${cat [=id]}%${goto [=1+iborder+column*3+6*2]}${color1}wa${alignr [=iborder-1]}${color}${template1 cat\ [=wa] 40}${cat [=wa]}%
<#list 1..2 as x>
${voffset 3}${offset [=iborder]}${color1}core [=x]${alignr [=(20*6)-1]}${color}${cpu cpu[=x]}%
${voffset -13}${alignr [=(9*6)-1]}${freq [=x]}MHz
${voffset -13}${alignr}${template1 hwmon\ coretemp\ temp\ [=x+1] [=threshold.tempCPUCore]}${hwmon coretemp temp [=x+1]}°
</#list>
${voffset 3}${offset [=iborder]}${color1}processes ${color}${running_processes}${alignr [=iborder-1]}${color}${running_threads} ${color1}threads
${voffset 8}\
# :::::: top processes
${offset [=iborder]}${color1}top processes ${hr}
${voffset 3}\
# ::: top cpu
${color1}${offset [=iborder]}process${alignr [=iborder-1]}cpu     mem
<#assign processes = 5>
<#list 1..processes as x>
${voffset 3}${color}${offset [=iborder]}${top name [=x]}${alignr [=iborder-1]}${top cpu [=x]}% ${top mem [=x]}%
</#list>
# ::: top memory
${voffset 8}\
${offset [=iborder]}${color1}process${alignr [=iborder-1]}memory    perc
<#list 1..processes as x>
${voffset 3}${color}${offset [=iborder]}${top_mem name [=x]}${alignr [=iborder-1]}${top_mem mem_res [=x]} ${top_mem mem [=x]}%
</#list>
# ::: top disk i/o
${voffset 8}\
<#-- there seems to be a bug in the goto variable, adding 1px to get the proper length of 6px per char -->
${color1}${offset [=iborder]}process${goto [=1+6+16*6+6+6*3]}read${alignr [=iborder-1]}write
<#list 1..processes as x><#-- in order to left align the r/w values, we need to lines per process :S -->
${voffset 3}${color}${offset [=iborder]}${top_io name [=x]}${alignr [=iborder-1+8*6]}${top_io io_read [=x]}
${voffset -13}${alignr [=iborder-1]}${top_io io_write [=x]}
</#list>
# :::::: memory
${voffset 8}\
${offset [=iborder]}${color1}memory ${hr}
${voffset 6}${offset [=iborder]}${color1}used${goto [=1+iborder+6*6+6]}${color}${mem}${alignr [=iborder-1]}${color}${memmax}${color1} total   
${voffset 3}${offset [=iborder]}${color1}free${goto [=1+iborder+6*6+6]}${color}${memfree}${alignr [=iborder-1]}${color}${swap}${color1} swap    
<#assign swapRead = inputDir + "system.swap.read",
         swapWrite = inputDir + "system.swap.write">
${voffset 3}${offset [=iborder]}${color1}cache${goto [=1+iborder+6*6+6]}${color}${cached}${alignr [=iborder-1]}${color}${cat [=swapRead]}${color1} swap in 
${voffset 3}${offset [=iborder]}${color1}buffer${goto [=1+iborder+6*6+6]}${color}${buffers}${alignr [=iborder-1]}${cat [=swapWrite]}${color1} swap out
# :::::: now playing
${voffset [=8+3]}\
${offset [=iborder]}${color1}${if_existing [=inputDir + "musicplayer.playbackStatus"] Playing}${color2}${endif}now playing ${hr}
${if_existing [=inputDir + "musicplayer.status"] off}\
${voffset 3}${offset [=iborder]}${color}no music player running
${else}\
<#assign y = 8*5+15*16+processes*3*16><#-- voffest 8+titles/lines+processes -->
${image ~/conky/monochrome/images/common/[=image.primaryColor]-album-cover.png -p 141,[=y] -n}\
${image /tmp/conky/musicplayer.track.art -p 134,[=y-4] -s 66x66 -n}\
${voffset 3}${offset [=iborder]}${color}${scroll wait 21 4 1 ${cat /tmp/conky/musicplayer.track.title}}
${voffset 3}${offset [=iborder]}${scroll wait 21 4 1 ${cat /tmp/conky/musicplayer.track.album}}
${voffset 3}${offset [=iborder]}${scroll wait 21 4 1 ${cat /tmp/conky/musicplayer.track.artist}}
${voffset 3}${offset [=iborder]}${scroll wait 21 4 1 ${cat /tmp/conky/musicplayer.track.genre}}
${endif}\
# :::::: wifi
${voffset [=8+3]}\
${color1} wireless ${hr}
<#assign netDevice = networkDevices?first>
${if_up [=netDevice.name]}\
${voffset 3}${offset [=iborder]}${color1}frequency${goto [=1+iborder+10*6]}${color}${wireless_freq [=netDevice.name]}${alignr [=iborder-1]}${wireless_channel [=netDevice.name]} ${color1}chan
${voffset 3}${offset [=iborder]}${color1}bitrate${goto [=1+iborder+10*6]}${color}${wireless_bitrate [=netDevice.name]}
${voffset 3}${offset [=iborder]}${color1}upload${goto [=1+iborder+10*6]}${color}${totalup [=netDevice.name]}${alignr [=iborder-1]}${totaldown [=netDevice.name]} ${color1}down
${else}\
${voffset 3}${offset [=iborder]}${color}not connected to wifi
${endif}\
]];
</@outputFileDirective>
</#if>
