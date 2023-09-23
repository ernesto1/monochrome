<#import "/lib/menu-square.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua ~/conky/monochrome/musicPlayer.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 123,
  gap_y = 10,

  -- window settings
  minimum_width = 373,      -- conky will add an extra pixel to this width
  maximum_width = 373,
  minimum_height = 20,      -- conky will add an extra pixel to this height
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
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  
  -- colors
  default_color = '[=colors.systemText]',  -- regular text
  color1 = '[=colors.systemLabels]',         -- text labels
  
  -- n.b. this conky requires the music-player java app to be running in the background
  --      it generates input files under /tmp/conky/musicplayer.* which this conky will read
};

conky.text = [[
# the UI of this conky changes as per one of these states: no music player is running
#                                                          song with album art
#                                                          song with no album art
# :::::::: no player available
${if_existing /tmp/conky/musicplayer.name Nameless}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sound-wave-small.png -p 0,0}\
<@menu.table x=49 y=0 width=110 header=3 body=43/>
${voffset 10}${goto 55}${color1}now playing
${voffset 4}${goto 55}${color}no player running${voffset 5}\
${else}\
${lua load_track_info}\
# :::::::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-music-player-album.png -p 0,0}\
${lua_parse album_art_image ${cat /tmp/conky/musicplayer.albumArtPath} 146x146 6,7}\
# having album art will push the track details text & images towards the bottom right
${lua add_offsets 162 62}${lua_parse assess_vertical_offset 16 album artist genre}\
${lua_parse conky_draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-music-player-header.png 0 0}\
# ::: player header
${lua_parse conky_add_y_offset voffset 2}${lua_parse add_x_offset goto 6}${color1}\
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}now playing on\
${else}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}${endif}\
${goto 310}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}${voffset 7}
${lua add_offsets 0 22}\
${endif}\
# :::::::: track details
# menu expands based on the track metadata fields available, only 'title' is considered mandatory
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-dark.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-light.png 45 0}\
# right side blank image
${lua_parse draw_image ~/conky/monochrome/images/common/menu-blank.png 211 0}\
${voffset 3}${lua_parse add_x_offset goto 6}${color1}title${lua_parse add_x_offset goto 51}${color}${lua_parse truncate_string ${lua get title} 26}\
${if_match "${lua get album}" != "unknown album"}\
<#-- vertical offset would normally be 3px between fields but in order to support optional fields and not introduce
     blank new lines, each field does have a line break.  Hence the use of 16px in order to compensate for this -->
${voffset 16}${lua_parse add_x_offset goto 6}${color1}album${lua_parse add_x_offset goto 51}${color}${lua_parse truncate_string ${lua get album} 26}\
${endif}\
${if_match "${lua get artist}" != "unknown artist"}\
${voffset 16}${lua_parse add_x_offset goto 6}${color1}artist${lua_parse add_x_offset goto 51}${color}${lua_parse truncate_string ${lua get artist} 26}\
${endif}\
${if_match "${lua get genre}" != "unknown genre"}\
${voffset 16}${lua_parse add_x_offset goto 6}${color1}genre${lua_parse add_x_offset goto 51}${color}${lua_parse truncate_string ${lua get genre} 26}\
${endif}\
${voffset 4}\
# final adjustments to the track details menu image based on what UI is being used
# :::::::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
${voffset 6}\
# bottom blank image
${image ~/conky/monochrome/images/common/menu-blank.png -p 162,153}\
${else}\
# :::::::: no album art
# add the background sound wave image to the right of the menu
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sound-wave.png 141 0}\
${endif}\
${endif}\
]];
