<#import "/lib/menu-square.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- top|middle|bottom_left|right
  gap_x = 123,
  gap_y = 430,

  -- window settings
  minimum_width = 245,      -- conky will add an extra pixel to this  
  maximum_width = 245,
  minimum_height = 1021,
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
  
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.systemText]',  -- regular text
  color1 = '[=colors.systemLabels]',
  color2 = '[=colors.highlight]'         -- highlight important packages
};

conky.text = [[
<#assign y = 0,
         header = 75,
         height = 87,
         gap = 3>     <#-- empty space between windows -->
<@menu.verticalTable x=0 y=y header=header body=159-header height=height/>
<#assign y += height + gap>
${lua add_offsets 0 [= height + gap]}\
<#assign inputDir = "/tmp/conky"
         peersFile = inputDir + "/transmission.peers",
         seedingFile = inputDir + "/transmission.seeding"
         downloadingFile = inputDir + "/transmission.downloading",
         idleFile = inputDir + "/transmission.idle",
         activeTorrentsFile = inputDir + "/transmission.active">
${voffset [=2 + gap]}${offset 5}${color1}swarm${goto 81}${color}${if_existing [=peersFile]}${lua pad ${lua get peers ${lines [=peersFile]}}} peers${else}file missing${endif}
${voffset 3}${offset 5}${color1}active${goto 81}${color}${if_existing [=activeTorrentsFile]}${lua pad ${lua get active ${lines [=activeTorrentsFile]}}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}seeding${goto 81}${color}${if_existing [=seedingFile]}${lua pad ${lines [=seedingFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}downloading${goto 81}${color}${if_existing [=downloadingFile]}${lua pad ${lines [=downloadingFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}idle${goto 81}${color}${if_existing [=idleFile]}${lua pad ${lines [=idleFile]}} torrents${else}file missing${endif}
${voffset [= 7 + gap]}\
# :::::::::::: active torrents
${if_existing [=activeTorrentsFile]}\
${if_match ${lua get active} > 0}\
<#assign header = 19, width = 159, speedCol = 39, colGap = 1>
<@menu.table x=0 y=y width=width header=header bottomEdges=false/>
<@menu.table x=width+colGap y=y width=speedCol header=header bottomEdges=false/>
<@menu.table x=width+colGap+speedCol+colGap y=y width=speedCol header=header bottomEdges=false/>
${lua configure_menu [=conky] [=image.primaryColor]-menu-light-edge-bottom [=width?c] 3 false}\
${lua add_offsets 0 [=header]}\
${offset 5}${color1}active torrents${goto 184}up${offset 16}down${voffset 3}
<#assign maxLines = 10>
${color}${color}${lua_parse populate_menu [=activeTorrentsFile] [=maxLines] 3}
${voffset [= 7 + gap]}\
${lua_parse draw_bottom_edges [=width+colGap] 39}${lua_parse draw_bottom_edges [=width+colGap+speedCol+colGap] 39}\
${lua add_offsets 0 [=gap]}\
${endif}\
${else}\
<#assign body = 36>
<@menu.menu x=0 y=y width=width height=body/>
${lua add_offsets 0 [=body + gap]}\
${offset 5}${color}active torrents input
${voffset 3}${offset 5}file is missing
${voffset [= 7 + gap]}\
${endif}\
# ::::::::::::::::: package updates :::::::::::::::::
${if_existing /tmp/conky/dnf.packages.formatted}\
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted", 
         header = 27,
         height = 22>
<@menu.verticalTable x=0 y=0 header=header body=159-header height=height fixed=false/>
${lua add_offsets 0 [= height + gap]}\
${voffset 2}${offset 5}${color1}dnf${goto 33}${color}${lines [=packagesFile]} package updates
${voffset [= 7 + gap]}\
<#assign header = 19, versionCol = 51>
<@menu.table x=0 y=0 width=width header=header bottomEdges=false fixed=false/>
<@menu.table x=width+colGap y=0 width=versionCol header=header bottomEdges=false fixed=false/>
${lua configure_menu [=conky] [=image.primaryColor]-menu-light-edge-bottom [=width?c] 2 false}\
${lua add_offsets 0 [=header]}\
${offset 5}${color1}package${goto 166}version${voffset 4}
<#assign maxLines = 45>
${color}${lua_parse populate_menu [=packagesFile] [=maxLines] 900}
${endif}\
]]
