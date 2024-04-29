<#import "/lib/menu-square.ftl" as menu>
  -- n.b. this conky requires the music-player java app to be running in the background
  --      it generates input files under /tmp/conky/musicplayer.* which this conky will read
  
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua ~/conky/monochrome/musicPlayer.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_right',  -- top|middle|bottom_left|right
  gap_x = 3,
  gap_y = 127,

  -- window settings
  <#assign width = 159, iconHeight = 38>
  minimum_width = [=width],      -- conky will add an extra pixel to this width
  maximum_width = [=width],
  minimum_height = [=iconHeight],      -- conky will add an extra pixel to this height
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
  
  -- images
  imlib_cache_flush_interval = 250,

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  
  -- colors
  default_color = '[=colors.systemText]',  -- regular text
  color1 = '[=colors.systemLabels]',         -- text labels
  color3 = '[=colors.secondary.labels]',         -- secondary menu labels
  color4 = '[=colors.secondary.text]'         -- secondary menu text
};

conky.text = [[
# the UI of this conky has four states: song with album art
#                                       song with no album art
#                                       no music player is running
#                                       dependent java dbus listener application is not running
${if_existing /tmp/conky/musicplayer.name}\
# :::::::: no player available
${if_existing /tmp/conky/musicplayer.name Nameless}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sound-wave.png -p 0,0}\
<#assign iconWidth = 38,       <#-- icon is a square -->
         gap = 2>
<@menu.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconHeight/>
${voffset 5}${goto 48}${color1}now playing
${voffset 2}${goto 48}${color}no player running${voffset 5}\
${else}\
# :::::::: player available
${lua load_track_info}\
# ::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-music-player-album.png -p 0,0}\
${lua_parse load_image ${cat /tmp/conky/musicplayer.albumArtPath} 147x147 6 6}\
${voffset [=width+gap]}${lua increment_offsets 0 [=width + gap]}\
${endif}\
# ::: playback status
<#assign height = 19>
${if_match "${lua get playbackStatus ${cat /tmp/conky/musicplayer.playbackStatus}}" == "Playing"}\
${lua_parse conky_draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-music-player-bar-playing.png 0 0}${color4}\
${else}\
${lua_parse conky_draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-music-player-bar.png 0 0}${color1}\
${endif}\
${lua increment_offsets 0 [=height + gap]}\
${voffset 2}${offset 5}${lua get playbackStatus}${alignr 3}${color}${cat /tmp/conky/musicplayer.name}${voffset 6}
# ::: track details
# menu expands based on the track metadata fields available, only 'title' is considered mandatory
<@menu.panel x=0 y=0 width=width isFixed=false/>
${if_match "${lua get playbackStatus}" == "Playing"}\
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-panel-sound-wave.png [=width-69] 0}\
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
${else}\
# :::::::: error state | input files are missing
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-sound-wave.png -p 0,0}\
<@menu.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconHeight isDark=true color=image.secondaryColor/>
${voffset 5}${offset 48}${color3}now playing
${voffset 2}${offset 48}${color4}missing files
${endif}\
]];
