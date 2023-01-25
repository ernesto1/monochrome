conky.config = {
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',       -- top|middle|bottom_left|middle|right
  gap_x = 152,                  -- same as passing -x at command line
  gap_y = 290,

  -- window settings
  minimum_width = 218,
  minimum_height = 110,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)
  own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',

  -- transparency configuration
  draw_blended = false,
  own_window_transparent = true,
  own_window_argb_visual = true,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 1,         -- width of border window in pixels
  stippled_borders = 0,     -- border stippling (dashing) in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels

  -- graph settings
  draw_graph_borders = false, -- borders around the graph, ex. cpu graph, network down speed grah
                              -- does not include bars, ie. wifi strength bar, cpu bar

  imlib_cache_flush_interval = 300,
  -- use the parameter -n on ${image ..} to never cache and always update the image upon a change
  
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)

  -- colors
  default_color = '[=colors.systemText]',  -- regular text
  color1 = '[=colors.systemLabels]',         -- text labels
  color2 = '[=colors.highlight]'             -- flag important packages
};

conky.text = [[
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-table.png -p 0,0}\
${voffset 4}${color1}${goto 30}kernel${goto 74}${color}${kernel}
${voffset 3}${goto 30}${color1}uptime${goto 74}${color}${uptime}
${voffset 3}${offset 5}${color1}compositor${goto 74}${color}${execi 3600 echo $XDG_SESSION_TYPE}
${voffset 8}\
# if on wifi
<#if system == "laptop">
${image ~/conky/monochrome/images/glass/[=image.primaryColor]-menu-table.png -p 0,27}\
${voffset 3}${goto 24}${color1}network${goto 74}${color}${wireless_essid wlp4s0}
${voffset 3}${color1}${goto 18}local ip${goto 74}${color}${addr wlp4s0}
</#if>
${voffset 3}${offset 5}${color1}bittorrent${goto 74}${color}${tcp_portmon 51413 51413 count} peer(s)
${voffset 3}${color1}${goto 42}zoom${goto 74}${color}${if_running zoom}running${else}off${endif}
# :::::::::::: package updates
${if_existing /tmp/dnf.packages.preview}\
<#if system == "desktop"><#assign y = 92><#else><#assign y = 132></#if>
${image ~/conky/monochrome/images/glass/blue-menu.png -p 0,[=y]}\
${image ~/conky/monochrome/images/glass/blue-menu-transparent.png -p 0,[=y + 38]}\
${voffset 15}${alignc}${color1}dnf package management
${voffset 3}${alignc}${color}${lines /tmp/dnf.packages} package update(s) available
${voffset 5}${offset 5}${color1}package${alignr 4}version
# the dnf package lookup script refreshes the package list every 10m
<#if system == "desktop"><#assign lines = 100><#else><#assign lines = 28></#if>
${voffset 3}${color}${execpi 20 head -n [=lines] /tmp/dnf.packages.preview}
${endif}\
${voffset -9}
]];
