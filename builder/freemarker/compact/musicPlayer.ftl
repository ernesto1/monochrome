<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  <#if conky == "widgets-dock"><#assign monitor = 1><#else><#assign monitor = 0></#if>
  xinerama_head = [=monitor],      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_right',  -- top|middle|bottom_left|right
  <#if conky == "widgets-dock"><#assign x = 142, y = 119><#else><#assign x = 5, y = 5></#if>
  gap_x = [=x],
  gap_y = [=y],

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
  imlib_cache_flush_interval = 250,

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
# :::::::: no player available
${if_existing /tmp/conky/musicplayer.name Nameless}\
<#assign y = 0>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-rhythmbox.png -p 0,[=y]}\
<@menu.menu x=55 y=33 width=113 height=38/>
${voffset 36}${offset 61}${color1}now playing
${voffset 4}${offset 61}${color}no player running
${else}\
# :::::::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
<#assign top = 19,    <#-- menu header -->
         body = 185,  <#-- size of the current window without the header -->
         gap = 3>   <#-- empty space between windows -->
<@menu.menu x=0 y=y width=width height=top+body isDark=true/>
${voffset 2}${alignc}${color1}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}} ${color}: ${if_existing /tmp/conky/musicplayer.playbackStatus Playing}${color1}${endif}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${lua_parse album_art_image ${cat /tmp/conky/musicplayer.albumArtPath} 181x181 4,[=(top)?c]}\
<#assign y += y + top + body + gap, body = 71>
<@menu.verticalTable x=0 y=y header=45 body=width-45 height=body/>
${voffset 196}\
${else}\
# :::::::: no album art available
<#assign y = 0>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-rhythmbox.png -p 0,[=y]}\
<@menu.menu x=55 y=33 width=width-55 height=38 isDark=true/>
${voffset 36}${offset 61}${color1}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}
${voffset 4}${offset 61}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
<#assign y += 71 + gap, body = 71>
<@menu.verticalTable x=0 y=y header=45 body=width-45 height=body/>
${voffset 12}\
${endif}\
# :::::::: track details
${offset 5}${color1}title${goto 50}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.title}}
${voffset 3}${offset 5}${color1}album${goto 50}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.album}}
${voffset 3}${offset 5}${color1}artist${goto 50}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.artist}}
${voffset 3}${offset 5}${color1}genre${goto 50}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.genre}}${voffset 5}
${endif}\
]];
