<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 2148,               -- same as passing -x at command line
  gap_y = 0,

  -- window settings
  minimum_width = 400,      -- conky will add an extra pixel to this  
  minimum_height = 163,      -- conky will add an extra pixel to this height
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
  use_xft = true,
  xftalpha = 0,
  draw_shades = true,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  font = 'Typo Round Light Demo:size=11',     -- text
  font0 = 'Typo Round Light Demo:size=15',      -- title
  font1 = 'Typo Round Light Demo:size=10',      -- small text
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.bar]',        -- track title
  color2 = '[=colors.labels]',     -- labels
  color3 = 'white'     -- labels
  
  -- n.b. this conky requires the music-player java app to be running in the background
  --      it generates input files under /tmp/conky/musicplayer.* which this conky will read
};

conky.text = [[
# the UI of this conky changes as per one of these states: no music player is running
#                                                          song with album art
#                                                          song with no album art
# :::::::: no player available
${if_existing /tmp/conky/musicplayer.name Nameless}\
<#assign y = 42>
${image ~/conky/monochrome/images/common/grape-rhythmbox.png -p 15,[=y]}\
${voffset 70}${offset 75}${font1}${color3}now playing
${voffset 4}${offset 75}${color2}no player running
${else}\
# :::::::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
<#assign y = 0>
${image ~/conky/monochrome/images/[=conky]/album-shadow.png -p 0,[=y]}\
<#assign y = 22>
${lua_parse album_art_image ${cat /tmp/conky/musicplayer.albumArtPath} 110x110 15,[=y]}\
${lua add_offsets 65 20}\
${else}\
${image ~/conky/monochrome/images/common/grape-rhythmbox.png -p 15,42}\
${endif}\
# ::::::::: track details
${lua_parse add_y_offset voffset 42}${lua_parse add_x_offset offset 78}${font0}${color1}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.title} 34}
${lua_parse add_x_offset offset 78}${font}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.album} 36}
${voffset 4}${lua_parse add_x_offset offset 78}${font}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.artist} 36}
${endif}\
]];
