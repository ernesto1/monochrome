<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/menu.lua',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- header|middle|bottom_left|right
  gap_x = 205,
  gap_y = 557,

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
  text_buffer_size=2048,

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
# this conky requires the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote
# :::::::::::: bittorrent peers
${if_running transmission-gt}\
<#assign y = 0, 
         header = 19, <#-- menu header -->
         body = 234,  <#-- menu window without the header -->
         gap = 3>     <#-- empty space between windows -->
<@menu.menu x=0 y=y width=width height=body/>
<#assign compositeHeader = header + 1 + header><#-- height in pixels before we get to the text portion of the menu -->
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-peers.png -p 38,[=y+compositeHeader+32]}\
<#assign file = "/tmp/conky/bittorrent.peers", maxLines = 12>
${lua compute ${exec transmission-remote -t active -pi | grep -e '^[0-9]' | cut -c 1-15,78-100 --output-delimiter='  ' | sort -t . -k 1n -k 2n -k 3n -k 4n | sed 's/^/${voffset 3}${offset 5}/' | head -[=maxLines] > [=file]}}\
${voffset 2}${offset 5}${color1}swarm${goto 50}${color}${lua compute_and_save peers ${lines [=file]}} peer(s)
${voffset -5}${color2}${hr 1}${voffset -8}
<#-- the trailing voffset of the table header is tied to the 'y' coordinate given to the bottom edge lua function.
     on a composite table it would have been ${voffset 4} here and [=y+compositeHeader] for the lua function -->
${voffset 7}${offset 5}${color1}ip address${goto 113}client${voffset 1}
${if_match ${lua retrieve peers} > 0}\
${color}${catp [=file]}${lua_parse pad_lines peers [=maxLines]}${voffset 11}
${lua_parse bottom_edge_load_value [=conky] [=image.primaryColor]-menu-light-edge-bottom 0 [=y+compositeHeader-3] [=width?c] 3 peers 12}\
${else}\
${voffset 84}${alignc}${color}no peer connections
${voffset 3}${alignc}established${voffset 90}
${endif}\
<#assign y += body + gap>
# :::::::::::: files being downloaded or seeded at the moment
# $ transmission-remote -t active -l
#     ID   Done       Have  ETA           Up    Down  Ratio  Status       Name
#    168   100%   11.74 GB  17 days      0.0     0.0   2.47  Seeding      fedora 37.iso
#     87   100%    2.96 GB  4 days      12.0     0.0   95.8  Seeding      photo gallery
#    126*  100%   16.99 GB  230 days     0.0     0.0   97.7  Seeding      books
# Sum:            31.69 GB              12.0     0.0
#
# the final 'sed' cmd in the pipeline is to escape torrents with '#' in the name, conky will interpret them
# as comments and that will mess up the formatting
<#assign file = "/tmp/conky/bittorrent.torrents">
${lua compute ${exec transmission-remote -t active -l | grep -E 'Seeding|Downloading' | sed 's/.\+\(Seeding\|Downloading\) \+//' | sed 's/^/${voffset 3}${offset 5}/' | sed 's/#/\\#/g' | sort > [=file]}}\
${if_match ${lines [=file]} > 0}\
<@menu.menu x=0 y=y width=width height=400 bottomEdges=false/>
${offset 5}${color1}active${goto 50}${color}${lua compute_and_save files ${lines [=file]}} torrent(s)
${voffset -5}${color2}${hr 1}${voffset -8}
${voffset 7}${offset 5}${color1}downloading/seeding${voffset 1}
${color}${catp [=file]}${voffset 5}
<#assign y += header + 1 + header - 3, maxLines = 50>
${lua_parse bottom_edge_load_value [=conky] [=image.primaryColor]-menu-light-edge-bottom 0 [=y?c] [=width?c] 3 files [=maxLines]}\
${endif}\
${endif}\
]];
