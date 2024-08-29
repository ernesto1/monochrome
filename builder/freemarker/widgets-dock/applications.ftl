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
  alignment = 'middle_right',   -- top|middle|bottom_left|right
  gap_x = 7,
  <#if system == "desktop"><#assign yOffset = -42><#else><#assign yOffset = -26></#if>
  gap_y = [=yOffset],

  -- window settings
  <#assign width = 169>
  minimum_width = [=width],     -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = <#if system == "desktop">1354<#else>695</#if>,
  own_window = true,
  own_window_type = 'desktop',  -- values: desktop (background), panel (bar)

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
  max_user_text = 20000,    -- max size of user text buffer in bytes, i.e. text inside conky.text section 
                            -- default is 16,384 bytes
  
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
<#assign totalLines = 72>
<#if system == "desktop"><#assign packageLines = 16><#else><#assign packageLines = 6></#if>
${lua set_total_lines [=totalLines]}\
# :::::::::::: package updates
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted",
         iconWidth = 38,       <#-- icon is a square -->
         iconHeight = 38,
         singleLineHeight = 23,
         y = 0,
         gap = 3,               <#-- empty space across panels of the same application -->
         sectionGap = 4>        <#-- empty space between application panels -->
${if_existing [=packagesFile]}\
${image ~/conky/monochrome/images/common/[=image.primaryColor]-packages.png -p 0,0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=y width=width-iconWidth height=iconHeight isDark=true/>
${voffset 5}${offset 45}${color1}dandified yum
${voffset 2}${offset 45}${color}${lines [=packagesFile]} package updates${voffset [=5+gap]}
<#assign y += iconHeight + gap>
<@panel.table x=0 y=y width=width header=singleLineHeight/>
<#assign y += singleLineHeight>
${lua increment_offsets 0 [=y]}\
# optional dnf branding, can be removed or won't matter if the image does not exist
${image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dnf.png -p 95,[=y+2]}\
${voffset 5}${offset 5}${color1}package${alignr 4}version${voffset [=4+gap]}
${color}${lua_parse paginate [=packagesFile] [=packageLines]}${lua increase_y_offset [=packagesFile]}${voffset [=5 + sectionGap]}
<@panel.panelBottomCorners x=0 y=0 width=width isFixed=false/>
${lua increment_offsets 0 [=sectionGap]}\
${else}\
# ::: no updates available or dnf script not running
${image ~/conky/monochrome/images/common/[=image.primaryColor]-packages.png -p 0,0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconHeight/>
${voffset 5}${offset 45}${color1}dandified yum
${voffset 2}${offset 45}${color}no package updates${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconHeight + sectionGap]}${lua decrease_total_lines 2}\
${endif}\
# :::::::::::::::: now playing
# the UI of this conky has four states: song with album art
#                                       song with no album art
#                                       no music player is running
#                                       dependent java dbus listener application is not running
# ::: no player available
${if_existing /tmp/conky/musicplayer.name}\
${if_existing /tmp/conky/musicplayer.name Nameless}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-sound-wave.png 0 0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconHeight isFixed=false/>
${voffset 5}${lua_parse add_x_offset offset 45}${color1}now playing
${voffset 2}${lua_parse add_x_offset offset 45}${color}no player running${voffset [=5 + sectionGap]}
${lua increment_offsets 0 [=iconHeight + sectionGap]}\
${else}\
# ::: player status
${lua increment_offsets 0 [=gap]}${voffset [=gap]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-sound-wave.png 0 0}\
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconHeight isFixed=false color=image.secondaryColor/>
${voffset 5}${lua_parse add_x_offset offset 45}${color3}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}
${voffset 2}${lua_parse add_x_offset offset 45}${color4}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${else}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-sound-wave.png 0 0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconHeight isFixed=false/>
${voffset 5}${lua_parse add_x_offset offset 45}${color1}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}
${voffset 2}${lua_parse add_x_offset offset 45}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${endif}\
${lua increment_offsets 0 [=iconHeight + gap]}\
${voffset [= 6 + gap]}\
# ::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
<#assign border = 2>
<@panel.panel x=0 y=0 width=width height=width isFixed=false/>
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-album-placeholder.png [=border] [=border]}\
${lua_parse load_image ${cat /tmp/conky/musicplayer.albumArtPath} [=width-border*2]x[=width-border*2] [=border] [=border]}\
${voffset [=width + gap]}${lua increment_offsets 0 [=width + gap]}${lua decrease_total_lines 12}\
${endif}\
# ::: track details
# panel expands based on the track metadata fields available
# the position of the bottom edge images is shifted down 16px for each field
<#-- 3 px top border | 16 px text | 3 px bottom border -->
# -------  vertical table image top -------
<#assign header = 45, height = 23>
<@panel.verticalMenuHeader x=0 y=0 header=header body=width-header isFixed=false/>
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-sound-wave.png [=width-53-7] 1}\
${endif}\
# --------- end of table image top ---------
${lua increment_offsets 0 [=height - 7]}\<#-- edges are 7x7 px, therefore reduce the height of the bottom edges from the panel -->
${voffset 4}${lua_parse add_x_offset offset 5}${color1}title${lua_parse add_x_offset goto 50}${color}${cat /tmp/conky/musicplayer.title}${lua decrease_total_lines 2}
${if_match "${lua get album ${cat /tmp/conky/musicplayer.album}}" != "unknown album"}\
${voffset 3}${lua_parse add_x_offset offset 5}${color1}album${lua_parse add_x_offset goto 50}${color}${lua get album}${lua increment_offsets 0 16}${lua decrease_total_lines 1}
${endif}\
${if_match "${lua get artist ${cat /tmp/conky/musicplayer.artist}}" != "unknown artist"}\
${voffset 3}${lua_parse add_x_offset offset 5}${color1}artist${lua_parse add_x_offset goto 50}${color}${lua get artist}${lua increment_offsets 0 16}${lua decrease_total_lines 1}
${endif}\
${if_match "${lua get genre ${cat /tmp/conky/musicplayer.genre}}" != "unknown genre"}\
${voffset 3}${lua_parse add_x_offset offset 5}${color1}genre${lua_parse add_x_offset goto 50}${color}${lua get genre}${lua increment_offsets 0 16}${lua decrease_total_lines 1}
${endif}\
# ------  vertical table image bottom ------
<#-- draw the bottom edges at the final calculated location -->
<@panel.verticalMenuBottom x=0 y=0 header=header body=width-header isFixed=false/>
# -------- end of table image bottom -------
${lua increment_offsets 0 [=7 + sectionGap + gap]}\<#-- edges are 7x7 px -->
${voffset [= 8 + sectionGap]}\
${endif}\
${else}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-sound-wave.png 0 0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconHeight isFixed=false isDark=true color=image.secondaryColor/>
${voffset 5}${lua_parse add_x_offset offset 45}${color3}now playing
${voffset 2}${lua_parse add_x_offset offset 45}${color4}input files missing${voffset [=5 + sectionGap]}
${lua increment_offsets 0 [=iconHeight + sectionGap]}\
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
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-torrents.png 0 0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconHeight isFixed=false/>
${voffset 5}${offset 45}${color1}transmission
${voffset 2}${offset 45}${color}no active torrents${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconHeight + sectionGap]}${lua decrease_total_lines 2}\
${else}\
# ::: active torrents
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-torrents.png 0 0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconHeight isFixed=false isDark=true/>
${voffset 5}${offset 45}${color1}transmission
${voffset 2}${offset 45}${color}${lua get activeNum} active torrents${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconHeight + gap]}\
<#assign header = 59,   <#-- section for the labels -->
         height = 55>
