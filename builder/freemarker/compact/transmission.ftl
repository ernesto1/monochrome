<#import "/lib/panel-round.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- header|middle|bottom_left|right
  gap_x = 195,
  gap_y = 686,

  -- window settings
  minimum_width = 275,          -- conky will add an extra pixel to height and width
  maximum_width = 275,
  minimum_height = 1035,
  own_window = true,
  own_window_type = 'desktop',  -- values: desktop (background), panel (bar)
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
  default_color = '[=colors.panelText]', -- regular text
  color1 = '[=colors.labels]',         -- labels
  color2 = '[=colors.warning]',        -- bar critical
  color3 = '[=colors.secondary.labels]',         -- secondary panel labels
  color4 = '[=colors.secondary.text]'         -- secondary panel text
};

conky.text = [[
# this conky requires:
# - the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote
# - the transmission.bash script running in the background
<#assign totalLines = 33>
${lua set_total_lines [=totalLines]}\
# :::::::::::: torrents overview
<#assign y = 0,
         header = 75, <#-- panel header -->
         body = 71,   <#-- panel window without the header -->
         width = 189, <#-- default panel width -->
         gap = 3>     <#-- empty space between windows -->
<@panel.verticalTable x=0 y=y header=header body=width-header height=body/>
<#assign y += body + gap>
${lua increment_offsets 0 [=y?c]}\
<#assign inputDir = "/tmp/conky"
         peersFile = inputDir + "/transmission.peers",
         seedingFile = inputDir + "/transmission.seeding",
         downloadingFile = inputDir + "/transmission.downloading",
         idleFile = inputDir + "/transmission.idle",
         activeTorrentsFile = inputDir + "/transmission.active">
${voffset 5}${offset 5}${color1}swarm${goto 81}${color}${if_existing [=peersFile]}${lua pad ${lua get peers ${lines [=peersFile]}}} peers${else}file missing${endif}
${voffset 3}${offset 5}${color1}seeding${goto 81}${color}${if_existing [=seedingFile]}${lua pad ${lines [=seedingFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}downloading${goto 81}${color}${if_existing [=downloadingFile]}${lua pad ${lines [=downloadingFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}idle${goto 81}${color}${if_existing [=idleFile]}${lua pad ${lines [=idleFile]}} torrents${else}file missing${endif}
${voffset [= 7 + gap]}\
# :::::::::::: active torrents
${if_existing [=activeTorrentsFile]}\
${if_match ${lua get activeNum ${lines [=activeTorrentsFile]}} > 0}\
${lua configure_panel [=image.primaryColor] light [=width?c] 3}\
<#assign header = 19, speedCol = 39, colGap = 1>
<@panel.table x=0 y=y width=width header=header />
<@panel.table x=width+colGap y=y width=39 header=header color=image.secondaryColor/>
<@panel.table x=width+colGap+speedCol+colGap y=y width=39 header=header />
${image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-peers.png -p 38,[=y+header+22]}\
<#assign y += header>
${lua increment_offsets 0 [=header]}\
${offset 5}${color1}active torrents ${color}(${color}${lua get activeNum}${color})${color1}${goto 214}${color3}up${offset 16}${color1}down${voffset 3}
${color}${lua_parse populate_panel_from_file [=activeTorrentsFile] [=totalLines - 3]}${voffset [= 7 + gap]}
${lua_parse draw_bottom_edges [=width+colGap] 39 [=image.secondaryColor]}${lua_parse draw_bottom_edges [=width+colGap+speedCol+colGap] 39}\
${lua increment_offsets 0 [=gap]}\
${else}\
<#assign body = 20>
<@panel.panel x=0 y=71 + gap width=width height=body/>
${lua increment_offsets 0 [=body + gap]}\
${offset 41}${color}no active torrents
${endif}\
${else}\
<#assign body = 20>
<@panel.panel x=0 y=71 + gap width=width height=body color=image.secondaryColor/>
${lua increment_offsets 0 [=body + gap]}\
${goto 12}${color4}missing active torrents file${voffset [= 7 + gap]}
${endif}\
# :::::::::::: peers
${if_existing [=peersFile]}\
${if_match ${lua get peers} > 0}\
<#assign ipCol = 101, clientCol = 87>
${lua configure_panel [=image.primaryColor] light [=ipCol] 3}\
<@panel.table x=0 y=0 width=ipCol header=header isFixed=false/>
<@panel.table x=ipCol+colGap y=0 width=clientCol header=header isFixed=false/>
<@panel.table x=width+colGap y=0 width=39 header=header isFixed=false color=image.secondaryColor/>
<@panel.table x=width+colGap+speedCol+colGap y=0 width=39 header=header isFixed=false/>
${lua increment_offsets 0 [=header]}\
${offset 5}${color1}ip address${goto 108}client${goto 214}${color3}up${offset 16}${color1}down${voffset 3}
${color}${lua_parse populate_panel_from_file [=peersFile] [=totalLines]}
${lua_parse draw_bottom_edges [=ipCol+colGap] [=clientCol]}${lua_parse draw_bottom_edges [=width+colGap] [=speedCol] [=image.secondaryColor]}${lua_parse draw_bottom_edges [=width+colGap+speedCol+colGap] [=speedCol]}\
${endif}\
${else}\
<#assign body = 20>
<@panel.panel x=0 y=0 width=width height=body isFixed=false color=image.secondaryColor/>
${lua increment_offsets 0 [=body + gap]}\
${goto 24}${color4}missing peers input file
${endif}\
]];
