conky.config = {
  lua_load = '~/conky/monochrome/menu.lua',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- top|middle|bottom_left|right
  gap_x = 205,
  gap_y = 557,

  -- window settings
  minimum_width = 189,      -- conky will add an extra pixel to this  
  maximum_width = 189,
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
  
  imlib_cache_flush_interval = 250,
  text_buffer_size=3500,

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.menuText]',  -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.highlight]',         -- highlight important packages
  
  -- torrent peer ip/port: ${template1 #}
  template1 = [[${voffset 3}${offset 5}${color}${tcp_portmon 51413 51413 rip \1}${alignr 5}${tcp_portmon 51413 51413 rport \1}]]
};

conky.text = [[
# :::::::::::: bittorrent peers
${if_running transmission-gt}\
<#assign y = 0, 
         top = 19,    <#-- menu header -->
         body = 190,  <#-- size of the current window without the top and bottom edges -->
         bottom = 7,  <#-- window bottom edge -->
         space = 5,   <#-- empty space between windows -->
         windowYcoordinate = y> <#-- starting y coordinate of the current window -->
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-horizontal.png -p 0,[=y?c]}\
${voffset 2}${offset 5}${color1}bittorrent${goto 75}${color}${tcp_portmon 51413 51413 count} peer(s)
<#assign y += top>
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
<#assign y += 1>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-top-flat.png -p 0,[=y?c]}\
<#assign y += top>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu.png -p 0,[=y?c]}\
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-bittorrent.png -p 38,[=(y+32)?c]}\
<#assign y += body>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-bottom.png -p 0,[=y?c]}\
<#assign y += bottom + space>
${voffset 7}${offset 5}${color1}ip address${alignr 5}remote port${voffset 3}
${if_match ${tcp_portmon 51413 51413 count} > 0}\
<#list 0..11 as x>
${template1 [=x]}<#if x?is_last>${voffset 11}</#if>
</#list>
${else}\
${voffset 84}${alignc}${color}no peer connections
${voffset 3}${alignc}established${voffset 90}
${endif}\
# :::::::::::: files being seeded at the moment
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-horizontal.png -p 0,[=y?c]}\
# sample 'lsof' lines being grep'ed for determining files being seeded by transmission
# FD     TYPE DEVICE     SIZE/OFF      NODE NAME
# 102r   REG  8,16     3297924792 163446839 /media/movie.mp4            < use read file descriptor pattern
# 74r    REG  0,19              0  19821859 /proc/513729/mountinfo      < non real files have a size of 0 bytes
# 100u   REG  0,1        67108864    718707 /memfd:pulseaudio (deleted) < items with 'deleted' are excluded
# files less than 1000 bytes are ignored, ex. txt, nfo, info files
<#assign file = "/tmp/conky/bittorrent">
${lua compute ${exec lsof -c transmission -n | grep -v deleted | grep -E '[0-9]+[a-z|A-Z] +REG +[0-9]+,[0-9]+ +[0-9]{6,}' | sed 's|.\+/||' | sed 's/^/${voffset 3}${offset 5}/' | sed 's/#/\\#/g' | sort > [=file]}}\
${voffset 2}${offset 5}${color1}seeding${goto 75}${color}${lua compute_and_save files ${lines [=file]}} files
<#assign y += top>
${image ~/conky/monochrome/images/menu-blank.png -p 0,[=y?c]}\
<#assign y += 1>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu-top-flat.png -p 0,[=y?c]}\
<#assign y += top>
${image ~/conky/monochrome/images/compact/[=image.primaryColor]-menu.png -p 0,[=y?c]}\
${lua_parse bottom_edge_load_value compact [=image.primaryColor]-menu-bottom.png 0 [=y?c] 3 files}\
${voffset 7}${offset 5}${color1}file name${voffset 4}
${color}${catp [=file]}${voffset 5}
${endif}\
]];
