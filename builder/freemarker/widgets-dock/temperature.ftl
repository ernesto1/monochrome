conky.config = {
  lua_load = '~/conky/monochrome/common.lua',

  update_interval = 1,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',  -- top|middle|bottom_left|right
  gap_x = 0,               -- same as passing -x at command line
  <#if device == "desktop"><#assign yOffset = -305><#else><#assign yOffset = -225></#if><#lt>
  gap_y = [=yOffset],

  -- window settings | conky width matches the sidebar conky
  <#assign lso = 27,          <#-- horizontal offset to account for sidebar image's left shadow -->
           width = lso + 90>  <#-- width of the sidebar image -->
  <#if isVerbose><#assign width += 53></#if>
  minimum_width = [=width],
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
  font0 = 'URW Gothic:size=12',  -- medium
  font1 = 'URW Gothic:size=23',  -- big
  
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]',        -- bar critical
};

conky.text = [[
# :::::::: cpu
<#if device == "desktop" >
${voffset 45}${offset [=lso + 6]}${color2}${if_match ${lua get cpuTemp ${hwmon atk0110 temp 1}} > [=threshold.tempCPU]}${color3}${endif}${lua_bar 3,45 get cpuTemp}
<#if isVerbose>
${voffset -29}${goto [=lso + 72]}${color}${font1}${lua get cpuTemp}${font0}°C${font}${voffset 8}
<#else>
${font}${voffset 6}\
</#if>
# :::::::: ati video card
${voffset 45}${offset [=lso + 6]}${color2}${if_match ${lua get videoTemp ${hwmon radeon temp 1}} > [=threshold.tempVideo]}${color3}${endif}${lua_bar 3,45 get videoTemp}
<#if isVerbose>
${voffset -29}${goto [=lso + 72]}${color}${font1}${lua get videoTemp}${font0}°C${font}${voffset 8}
<#else>
${font}${voffset 6}\
</#if>
# :::::::: hard disks
${lua compute diskTemp ${lua get_max_resource_usage ${hwmon 0 temp 1} ${hwmon 1 temp 1} ${hwmon 2 temp 1}}}\
${voffset 45}${offset [=lso + 6]}${color2}${if_match ${lua get diskTemp} > [=threshold.tempDisk]}${color3}${endif}${lua_bar 3,45 get diskTemp}
<#if isVerbose>
${voffset -29}${goto [=lso + 72]}${color}${font1}${lua get diskTemp}${font0}°C${font}${voffset 8}
<#else>
${font}${voffset 6}\
</#if>
# :::::::: fans
${lua compute fanSpeed ${lua get_max_resource_usage ${hwmon atk0110 fan 3} ${hwmon atk0110 fan 1} ${hwmon atk0110 fan 2} ${hwmon atk0110 fan 4}}}\
${voffset 45}${offset [=lso + 6]}${color2}${if_match ${lua get fanSpeed} > [=threshold.fanSpeed?c]}${color3}${endif}${lua_bar 3,45 conky_get_usage_percentage 2600 fanSpeed}
<#if isVerbose>
${voffset -29}${goto [=lso + 72]}${color}${font1}${font}${lua get fanSpeed} rpm${voffset 8}
${voffset -150}\
</#if>
<#else>
# laptop only reports cpu core temperatures, displaying the hottest of the two cores
${lua compute cpuTemp ${lua get_max_resource_usage ${hwmon coretemp temp 2} ${hwmon coretemp temp 3}}}\
${voffset 45}${offset [=lso + 6]}${color2}${if_match ${lua get cpuTemp} > [=threshold.tempCPUCore]}${color3}${endif}${lua_bar 3,45 get cpuTemp}
<#if isVerbose>
${voffset -29}${goto [=lso + 72]}${color}${font1}${lua get cpuTemp}${font0}°C${font}${voffset 8}
${voffset -58}\
</#if>
</#if>
]];
