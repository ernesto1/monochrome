conky.config = {
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',  -- top|middle|bottom_left|right
  gap_x = 150,               -- same as passing -x at command line
  gap_y = 90,

  -- window settings
  minimum_width = 189,      -- conky will add an extra pixel to this  
  maximum_width = 189,
  minimum_height = 493,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)
  own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 1,         -- width of border window in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels
  
  -- transparency configuration
  draw_blended = false,
  own_window_transparent = true,
  own_window_argb_visual = true,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)
  
  -- images
  imlib_cache_flush_interval = 250,
  
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address  
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.detailsText]',  -- regular text
  color1 = '[=colors.labels]',
  
  -- top cpu process: ${template1 processNumber}
  template1 = [[${voffset 3}${color}${offset 5}${top name \1}${alignr 5}${top cpu \1}% ${top pid \1}]],
  -- top mem process: ${template2 processNumber}
  template2 = [[${voffset 3}${color}${offset 5}${top_mem name \1}${alignr 5}${top_mem mem_res \1} ${top_mem pid \1}]],
  -- torrent peer ip/port: ${template3 #}
  template3 = [[${voffset 3}${offset 5}${color}${tcp_portmon 51413 51413 rip \1}${alignr 5}${tcp_portmon 51413 51413 rport \1}]]
};

conky.text = [[
# :::::::::::: top cpu/mem processes
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-block-large.png -p 0,0}\
${voffset 3}${color1}${offset 5}process${alignr 5}cpu   pid${voffset 1}
${template1 1}
${template1 2}
${template1 3}
${template1 4}
${template1 5}
${voffset 8}${color1}${offset 5}process${alignr 5}memory   pid${voffset 1}
${template2 1}
${template2 2}
${template2 3}
${template2 4}
${template2 5}
# :::::::::::: network
# assumption: only one network device will be connected to the internet at a time
<#list networkDevices[system] as device>
<#if device.type == "wifi">
# :::::: wifi
${if_up [=device.name]}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-block-small.png -p 0,210}\
${voffset 17}${offset 5}${color1}network${goto 60}${color}${wireless_essid [=device.name]}
${voffset 3}${offset 5}${color1}local ip${goto 60}${color}${addr [=device.name]}
${voffset 3}${offset 5}${color1}bitrate${goto 60}${color}${wireless_bitrate [=device.name]}
${voffset 3}${offset 5}${color1}channel${goto 60}${color}${wireless_channel [=device.name]}
${endif}\
</#if>
<#if device.type == "ethernet">
# :::::: ethernet
${if_up [=device.name]}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-block-small.png -p 0,210}\
${voffset 17}${offset 5}${color1}local ip${goto 73}${color}${addr [=device.name]}
${voffset 3}${offset 5}${color1}speed${goto 73}${color}${execi 180 ethtool [=device.name] 2>/dev/null | grep -i speed | cut -d ' ' -f 2}
${voffset 3}${offset 5}${color1}total up${goto 73}${color}${totalup [=device.name]}
${voffset 3}${offset 5}${color1}total down${goto 73}${color}${totaldown [=device.name]}
${endif}\
</#if>
</#list>
# in case no internet connection is available we have to "fill the gap" so the next section prints properly
${if_gw}${else}${voffset 75}${endif}\
# :::::: bittorrent
${if_running transmission-gt}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-block-large.png -p 0,288}\
${voffset 17}${offset 5}${color1}bittorrent${goto 73}${color}${tcp_portmon 51413 51413 count} peer(s)
${voffset 6}${offset 5}${color1}ip address${alignr 5}remote port
${if_match ${tcp_portmon 51413 51413 count} > 0}\
${voffset}${template3 0}
${template3 1}
${template3 2}
${template3 3}
${template3 4}
${template3 5}
${template3 6}
${template3 7}
${template3 8}
${template3 9}
${else}\
${voffset 60}${alignc}${color}no peer connections
${voffset 3}${alignc}established
${endif}\
${endif}\
]];
