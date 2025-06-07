<#import "/lib/panel-round.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_middle',  -- top|middle|bottom_left|right|middle
  gap_x = 0,
  gap_y = 6,

  -- window settings
  <#assign width = 299>
  minimum_width = [=width],      -- conky will add an extra pixel to this
  maximum_width = [=width],
  <#assign conkyHeight = 359>
  minimum_height = [=conkyHeight],
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
  
  imlib_cache_flush_interval = 250,

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]',        -- text labels
  color4 = '[=colors.secondary.text]',        -- secondary panel text
};

conky.text = [[
# this conky requires:
# - the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote
# - the transmission.bash script running in the background
# :::::::::::: torrents overview
<#assign border = 6,
         inputDir = "/tmp/conky",
         activeTorrentsFile = inputDir + "/transmission.active",
         max = 22>
# :::::::::::: active torrents
${if_existing [=activeTorrentsFile]}\
${if_match ${lines [=activeTorrentsFile]} > 0}\
${lua read_file [=activeTorrentsFile]}${lua calculate_voffset [=activeTorrentsFile] [=max]}\
# ------- light panel top edge    -------
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light-edge-top-left.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark.png 180 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png 221 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light-edge-top-right.png 292 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 299 0}\
${color}${lua_parse add_y_offset voffset 2}${lua_parse head [=activeTorrentsFile] [=max] [=border]}${lua increase_y_offset [=activeTorrentsFile]}
<@panel.panelsBottom x=0 y=0 widths=[width] gap=colGap isFixed=false/>
${else}\
<@panel.panel x=20 y=conkyHeight-23 height=23 width=257/>
${voffset [=5+(max-1)*16]}${alignc}${color1}transmission ${color}no active torrents running
${endif}\
${else}\
<@panel.panel x=0 y=conkyHeight-23 height=23 width=width color=image.secondaryColor/>
${voffset [=5+(max-1)*16]}${alignc}${color4}active torrents input file is missing
${endif}\
]];
