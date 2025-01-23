<#import "/lib/panel-round.ftl" as panel>
conky.config = {  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
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
  minimum_height = 973,
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

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.warning]'
};

conky.text = [[
# :::::::::::: system
<#assign y = 0,
         gap = 6,
         height = 3*16+6,
         inputDir = "/tmp/conky",
         packagesFile = inputDir + "/dnf.packages.formatted">
<@panel.panel x=0 y=y height=height width=width color=image.primaryColor/>
<#assign y = height + gap>
${voffset 4}${offset [=border]}${color}${scroll wait 14 1 1 ${kernel}}
${voffset 3}${offset [=border]}${color1}uptime${alignr [=lborder]}${color}${uptime_short}
${voffset 3}${offset [=border]}${color1}dnf${alignr [=lborder]}${color}${if_existing [=packagesFile]}${lines [=packagesFile]}${else}none${endif}
# :::::::::::: cpu
<#assign height = 3*16+6>
<@panel.panel x=0 y=y height=height width=width color=image.primaryColor/>
<#assign y += height + gap>
<#assign us = inputDir + "/system.cpu.us",
         sy = inputDir + "/system.cpu.sy">
${voffset [=6 + gap]}\
${voffset 3}${offset [=border]}${color1}us ${color}${cat [=us]}%${goto 55}${color1}sy${alignr [=lborder]}${color}${cat [=sy]}%
<#assign id = inputDir + "/system.cpu.id",
         wa = inputDir + "/system.cpu.wa">
${voffset 3}${offset [=border]}${color1}id ${color}${cat [=id]}%${goto 55}${color1}wa${alignr [=lborder]}${color}${cat [=wa]}%
${voffset 3}${offset [=border]}${color1}load${alignr [=lborder]}${color}${loadavg 1} ${loadavg 2}
# :::::::::::: memory
<#assign height = 7*16+6>
<@panel.panel x=0 y=y height=height width=width color=image.primaryColor/>
<#assign y += height + gap>
${voffset [=6 + gap]}\
${voffset 3}${offset [=border]}${color1}used${alignr [=lborder]}${color}${if_match ${memperc} >= [=threshold.mem]}${color2}${endif}${mem}
${voffset 3}${offset [=border]}${color1}free${alignr [=lborder]}${color}${memfree}
${voffset 3}${offset [=border]}${color1}buff${alignr [=lborder]}${color}${buffers}
${voffset 3}${offset [=border]}${color1}cache${alignr [=lborder]}${color}${cached}
${voffset 3}${offset [=border]}${color1}swap${alignr [=lborder]}${color}${swap}
${voffset 3}${offset [=border]}${color1}si${alignr [=lborder]}${color}${cat /tmp/conky/system.swap.read}
${voffset 3}${offset [=border]}${color1}so${alignr [=lborder]}${color}${cat /tmp/conky/system.swap.write}
# :::::::::::: device read
<#assign height = 5*16+6>
<@panel.panel x=0 y=y height=height width=width color=image.primaryColor/>
<#assign y += height + gap>
${voffset [=6 + gap]}\
<#list networkDevices as device>
${voffset 3}${offset [=border]}${color1}[=device.name[0..4]]${alignr [=lborder]}${color}${upspeed [=device.name]}
</#list>
<#list hardDisks as disk>
${voffset 3}${offset [=border]}${color1}[=disk.device]${alignr [=lborder]}${color}${diskio_read /dev/[=disk.device]}
</#list>
# :::::::::::: device write
<#assign height = 5*16+6>
<@panel.panel x=0 y=y height=height width=width color=image.primaryColor/>
<#assign y += height + gap>
${voffset [=6 + gap]}\
<#list networkDevices as device>
${voffset 3}${offset [=border]}${color1}[=device.name[0..4]]${alignr [=lborder]}${color}${downspeed [=device.name]}
</#list>
<#list hardDisks as disk>
${voffset 3}${offset [=border]}${color1}[=disk.device]${alignr [=lborder]}${color}${diskio_write /dev/[=disk.device]}
</#list>
# :::::::::::: filesystems
<#assign height = 5*16+6>
<@panel.panel x=0 y=y height=height width=width color=image.primaryColor/>
<#assign y += height + gap>
${voffset [=6 + gap]}\
<#list hardDisks as hardDisk>
<#list hardDisk.partitions as partition>
${voffset 3}${offset [=border]}${color1}[=partition.name]${alignr [=lborder]}${color}${if_match ${fs_used_perc [=partition.path]} >= [=threshold.filesystem]}${color2}${endif}${fs_used_perc [=partition.path]}%
</#list>
</#list>
# :::::::::::: temperatures
<#assign height = 9*16+6>
<@panel.panel x=0 y=y height=height width=width color=image.primaryColor/>
<#assign y += height + gap>
${voffset [=6 + gap]}\
${voffset 3}${offset [=border]}${color1}cpu${alignr}${color}${hwmon atk0110 temp 1}°
${voffset 3}${offset [=border]}${color1}core 1${alignr}${color}${hwmon coretemp temp 2}°
${voffset 3}${offset [=border]}${color1}core 2${alignr}${color}${hwmon coretemp temp 3}°
${voffset 3}${offset [=border]}${color1}core 3${alignr}${color}${hwmon coretemp temp 4}°
${voffset 3}${offset [=border]}${color1}core 4${alignr}${color}${hwmon coretemp temp 5}°
${voffset 3}${offset [=border]}${color1}radeon${alignr}${color}${hwmon radeon temp 1}°
<#list hardDisks as disk>
<#if disk.hwmonIndex??>
${voffset 3}${offset [=border]}${color1}[=disk.name[0..8]]${alignr}${color}${hwmon [=disk.hwmonIndex] temp 1}°
</#if>
</#list>
# :::::::::::: fans
<#assign height = 4*16+6>
<@panel.panel x=0 y=y height=height width=width color=image.primaryColor/>
<#assign y += height + gap>
${voffset [=6 + gap]}\
${voffset 3}${offset [=border]}${color1}front${alignr [=lborder]}${color}${hwmon atk0110 fan 3} rpm
${voffset 3}${offset [=border]}${color1}cpu${alignr [=lborder]}${color}${if_match ${to_bytes ${hwmon atk0110 fan 1}} <= 400}${color2}${endif}${hwmon atk0110 fan 1} rpm
${voffset 3}${offset [=border]}${color1}top${alignr [=lborder]}${color}${hwmon atk0110 fan 2} rpm
${voffset 3}${offset [=border]}${color1}back${alignr [=lborder]}${color}${hwmon atk0110 fan 4} rpm
# :::::::::::: now playing
<#assign height = 3 + width-border + 3*16 + 6>
<@panel.panel x=0 y=y height=height width=width color=image.primaryColor/>
${image ~/conky/monochrome/java/albumArt/nowPlaying -p [=3],[=y+3] -s [=width-border]x[=width-border] -n}\
<#assign y += height + gap>
${voffset [=gap + 3 + width]}\
${voffset 3}${offset [=border]}${color}${scroll wait 14 2 1 ${cat /tmp/conky/musicplayer.title}}
${voffset 3}${offset [=border]}${color}${scroll wait 14 2 1 ${cat /tmp/conky/musicplayer.album}}
${voffset 3}${offset [=border]}${color}${scroll wait 14 2 1 ${cat /tmp/conky/musicplayer.artist}}
# :::::::::::: transmission
<#assign height = 4*16+6>
<@panel.panel x=0 y=y height=height width=width color=image.primaryColor/>
<#assign y += height + gap>
${voffset [=6 + gap]}\
<#assign inputDir = "/tmp/conky/",
         activeFile = inputDir + "transmission.active",
         peersFile = inputDir + "transmission.peers",
         uploadFile = inputDir + "transmission.speed.up",
         downloadFile = inputDir + "transmission.speed.down">
<#-- bug with ${lines} not honoring the ${alignr} offset -->
${voffset 3}${offset [=border]}${color1}torrents${alignr}${color}${lines [=activeFile]} 
${voffset 3}${offset [=border]}${color1}peers${alignr}${color}${lines [=peersFile]} 
${voffset 3}${offset [=border]}${color1}up${alignr [=lborder]}${color}${cat [=uploadFile]}
${voffset 3}${offset [=border]}${color1}down${alignr [=lborder]}${color}${cat [=downloadFile]}
]];
