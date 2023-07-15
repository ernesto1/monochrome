<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 142,
  gap_y = 121,

  -- window settings
  <#assign width = 189>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  minimum_height = 71,      -- conky will add an extra pixel to this height
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
  imlib_cache_flush_interval = 2,

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.menuText]',  -- regular text
  color1 = '[=colors.labels]'
  
  -- n.b. this conky requires the music-player java app to be running in the background
  --      it generates input files under /tmp/conky/musicplayer.* which this conky will read
};

conky.text = [[
# the UI of this conky changes as per one of these states: no music player is running
#                                                          song with album art
#                                                          song with no album art
# :::: no player available
${if_existing /tmp/conky/musicplayer.name Nameless}\
<#assign y = 0>
${image ~/conky/monochrome/images/common/[=image.primaryColor]-rhythmbox.png -p 0,[=y]}\
<@menu.menu x=58 y=33 width=111 height=38/>
${voffset 36}${offset 63}${color1}now playing
${voffset 4}${offset 63}${color}no player running
${else}\
# :::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
<#assign header = 19,    <#-- menu header -->
         body = 185,  <#-- size of the album window without the header -->
         gap = 5>   <#-- empty space between windows -->
<@menu.menu x=0 y=y width=width height=header+body isDark=true/>
${voffset 2}${alignc}${color1}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}} ${color}: ${if_existing /tmp/conky/musicplayer.playbackStatus Playing}${color1}${endif}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${lua_parse album_art_image ${cat /tmp/conky/musicplayer.albumArtPath} 181x181 4,[=(header)?c]}\
<#assign y += header + body + gap>
${voffset [=193 + gap]}\
# :::: track details
<@menu.verticalTable x=0 y=y header=45 body=width-45 height=71/>
${offset 5}${color1}title${goto 50}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.title}}
${voffset 3}${offset 5}${color1}album${goto 50}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.album}}
${voffset 3}${offset 5}${color1}artist${goto 50}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.artist}}
${voffset 3}${offset 5}${color1}genre${goto 50}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.genre}}${voffset 5}
${else}\
# :::: no album art 
${image ~/conky/monochrome/images/common/[=image.primaryColor]-rhythmbox.png -p 0,0}\
<@menu.menu x=54 y=0 width=width-54 height=71 isDark=false/>
${voffset 4}${offset 59}${color}${if_existing /tmp/conky/musicplayer.playbackStatus Playing}${color1}${endif}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.title} 21}
${voffset 3}${offset 59}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.album} 21}
${voffset 3}${offset 59}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.artist} 21}
${voffset 3}${offset 59}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.genre} 21}
${endif}\
${endif}\
]];
