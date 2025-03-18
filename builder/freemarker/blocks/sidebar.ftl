<#import "/lib/panel-round.ftl" as panel>
conky.config = {  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',  -- top|middle|bottom_left|right
  gap_x = 6,
  <#if system == "desktop"><#assign yOffset = 0><#else><#assign yOffset = 0></#if>
  gap_y = [=yOffset],

  -- window settings
  <#assign border = 6,
           lborder = border - 1,
           width = border * 2 + 83>
  minimum_width = [=width],      -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = 982,
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
  
  -- miscellanous settings
  imlib_cache_flush_interval = 250,

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.warning]',
  color3 = '[=colors.secondary.text]',        -- secondary panel text
  
  -- ::: templates
  -- highlight value if resource usage is high
  template1 = [[${if_match ${\1} >= \2}${color2}${endif}]],
  -- highlight value if resource usage is low or high
  template2 = [[${if_match ${\1} <= \2}${color2}${endif}${if_match ${\1} >= \3}${color2}${endif}]],
  -- use secondary color if music is playing
  template3 = [[${color}${if_existing /tmp/conky/musicplayer.playbackStatus Playing}${color3}${endif}]]
};

conky.text = [[
# :::::::::::: system
<#assign y = 0,
         gap = 6,
         height = 3*16+7,
         inputDir = "/tmp/conky",
         packagesFile = inputDir + "/dnf.packages.formatted">
<@panel.panel x=0 y=y height=height width=width/>
<#assign y = height + gap>
${voffset 5}${offset [=border]}${color}${scroll wait 14 1 1 ${kernel}}
${voffset 3}${offset [=border]}${color1}uptime${alignr [=lborder]}${color}${uptime_short}
${voffset 3}${offset [=border]}${color1}updates${alignr [=lborder]}${color}${if_existing [=packagesFile]}${lines [=packagesFile]}${else}none${endif}
# :::::::::::: cpu
<#assign height = 3*16+7>
<@panel.panel x=0 y=y height=height width=width/>
<#assign y += height + gap>
<#assign us = inputDir + "/system.cpu.us",
         id = inputDir + "/system.cpu.id">
${voffset [=7 + gap]}\
${voffset 3}${offset [=border]}${color1}us ${color}${template1 cat\ [=us] 50}${cat [=us]}%${goto 55}${color1}id${alignr [=lborder]}${color}${cat [=id]}%
<#assign sy = inputDir + "/system.cpu.sy",
         wa = inputDir + "/system.cpu.wa">
${voffset 3}${offset [=border]}${color1}sy ${color}${cat [=sy]}%${goto 55}${color1}wa${alignr [=lborder]}${color}${template1 cat\ [=wa] 20}${cat [=wa]}%
${voffset 3}${offset [=border]}${color1}load${alignr [=lborder]}${color}${loadavg 1} ${loadavg 2}
# :::::::::::: memory
<#assign height = 7*16+7>
<@panel.panel x=0 y=y height=height width=width/>
<#assign y += height + gap>
${voffset [=7 + gap]}\
${voffset 3}${offset [=border]}${color1}used${alignr [=lborder]}${color}${template1 memperc [=threshold.mem]}${mem}
${voffset 3}${offset [=border]}${color1}free${alignr [=lborder]}${color}${memfree}
${voffset 3}${offset [=border]}${color1}buff${alignr [=lborder]}${color}${buffers}
${voffset 3}${offset [=border]}${color1}cache${alignr [=lborder]}${color}${cached}
${voffset 3}${offset [=border]}${color1}si${alignr [=lborder]}${color}${cat /tmp/conky/system.swap.read}
${voffset 3}${offset [=border]}${color1}so${alignr [=lborder]}${color}${cat /tmp/conky/system.swap.write}
${voffset 3}${offset [=border]}${color1}swap${alignr [=lborder]}${color}${template1 swapperc [=threshold.swap]}${swap}
# :::::::::::: device read
<#assign height = 5*16+7>
<@panel.panel x=0 y=y height=height width=width isDark=true/>
<#assign y += height + gap>
${voffset [=7 + gap]}\
<#list networkDevices as device><#-- higlight if upload speed is greater than 2.5MiB -->
${voffset 3}${offset [=border]}${color1}[=device.name[0..4]]${alignr [=lborder]}${color}${template1 to_bytes\ ${upspeed\ [=device.name]} 2726297}${upspeed [=device.name]}
</#list>
<#list hardDisks as disk>
${voffset 3}${offset [=border]}${color1}[=disk.device]${alignr [=lborder]}${color}${diskio_read /dev/[=disk.device]}
</#list>
# :::::::::::: device write
<#assign height = 5*16+7>
<@panel.panel x=0 y=y height=height width=width/>
<#assign y += height + gap>
${voffset [=7 + gap]}\
<#list networkDevices as device><#-- higlight if download speed is greater than 60MiB -->
${voffset 3}${offset [=border]}${color1}[=device.name[0..4]]${alignr [=lborder]}${color}${template1 to_bytes\ ${downspeed\ [=device.name]} 62914560}${downspeed [=device.name]}
</#list>
<#list hardDisks as disk>
${voffset 3}${offset [=border]}${color1}[=disk.device]${alignr [=lborder]}${color}${diskio_write /dev/[=disk.device]}
</#list>
# :::::::::::: filesystems
<#assign height = 5*16+7>
<@panel.panel x=0 y=y height=height width=width/>
<#assign y += height + gap>
${voffset [=7 + gap]}\
<#list hardDisks as hardDisk>
<#list hardDisk.partitions as partition>
${voffset 3}${offset [=border]}${color1}[=partition.name]${alignr [=lborder]}${color}${template1 fs_used_perc\ [=partition.path] [=threshold.filesystem]}${fs_used_perc [=partition.path]}%
</#list>
</#list>
# :::::::::::: temperatures
<#assign height = 9*16+7>
<@panel.panel x=0 y=y height=height width=width/>
<#assign y += height + gap>
${voffset [=7 + gap]}\
${voffset 3}${offset [=border]}${color1}cpu${alignr}${color}${template1 hwmon\ atk0110\ temp\ 1 [=threshold.tempCPU]}${hwmon atk0110 temp 1}°
${voffset 3}${offset [=border]}${color1}core 1${alignr}${color}${template1 hwmon\ coretemp\ temp\ 2 [=threshold.tempCPUCore]}${hwmon coretemp temp 2}°
${voffset 3}${offset [=border]}${color1}core 2${alignr}${color}${template1 hwmon\ coretemp\ temp\ 3 [=threshold.tempCPUCore]}${hwmon coretemp temp 3}°
${voffset 3}${offset [=border]}${color1}core 3${alignr}${color}${template1 hwmon\ coretemp\ temp\ 4 [=threshold.tempCPUCore]}${hwmon coretemp temp 4}°
${voffset 3}${offset [=border]}${color1}core 4${alignr}${color}${template1 hwmon\ coretemp\ temp\ 5 [=threshold.tempCPUCore]}${hwmon coretemp temp 5}°
${voffset 3}${offset [=border]}${color1}radeon${alignr}${color}${template1 hwmon\ radeon\ temp\ 1 [=threshold.tempVideo]}${hwmon radeon temp 1}°
<#list hardDisks as disk>
<#if disk.hwmonIndex??>
${voffset 3}${offset [=border]}${color1}[=disk.name[0..8]]${alignr}${color}${template1 hwmon\ [=disk.hwmonIndex]\ temp\ 1 [=threshold.tempDisk]}${hwmon [=disk.hwmonIndex] temp 1}°
</#if>
</#list>
# :::::::::::: fans
<#assign height = 4*16+7>
<@panel.panel x=0 y=y height=height width=width/>
<#assign y += height + gap>
${voffset [=7 + gap]}\
${voffset 3}${offset [=border]}${color1}front${alignr [=lborder]}${color}${template2 hwmon\ atk0110\ fan\ 3 400 2300}${hwmon atk0110 fan 3} rpm
${voffset 3}${offset [=border]}${color1}cpu${alignr [=lborder]}${color}${template2 hwmon\ atk0110\ fan\ 1 400 2300}${hwmon atk0110 fan 1} rpm
${voffset 3}${offset [=border]}${color1}top${alignr [=lborder]}${color}${template2 hwmon\ atk0110\ fan\ 2 400 2300}${hwmon atk0110 fan 2} rpm
${voffset 3}${offset [=border]}${color1}back${alignr [=lborder]}${color}${template2 hwmon\ atk0110\ fan\ 4 400 2300}${hwmon atk0110 fan 4} rpm
# :::::::::::: now playing
<#assign  height = 3 + width-border + 3*16 + 6,
          inputDir = "/tmp/conky/">
<@panel.panel x=0 y=y height=height width=width/>
${if_existing [=inputDir + "musicplayer.status"] off}\
${voffset [=gap + 3 + width + 16]}\
${voffset 3}${offset [=border]}${color1}now playing
${voffset 3}${offset [=border]}${color}${scroll wait 14 2 1 no player running}
${else}\
${if_existing [=inputDir + "musicplayer.playbackStatus"] Playing}\
<@panel.panel x=0 y=y height=height width=width color=image.secondaryColor/>
${endif}\
${if_existing [=inputDir + "musicplayer.track.albumArtPath"]}\
${image ~/conky/monochrome/java/albumArt/nowPlaying -p [=3],[=y+3] -s [=width-border]x[=width-border] -n}\
<#assign y += height + gap>
${voffset [=gap + 3 + width]}\
${else}\
${voffset [=gap + 3 + width - 16]}\
${voffset 3}${offset [=border]}${template3}${scroll wait 14 2 1 ${cat [=inputDir + "musicplayer.name"]}}
${endif}\
${voffset 3}${offset [=border]}${template3}${scroll wait 14 2 1 ${cat [=inputDir + "musicplayer.track.title"]}}
${voffset 3}${offset [=border]}${template3}${scroll wait 14 2 1 ${cat [=inputDir + "musicplayer.track.album"]}}
${voffset 3}${offset [=border]}${template3}${scroll wait 14 2 1 ${cat [=inputDir + "musicplayer.track.artist"]}}
${endif}\
# :::::::::::: transmission
<#assign height = 4*16+7>
<@panel.panel x=0 y=y height=height width=width/>
<#assign y += height + gap>
${voffset [=7 + gap]}\
<#assign activeFile = inputDir + "transmission.active",
         peersFile = inputDir + "transmission.peers",
         uploadFile = inputDir + "transmission.speed.up",
         downloadFile = inputDir + "transmission.speed.down">
<#-- bug with ${lines} not honoring the ${alignr} offset -->
${voffset 3}${offset [=border]}${color1}torrents${alignr}${color}${lines [=activeFile]} 
${voffset 3}${offset [=border]}${color1}peers${alignr}${color}${lines [=peersFile]} 
${voffset 3}${offset [=border]}${color1}up${alignr [=lborder]}${color}${cat [=uploadFile]}
${voffset 3}${offset [=border]}${color1}dwn${alignr [=lborder]}${color}${cat [=downloadFile]}
]];
