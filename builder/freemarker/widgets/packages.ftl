<#import "/lib/panel-round.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 4,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_right',
  gap_x = 5,
  gap_y = 53,

  -- window settings
  <#assign width = 200>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  own_window = true,
  own_window_type = 'desktop',              -- values: desktop (background), panel (bar)
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
  draw_graph_borders = false, -- borders around the graph, ex. cpu graph, network down speed graph
                              -- does not include bars, ie. wifi strength bar, cpu bar

  imlib_cache_flush_interval = 250,

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  
  -- colors
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]',        -- text labels
  color2 = '[=colors.bar]'         -- bar
};

conky.text = [[
# :::::::::::: package updates
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted">
${if_existing [=packagesFile]}\
<#assign y = 0, 
         header = 39>    <#-- panel header -->
<@panel.table x=0 y=y width=width header=header/>
<#assign y += header + 13><#-- head() function requires the file text to be at 10 px below its panel edge, so adding the remaining px due to package/version header -->
${lua increment_offsets 0 [=y]}\
# optional dnf branding, can be removed or won't matter if the image does not exist
${image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dnf.png -p 121,[=(y+4)?c]}\
${voffset 3}${alignc}${color1}dnf package management
${voffset 5}${alignc}${color}${lines [=packagesFile]} package update(s) available
${voffset 6}${offset 5}${color1}package${alignr 4}version${voffset 1}
<#assign maxLines = 25>
${color}${lua_parse head [=packagesFile] [=maxLines]}${lua increase_y_offset [=packagesFile]}${voffset 5}
<@panel.panelBottomCorners x=0 y=0 width=width isFixed=false/>
${endif}\
]];
