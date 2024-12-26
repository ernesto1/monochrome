conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',     -- top|middle|bottom_left|middle|right
  gap_x = 6 ,                -- same as passing -x at command line
  gap_y = -16,

  -- window settings
  <#assign border = 6,
           lborder = border - 1,
           width = border * 2 + 83>
  minimum_width = [=width],
  maximum_width = [=width],
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)

  -- transparency configuration
  draw_blended = false,
  own_window_transparent = false,
  own_window_argb_visual = false,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)
  own_window_colour = '[=colors.panelColor]',

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 0,         -- width of border window in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels

  -- graph settings
  draw_graph_borders = false, -- borders around the graph, ex. cpu graph, network down speed grah
                              -- does not include bars, ie. wifi strength bar, cpu bar

  imlib_cache_flush_interval = 2,
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address
  
  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',         -- text labels
  color2 = '[=colors.warning]',         -- high resource usage
  color3 = '[=colors.category]',         -- text labels
};

conky.text = [[
# ::::::::::::::::: cpu
${voffset [=border-5]}${offset [=border]}${color3}cpu
<#assign inputDir = "/tmp/conky",
         us = inputDir + "/system.cpu.us",
         sy = inputDir + "/system.cpu.sy">
${voffset 3}${offset [=border]}${color1}us ${color}${cat [=us]}%${goto 55}${color1}sy${alignr [=lborder]}${color}${cat [=sy]}%
<#assign id = inputDir + "/system.cpu.id",
         wa = inputDir + "/system.cpu.wa">
${voffset 3}${offset [=border]}${color1}id ${color}${cat [=id]}%${goto 55}${color1}wa${alignr [=lborder]}${color}${cat [=wa]}%
${voffset 3}${offset [=border]}${color1}load ${color}${loadavg 1 2}
# ::::::::::::::::: memory
${voffset 5}${offset [=border]}${color3}memory
${voffset 3}${offset [=border]}${color1}total${alignr [=lborder]}${color}${memmax}
${voffset 3}${offset [=border]}${color1}free${alignr [=lborder]}${color}${memfree}
${voffset 3}${offset [=border]}${color1}used${alignr [=lborder]}${color}${if_match ${memperc} >= [=threshold.mem]}${color2}${endif}${mem}
${voffset 3}${offset [=border]}${color1}buff${alignr [=lborder]}${color}${buffers}
${voffset 3}${offset [=border]}${color1}cache${alignr [=lborder]}${color}${cached}
${voffset 3}${offset [=border]}${color1}si${alignr [=lborder]}${color}${cat /tmp/conky/system.swap.read}
${voffset 3}${offset [=border]}${color1}so${alignr [=lborder]}${color}${cat /tmp/conky/system.swap.write}
${voffset 3}${offset [=border]}${color1}swap${alignr [=lborder]}${color}${swap}
# ::::::::::::::::: i/o
${voffset 5}${offset [=border]}${color3}device i/o
<#assign device = hardDisks?first>
${voffset 3}${offset [=border]}${color1}read${alignr [=lborder]}${color}${diskio_read /dev/[=device.device]}
${voffset 3}${offset [=border]}${color1}write${alignr [=lborder]}${color}${diskio_write /dev/[=device.device]}
<#assign device = networkDevices?first>
${voffset 3}${offset [=border]}${color1}up${alignr [=lborder]}${color}${upspeed [=device.name]}
${voffset 3}${offset [=border]}${color1}down${alignr [=lborder]}${color}${downspeed [=device.name]}
# ::::::::::::::::: filesystems
${voffset 5}${offset [=border]}${color3}filesystems
<#list hardDisks as hardDisk>
<#list hardDisk.partitions as partition>
${voffset 3}${offset [=border]}${color1}[=partition.name]${alignr [=lborder]}${color}${if_match ${fs_used_perc [=partition.path]} >= [=threshold.filesystem]}${color2}${endif}${fs_used_perc [=partition.path]}%
</#list>
</#list>
# ::::::::::::::::: media
${if_existing /tmp/conky/musicplayer.albumArtPath}\
${voffset 5}${offset [=border]}${color3}${cat /tmp/conky/musicplayer.name}
${image ~/conky/monochrome/java/albumArt/albumArt -p [=border],[=357+border] -s [=width-border*2]x[=width-border*2]}\
${voffset 87}\
${voffset 6}${offset [=border]}${color}${scroll wait 14 3 1 ${cat /tmp/conky/musicplayer.title}}
${voffset 3}${offset [=border]}${color}${scroll wait 14 3 1 ${cat /tmp/conky/musicplayer.artist}}
${endif}\
<#if system == "laptop">
# ::::::::::::::::: wifi
<#assign device = networkDevices?first>
${if_up [=device.name]}\
# shift the y offset further down in order to move the music album art
${voffset 5}${offset [=border]}${color3}wifi
${voffset 3}${offset [=border]}${color1}net ${color}${scroll wait 10 3 1 ${wireless_essid [=device.name]}}
${voffset 3}${offset [=border]}${color1}strength${alignr [=lborder]}${color}${if_match ${wireless_link_qual_perc [=device.name]} <= [=threshold.wifi]}${color2}${endif}${wireless_link_qual_perc [=device.name]}%
${voffset 3}${offset [=border]}${color1}bit${alignr [=lborder]}${color}${wireless_bitrate [=device.name]}
${voffset 3}${offset [=border]}${color1}channel${alignr [=lborder]}${color}${wireless_channel [=device.name]}
${endif}\
</#if>
# ::::::::::::::::: system
${voffset 5}${offset [=border]}${color3}system
${voffset 3}${offset [=border]}${color1}uptime${alignr [=lborder]}${color}${uptime_short}
<#if system == "laptop">
${voffset 3}${offset [=border]}${color1}${if_match "${acpiacadapter}"=="on-line"}power${else}battery${endif}${alignr [=lborder]}${color}${if_match ${battery_percent BAT0} <= [=threshold.bat]}${color2}${endif}${battery_percent BAT0}%
</#if>
<#assign packagesFile = inputDir + "/dnf.packages.formatted">
${voffset 3}${offset [=border]}${color1}updates${alignr [=lborder]}${color}${if_existing [=packagesFile]}${lines [=packagesFile]}${else}none${endif}
# ::::::::::::::::: temperature
${voffset 5}${offset [=border]}${color3}temperature
<#if system == "laptop">
${voffset 3}${offset [=border]}${color1}core 1${alignr}${color}${hwmon coretemp temp 2}°
${voffset 3}${offset [=border]}${color1}core 2${alignr}${color}${hwmon coretemp temp 3}°
</#if>
${voffset [=-15+border]}\
]];
