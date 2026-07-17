<#import "/lib/panel-square.ftl" as panel>
--[[
this conky requires the following supporting scripts running in the background:

 - dnfPackageLookup.bash
 - the music-player java app
 - transmission.bash
   requires the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote

output files from these supporting apps are read from /tmp/conky
]]

conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 1.5,    -- update interval in seconds
  xinerama_head = 0,        -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,     -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_middle',  -- top|middle|bottom_left|right
  gap_x = 0,
  gap_y = 6,

  -- window settings
  <#assign height = 73,
           <#-- now playing section -->
           albumWidth = height-2,                 <#-- album art width -->
           albumSection = 2+albumWidth+6,
           labelWidth = albumSection+6*6+6,       <#-- width of the dark portion of the vertical table -->
           nowPlayingWidth = labelWidth+6+23*6+6
           <#-- transmission overview section -->
           transmissionHeaderWidth = 6+8*6+6,
           transmissionPanelWidth = transmissionHeaderWidth+6+9*6+6,
           <#-- transmission active torrents section -->
           transmissionTorrentsWidth = 50*6,
           transmissionWidth = transmissionPanelWidth + transmissionTorrentsWidth
           width  = nowPlayingWidth + transmissionWidth>
  minimum_width = [=width],     -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = [=height?c],        -- must match the conky sidebar's heigh (the colored bar itself)
  own_window = true,
  own_window_type = 'desktop',  -- values: desktop (background), panel (bar)

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 0,         -- width of border window in pixels
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
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]'
};

