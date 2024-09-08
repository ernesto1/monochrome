<#import "/lib/panel-round.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
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
  minimum_height = 345,
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
  color1 = '[=colors.secondary.labels]',        -- text labels
};

conky.text = [[
# this conky requires:
# - the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote
# - the transmission.bash script running in the background
# :::::::::::: torrents overview
<#assign y = 0,
         header = 19,     <#-- panel header -->
         body = 70,       <#-- panel area without the header -->
         width = 202,     <#-- activity torrents column width -->
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
<@panel.table x=0 y=y width=width header=header color=image.secondaryColor isFixed=false/>
<@panel.table x=width+colGap y=y width=speedCol header=header color=image.secondaryColor isFixed=false/>
<@panel.table x=width+colGap+speedCol+colGap y=y width=speedCol header=header color=image.secondaryColor isFixed=false/>
${lua_parse add_y_offset voffset 2}${offset 5}${color1}active torrents${goto 226}up${goto 254}down${voffset 6}
${lua increment_offsets 0 [=header]}\
<#assign y += header>
${color}${lua_parse head [=activeTorrentsFile] [=max]}${lua increase_y_offset [=activeTorrentsFile]}${voffset 4}
<@panel.panelsBottom x=0 y=0 widths=[width,speedCol,speedCol] gap=colGap isFixed=false color=image.secondaryColor/>
<#assign x = width + colGap + speedCol + colGap + speedCol + gap>
${lua reset_state}${lua increment_offsets [=x] 0}\
${else}\
${lua increment_offsets 0 326}\
<@panel.panel x=0 y=0 width=width height=3+16+1 color=image.secondaryColor isFixed=false/>
${lua_parse add_y_offset voffset 2}${goto 49}${color}no active torrents${voffset 4}
${lua reset_state}${lua increment_offsets [=width + 14] 0}\
${endif}\
${else}\
<#assign body = 36>
${lua increment_offsets 0 310}\
<@panel.panel x=0 y=0 width=width height=body color=image.secondaryColor isFixed=false/>
${lua_parse add_y_offset voffset 2}${goto 24}${color}active torrents input file
${voffset 3}${goto 72}is missing${voffset 4}
${lua reset_state}${lua increment_offsets [=width + 14] 0}\
${endif}\
# :::::::::::: peers
# peers panel is displayed on the right side of the active torrents panel
${voffset -345}\
<#assign peersFile = inputDir + "/transmission.peers">
${if_existing [=peersFile]}\
${if_match ${lines [=peersFile]} > 0}\
${lua read_file [=peersFile]}${lua calculate_voffset [=peersFile] [=max]}\
<#assign ipCol = 101, clientCol = 87>
<@panel.table x=0 y=0 width=ipCol header=header isFixed=false color=image.secondaryColor/>
<@panel.table x=ipCol+colGap y=0 width=clientCol header=header isFixed=false color=image.secondaryColor/>
<@panel.table x=ipCol+colGap+clientCol+colGap y=0 width=39 header=header isFixed=false color=image.secondaryColor/>
<@panel.table x=ipCol+colGap+clientCol+colGap+speedCol+colGap y=0 width=39 header=header isFixed=false color=image.secondaryColor/>
${lua_parse add_y_offset voffset 2}${lua_parse add_x_offset offset 5}${color1}ip address${offset 43}client${offset 69}up${offset 16}down${voffset 6}
${lua increment_offsets 0 [=header]}\
${color}${lua_parse head_mem [=peersFile] [=max]}${lua increase_y_offset [=peersFile]}
<@panel.panelsBottom x=0 y=0 widths=[ipCol,clientCol,speedCol,speedCol] gap=colGap isFixed=false color=image.secondaryColor/>
${else}\
${lua increment_offsets 0 326}\
<@panel.panel x=0 y=0 width=width height=3+16+1 color=image.secondaryColor isFixed=false/>
${lua_parse add_y_offset voffset 2}${lua_parse add_x_offset offset 47}${color}no peers connected${voffset 4}
${endif}\
${else}\
${lua increment_offsets 0 310}\
<@panel.panel x=0 y=0 width=width height=body color=image.secondaryColor isFixed=false/>
${lua_parse add_y_offset voffset 2}${lua_parse add_x_offset offset 27}${color}torrent peers input file
${voffset 3}${lua_parse add_x_offset offset 72}is missing
${endif}\
]];
