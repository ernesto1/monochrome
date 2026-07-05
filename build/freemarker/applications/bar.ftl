<#import "/lib/panel-round.ftl" as panel>
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
           albumWidth = height-2,       <#-- album art width -->
           width  = 5+albumWidth+33*6>
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
  max_user_text = 26000,    -- max size of user text buffer in bytes, i.e. text inside conky.text section
                            -- default is 16,384 bytes

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.highlight]'         -- highlight important packages
};

conky.text = [[
${voffset 3}\
#
# :::::::::::::::: now playing ::::::::::::::::
# the UI of this conky has four states: song with album art
#                                       song with no album art
#                                       no music player is running
#                                       dependent java dbus listener application is not running
# :::::: no player available
${if_existing /tmp/conky/musicplayer.status}\
${if_existing /tmp/conky/musicplayer.status off}\
<@panel.panel x=0 y=0 width=176 height=height/>
<#assign defaultAlbumHeight = 45>
${image ~/conky/monochrome/images/common/[=image.primaryColor]-album-cover.png -p 10,[=((height-defaultAlbumHeight)/2)?round] -s [=defaultAlbumHeight]x[=defaultAlbumHeight]}\
${voffset [=3+16]}${offset [=6+4+defaultAlbumHeight+6+4]}${color1}now playing
${voffset 3}${offset [=6+4+defaultAlbumHeight+6+4]}${color}no player running
${else}\
# :::::: player running
<#assign labelWidth = 5+albumWidth+6+6*6+6> <#-- width of the dark portion of the vertical table -->
<@panel.verticalTable x=0 y=0 header=labelWidth body=width-labelWidth height=height/>
<#assign defaultAlbumHeight = 50>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-album-cover.png -p [=((5+height-defaultAlbumHeight)/2)?round],[=((height-defaultAlbumHeight)/2)?round] -s [=defaultAlbumHeight]x[=defaultAlbumHeight]}\
${if_existing /tmp/conky/musicplayer.track.art}\
${image /tmp/conky/musicplayer.track.art -p 7,1 -s [=albumWidth]x[=albumWidth] -n}\
${endif}\
${voffset 3}${offset [=5+albumWidth+6]}${color1}title${goto [=labelWidth+6]}${color}${scroll wait 23 4 1 ${cat /tmp/conky/musicplayer.track.title}}
${voffset 3}${offset [=5+albumWidth+6]}${color1}album${goto [=labelWidth+6]}${color}${scroll wait 23 4 1 ${cat /tmp/conky/musicplayer.track.album}}
${voffset 3}${offset [=5+albumWidth+6]}${color1}artist${goto [=labelWidth+6]}${color}${scroll wait 23 4 1 ${cat /tmp/conky/musicplayer.track.artist}}
${voffset 3}${offset [=5+albumWidth+6]}${color1}genre${goto [=labelWidth+6]}${color}${cat /tmp/conky/musicplayer.track.genre}
${endif}\
${else}\
no files!
${endif}\
]];
