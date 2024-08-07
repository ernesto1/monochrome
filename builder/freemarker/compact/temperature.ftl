conky.config = {
  lua_load = '~/conky/monochrome/common.lua',

  update_interval = 2,  -- update interval in seconds
  total_run_times = 0,  -- this is the number of times conky will update before quitting, set to zero to run forever
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',      -- top|middle|bottom_left|middle|right
  gap_x = 15,                     -- same as passing -x at command line
  gap_y = -532,

  -- window settings
  minimum_width = 189,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)

  -- transparency configuration
  draw_blended = false,
  own_window_transparent = true,
  own_window_argb_visual = true,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 0,         -- width of border window in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels

  -- graph settings
  draw_graph_borders = false, -- borders around the graph, ex. cpu graph, network down speed grah
                              -- does not include bars, ie. wifi strength bar, cpu bar

  imlib_cache_flush_interval = 250,
  -- use the parameter -n on ${image ..} to never cache and always update the image upon a change
  
  if_up_strictness = 'address', -- network device must be up, having link and an assigned IP address
                                -- to be considered "up" by ${if_up}
                                -- values are: up, link or address

  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  draw_outline = false,   -- black outline around text (not good if text is black)
  
  -- colors
  default_color = '[=colors.text]',  -- regular text
  color1 = '[=colors.labels]',         -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]'         -- bar critical
};

conky.text = [[
<#assign iborder = 6> <#-- inner horizontal border -->
${offset [=iborder]}${color1}device${alignr [=iborder]}temperature
${voffset 8}${offset [=iborder]}${color}cpu${alignr}${lua_parse print_resource_usage ${hwmon atk0110 temp 1} [=threshold.tempCPU] ${color3}}°C
${voffset 4}${offset [=iborder]}${color}cpu core 1${alignr}${lua_parse print_resource_usage ${hwmon coretemp temp 2} [=threshold.tempCPUCore] ${color3}}°C
${voffset 3}${offset [=iborder]}${color}cpu core 2${alignr}${lua_parse print_resource_usage ${hwmon coretemp temp 3} [=threshold.tempCPUCore] ${color3}}°C
${voffset 3}${offset [=iborder]}${color}cpu core 3${alignr}${lua_parse print_resource_usage ${hwmon coretemp temp 4} [=threshold.tempCPUCore] ${color3}}°C
${voffset 3}${offset [=iborder]}${color}cpu core 4${alignr}${lua_parse print_resource_usage ${hwmon coretemp temp 5} [=threshold.tempCPUCore] ${color3}}°C
${voffset 3}${offset [=iborder]}${color}AMD Radeon HD7570${alignr}${lua_parse print_resource_usage ${hwmon radeon temp 1} [=threshold.tempVideo] ${color3}}°C
<#list hardDisks[system] as disk>
<#if disk.hwmonIndex??>
${voffset 3}${offset [=iborder]}${color}[=disk.name]${alignr}${lua_parse print_resource_usage ${hwmon [=disk.hwmonIndex] temp 1} [=threshold.tempDisk] ${color3}}°C
</#if>
</#list>
${voffset 8}${offset [=iborder]}${color1}fan${alignr [=iborder]}revolutions
${voffset 8}${offset [=iborder]}${color}chasis front intake${alignr [=iborder]}${lua_parse print_resource_usage ${hwmon atk0110 fan 3} [=(threshold.fanSpeed)?c] ${color3}} rpm
${voffset 3}${offset [=iborder]}${color}cpu fan${alignr [=iborder]}${lua_parse print_resource_usage ${hwmon atk0110 fan 1} [=(threshold.fanSpeed)?c] ${color3}} rpm
${voffset 3}${offset [=iborder]}${color}chasis top exhaust${alignr [=iborder]}${lua_parse print_resource_usage ${hwmon atk0110 fan 2} [=(threshold.fanSpeed)?c] ${color3}} rpm
${voffset 3}${offset [=iborder]}${color}chasis back exhaust${alignr [=iborder]}${lua_parse print_resource_usage ${hwmon atk0110 fan 4} [=(threshold.fanSpeed)?c] ${color3}} rpm
]]
