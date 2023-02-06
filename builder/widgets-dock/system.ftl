<#import "/lib/network.ftl" as net>
conky.config = {
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- top|middle|bottom_left|right
  gap_x = 150,
  gap_y = 203,

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
  color2 = '[=colors.highlight]',         -- highlight important packages
  
  -- top cpu process: ${template1 processNumber}
  template1 = [[${voffset 3}${color}${offset 5}${top name \1}${alignr 5}${top cpu \1}% ${top pid \1}]],
  -- top mem process: ${template2 processNumber}
  template2 = [[${voffset 3}${color}${offset 5}${top_mem name \1}${alignr 5}${top_mem mem_res \1} ${top_mem pid \1}]],
  -- torrent peer ip/port: ${template3 #}
  template3 = [[${voffset 3}${offset 5}${color}${tcp_portmon 51413 51413 rip \1}${alignr 5}${tcp_portmon 51413 51413 rport \1}]]
};

conky.text = [[
# :::::::::::: top cpu processes
<#assign y = 0, top = 19, body = 109, bottom = 12> <#-- body of top cpu window -->
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-top.png -p 0,0}\
<#assign y += top>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu.png -p 0,[=y]}\
<#assign y += body>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-bottom.png -p 0,[=y]}\
${voffset 2}${color1}${offset 5}process${alignr 5}cpu   pid${voffset 3}
<#list 1..7 as x>
${template1 [=x]}
</#list>
# :::::::::::: top mem processes
<#assign y += bottom>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-top.png -p 0,[=y]}\
<#assign y += top + body>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-bottom.png -p 0,[=y]}\
${voffset 12}${color1}${offset 5}process${alignr 5}memory   pid${voffset 3}
<#list 1..7 as x>
${template2 [=x]}
</#list>
# :::::::::::: network
# assumption: only one network device will be connected to the internet at a time
<#assign y += bottom>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-horizontal.png -p 0,[=y]}\
<@net.networkDetails networkDevices[system] y/>
# :::::::::::: bittorrent peers
${if_running transmission-gt}\
<#assign y += 78, peersHeight = y> <#-- vertical menu image size -->
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-top.png -p 0,[=y]}\
<#assign y += top + 174> <#-- size of peer list body -->
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-bottom.png -p 0,[=y]}\
${voffset 15}${offset 5}${color1}bittorrent${goto 75}${color}${tcp_portmon 51413 51413 count} peer(s)
${voffset 6}${offset 5}${color1}ip address${alignr 5}remote port
${if_match ${tcp_portmon 51413 51413 count} > 0}\
<#list 0..9 as x>
${template3 [=x]}
</#list>
${else}\
${voffset 67}${alignc}${color}no peer connections
${voffset 3}${alignc}established${voffset 64}
${endif}\
${else}\
${image ~/conky/monochrome/images/widgets-dock/menu-blank.png -p 0,[=peersHeight]}\
${image ~/conky/monochrome/images/widgets-dock/menu-blank.png -p 0,[=peersHeight + 78]}\<#-- height of blank image -->
${image ~/conky/monochrome/images/widgets-dock/menu-blank.png -p 0,[=peersHeight + 78 + 49]}\
${voffset 207}\
${endif}\
# :::::::::::: package updates
${if_existing /tmp/dnf.packages}\
<#assign y += bottom>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-top.png -p 0,[=y]}\
${voffset 12}${offset 5}${color1}package${alignr 5}version${voffset 3}
<#if system == "desktop"><#assign lines = 87><#else><#assign lines = 15></#if>
${voffset 3}${color}${execpi 20 head -n [=lines] /tmp/dnf.packages.preview}${voffset 4}
${endif}\
]];
