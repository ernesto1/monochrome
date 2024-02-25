<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- header|middle|bottom_left|right
  gap_x = 1299,
  gap_y = 141,

  -- window settings
  minimum_width = 555,      -- conky will add an extra pixel to this
  maximum_width = 555,
  minimum_height = 342,
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
  default_color = '[=colors.secondary.text]', -- regular text
  color1 = '[=colors.labels]',        -- text labels
};

conky.text = [[
# this conky requires:
# - the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote
# - the transmission.bash script running in the background
# :::::::::::: torrents overview
<#assign y = 0,
         header = 19,     <#-- menu header -->
         body = 70,       <#-- menu window without the header -->
         width = 202,     <#-- menu width -->
         gap = 5,         <#-- empty space between windows -->
         inputDir = "/tmp/conky",
         activeTorrentsFile = inputDir + "/transmission.active",
         speedCol = 39,
         colGap = 1,
         max = 20>
# :::::::::::: active torrents
${if_existing [=activeTorrentsFile]}\
${if_match ${lines [=activeTorrentsFile]} > 0}\
${lua read_file [=activeTorrentsFile]}${lua calculate_voffset [=activeTorrentsFile] [=max]}\
<@menu.table x=0 y=y width=width header=header bottomEdges=false color=image.secondaryColor fixed=false/>
<@menu.table x=width+colGap y=y width=speedCol header=header bottomEdges=false color=image.secondaryColor fixed=false/>
<@menu.table x=width+colGap+speedCol+colGap y=y width=speedCol header=header bottomEdges=false color=image.secondaryColor fixed=false/>
${lua configure_menu [=image.secondaryColor] light [=width?c] 3 true}\
${lua_parse add_y_offset voffset 2}${offset 5}${color1}active torrents${goto 226}up${goto 254}down${voffset 3}
${lua add_offsets 0 [=header]}\
<#assign y += header>
${color}${lua_parse populate_menu_from_mem [=activeTorrentsFile] [=max]}${voffset 4}
${lua_parse draw_bottom_edges [=width+colGap] [=speedCol]}${lua_parse draw_bottom_edges [=width+colGap+speedCol+colGap] [=speedCol]}\
<#assign x = width + colGap + speedCol + colGap + speedCol + gap>
${lua reset_state}${lua add_offsets [=x] 0}\
${else}\
${lua add_offsets 0 323}\
<@menu.menu x=0 y=0 width=width height=3+16+1 color=image.secondaryColor fixed=false/>
${lua_parse add_y_offset voffset 2}${goto 49}${color}no active torrents${voffset 4}
${lua reset_state}${lua add_offsets [=width + 14] 0}\
${endif}\
${else}\
<#assign body = 36>
${lua add_offsets 0 307}\
<@menu.menu x=0 y=0 width=width height=body color=image.secondaryColor fixed=false/>
${lua_parse add_y_offset voffset 2}${goto 24}${color}active torrents input file
${voffset 3}${goto 72}is missing${voffset 4}
${lua reset_state}${lua add_offsets [=width + 14] 0}\
${endif}\
# :::::::::::: peers
# peers menu is displayed on the right side of the active torrents menu
${voffset -342}\
<#assign peersFile = inputDir + "/transmission.peers">
${if_existing [=peersFile]}\
${if_match ${lines [=peersFile]} > 0}\
${lua read_file [=peersFile]}${lua calculate_voffset [=peersFile] [=max]}\
<#assign ipCol = 101, clientCol = 87>
${lua configure_menu [=image.secondaryColor] light [=ipCol] 3}\
<@menu.table x=0 y=0 width=ipCol header=header bottomEdges=false fixed=false color=image.secondaryColor/>
<@menu.table x=ipCol+colGap y=0 width=clientCol header=header bottomEdges=false fixed=false color=image.secondaryColor/>
<@menu.table x=ipCol+colGap+clientCol+colGap y=0 width=39 header=header bottomEdges=false fixed=false color=image.secondaryColor/>
<@menu.table x=ipCol+colGap+clientCol+colGap+speedCol+colGap y=0 width=39 header=header bottomEdges=false fixed=false color=image.secondaryColor/>
${lua_parse add_y_offset voffset 2}${lua_parse add_x_offset offset 5}${color1}ip address${offset 43}client${offset 69}up${offset 16}down${voffset 3}
${lua add_offsets 0 [=header]}\
${color}${lua_parse populate_menu_from_mem [=peersFile] [=max]}
${lua_parse draw_bottom_edges [=ipCol+colGap] [=clientCol]}${lua_parse draw_bottom_edges [=ipCol+colGap+clientCol+colGap] [=speedCol]}${lua_parse draw_bottom_edges [=ipCol+colGap+clientCol+colGap+speedCol+colGap] [=speedCol]}\
${else}\
${lua add_offsets 0 323}\
<@menu.menu x=0 y=0 width=width height=3+16+1 color=image.secondaryColor fixed=false/>
${lua_parse add_y_offset voffset 2}${lua_parse add_x_offset offset 47}${color}no peers connected${voffset 4}
${endif}\
${else}\
${lua add_offsets 0 307}\
<@menu.menu x=0 y=0 width=width height=body color=image.secondaryColor fixed=false/>
${lua_parse add_y_offset voffset 2}${lua_parse add_x_offset offset 27}${color}torrent peers input file
${voffset 3}${lua_parse add_x_offset offset 72}is missing
${endif}\
]];
