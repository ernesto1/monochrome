<#import "/lib/panel-round.ftl" as panel>
conky.config = {  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_middle',  -- top|middle|bottom_left|right
  gap_x = 0,
  gap_y = 6,

  -- window settings
  <#assign width = 1144>
  minimum_width = [=width?c],      -- conky will add an extra pixel to this
  maximum_width = [=width?c],
  minimum_height = 23,
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
  
  -- ::: templates
  -- highlight value if resource usage is high
  template1 = [[${if_match ${\1} >= \2}${color2}${endif}]],
  -- highlight value if resource usage is low
  template2 = [[${if_match ${\1} <= \2}${color2}${endif}]],
  
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.warning]'  
};

conky.text = [[
<@panel.panel x=0 y=0 width=width height=23 isDark=isDark/>
<#-- char width is 6px, use single space for borders -->
<#assign charWidth = 6, x = charWidth>
# :::::: cpu
${voffset 5}${goto [=x?c]}${color1}load ${color}${loadavg}\
<#-- x notation = num char label * c + single space (c) + num char value * c + single space (c) -->
<#assign x += 4 * charWidth + charWidth + 16 * charWidth + charWidth>
${goto [=x?c]}${color1}cpu ${color}${template1 cpu\ 0 [=threshold.cpu]}${cpu 0}%\
<#assign x += 3 * charWidth + charWidth + 4 * charWidth + charWidth>
<#assign x += charWidth><#-- section break -->
# :::::: memory
${goto [=x?c]}${color1}mem ${color}${template1 memperc [=threshold.mem]}${memperc}%\
<#assign x += 3 * charWidth + charWidth + 3 * charWidth + charWidth>
${goto [=x?c]}${color1}swap ${color}${template1 swapperc [=threshold.swap]}${swapperc}%\
<#assign x += 4 * charWidth + charWidth + 3 * charWidth + charWidth>
<#assign x += charWidth><#-- section break -->
# :::::: filesystems
<#list hardDisks as hardDisk>
<#list hardDisk.partitions as partition>
${goto [=x?c]}${color1}[=partition.name] ${color}${template1 fs_used_perc\ [=partition.path] [=threshold.filesystem]}${fs_used_perc [=partition.path]}%\
<#assign x += partition.name?length * charWidth + charWidth + 3 * charWidth + charWidth>
</#list>
</#list>
<#assign x += charWidth><#-- section break -->
# :::::: disk i/o
<#assign disk = hardDisks?first>
${goto [=x?c]}${color1}read ${color}${diskio_read /dev/[=disk.device]}\
<#assign x += 4 * charWidth + charWidth + 7 * charWidth + charWidth>
${goto [=x?c]}${color1}write ${color}${diskio_write /dev/[=disk.device]}\
<#assign x += 5 * charWidth + charWidth + 7 * charWidth + charWidth>
<#assign x += charWidth><#-- section break -->
# :::::: network
<#assign netDevice = networkDevices?first>
${goto [=x?c]}${color1}up ${color}${upspeed [=netDevice.name]}\
<#assign x += 2 * charWidth + charWidth + 7 * charWidth + charWidth>
${goto [=x?c]}${color1}down ${color}${downspeed [=netDevice.name]}\
<#assign x += 4 * charWidth + charWidth + 7 * charWidth + charWidth>
<#assign x += charWidth><#-- section break -->
${goto [=x?c]}${color1}wifi ${color}${scroll wait 14 2 1 ${wireless_essid [=netDevice.name]}}\
<#assign x += 4 * charWidth + charWidth + 14 * charWidth + charWidth>
${goto [=x?c]}${color1}strength ${color}${template2 wireless_link_qual_perc\ [=netDevice.name] [=threshold.wifi]}${wireless_link_qual_perc [=netDevice.name]}%\
<#assign x += 8 * charWidth + charWidth + 4 * charWidth + charWidth>
<#assign x += charWidth><#-- section break -->
# :::::: miscellaneous
${goto [=x?c]}${color1}${if_match "${acpiacadapter}"=="on-line"}power ${else}battery ${endif}${color}${template2 battery_percent\ BAT0 [=threshold.bat]}${battery_percent BAT0}%\
<#assign x += 6 * charWidth + charWidth + 4 * charWidth + charWidth>
${goto [=x?c]}${color1}uptime ${color}${uptime}\
]];
