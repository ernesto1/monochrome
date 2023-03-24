conky.config = {
  lua_load = '~/conky/monochrome/mediaPlayer.lua',
  
  update_interval = 2,    -- update interval in seconds
  <#if conky == "widgets-dock"><#assign monitor = 1><#else><#assign monitor = 0></#if>
  xinerama_head = [=monitor],      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_right',  -- top|middle|bottom_left|right
  gap_x = 5,
  gap_y = 5,

  -- window settings
  minimum_width = 189,      -- conky will add an extra pixel to this  
  maximum_width = 189,
  minimum_height = 281,
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
  
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address  
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.menuText]',  -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.highlight]'          -- highlight important packages  
};

conky.text = [[
# :::: cover art
<#assign y = 0, 
         top = 19,    <#-- menu header -->
         body = 182,  <#-- size of the current window without the top and bottom edges -->
         bottom = 7,  <#-- window bottom edge -->
         space = 3>   <#-- empty space between windows -->
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-top.png -p 0,[=y?c]}\
<#assign y += top>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu.png -p 0,[=y?c]}\
<#assign y += body>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-bottom.png -p 0,[=y?c]}\
${voffset 2}${alignc}${color1}${cat /tmp/mediaplayer.playbackStatus}
${if_existing /tmp/mediaplayer.albumArtPath}\
${lua_parse album_art_image ${cat /tmp/mediaplayer.albumArtPath} 181x181 4,[=(top+4)?c]}\
${else}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-rhythmbox.png -p 0,[=top?c]}\
${endif}\
# :::: track details
<#assign y += bottom + space, body = 71>
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-horizontal.png -p 0,[=y?c]}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-menu-horizontal-data.png -p 45,[=y?c]}\
<#assign y += body>
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
${voffset 200}${offset 5}${color1}title${goto 50}${color}${cat /tmp/mediaplayer.title}
${voffset 3}${offset 5}${color1}album${goto 50}${color}${cat /tmp/mediaplayer.album}
${voffset 3}${offset 5}${color1}artist${goto 50}${color}${cat /tmp/mediaplayer.artist}
${voffset 3}${offset 5}${color1}genre${goto 50}${color}${cat /tmp/mediaplayer.genre}
]];
