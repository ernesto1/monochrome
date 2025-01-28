<#import "/lib/panel-round.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',  -- header|middle|bottom_left|right
  gap_x = 107,
  gap_y = -618,

  -- window settings
  <#assign width = 271>
  minimum_width = [=width],      -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = 400,
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
  
  imlib_cache_flush_interval = 250,
  text_buffer_size=2096,

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]',        -- text labels
};

conky.text = [[
# this conky requires:
# - the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote
# - the transmission.bash script running in the background
# :::::::::::: torrents overview
<#assign y = 0,
         inputDir = "/tmp/conky",
         activeTorrentsFile = inputDir + "/transmission.active",
         max = 40>
# :::::::::::: active torrents
${if_existing [=activeTorrentsFile]}\
${if_match ${lines [=activeTorrentsFile]} > 0}\
<@panel.panel x=0 y=y width=width isFixed=false/>
${color}${voffset 2}${lua_parse head [=activeTorrentsFile] [=max] 6}${lua increase_y_offset [=activeTorrentsFile]}
<@panel.panelsBottom x=0 y=0 widths=[width] gap=colGap isFixed=false/>
${endif}\
${endif}\
]];
