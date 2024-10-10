<#import "/lib/panel-round.ftl" as panel>
conky.config = {  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_middle',  -- top|middle|bottom_left|right
  gap_x = 0,
  gap_y = 5,

  -- window settings
  <#assign width = 518>
  minimum_width = [=width],      -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = 23,
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
  own_window_argb_value = 255,      -- range from 0 (transparent) to 255 (opaque)
  
  -- miscellanous settings
  imlib_cache_flush_interval = 250,
  
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.panelText]',  -- regular text
  color1 = '[=colors.labels]'
};

conky.text = [[
<@panel.panel x=0 y=0 width=width height=23/>
<#-- char width is 6px, use single space for borders -->
<#assign x = 5, charWidth = 6>
${voffset 5}${goto [=x?c]}${color1}load ${color}${loadavg}\
<#assign x += 4 * charWidth + charWidth + 16 * charWidth + charWidth,
         inputDir = "/tmp/conky",
         file = inputDir + "/system.cpu.us">
${goto [=x?c]}${color1}us ${color}${cat [=file]}\
<#assign x += 2 * charWidth + charWidth + 2 * charWidth + charWidth,
         file = inputDir + "/system.cpu.sy">
${goto [=x?c]}${color1}sy ${color}${cat [=file]}\
<#assign x += 2 * charWidth + charWidth + 2 * charWidth + charWidth,
         file = inputDir + "/system.cpu.id">
${goto [=x?c]}${color1}id ${color}${cat [=file]}\
<#assign x += 2 * charWidth + charWidth + 2 * charWidth + charWidth,
         file = inputDir + "/system.cpu.wa">
${goto [=x?c]}${color1}wa ${color}${cat [=file]}\
<#assign x += 2 * charWidth + charWidth + 2 * charWidth + charWidth,
         file = inputDir + "/system.swap.read">
${goto [=x?c]}${color1}si ${color}${cat [=file]}\
<#assign x += 2 * charWidth + charWidth + 8 * charWidth + charWidth,
         file = inputDir + "/system.swap.write">
${goto [=x?c]}${color1}so ${color}${cat [=file]}\
<#assign x += 2 * charWidth + charWidth + 8 * charWidth + charWidth,
         packagesFile = inputDir + "/dnf.packages.formatted">
${goto [=x?c]}${color1}dnf ${color}${if_existing [=packagesFile]}${lines [=packagesFile]}${else}0${endif} updates\
]];