<@panel.verticalTable x=0 y=0 header=header body=width-header height=height isFixed=false/>
${voffset 3}${offset 5}${color1}swarm${goto 67}${color}${if_existing [=peersFile]}${lua pad ${lines [=peersFile]} 6} peers${else}file missing${endif}
${voffset 3}${offset 5}${color1}upload${color}${if_existing [=uploadFile]}${alignr 43}${cat [=uploadFile]}${else}file missing${endif}
${voffset 3}${offset 5}${color1}download${color}${if_existing [=downloadFile]}${alignr 43}${cat [=downloadFile]}${else}file missing${endif}${voffset [=5 + gap]}
${lua increment_offsets 0 [=height + gap]}\
# ::: torrent uploads
${if_match ${lines [=torrentsUpFile]} > 0}\
# -------  table | [=image.primaryColor] 2 columns | top edge    -------
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark-edge-top-left.png 0 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-panel-dark.png 139 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-panel-dark-edge-top-right.png 162 0}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png 0 [=singleLineHeight]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-panel-light.png 139 [=singleLineHeight]}\
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 169 0}\
${lua increment_offsets 0 [=singleLineHeight]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-peers.png [=((width-139)/2)?round] 22}\
${voffset 5}${offset 5}${color1}torrent${alignr 4}up${voffset [=4+gap]}
${color}${lua_parse head [=torrentsUpFile] [=totalLines - 5]}${voffset [= 5 + gap]}${lua increase_y_offset [=torrentsUpFile]}
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
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-light.png 0 [=singleLineHeight]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dark.png 136 [=singleLineHeight]}\
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 169 0}\
${lua increment_offsets 0 [=singleLineHeight]}\
${voffset 5}${offset 5}${color1}torrent${alignr 4}down${voffset [=4+gap]}
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
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-torrents.png 0 0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconHeight color=image.secondaryColor isFixed=false isDark=true/>
${voffset 5}${offset 45}${color3}transmission
${voffset 2}${offset 45}${color4}input files missing${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconHeight + sectionGap]}${lua decrease_total_lines 2}\
${endif}\
]]
