<#import "/lib/menu-round.ftl" as menu>
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
  gap_x = 5,
  gap_y = [=32+5],

  -- window settings
  <#assign width = 169>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  minimum_height = <#if system == "desktop">1016<#else>400</#if>,
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
  default_color = '[=colors.menuText]', -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.highlight]',        -- highlight important packages
  color3 = '[=colors.secondary.labels]',         -- secondary menu labels
  color4 = '[=colors.secondary.text]'         -- secondary menu text
};

conky.text = [[
<#if system == "desktop"><#assign packageLines = 25><#else><#assign packageLines = 20></#if>
<#assign totalLines = packageLines * 2>
${lua set_total_lines [=totalLines]}\
# :::::::::::: package updates
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted",
         iconWidth = 38,       <#-- icon is a square -->
         iconheight = 38,
         titleHeight = 19,
         y = 0,
         gap = 3,               <#-- empty space across panels of the same application -->
         sectionGap = 8>        <#-- empty space between application panels -->
${if_existing [=packagesFile]}\
${image ~/conky/monochrome/images/widgets-dock/[=image.secondaryColor]-packages-small.png -p 0,0}\
<@menu.noLeftEdgePanel x=0+iconWidth y=y width=width-iconWidth height=iconheight color=image.secondaryColor/>
${voffset 5}${offset 45}${color3}dandified yum
${voffset 2}${offset 45}${color4}${lines [=packagesFile]} package updates${voffset [= 7 + gap]}
<#assign y += iconheight + gap>
<@menu.table x=0 y=y width=width header=titleHeight/>
<#assign y += titleHeight>
${lua increment_offsets 0 [=y]}\
# optional dnf branding, can be removed or won't matter if the image does not exist
${image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-dnf.png -p 111,[=y+2]}\
${offset 5}${color1}package${alignr 4}version${voffset [=3+gap]}
${color}${lua_parse paginate [=packagesFile] [=packageLines]}${lua increase_y_offset [=packagesFile]}${voffset [=5 + sectionGap]}
<@menu.panelBottomCorners x=0 y=0 width=width isFixed=false/>
${lua increment_offsets 0 [=sectionGap]}\
${else}\
# ::: no updates available or dnf script not running
${image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-packages-small.png -p 0,0}\
<@menu.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight/>
${voffset 5}${offset 45}${color1}dandified yum
${voffset 2}${offset 45}${color}no package updates${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${endif}\
<#if system == "desktop">
# :::::::::::: transmission bittorrent client
<#assign inputDir = "/tmp/conky"
         peersFile = inputDir + "/transmission.peers",
         seedingFile = inputDir + "/transmission.seeding"
         downloadingFile = inputDir + "/transmission.downloading",
         idleFile = inputDir + "/transmission.idle",
         activeTorrentsFile = inputDir + "/transmission.active">
${if_existing [=activeTorrentsFile]}\
# ::: no active torrents
${if_match ${lua get activeNum ${lines [=activeTorrentsFile]}} == 0}\
${lua_parse draw_image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-torrents-small.png 0 0}\
<@menu.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight isFixed=false/>
${voffset 5}${offset 45}${color1}transmission
${voffset 2}${offset 45}${color}no active torrents${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${else}\
# ::: active torrents
${lua_parse draw_image ~/conky/monochrome/images/widgets-dock/[=image.secondaryColor]-torrents-small.png 0 0}\
<@menu.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight color=image.secondaryColor isFixed=false/>
${voffset 5}${offset 45}${color3}transmission
${voffset 2}${offset 45}${color4}${lua get activeNum} active torrents${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconheight + gap]}\
<#assign header = 75, <#-- menu header -->
         body = 71>   <#-- menu window without the header -->
<@menu.verticalTable x=0 y=0 header=header body=width-header height=body isFixed=false/>
${voffset 3}${offset 5}${color1}seeding${goto 81}${color}${if_existing [=seedingFile]}${lua pad ${lines [=seedingFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}downloading${goto 81}${color}${if_existing [=downloadingFile]}${lua pad ${lines [=downloadingFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}idle${goto 81}${color}${if_existing [=idleFile]}${lua pad ${lines [=idleFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}swarm${goto 81}${color}${if_existing [=peersFile]}${lua pad ${lua get peers ${lines [=peersFile]}}} peers${else}file missing${endif}${voffset [= 7 + gap]}
${lua increment_offsets 0 [=body + gap]}\
<@menu.table x=0 y=0 width=width header=titleHeight isFixed=false/>
${lua increment_offsets 0 [=titleHeight]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-peers.png [=((width-112)/2)?round] 22}\
${alignc}${color1}active torrents${voffset [=3+gap]}
${color}${lua_parse head [=activeTorrentsFile] [=totalLines]}${lua increase_y_offset [=activeTorrentsFile]}
<@menu.panelBottomCorners x=0 y=0 width=width isFixed=false/>
${lua increment_offsets 0 [=gap]}\
${endif}\
${else}\
# ::: error state
${lua_parse draw_image ~/conky/monochrome/images/widgets-dock/[=image.primaryColor]-torrents-small.png 0 0}\
<@menu.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight color=image.secondaryColor isFixed=false isDark=true/>
${voffset 5}${offset 45}${color3}transmission
${voffset 2}${offset 45}${color4}input files missing${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${endif}\
</#if>
]]
