<#import "/lib/menu-round.ftl" as menu>
<#import "lib/network.ftl" as net>
conky.config = {  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',  -- top|middle|bottom_left|right
  gap_x = 142,
  gap_y = 467,

  -- window settings
  <#assign width = 169>
  minimum_width = [=width],      -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = 414,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)
  own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',

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
  top_name_verbose = true,          -- show full command in ${top ...}
  top_name_width = 18,              -- how many characters to print
  text_buffer_size = 2048,
  if_up_strictness = 'address',     -- network device must be up, having link and an assigned IP address
                                    -- to be considered "up" by ${if_up}
                                    -- values are: up, link or address
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.menuText]',  -- regular text
  color1 = '[=colors.labels]',
  color3 = '[=colors.secondary.labels]',         -- secondary menu labels
  color4 = '[=colors.secondary.text]',         -- secondary menu text
  
  -- templates
  -- top cpu process: ${template0 processNumber}
  template0 = [[${voffset 3}${offset 5}${color}${top name \1}${alignr 4}${top cpu \1}%]],
  -- top mem process: ${template1 processNumber}
  template1 = [[${voffset 3}${offset 5}${color}${top_mem name \1}${alignr 4}${top_mem mem_res \1}]]
};

conky.text = [[
# :::::::::::: cpu
<#assign y = 0,
         titleHeight = 19,
         gap = 2,
         sectionGap = 3>   <#-- empty space between panels -->
<@menu.panel x=0 y=y width=width height=titleHeight color=image.secondaryColor/>
${voffset 2}${alignc}${color3}cpu${voffset [=6+gap]}
<#assign y += titleHeight + gap, body = 84>
<@menu.table x=0 y=y width=width header=titleHeight body=body/>
${offset 5}${color1}process${alignr 4}cpu${voffset 3}
<#list 1..5 as x>
${template0 [=x]}
</#list>
<#assign y += titleHeight + body + gap, header = 71, body = 19>
<@menu.verticalTable x=0 y=y header=header body=width-header height=body/>
${voffset [= 7 + gap]}${offset 5}${color1}load avg${goto 77}${color}${loadavg}${voffset [=6+sectionGap]}
<#assign y += body + sectionGap>
# :::::::::::: memory
<@menu.panel x=0 y=y width=width height=titleHeight color=image.secondaryColor/>
${alignc}${color3}memory${voffset [=6+gap]}
<#assign y += titleHeight + gap, body = 84>
<@menu.table x=0 y=y width=width header=titleHeight body=body/>
${offset 5}${color1}process${alignr 4}memory${voffset 3}
<#list 1..5 as x>
${template1 [=x]}
</#list>
<#assign y += titleHeight + body + gap,
         header = 71,
         body = 38,
         inputDir = "/tmp/conky",
         swapRead = inputDir + "/system.swap.read",
         swapWrite = inputDir + "/system.swap.write">
<@menu.verticalTable x=0 y=y header=header body=width-header height=body/>
${voffset [= 7 + gap + 2]}${offset 5}${color1}swap read${goto 77}${color}${cat [=swapRead]}
${voffset 3}${offset 5}${color1}swap write${goto 77}${color}${cat [=swapWrite]}${voffset [=7+sectionGap]}
<#assign y += body + sectionGap>
# :::::::::::: network
<@menu.panel x=0 y=y width=width height=titleHeight color=image.secondaryColor/>
${alignc}${color3}network${voffset [=8+gap]}
<#assign y += titleHeight + gap>
# assumption: only one network device will be connected to the internet at a time
<@net.networkDetails devices=networkDevices[system] y=y width=width gap=sectionGap/>
<#assign y += 71 + sectionGap>
]];
