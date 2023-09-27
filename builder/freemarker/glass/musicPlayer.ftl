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
  gap_y = 5,

  -- window settings
  <#assign width = 159>
  minimum_width = [=width-1],      -- conky will add an extra pixel to this width
  maximum_width = [=width-1],
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
${if_existing /tmp/conky/musicplayer.albumArtPath}\
# :::::::: album art
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-music-player-album.png -p 0,0}\
${lua_parse album_art_image ${cat /tmp/conky/musicplayer.albumArtPath} 147x147 6,6}\
${endif}\
<#assign y = width + 2>
${lua add_offsets 0 [=y]}\
# ::: player header
<#assign height = 19>
<@menu.verticalTable x=0 y=0 header=90 body=width-90 height=height fixed=false/>
${lua_parse conky_draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-music-player-separator.png 58 0}\
<#assign y += height + 2>
${lua add_offsets 0 [=y]}\
${voffset [=width+3+1]}${offset 5}${color1}\
${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}${alignr 3}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}${voffset 6}
# ::: track details
# menu expands based on the track metadata fields available, only 'title' is considered mandatory
<@menu.menu x=0 y=y width=width height=height bottomEdges=false fixed=false/>
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sound-wave.png -p [=width-69],[=y]}\
${endif}\
${voffset 3}${offset 5}${color}${lua_parse truncate_string ${lua get title} 25}\
${if_match "${lua get album}" != "unknown album"}\
<#-- vertical offset would normally be 3px between fields but in order to support optional fields and not introduce
     blank new lines, each field does have a line break.  Hence the use of 16px in order to compensate for this -->
${voffset 16}${goto 5}${color}${lua_parse truncate_string ${lua get album} 25}\
${endif}\
${if_match "${lua get artist}" != "unknown artist"}\
${voffset 16}${goto 5}${color}${lua_parse truncate_string ${lua get artist} 25}\
${endif}\
${if_match "${lua get genre}" != "unknown genre"}\
${voffset 16}${goto 5}${color}${lua_parse truncate_string ${lua get genre} 25}\
${endif}\
${voffset 3}\
${endif}\
]];
