<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/menu.lua',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- header|middle|bottom_left|right
  gap_x = 205,
  gap_y = 557,

  -- window settings
  <#assign width = 189>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  own_window = true,
  own_window_type = 'deskheader',    -- values: deskheader (background), panel (bar)
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
  color1 = '[=colors.labels]',            -- labels
  color2 = '[=(colors.warning)?c]',         -- bar critical
  
  -- torrent peer ip/port: ${template1 #}
  template1 = [[${voffset 3}${offset 5}${color}${tcp_portmon 51413 51413 rip \1}${alignr 5}${tcp_portmon 51413 51413 rport \1}]]
};

conky.text = [[
# :::::::::::: bittorrent peers
${if_running transmission-gt}\
<#assign y = 0, 
         header = 19, <#-- menu header -->
         body = 197,  <#-- menu window without the header -->
         gap = 3>     <#-- empty space between windows -->
<@menu.compositeTable x=0 y=y width=width vheader=69 hbody=body/>
${voffset 2}${offset 5}${color1}bittorrent${goto 75}${color}${tcp_portmon 51413 51413 count} peer(s)
${voffset -5}${color2}${hr 1}${voffset -8}
<#assign y += header + 1 + header + body + gap>
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
<@menu.compositeTable x=0 y=y width=width vheader=69 hbody=400 bottomEdges=false/>
# sample 'lsof' lines being grep'ed for determining files being seeded by transmission
# FD     TYPE DEVICE     SIZE/OFF      NODE NAME
# 102r   REG  8,16     3297924792 163446839 /media/movie.mp4            < use read file descriptor pattern
# 74r    REG  0,19              0  19821859 /proc/513729/mountinfo      < non real files have a size of 0 bytes
# 100u   REG  0,1        67108864    718707 /memfd:pulseaudio (deleted) < items with 'deleted' are excluded
# files less than 1000 bytes are ignored, ex. txt, nfo, info files
<#assign file = "/tmp/conky/bittorrent">
${lua compute ${exec lsof -c transmission -n | grep -v deleted | grep -E '[0-9]+[a-z|A-Z] +REG +[0-9]+,[0-9]+ +[0-9]{6,}' | sed 's|.\+/||' | sed 's/^/${voffset 3}${offset 5}/' | sed 's/#/\\#/g' | sort > [=file]}}\
${offset 5}${color1}seeding${goto 75}${color}${lua compute_and_save files ${lines [=file]}} files
${voffset -5}${color2}${hr 1}${voffset -8}
${voffset 7}${offset 5}${color1}file name${voffset 4}
${color}${catp [=file]}${voffset 5}
<#assign y += header + 1 + header, maxLines = 50>
${lua_parse bottom_edge_load_value [=conky] [=image.primaryColor]-menu-light-edge-bottom 0 [=y?c] [=width?c] 3 files [=maxLines]}\
${endif}\
]];
