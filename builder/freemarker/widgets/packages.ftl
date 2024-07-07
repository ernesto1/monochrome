<#import "/lib/panel-round.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_right',
  gap_x = 3,
  gap_y = 35,

  -- window settings
  <#assign width = 188>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  minimum_height = 387,
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
         iconHeight = 38,
         gap = 3>
${image ~/conky/monochrome/images/common/[=image.primaryColor]-packages.png -p 0,0}\
<@panel.noLeftEdgePanel x=iconHeight y=0 width=width-iconHeight height=iconHeight isDark=true/>
${voffset 5}${offset 45}${color1}dandified yum
${voffset 2}${offset 45}${color}${lines [=packagesFile]} package updates${voffset [= 7 + gap]}
<#assign y += iconHeight + gap, header = 19>
<@panel.table x=0 y=y header=header width=width/>
<#assign y += header>
${lua increment_offsets 0 [=y]}\
${offset 5}${color1}package${alignr 4}version${voffset [=3+gap]}
${image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dnf.png -p 118,[=(y+4)?c]}\
<#assign maxLines = 20>
${color}${lua_parse paginate [=packagesFile] [=maxLines]}${lua increase_y_offset [=packagesFile]}${voffset 5}
<@panel.panelBottomCorners x=0 y=0 width=width isFixed=false/>
${else}\
${image ~/conky/monochrome/images/common/[=image.primaryColor]-packages.png -p 17,0}\
<@panel.noLeftEdgePanel x=iconHeight+17 y=0 width=width-iconHeight-17 height=iconHeight/>
${voffset 5}${offset [=45+17]}${color1}package updates
${voffset 2}${offset [=45+17]}${color}no updates available${voffset 5}
${endif}\
]];
