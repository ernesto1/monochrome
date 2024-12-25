conky.config = {
  lua_load = '~/conky/monochrome/common.lua',
  lua_draw_hook_pre = 'reset_state',
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_right',     -- top|middle|bottom_left|middle|right
  gap_x = 6 ,                -- same as passing -x at command line
  gap_y = -16,

  -- window settings
  <#assign width = 97>
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

  imlib_cache_flush_interval = 250,
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
${voffset 2}${offset 7}${color3}cpu
<#assign inputDir = "/tmp/conky",
         us = inputDir + "/system.cpu.us",
         sy = inputDir + "/system.cpu.sy">
${voffset 3}${offset 7}${color1}us ${color}${cat [=us]}%${goto 55}${color1}sy ${color}${cat [=sy]}%
<#assign id = inputDir + "/system.cpu.id",
         wa = inputDir + "/system.cpu.wa">
${voffset 3}${offset 7}${color1}id ${color}${cat [=id]}%${goto 55}${color1}wa ${color}${cat [=wa]}%
${voffset 3}${offset 7}${color1}load ${color}${loadavg 1 2}
# ::::::::::::::::: memory
${voffset 5}${offset 7}${color3}memory
${voffset 3}${offset 7}${color1}total${alignr 6}${color}${memmax}
${voffset 3}${offset 7}${color1}free${alignr 6}${color}${memfree}
${voffset 3}${offset 7}${color1}used${alignr 6}${color}${mem}
${voffset 3}${offset 7}${color1}buff${alignr 6}${color}${buffers}
${voffset 3}${offset 7}${color1}cache${alignr 6}${color}${cached}
${voffset 3}${offset 7}${color1}si${alignr 6}${color}${cat /tmp/conky/system.swap.read}
${voffset 3}${offset 7}${color1}so${alignr 6}${color}${cat /tmp/conky/system.swap.write}
${voffset 3}${offset 7}${color1}swap${alignr 6}${color}${swap}
# ::::::::::::::::: i/o
${voffset 5}${offset 7}${color3}device i/o
<#assign device = hardDisks?first>
${voffset 3}${offset 7}${color1}read${alignr 6}${color}${diskio_read /dev/[=device.device]}
${voffset 3}${offset 7}${color1}write${alignr 6}${color}${diskio_write /dev/[=device.device]}
<#assign device = networkDevices?first>
${voffset 3}${offset 7}${color1}up${alignr 6}${color}${upspeed [=device.name]}
${voffset 3}${offset 7}${color1}down${alignr 6}${color}${downspeed [=device.name]}
# ::::::::::::::::: filesystems
${voffset 5}${offset 7}${color3}filesystems
<#list hardDisks as hardDisk>
<#list hardDisk.partitions as partition>
${voffset 3}${offset 7}${color1}[=partition.name]${alignr 6}${color}${fs_used_perc [=partition.path]}%
</#list>
</#list>
<#if system == "laptop">
# ::::::::::::::::: wifi
<#assign device = networkDevices?first>
${if_up [=device.name]}\
# shift the y offset further down in order to move the music album art
${lua increment_offsets 0 82}\
${voffset 5}${offset 7}${color3}wifi
${voffset 3}${offset 7}${color1}net${alignr 6}${color}${lua_parse truncate_string ${wireless_essid [=device.name]} 10}
${voffset 3}${offset 7}${color1}strength${alignr 6}${color}${wireless_link_qual_perc [=device.name]}%
${voffset 3}${offset 7}${color1}bit${alignr 6}${color}${wireless_bitrate [=device.name]}
${voffset 3}${offset 7}${color1}channel${alignr 6}${color}${wireless_channel [=device.name]}
${endif}\
</#if>
# ::::::::::::::::: media
${if_existing /tmp/conky/musicplayer.albumArtPath}\
${voffset 5}${offset 7}${color3}${cat /tmp/conky/musicplayer.name}
${lua increment_offsets 0 364}\
${lua_parse load_image ${cat /tmp/conky/musicplayer.albumArtPath} [=width-7*2]x[=width-7*2] [=7] 0}\
${voffset 85}\
${voffset 6}${offset 7}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.title} 14}
${voffset 3}${offset 7}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.artist} 14}
${endif}\
# ::::::::::::::::: system
${voffset 5}${offset 7}${color3}system
${voffset 3}${offset 7}${color1}uptime${alignr 6}${color}${uptime_short}
<#if system == "laptop">
${voffset 3}${offset 7}${color1}${if_match "${acpiacadapter}"=="on-line"}power${else}battery${endif}${alignr 6}${color}${battery_percent BAT0}%
</#if>
<#assign packagesFile = inputDir + "/dnf.packages.formatted">
${voffset 3}${offset 7}${color1}updates${alignr 6}${color}${if_existing [=packagesFile]}${lines [=packagesFile]}${else}none${endif}
${voffset -8}\
]];
