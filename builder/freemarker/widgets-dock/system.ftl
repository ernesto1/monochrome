<#import "lib/network.ftl" as net>
conky.config = {
  lua_load = '~/conky/monochrome/menu.lua',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- top|middle|bottom_left|right
  gap_x = 142,
  gap_y = 120,

  -- window settings
  minimum_width = 189,      -- conky will add an extra pixel to this  
  maximum_width = 189,
  minimum_height = 275,
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
  default_color = '[=colors.menuText]',  -- regular text
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
<#assign y = 0, 
         top = 19,    <#-- menu header -->
         body = 109,  <#-- size of the current window without the top and bottom edges -->
         bottom = 7,  <#-- window bottom edge -->
         space = 5>   <#-- empty space between windows -->
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-top.png -p 0,[=y?c]}\
<#assign y += top>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu.png -p 0,[=y?c]}\
<#assign y += body>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-bottom.png -p 0,[=y?c]}\
<#assign y += bottom + space>
${voffset 2}${color1}${offset 5}process${alignr 5}cpu   pid${voffset 3}
<#list 1..7 as x>
${template1 [=x]}
</#list>
# :::::::::::: top mem processes
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-top.png -p 0,[=y?c]}\
<#assign y += top + body>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-bottom.png -p 0,[=y?c]}\
<#assign y += bottom + space>
${voffset 12}${color1}${offset 5}process${alignr 5}memory   pid${voffset 3}
<#list 1..7 as x>
${template2 [=x]}
</#list>
# :::::::::::: network
# assumption: only one network device will be connected to the internet at a time
<#assign windowYcoordinate = y>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-horizontal.png -p 0,[=y?c]}\
<#assign body = 71, y += body><#-- vertical menu image includes the bottom edge, hence no bottom image used -->
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
<#assign y += space>
<@net.networkDetails networkDevices[system] windowYcoordinate/>
${voffset 10}\
<#if system == "desktop">
# :::::::::::: bittorrent peers
${if_running transmission-gt}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-horizontal.png -p 0,[=y?c]}\
${voffset 2}${offset 5}${color1}bittorrent${goto 75}${color}${tcp_portmon 51413 51413 count} peer(s)
${voffset -5}${hr 1}${voffset -8}
<#assign y += top>
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
<#assign y += 1, windowYcoordinate = y>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-top-flat.png -p 0,[=y?c]}\
<#assign y += top>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu.png -p 0,[=y?c]}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-bittorrent.png -p 38,[=(y+15)?c]}\
<#assign body = 157, y += body>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-bottom.png -p 0,[=y?c]}\
<#assign y += bottom + space>
${voffset 7}${offset 5}${color1}ip address${alignr 5}remote port${voffset 3}
${if_match ${tcp_portmon 51413 51413 count} > 0}\
<#list 0..9 as x>
${template3 [=x]}<#if x?is_last>${voffset 10}</#if>
</#list>
${else}\
${voffset 67}${alignc}${color}no peer connections
${voffset 3}${alignc}established${voffset 74}
${endif}\
${else}\
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=windowYcoordinate]}\
${voffset 208}\
${endif}\
</#if>
# :::::::::::: package updates
${if_existing /tmp/conky/dnf.packages.formatted}\
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-top.png -p 0,[=y?c]}\
<#assign y += top>
<#if system == "desktop"><#assign maxLines = 54><#else><#assign maxLines = 23></#if>
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu.png -p 0,[=y?c]}\
# optional dnf branding, can be removed or won't matter if the image does not exist
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-menu-dnf.png -p 114,[=(y+2)?c]}\
${lua_parse bottom_edge_parse widgets-dock [=image.primaryColor]-menu-bottom.png 0 [=y?c] 2 ${lines /tmp/conky/dnf.packages.formatted} [=maxLines]}\
${voffset 2}${offset 5}${color1}package${alignr 5}version${voffset 4}
${color}${execpi 30 head -n [=maxLines] /tmp/conky/dnf.packages.formatted}${voffset 5}
${endif}\
]];
