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
  <#if system == "desktop"><#assign width = 1135><#else><#assign width = 824></#if>
  minimum_width = [=width?c],      -- conky will add an extra pixel to this
  maximum_width = [=width?c],
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
<#assign charWidth = 6, x = charWidth>
${voffset 5}${goto [=x?c]}${color1}load ${color}${loadavg}\
<#-- x notation = num char label * c + single space (c) + num char value * c + single space (c) -->
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
<#if system == "desktop">
<#assign x += 2 * charWidth + charWidth + 2 * charWidth + charWidth>
${goto [=x?c]}${color1}used ${color}${mem}\
<#assign x += 4 * charWidth + charWidth + 7 * charWidth + charWidth>
${goto [=x?c]}${color1}free ${color}${memfree}\
<#assign x += 4 * charWidth + charWidth + 7 * charWidth + charWidth>
${goto [=x?c]}${color1}buff ${color}${buffers}\
<#assign x += 4 * charWidth + charWidth + 7 * charWidth + charWidth>
${goto [=x?c]}${color1}cache ${color}${cached}\
<#assign x += 5 * charWidth + charWidth + 7 * charWidth + charWidth>
${goto [=x?c]}${color1}swap ${color}${swap}\
<#assign x += 4 * charWidth + charWidth + 7 * charWidth + charWidth>
<#else>
<#assign x += 2 * charWidth + charWidth + 2 * charWidth + charWidth>
</#if>
<#assign file = inputDir + "/system.swap.read">
${goto [=x?c]}${color1}si ${color}${cat [=file]}\
<#assign x += 2 * charWidth + charWidth + 8 * charWidth + charWidth,
         file = inputDir + "/system.swap.write">
${goto [=x?c]}${color1}so ${color}${cat [=file]}\
<#assign x += 2 * charWidth + charWidth + 8 * charWidth + charWidth,
         device = hardDisks?first>
${goto [=x?c]}${color1}read ${color}${diskio_read /dev/[=device.device]}\
<#assign x += 4 * charWidth + charWidth + 7 * charWidth + charWidth>
${goto [=x?c]}${color1}write ${color}${diskio_write /dev/[=device.device]}\
<#assign x += 5 * charWidth + charWidth + 7 * charWidth + charWidth,
         device = networkDevices?first>
${goto [=x?c]}${color1}up ${color}${upspeed [=device.name]}\
<#assign x += 2 * charWidth + charWidth + 7 * charWidth + charWidth>
${goto [=x?c]}${color1}down ${color}${downspeed [=device.name]}\
<#if system == "laptop">
<#assign x += 4 * charWidth + charWidth + 7 * charWidth + charWidth,
         packagesFile = inputDir + "/dnf.packages.formatted">
${goto [=x?c]}${color1}dnf ${color}${if_existing [=packagesFile]}${lines [=packagesFile]}${else}no${endif} updates\
</#if>
]];
