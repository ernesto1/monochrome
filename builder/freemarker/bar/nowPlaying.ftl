<#import "/lib/panel-round.ftl" as panel>
conky.config = {  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_right',  -- top|middle|bottom_left|right
  gap_x = 6,
  gap_y = 38,

  -- window settings
  <#assign border = 6,
           lborder = border - 1,
           width = border * 2 + 83>
  minimum_width = [=width],      -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = 146,
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
  own_window_argb_visual = true,    -- turn on transparency
  
  -- miscellanous settings
  imlib_cache_flush_interval = 250,

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]',
  color3 = '[=colors.secondary.text]',        -- secondary panel text
  
  -- ::: templates
  -- use secondary color if music is playing
  template1 = [[${color}${if_existing /tmp/conky/musicplayer.playbackStatus Playing}${color3}${endif}]]
};

conky.text = [[
# :::::::::::: now playing
<#assign y = 0,
         gap = 6,
         height = 3 + width-border + 3*16 + 6,
         inputDir = "/tmp/conky/">
<@panel.panel x=0 y=y height=height width=width/>
${if_existing [=inputDir + "musicplayer.status"] off}\
${voffset [=3 + width - border + 16 + 1]}\
${voffset 3}${offset [=border]}${color1}now playing
${voffset 3}${offset [=border]}${color}${scroll wait 14 2 1 no player running}
${else}\
${if_existing [=inputDir + "musicplayer.playbackStatus"] Playing}\
<@panel.panel x=0 y=y height=height width=width color=image.secondaryColor/>
${endif}\
${if_existing [=inputDir + "musicplayer.track.albumArtPath"]}\
${image ~/conky/monochrome/java/albumArt/nowPlaying -p [=3],[=y+3] -s [=width-border]x[=width-border] -n}\
<#assign y += height + gap>
${voffset [=3 + width - border + 1]}\
${else}\
${voffset [=3 + width - border - 16 + 1]}\
${voffset 3}${offset [=border]}${template1}${scroll wait 14 2 1 ${cat [=inputDir + "musicplayer.name"]}}
${endif}\
${voffset 3}${offset [=border]}${template1}${scroll wait 14 2 1 ${cat [=inputDir + "musicplayer.track.title"]}}
${voffset 3}${offset [=border]}${template1}${scroll wait 14 2 1 ${cat [=inputDir + "musicplayer.track.album"]}}
${voffset 3}${offset [=border]}${template1}${scroll wait 14 2 1 ${cat [=inputDir + "musicplayer.track.artist"]}}
${endif}\
]];
