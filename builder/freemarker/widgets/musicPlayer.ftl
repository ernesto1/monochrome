<#import "/lib/panel-round.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 2148,               -- same as passing -x at command line
  gap_y = 0,

  -- window settings
  minimum_width = 402,      -- conky will add an extra pixel to this
  maximum_width = 402,
  minimum_height = 158,     -- conky will add an extra pixel to this height
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
  use_xft = true,
  xftalpha = 1,
  draw_shades = true,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  font = 'Typo Round Light Demo:size=11',     -- text
  font0 = 'Typo Round Light Demo:size=15',    -- title
  
  -- colors
  default_color = 'white',  -- regular text
  color1 = '[=colors.warning]',        -- error
  
  -- n.b. this conky requires the music-player java app to be running in the background
  --      it generates the input files under /tmp/conky/musicplayer.* which this conky reads
};

conky.text = [[
# the UI of this conky changes as per one of these states: no music player is running
#                                                          song with album art
#                                                          song with no album art
#                                                          dependent java dbus listener application is not running
${image ~/conky/monochrome/images/widgets/[=image.primaryColor]-album-cover.png -p 0,0}\
${if_existing /tmp/conky/musicplayer.status}\
# :::::::: no player available
${if_existing /tmp/conky/musicplayer.status off}\
<#-- top 0 | middle 8 | bottom 62 -->
${voffset 74}${offset 139}${font0}now playing
${voffset 0}${offset 139}${font}no music player running
${else}\
# :::::::: album art
<#assign albumArtFile = "/tmp/conky/musicplayer.track.art">
${if_existing [=albumArtFile]}\
${image ~/conky/monochrome/images/[=conky]/album-shadow.png -p 0,0}\
${lua_parse draw_image [=albumArtFile] 15 22 110x110}\
${voffset 9}\
${endif}\
# ::::::::: track details
# artist & genre are optional (not all tracks have it defined) so we don't display if it is not available
# hence we shift the text when the data point is missing
${if_match "${lua get artist ${cat /tmp/conky/musicplayer.track.artist}}" == "unknown artist"}${voffset 22}${endif}\
${if_match "${lua get genre ${cat /tmp/conky/musicplayer.track.genre}}" == "unknown genre"}${voffset 22}${endif}\
${voffset 31}${offset 139}${font0}${color}${cat /tmp/conky/musicplayer.track.title}
${offset 139}${font}${color}${cat /tmp/conky/musicplayer.track.album}
${if_match "${lua get artist}" != "unknown artist"}${voffset 4}${offset 139}${font}${color}${lua get artist}${endif}
${if_match "${lua get genre}" != "unknown genre"}${voffset 4}${offset 139}${font}${color}${lua get genre}${endif}
${endif}\
${else}\
${voffset 74}${offset 139}${font0}now playing
${voffset 0}${offset 139}${font}${color1}missing input files
${endif}\
${voffset -100}\
]];