--[[
this conky is a dynamic bar that changes width depending on the size of the 'now playing' and 'transmission' sections, hence the use of the lua increment_offsets(), draw_image(), add_x_offset() and alignr() functions
]]
conky.text = [[
# calculate horizontal offset based on what panels will be shown on this iteration
${if_existing /tmp/conky/musicplayer.status on}${else}\
<#assign noAppWidth = height+20*6,    <#-- panel width when the application is not running -->
         panelOffset = ((nowPlayingWidth-noAppWidth)/2)?round>
${lua increment_offsets [=panelOffset] 0 [=panelOffset]}\
${endif}\
<#assign inputDir = "/tmp/conky/",
         torrentsFile = inputDir + "transmission.active">
${if_match ${lines [=torrentsFile]} == 0}\
<#assign panelOffset = ((transmissionWidth-noAppWidth)/2)?round>
${lua increment_offsets [=panelOffset] 0 [=panelOffset]}\
${else}\
${lua increment_offsets 0 0 [=transmissionTorrentsWidth]}\<#-- provide the right align offset for the torrent overview section -->
${endif}\
# BEGIN CONKY SECTIONS
${voffset 3}\
#
# :::::::::::::::: now playing ::::::::::::::::
# the UI of this conky has four states: song with album art
#                                       song with no album art
#                                       no music player is running
#                                       input files are missing (java dbus listener application is not running)
# :::::: no player available
${if_existing /tmp/conky/musicplayer.status}\
${if_existing /tmp/conky/musicplayer.status off}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png 0 0 [=noAppWidth]x[=height]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light-edge-top-left.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light-edge-bottom-left.png 0 [=height-7]}\
<#assign iconHeight = 45>
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-album-cover.png [=((height-iconHeight)/2)?round] [=((height-iconHeight)/2)?round] [=iconHeight]x[=iconHeight]}\
${voffset [=3+16]}${lua_parse add_x_offset offset [=height]}${color1}now playing
${voffset 3}${lua_parse add_x_offset offset [=height]}${color}no player running
${lua increment_offsets [=noAppWidth] 0}\
${voffset [=-1*(16*3)]}\
${else}\
# :::::: player running
<@panel.verticalTable x=0 y=0 header=labelWidth width=nowPlayingWidth height=height isFixed=false/>
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark-edge-top-left.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark-edge-bottom-left.png 0 [=height-7]}\
<#assign iconHeight = 50>
${lua_parse draw_image  ~/conky/monochrome/images/compact/[=image.primaryColor]-album-cover.png [=2+((albumWidth-iconHeight)/2)?round] [=((height-iconHeight)/2)?round] [=iconHeight]x[=iconHeight]}\
${if_existing /tmp/conky/musicplayer.track.art}\
${lua_parse draw_image  /tmp/conky/musicplayer.track.art 2 1 [=albumWidth]x[=albumWidth]}\
${endif}\
${voffset 3}${lua_parse add_x_offset offset [=albumSection]}${color1}title${lua_parse add_x_offset goto [=labelWidth+6]}${color}${scroll wait 23 4 1 ${cat /tmp/conky/musicplayer.track.title}}
${voffset 3}${lua_parse add_x_offset offset [=albumSection]}${color1}album${lua_parse add_x_offset goto [=labelWidth+6]}${color}${scroll wait 23 4 1 ${cat /tmp/conky/musicplayer.track.album}}
${voffset 3}${lua_parse add_x_offset offset [=albumSection]}${color1}artist${lua_parse add_x_offset goto [=labelWidth+6]}${color}${scroll wait 23 4 1 ${cat /tmp/conky/musicplayer.track.artist}}
${voffset 3}${lua_parse add_x_offset offset [=albumSection]}${color1}genre${lua_parse add_x_offset goto [=labelWidth+6]}${color}${cat /tmp/conky/musicplayer.track.genre}
${voffset [=-1*(16*4)]}\
${lua increment_offsets [=nowPlayingWidth] 0}\
${endif}\
${else}\
# :::::: error state
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png 0 0 [=noAppWidth]x[=height]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light-edge-top-left.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light-edge-bottom-left.png 0 [=height-7]}\
<#assign iconHeight = 45>
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-album-cover.png [=((height-iconHeight)/2)?round] [=((height-iconHeight)/2)?round] [=iconHeight]x[=iconHeight]}\
${voffset 3}${lua_parse add_x_offset offset [=height]}${color1}now playing
${voffset 3}${lua_parse add_x_offset offset [=height]}${color}input files missing
${voffset 3}${lua_parse add_x_offset offset [=height]}${color}is the java dbus
${voffset 3}${lua_parse add_x_offset offset [=height]}${color}listener running?
${voffset [=-1*(16*4)]}\
${lua increment_offsets [=noAppWidth] 0}\
${endif}\
#
# :::::::::::::::: transmission torrent overview ::::::::::::::::
#
${if_match ${lines [=torrentsFile]} == 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png 0 0 [=noAppWidth]x[=height]}\
<#assign iconHeight = 45>
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-transmission.png [=((height-iconHeight)/2)?round] [=((height-iconHeight)/2)?round] [=iconHeight]x[=iconHeight]}\
${voffset [=3+16]}${lua_parse add_x_offset offset [=height]}${color1}transmission
${voffset 3}${lua_parse add_x_offset offset [=height]}${color}no active torrents
${lua increment_offsets [=noAppWidth] 0}\
${else}\
<@panel.verticalTable x=0 y=0 header=transmissionHeaderWidth width=transmissionPanelWidth height=height isFixed=false/>
<#assign peersFile = inputDir + "transmission.peers.raw",
         uploadFile = inputDir + "transmission.speed.up"
         downloadFile = inputDir + "transmission.speed.down">
${voffset 3}${lua_parse add_x_offset offset 6}${color1}torrents${lua_parse alignr 0}${color}${lines [=torrentsFile]} 
${voffset 3}${lua_parse add_x_offset offset 6}${color1}swarm${lua_parse alignr 0}${color}${lines [=peersFile]} 
${voffset 3}${lua_parse add_x_offset offset 6}${color1}up${lua_parse alignr 6}${color}${cat [=uploadFile]}
${voffset 3}${lua_parse add_x_offset offset 6}${color1}down${lua_parse alignr 6}${color}${cat [=downloadFile]}
${voffset [=-1*(16*4)]}\
${lua increment_offsets [=transmissionPanelWidth] 0}\
#
# :::::::::::::::: transmission active torrents ::::::::::::::::
#
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png 0 0 [=transmissionTorrentsWidth]x[=height]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark.png [=29*6+6] 0 [=6+5*6+6]x[=height]}\
${lua_parse head [=torrentsFile] 4 6}
${lua increment_offsets [=transmissionTorrentsWidth] 0}\
${endif}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light-edge-top-right.png -7 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light-edge-bottom-right.png -7 [=height-7]}\
]];
