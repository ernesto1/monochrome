<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- header|middle|bottom_left|right
  gap_x = 205,
  gap_y = 553,

  -- window settings
  <#assign width = 189>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
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
  
  imlib_cache_flush_interval = 250,
  text_buffer_size=2096,

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.menuText]',  -- regular text
  color1 = '[=colors.labels]',            -- labels
  color2 = '[=(colors.warning)?c]'         -- bar critical
};

conky.text = [[
# this conky requires:
# - the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote
# - the transmission.bash script running in the background
# :::::::::::: bittorrent peers
${if_running transmission-gt}\
<#assign y = 0, 
         header = 75, <#-- menu header -->
         body = 71,   <#-- menu window without the header -->
         gap = 3>     <#-- empty space between windows -->
<@menu.verticalTable x=0 y=y header=header body=width-header height=body/>
<#assign y += body + gap>
<#assign inputDir = "/tmp/conky"
         peersFile = inputDir + "/transmission.peers",
         seedingFile = inputDir + "/transmission.seeding",
         downloadingFile = inputDir + "/transmission.downloading",
         idleFile = inputDir + "/transmission.idle",
         activeTorrentsFile = inputDir + "/transmission.active">
${voffset 5}${offset 5}${color1}swarm${goto 81}${color}${lua pad ${lua conky_compute_and_save peers ${lines [=peersFile]}}} peer(s)
${voffset 3}${offset 5}${color1}seeding${goto 81}${color}${lua pad ${lines [=seedingFile]}} torrent(s)
${voffset 3}${offset 5}${color1}downloading${goto 81}${color}${lua pad ${lines [=downloadingFile]}} torrent(s)
${voffset 3}${offset 5}${color1}idle${goto 81}${color}${lua pad ${lines [=idleFile]}} torrent(s)
${voffset 8}\
# :::::::::::: torrents being downloaded or seeded
${if_match ${lua compute_and_save active ${lines [=activeTorrentsFile]}} > 0}\
<#assign header = 19, body = 244>
<@menu.table x=0 y=y width=width header=header body=body bottomEdges=false/>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-peers.png -p 38,[=y+header+22]}\
${voffset 2}${alignc}${color1}active torrents${voffset 3}
<#assign maxLines = 15>
${color}${execp head -[=maxLines] [=activeTorrentsFile]}${lua_parse pad_lines active [=maxLines]}${voffset 10}
${lua_parse bottom_edge_load_value [=conky] [=image.primaryColor]-menu-light-edge-bottom 0 [=(y+header-2)?c] [=width?c] 3 active [=maxLines]}\
<#assign y += header + body + gap>
${else}\
${voffset [=header + body + gap + 2]}\
${endif}\
${if_match ${lua retrieve peers} > 0}\
<#assign header = 19, body = 212>
<@menu.table x=0 y=y width=width header=header body=body bottomEdges=false/>
${offset 5}${color1}ip address${goto 108}client${voffset 3}
<#assign maxLines = 50>
${color}${catp [=peersFile]}
${lua_parse bottom_edge_load_value [=conky] [=image.primaryColor]-menu-light-edge-bottom 0 [=y+header-2] [=width?c] 3 peers [=maxLines]}${voffset 6}\
${endif}\
${endif}\
]];
