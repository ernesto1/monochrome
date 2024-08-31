conky.config = {
  lua_load = '~/conky/monochrome/common.lua',

  update_interval = 1,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',  -- top|middle|bottom_left|right
  gap_x = 27,               -- same as passing -x at command line
  <#if system == "desktop"><#assign yOffset = -341><#else><#assign yOffset = -230></#if>
  gap_y = [=yOffset],

  -- window settings
  <#if border!true><#assign borderWidth = 1><#else><#assign borderWidth = 0></#if>
  minimum_width = [=58 + borderWidth],      -- conky will add an extra pixel to this
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 1,         -- width of border window in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels
  
  -- transparency configuration
  own_window_transparent = true,
  own_window_argb_visual = true,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)
  
  -- font settings
  use_xft = true,
  xftalpha = 1,
  uppercase = true,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  
  font = 'URW Gothic:size=9',    -- default: small
  font0 = 'Promenade de la Croisette:size=40',
  font1 = 'Promenade de la Croisette:size=37',
  font2 = 'Noto Sans CJK JP Thin:size=11',
  font3 = 'URW Gothic:size=12',  -- medium
  
  -- colors
  default_color = '[=colors.widgetText]',  -- regular text
  color1 = '[=colors.widgetTextSmall]',
  color3 = '[=colors.warning]',
  
  -- device temperature: ${template8 (value|conky expression}}
  template1 = [[${voffset 8}${offset 12}${font0}${color}\1${voffset -28}${font3}°${offset 4}${voffset -4}${font0}C${font}${color}${voffset 8}]]
  
  -- :::: overview
  -- this conky uses the 'panel' window type in order to create a sidebar panel effect on the monitor
  -- when an application window is maximized, the widgets will still be visible
  --
  -- widgets that require centered text within the sidebar will be placed here
};

conky.text = [[
<#if system == "desktop" >
${template1 ${lua_parse\ print_resource_usage\ ${hwmon\ atk0110\ temp\ 1}\ [=threshold.tempCPU]\ ${color3}}}
${template1 ${lua_parse\ print_resource_usage\ ${hwmon\ radeon\ temp\ 1}\ [=threshold.tempVideo]\ ${color3}}}
<#assign disksTemp = "">
<#list hardDisks[system] as hardDisk>
<#if hardDisk.hwmonIndex??><#assign disksTemp += "${hwmon\\ " + hardDisk.hwmonIndex + "\\ temp\\ 1}\\ "></#if>
</#list>
${template1 ${lua_parse\ print_max_resource_usage\ [=threshold.tempDisk]\ ${color3}\ [=disksTemp?remove_ending("\\ ")]}}
${voffset 8}${offset 7}${font0}${color}${lua_parse print_resource_usage ${hwmon atk0110 fan 1} [=(threshold.fanSpeed)?c] ${color3}}${font}${color}${voffset 8}
${alignc}${font0}${color}${time %I}${font1}:${time %M}
${voffset -29}${alignc}${color1}${font2}${time %a}
</#if>
]];
