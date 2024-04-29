<#import "/lib/menu-square.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua ~/conky/monochrome/musicPlayer.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_right',  -- top|middle|bottom_left|right
  gap_x = 3,
  gap_y = 158,

  -- window settings
  <#assign width = 159>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  minimum_height = 1016,
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
  default_color = '[=colors.systemText]', -- regular text
  color1 = '[=colors.systemLabels]',
  color2 = '[=colors.highlight]',        -- highlight important packages
  color3 = '[=colors.secondary.labels]',         -- secondary menu labels
  color4 = '[=colors.secondary.text]'         -- secondary menu text
};

conky.text = [[
<#assign packageLines = 25>
<#assign totalLines = packageLines * 2>
${lua set_total_lines [=totalLines]}\
#
# :::::::::::::::: package updates ::::::::::::::::
#
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted",
         iconWidth = 38,       <#-- icon is a square -->
         iconheight = 38,
         titleHeight = 19,
         y = 0,
         colGap = 1,
         gap = 3,               <#-- empty space across panels of the same application -->
         sectionGap = 4>        <#-- empty space between application panels -->
# ::: updates vailable
${if_existing [=packagesFile]}\
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-packages.png -p 0,0}\
<@menu.panel x=iconWidth+gap y=y width=width-iconWidth-gap height=iconheight color=image.secondaryColor/>
${voffset 5}${offset 48}${color3}dandified yum
${voffset 2}${offset 48}${color4}${lines [=packagesFile]} package updates${voffset [= 7 + gap]}
<#assign y += iconheight + gap>
<#assign header = 19, versionCol = 51>
<@menu.table x=0 y=y widths=[width-versionCol-colGap, versionCol] gap=colGap header=header/>
<#assign y += titleHeight>
${lua increment_offsets 0 [=y]}\
${offset 5}${color1}package${alignr 4}version${voffset [=3+gap]}
${color}${lua_parse paginate [=packagesFile] [=packageLines]}${lua increase_y_offset [=packagesFile]}${voffset [=5 + sectionGap]}
${lua_parse draw_image ~/conky/monochrome/images/common/menu-blank.png 0 0}\
# ------- table | 2 column(s) | bottom -------
${lua increment_offsets 0 [=sectionGap]}\
${else}\
# ::: no updates available or dnf script not running
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-packages.png -p 0,0}\
<@menu.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconheight/>
${voffset 5}${offset 48}${color1}dandified yum
${voffset 2}${offset 48}${color}no package updates${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${endif}\
#
# :::::::::::::::: torrents ::::::::::::::::
#
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
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-torrents.png 0 0}\
<@menu.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconheight isFixed=false/>
${voffset 5}${offset 48}${color1}transmission
${voffset 2}${offset 48}${color}no active torrents${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${else}\
# ::: active torrents
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-torrents.png 0 0}\
<@menu.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconheight color=image.secondaryColor isFixed=false/>
${voffset 5}${offset 48}${color3}transmission
${voffset 2}${offset 48}${color4}${lua get activeNum} active torrents${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconheight + gap]}\
<#assign header = 59,   <#-- section for the labels -->
         height = 55>
<@menu.verticalTable x=0 y=0 header=header body=width-header height=height isFixed=false/>
${voffset 3}${offset 5}${color1}swarm${alignr 21}${color}${if_existing [=peersFile]}${lines [=peersFile]} peers${else}file missing${endif}
${voffset 3}${offset 5}${color1}upload${color}${if_existing [=uploadFile]}${alignr 33}${cat [=uploadFile]}${else}file missing${endif}
${voffset 3}${offset 5}${color1}download${color}${if_existing [=downloadFile]}${alignr 33}${cat [=downloadFile]}${else}file missing${endif}${voffset [= 7 + gap]}
${lua increment_offsets 0 [=height + gap]}\
# ::: torrent uploads
# the torrent uploads table is composed of 2 columns: torrent name | upload
${if_match ${lines [=torrentsUpFile]} > 0}\
<#assign speedColWidth = 39,                          <#-- width of upload/download columns -->
         menuWidth = width - speedColWidth - colGap>
<@menu.table x=0 y=0 widths=[menuWidth, speedColWidth] header=titleHeight gap=colGap isFixed=false highlight=[2]/>
${lua increment_offsets 0 [=titleHeight]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-peers.png [=((width-139)/2)?round] 22}\
${offset 5}${color1}torrent${alignr 4}${color3}up${voffset [=3+gap]}
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-peers.png [=speedColWidth + colGap + 17] 22}\
${lua_parse head [=torrentsUpFile] [=totalLines-5]}${lua increase_y_offset [=torrentsUpFile]}${voffset [= 7 + gap]}
${lua_parse draw_image ~/conky/monochrome/images/common/menu-blank.png 0 0}\
# ------- table | 2 column(s) | bottom    -------
${lua increment_offsets 0 [=gap]}\
${endif}\
# ::: torrent downloads
${if_match ${lines [=torrentsDownFile]} > 0}\
<@menu.table x=0 y=0 widths=[menuWidth, speedColWidth] header=titleHeight gap=colGap isFixed=false/>
${lua increment_offsets 0 [=titleHeight]}\
${offset 5}${color1}torrent${alignr 4}down${voffset [=3+gap]}
${color}${lua_parse head [=torrentsDownFile] [=totalLines]}${lua increase_y_offset [=torrentsDownFile]}
${lua_parse draw_image ~/conky/monochrome/images/common/menu-blank.png 0 0}\
# -------  table | [=image.primaryColor] 2 columns | bottom edge -------
${endif}\
${lua increment_offsets 0 [=sectionGap]}\
${endif}\
${else}\
# ::: error state
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-torrents.png 0 0}\
<@menu.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconheight color=image.secondaryColor isFixed=false isDark=true/>
${voffset 5}${offset 48}${color3}transmission
${voffset 2}${offset 48}${color4}missing files${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${endif}\
]]
