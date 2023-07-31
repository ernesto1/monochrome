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
  minimum_width = 281,      -- conky will add an extra pixel to this
  maximum_width = 281,
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
         colGap = 1>
# :::::::::::: active torrents
${if_existing [=activeTorrentsFile]}\
${if_match ${lines [=activeTorrentsFile]} > 0}\
<@menu.table x=0 y=y width=width header=header bottomEdges=false color=image.secondaryColor/>
<@menu.table x=width+colGap y=y width=speedCol header=header bottomEdges=false color=image.secondaryColor/>
<@menu.table x=width+colGap+speedCol+colGap y=y width=speedCol header=header bottomEdges=false color=image.secondaryColor/>
${lua add_offsets 0 [=header]}\
${lua configure_menu grape light [=width?c] 3 true}\
<#assign y += header>
${voffset 2}${offset 5}${color1}active torrents${goto 226}up${goto 254}down${voffset 3}
<#assign maxLines = 17>
${color}${lua_parse populate_menu [=activeTorrentsFile]}${voffset 4}
${lua_parse draw_bottom_edges [=width+colGap] [=speedCol]}${lua_parse draw_bottom_edges [=width+colGap+speedCol+colGap] [=speedCol]}\
${endif}\
${else}\
<#assign body = 36>
<@menu.menu x=0 y=0 width=width height=body color=image.secondaryColor/>
${voffset 2}${goto 24}${color}active torrents input file
${voffset 3}${goto 72}is missing${voffset 4}
${endif}\
]];
