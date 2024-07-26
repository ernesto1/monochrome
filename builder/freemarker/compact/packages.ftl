<#import "/lib/panel-round.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 3,  -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- top|middle|bottom_left|right
  gap_x = 195,
  gap_y = 39,

  -- window settings
  <#assign width = 189>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  minimum_height = 38,
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
  
  -- images
  imlib_cache_flush_interval = 250,

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.panelText]',  -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.highlight]'          -- highlight important packages
};

conky.text = [[
# :::::::::::: package updates
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted">
${if_existing [=packagesFile]}\
<#assign y = 0, 
         header = 51, <#-- panel header -->
         body = 20,  <#-- panel window without the header -->
         gap = 3>     <#-- empty space between windows -->
<@panel.verticalTable x=0 y=y header=header body=width-header height=body/>
${voffset 2}${offset 5}${color1}dnf${goto 57}${color}${lines [=packagesFile]} package updates
<#assign y += body + gap>
<#assign header = 19, packageCol = 136, colGap = 1, versionCol = width - packageCol - colGap>
<@panel.table x=0 y=y header=header width=packageCol />
${lua configure_panel [=image.primaryColor] light [=packageCol] 3}\
<@panel.table x=packageCol + colGap y=y width=versionCol header=header />
<#assign y += header>
${lua increment_offsets 0 [=y]}\
# optional dnf branding, can be removed or won't matter if the image does not exist
${image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dnf.png -p [=packageCol-35-2],[=(y+2)?c]}\
${voffset 10}${offset 5}${color1}package${alignr 5}version${voffset 3}
<#if system == "desktop"><#assign maxLines = 37><#else><#assign maxLines = 15></#if>
${color}${lua_parse populate_panel_from_file [=packagesFile] [=maxLines]}${voffset 5}
${lua_parse draw_bottom_edges [=packageCol + colGap] [=versionCol]}\
${else}\
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-packages.png -p 0,0}\
<@panel.panel x=41 y=0 width=189-41 height=38/>
${voffset 4}${offset 48}${color1}dandified yum
${voffset 2}${offset 48}${color}no package updates
${endif}\
]];
