conky.config = {
  lua_load = '~/conky/monochrome/musicPlayer.lua ~/conky/monochrome/menu.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 125,
  gap_y = 30,

  -- window settings
  minimum_width = 400,      -- conky will add an extra pixel to this  
--  maximum_width = 800,
  minimum_height = 159,
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
  xft_alpha = 1,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)

  font0 = 'Typo Round Light Demo:size=10',
  font1 = 'Typo Round Regular Demo:size=15',
  
  -- colors
  default_color = 'white',  -- regular text
  color1 = '[=colors.systemText]'          -- text labels
  
  -- n.b. this conky requires the music-player java app to be running in the background
};

conky.text = [[
# :::: album art
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-album-cover.png -p 0,0}\
${lua_parse album_art_image ${cat /tmp/conky/musicplayer.albumArtPath} 146x146 7,7}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-solid.png -p 165,65}\
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-transparent.png -p 165,93}\
${image ~/conky/monochrome/images/menu-blank.png -p 165,155}\
${voffset 68}${goto 170}${color}${font1}${lua_parse read_file ${cat /tmp/conky/musicplayer.title}}${font0}
${voffset 7}${goto 170}${color1}${font0}${lua_parse read_file ${cat /tmp/conky/musicplayer.album}}
${voffset 1}${goto 170}${color1}${font0}${lua_parse read_file ${cat /tmp/conky/musicplayer.artist}}
${voffset 1}${goto 170}${color1}${font0}${lua_parse read_file ${cat /tmp/conky/musicplayer.genre}}
]];
