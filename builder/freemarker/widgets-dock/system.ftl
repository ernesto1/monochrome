<#import "/lib/menu-round.ftl" as menu>
<#import "lib/network.ftl" as net>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua',
  
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
         gap = 5>     <#-- empty space between windows -->
<@menu.table x=0 y=y width=width header=header body=body/>
<#assign y += header + body + gap>
${voffset 2}${color1}${offset 5}process${alignr 5}cpu   pid${voffset 3}
<#list 1..7 as x>
${template1 [=x]}
</#list>
# :::::::::::: top mem processes
<@menu.table x=0 y=y width=width header=header body=body/>
<#assign y += header + body + gap>
${voffset 12}${color1}${offset 5}process${alignr 5}memory   pid${voffset 3}
<#list 1..7 as x>
${template2 [=x]}
</#list>
# :::::::::::: network
# assumption: only one network device will be connected to the internet at a time
<@net.networkDetails devices=networkDevices[system] y=y width=width/>
<#assign y += 71 + gap>
${voffset 10}\
<#if system == "desktop">
# :::::::::::: transmission bittorrent client
# this panel requires:
# - the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote
# - the transmission.bash script running in the background
${if_running transmission-gt}\
<#assign header = 75, <#-- menu header -->
         body = 71,   <#-- menu window without the header -->
         gap = 5>     <#-- empty space between windows -->
<@menu.verticalTable x=0 y=y header=header body=width-header height=body/>
<#assign inputDir = "/tmp/conky"
         peersFile = inputDir + "/transmission.peers",
         seedingFile = inputDir + "/transmission.seeding"
         downloadingFile = inputDir + "/transmission.downloading",
         idleFile = inputDir + "/transmission.idle",
         activeTorrentsFile = inputDir + "/transmission.active">
${voffset 5}${offset 5}${color1}swarm${goto 81}${color}${lua pad ${lines [=peersFile]}} peer(s)
${voffset 2}${offset 5}${color1}seeding${goto 81}${color}${lua pad ${lines [=seedingFile]}} torrent(s)
${voffset 3}${offset 5}${color1}downloading${goto 81}${color}${lua pad ${lines [=downloadingFile]}} torrent(s)
${voffset 3}${offset 5}${color1}idle${goto 81}${color}${lua pad ${lines [=idleFile]}} torrent(s)
${voffset 13}\
<#assign y += body + gap>
${if_match ${lua compute_and_save active ${lines [=activeTorrentsFile]}} > 0}\
<#assign header = 19, body = 164>
<@menu.table x=0 y=y width=width header=header body=body bottomEdges=false/>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-peers.png -p 38,[=(y+header+18)?c]}\
<#assign maxLines = 10>
${alignc}${color1}active torrents${voffset 3}
${color}${execp head -[=maxLines] [=activeTorrentsFile]}${lua_parse pad_lines active [=maxLines]}${voffset 10}
${lua_parse bottom_edge_load_value [=conky] [=image.primaryColor]-menu-light-edge-bottom 0 [=y+header-2] [=width?c] 3 active [=maxLines]}\
<#assign y += header + body + gap>
${else}\
# no active torrents -> empty space
${voffset [=header + body + gap + 2]}
${endif}\
${else}\
# tranmission is not running -> empty space
${voffset [=71 + gap + header + body + gap + 2]}
${endif}\
</#if>
]];
