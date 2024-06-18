<#import "/lib/panel-round.ftl" as panel>
--[[
this conky requires the following supporting scripts running in the background:

 - dnfPackageLookup.bash
 - transmission.bash
   requires the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote

output files from these supporting scrips are read from /tmp/conky
]]

conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_right',  -- top|middle|bottom_left|right
  gap_x = 3,
  <#if system == "desktop"><#assign yOffset = 130><#else><#assign yOffset = 25></#if>
  gap_y = [=32+3+yOffset],

  -- window settings
  <#assign width = 169>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  minimum_height = <#if system == "desktop">1016<#else>340</#if>,
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
  
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.panelText]', -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.highlight]',        -- highlight important packages
  color3 = '[=colors.secondary.labels]',         -- secondary panel labels
  color4 = '[=colors.secondary.text]'         -- secondary panel text
};

conky.text = [[
<#if system == "desktop"><#assign packageLines = 22><#else><#assign packageLines = 18></#if>
<#assign totalLines = packageLines * 2>
${lua set_total_lines [=totalLines]}\
# :::::::::::: package updates
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted",
         iconWidth = 38,       <#-- icon is a square -->
         iconheight = 38,
         titleHeight = 19,
         y = 0,
         gap = 3,               <#-- empty space across panels of the same application -->
         sectionGap = 4>        <#-- empty space between application panels -->
${if_existing [=packagesFile]}\
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-packages-small.png -p 0,0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=y width=width-iconWidth height=iconheight color=image.secondaryColor/>
${voffset 5}${offset 45}${color3}dandified yum
${voffset 2}${offset 45}${color4}${lines [=packagesFile]} package updates${voffset [= 7 + gap]}
<#assign y += iconheight + gap>
<@panel.table x=0 y=y width=width header=titleHeight/>
<#assign y += titleHeight>
${lua increment_offsets 0 [=y]}\
# optional dnf branding, can be removed or won't matter if the image does not exist
${image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dnf.png -p 95,[=y+2]}\
${offset 5}${color1}package${alignr 4}version${voffset [=3+gap]}
${color}${lua_parse paginate [=packagesFile] [=packageLines]}${lua increase_y_offset [=packagesFile]}${voffset [=5 + sectionGap]}
<@panel.panelBottomCorners x=0 y=0 width=width isFixed=false/>
${lua increment_offsets 0 [=sectionGap]}\
${else}\
# ::: no updates available or dnf script not running
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-packages-small.png -p 0,0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight/>
${voffset 5}${offset 45}${color1}dandified yum
${voffset 2}${offset 45}${color}no package updates${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${endif}\
# :::::::::::: transmission bittorrent client
<#assign inputDir = "/tmp/conky/"
         peersFile = inputDir + "transmission.peers.raw",
         uploadFile = inputDir + "transmission.speed.up"
         downloadFile = inputDir + "transmission.speed.down",
         torrentsFile = inputDir + "transmission.torrents",
         torrentsUpFile = inputDir + "transmission.torrents.up",
         torrentsDownFile = inputDir + "transmission.torrents.down">
${if_existing [=torrentsFile]}\
# ::: no active torrents
${if_match ${lua get activeNum ${lines [=torrentsFile]}} == 0}\
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-torrents-small.png 0 0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight isFixed=false/>
${voffset 5}${offset 45}${color1}transmission
${voffset 2}${offset 45}${color}no active torrents${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${else}\
# ::: active torrents
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-torrents-small.png 0 0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight color=image.secondaryColor isFixed=false/>
${voffset 5}${offset 45}${color3}transmission
${voffset 2}${offset 45}${color4}${lua get activeNum} active torrents${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconheight + gap]}\
<#assign header = 59,   <#-- section for the labels -->
         height = 55>
<@panel.verticalTable x=0 y=0 header=header body=width-header height=height isFixed=false/>
${voffset 3}${offset 5}${color1}swarm${goto 67}${color}${if_existing [=peersFile]}${lua pad ${lines [=peersFile]} 6} peers${else}file missing${endif}
${voffset 3}${offset 5}${color1}upload${color}${if_existing [=uploadFile]}${alignr 43}${cat [=uploadFile]}${else}file missing${endif}
${voffset 3}${offset 5}${color1}download${color}${if_existing [=downloadFile]}${alignr 43}${cat [=downloadFile]}${else}file missing${endif}${voffset [= 7 + gap]}
${lua increment_offsets 0 [=height + gap]}\
# ::: torrent uploads
${if_match ${lines [=torrentsUpFile]} > 0}\
# -------  table | [=image.primaryColor] 2 columns | top edge    -------
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark-edge-top-left.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-panel-dark.png 139 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-panel-dark-edge-top-right.png 162 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png 0 19}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-panel-light.png 139 19}\
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 169 0}\
${lua increment_offsets 0 [=titleHeight]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-peers.png [=((width-139)/2)?round] 22}\
${offset 5}${color1}torrent${alignr 4}up${voffset [=3+gap]}
${color}${lua_parse head [=torrentsUpFile] [=totalLines]}${voffset [= 7 + gap]}${lua increase_y_offset [=torrentsUpFile]}
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light-edge-bottom-left.png 0 -7}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-panel-light-edge-bottom-right.png 162 -7}\
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 0 0}\
# -------  table | [=image.primaryColor] 2 columns | bottom edge -------
${lua increment_offsets 0 [=gap]}\
${endif}\
# ::: torrent downloads
${if_match ${lines [=torrentsDownFile]} > 0}\
# -------  table | [=image.primaryColor] 2 columns | top edge    -------
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark-edge-top-left.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark-edge-top-right.png 162 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png 0 19}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark.png 139 19}\
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 169 0}\
${lua increment_offsets 0 [=titleHeight]}\
${offset 5}${color1}torrent${alignr 4}down${voffset [=3+gap]}
${color}${lua_parse head [=torrentsDownFile] [=totalLines]}${lua increase_y_offset [=torrentsDownFile]}
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light-edge-bottom-left.png 0 -7}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark-edge-bottom-right.png 162 -7}\
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 0 0}\
# -------  table | [=image.primaryColor] 2 columns | bottom edge -------
${lua increment_offsets 0 [=sectionGap]}\
${endif}\
${endif}\
${else}\
# ::: error state
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-torrents-small.png 0 0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight color=image.secondaryColor isFixed=false isDark=true/>
${voffset 5}${offset 45}${color3}transmission
${voffset 2}${offset 45}${color4}input files missing${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${endif}\
]]
