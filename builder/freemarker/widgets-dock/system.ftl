<#import "/lib/menu-round.ftl" as menu>
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
  <#assign width = 189>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
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
  text_buffer_size=2048,
  
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
  color3 = '[=colors.widgetText]',       -- composite table horizontal line
  
  -- top cpu process: ${template1 processNumber}
  template1 = [[${voffset 3}${color}${offset 5}${top name \1}${alignr 5}${top cpu \1}% ${top pid \1}]],
  -- top mem process: ${template2 processNumber}
  template2 = [[${voffset 3}${color}${offset 5}${top_mem name \1}${alignr 5}${top_mem mem_res \1} ${top_mem pid \1}]]
};

conky.text = [[
# :::::::::::: top cpu processes
<#assign y = 0, 
         header = 19, <#-- menu header -->
         body = 116,  <#-- size of the current window without the header -->
         space = 5>   <#-- empty space between windows -->
<@menu.table x=0 y=y width=width header=header body=body/>
<#assign y += header + body + space>
${voffset 2}${color1}${offset 5}process${alignr 5}cpu   pid${voffset 3}
<#list 1..7 as x>
${template1 [=x]}
</#list>
# :::::::::::: top mem processes
<@menu.table x=0 y=y width=width header=header body=body/>
<#assign y += header + body + space>
${voffset 12}${color1}${offset 5}process${alignr 5}memory   pid${voffset 3}
<#list 1..7 as x>
${template2 [=x]}
</#list>
# :::::::::::: network
# assumption: only one network device will be connected to the internet at a time
<@net.networkDetails devices=networkDevices[system] y=y width=width/>
<#assign y += 71 + space>
${voffset 10}\
<#if system == "desktop">
# :::::::::::: bittorrent peers
# this panel requires the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote
${if_running transmission-gt}\
<@menu.compositeTable x=0 y=y width=width vheader=69 hbody=164 bottomEdges=false/>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-peers.png -p 38,[=(y+54)?c]}\
<#assign file = "/tmp/conky/bittorrent.peers.widgets-dock", maxLines = 10>
${lua compute ${exec transmission-remote -t active -pi | grep -e '^[0-9]' | cut -c 1-15,78-100 --output-delimiter='  ' | sort -t . -k 1n -k 2n -k 3n -k 4n | sed 's/^/${voffset 3}${offset 5}/' | head -[=maxLines] > [=file]}}\
${voffset 2}${offset 5}${color1}swarm${goto 75}${color}${lua compute_and_save peers ${lines [=file]}} peer(s)
${voffset -5}${color3}${hr 1}${voffset -8}
${voffset 7}${offset 5}${color1}ip address${goto 113}client${voffset 3}
${if_match ${lua retrieve peers} > 0}\
${color}${catp [=file]}${lua_parse pad_lines peers [=maxLines]}${voffset 10}
${lua_parse bottom_edge_load_value [=conky] [=image.primaryColor]-menu-light-edge-bottom 0 [=(y+header+1+header-2)?c] [=width?c] 3 peers 10}\
${else}\
${voffset 67}${alignc}${color}no peer connections
${voffset 3}${alignc}established${voffset 74}
${endif}\
${else}\
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y]}\
<#assign y += header + 1 + header + 164 + space>
${voffset 208}\
${endif}\
</#if>
# :::::::::::: package updates
${if_existing /tmp/conky/dnf.packages.formatted}\
<@menu.table x=0 y=y width=width header=header body=1000 bottomEdges=false/>
<#assign y += header>
# optional dnf branding, can be removed or won't matter if the image does not exist
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-dnf.png -p 114,[=(y+2)?c]}\
<#if system == "desktop"><#assign maxLines = 54><#else><#assign maxLines = 23></#if>
${lua_parse bottom_edge_parse [=conky] [=image.primaryColor]-menu-light-edge-bottom 0 [=y?c] [=width?c] 2 ${lines /tmp/conky/dnf.packages.formatted} [=maxLines]}\
${voffset 2}${offset 5}${color1}package${alignr 5}version${voffset 4}
${color}${execpi 30 head -n [=maxLines] /tmp/conky/dnf.packages.formatted}${voffset 5}
${endif}\
]];
