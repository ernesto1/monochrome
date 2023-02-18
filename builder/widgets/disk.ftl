<#assign width = 202,         <#-- disk image width + gap between conkys -->
         space = 14,          <#-- horizontal space in between disk conkys -->
         x = 1293 - width >   <#-- x is the x coordinate of the first disk conky -->
<#list hardDisks[system] as hardDisk>
<#assign diskName = hardDisk.name!hardDisk.device>
<@outputFileDirective file="disk-" + diskName>
conky.config = {
  update_interval = 2,  -- update interval in seconds
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  <#assign x += width + space>
  gap_x = [=x?c],               -- same as passing -x at command line
  gap_y = 3,

  -- window settings
  minimum_width = 202,
  minimum_height = 133,
  own_window = true,
  own_window_type = 'desktop',    -- values: desktop (background), panel (bar)
  own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',

  -- transparency configuration
  draw_blended = false,
  own_window_transparent = true,
  own_window_argb_visual = true,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 1,         -- width of border window in pixels
  stippled_borders = 1,     -- border stippling (dashing) in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels

  -- graph settings
  draw_graph_borders = false, -- borders around the graph, ex. cpu graph, network down speed grah
                              -- does not include bars, ie. wifi strength bar, cpu bar
  imlib_cache_flush_interval = 250,
                                
  -- font settings
  draw_shades = false,    -- black shadow on text (not good if text is black)
  
  -- colors
  default_color = '[=colors.text]', -- regular text
  color1 = '[=colors.labels]',        -- text labels
  color2 = '[=colors.bar]',        -- bar
  color3 = '[=colors.warning]',        -- bar critical
  color4  ='[=colors.offlineText]',        -- text for disconnected device
  
  -- :::::::::::::::::::::::::::::::: templates ::::::::::::::::::::::::::::::::
  -- disk partition: ${template1 partition name}
  template1 = [[${voffset 4}${goto 97}${color}\2${alignr 4}${fs_type \1}
${voffset 4}${goto 97}${color}${fs_used \1} /${alignr 4}${color}${fs_size \1}
${voffset 1}${goto 97}${color2}${if_match ${fs_used_perc \1} > 90}${color3}${endif}${fs_bar 3, 100 \1}]],
  
  -- hwmon entry: index/device type index threshold
  template2 = [[${if_match ${hwmon \1 \2 \3} > \4}${color3}${else}${color}${endif}${hwmon \1 \2 \3}]]
};

conky.text = [[
${if_existing /dev/[=hardDisk.device]}\
# disk io
<#if hardDisk.partitions?size gt 1 >
${image ~/conky/monochrome/images/widgets/[=image.primaryColor]-disk.png -p 0,0}\
<#else>
${image ~/conky/monochrome/images/widgets/[=image.primaryColor]-disk-single-partition.png -p 0,0}\
</#if>
${voffset -1}${offset 18}${diskiograph_read [=hardDisk.device] 37,67 [=colors.readGraph] [=hardDisk.readSpeed?c]}
${voffset -7}${offset 18}${diskiograph_write [=hardDisk.device] 37,67 [=colors.writeGraph] [=hardDisk.writeSpeed?c]}
${voffset 6}${offset 5}${color1}read${alignr 120}${color}${diskio_read [=hardDisk.device]}
${voffset 4}${offset 5}${color1}write${alignr 120}${color}${diskio_write [=hardDisk.device]}
${voffset -13}${goto 97}${color1}temp${offset 7}${color}<#if hardDisk.hwmonIndex??>${template2 [=hardDisk.hwmonIndex] temp 1 [=threshold.tempDisk]}°C<#else>n/a</#if>
# partitions
${voffset -125}${goto 97}${color1}[=hardDisk.device] partitions
<#list hardDisk.partitions as partition>
${template1 [=partition.path] [=partition.name]}
</#list>
${else}\
${image ~/conky/monochrome/images/widgets/[=image.secondaryColor]-disk-disconnected.png -p 0,0}\
${voffset 113}${alignr 125}${color4}[=hardDisk.device]
${endif}\
]];
</@outputFileDirective>
</#list>
