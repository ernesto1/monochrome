<#import "/lib/panel-square.ftl" as panel>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua ~/conky/monochrome/musicPlayer.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_right',  -- top|middle|bottom_left|right
  gap_x = 6,
  gap_y = -16,

  -- window settings
  <#assign width = 159>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  minimum_height = 1316,
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
  
  -- special settings
  imlib_cache_flush_interval = 250,
  
  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.systemText]', -- regular text
  color1 = '[=colors.systemLabels]',
  color2 = '[=colors.highlight]',        -- highlight important packages
  color3 = '[=colors.secondary.labels]',         -- secondary panel labels
  color4 = '[=colors.secondary.text]'         -- secondary panel text
};

conky.text = [[
<#assign totalLines = 50,
         packageLines = 13>
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
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-packages.png -p 0,0}\
# ::: updates vailable
${if_existing [=packagesFile]}\
<@panel.panel x=iconWidth+gap y=y width=width-iconWidth-gap height=iconheight isDark=true/>
${voffset 5}${offset 48}${color1}dandified yum
${voffset 2}${offset 48}${color}${lua get numUpdates ${lines [=packagesFile]}} ${if_match ${lua get numUpdates} < 100}package update${else}new updates${endif}${voffset [= 7 + gap]}
<#assign y += iconheight + gap>
<#assign header = 19, versionCol = 51>
<@panel.table x=0 y=y widths=[width-versionCol-colGap, versionCol] gap=colGap header=header/>
<#assign y += titleHeight>
${lua increment_offsets 0 [=y]}\
${offset 5}${color1}package${alignr 4}version${voffset [=3+gap]}
${color}${lua_parse paginate [=packagesFile] [=packageLines]}${lua increase_y_offset [=packagesFile]}${voffset [=5 + sectionGap]}
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 0 0}\
# ------- table | 2 column(s) | bottom -------
${lua increment_offsets 0 [=sectionGap]}\
${else}\
# ::: no updates available or dnf script not running
<@panel.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconheight/>
${voffset 5}${offset 48}${color1}dandified yum
${voffset 2}${offset 48}${color}no package updates${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${endif}\
#
# :::::::::::::: now playing :::::::::::::::
# the music player has four states: song with album art
#                                   song with no album art
#                                   no music player is running
#                                   dependent java dbus listener application is not running
<#assign  playerStatusFile="/tmp/conky/musicplayer.status",
          playerNameFile="/tmp/conky/musicplayer.name",
          iconHeight = 38>
${if_existing [=playerStatusFile]}\
# :::::::: no player available
${if_existing [=playerStatusFile] off}\
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sound-wave.png 0 0}\
<@panel.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconHeight isFixed=false/>
${voffset 5}${offset 48}${color1}now playing
${voffset 2}${offset 48}${color}no player running${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}\
${else}\
# :::::::: player available
${lua increment_offsets 0 [=gap]}${voffset [=gap]}${lua load_track_info}\
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sound-wave.png 0 0}\
${if_match "${lua get playbackStatus ${cat /tmp/conky/musicplayer.playbackStatus}}" == "Playing"}\
<@panel.panel x=41 y=0 width=189-41 height=iconHeight isFixed=false color=image.secondaryColor isDark=true/>
${voffset 5}${lua_parse add_x_offset offset 48}${color3}${cat [=playerNameFile]}
${voffset 2}${lua_parse add_x_offset offset 48}${color4}${lua get playbackStatus}
${else}\
<@panel.panel x=41 y=0 width=189-41 height=iconHeight isFixed=false/>
${voffset 5}${lua_parse add_x_offset offset 48}${color1}${cat [=playerNameFile]}
${voffset 2}${lua_parse add_x_offset offset 48}${color}${lua get playbackStatus}
${endif}\
${lua increment_offsets 0 [=iconHeight + gap]}\
${voffset [= 7 + gap]}\
# ::: album art
${if_existing /tmp/conky/musicplayer.track.albumArtPath}\
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-music-player-album.png 0 0}\
${lua_parse load_image ${cat /tmp/conky/musicplayer.track.albumArtPath} 155x155 2 2}\
${voffset [=width + gap]}${lua increment_offsets 0 [=width + gap]}\
${endif}\
# ::: track details
# panel expands based on the track metadata fields available, only 'title' is considered mandatory
<@panel.panel x=0 y=0 width=width isFixed=false/>
${if_match "${lua get playbackStatus}" == "Playing"}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-sound-wave.png [=width-69] 0}\
${endif}\
${lua increment_offsets 0 [=23]}\
${voffset 3}${offset 5}${color}${lua_parse truncate_string ${lua get title} 25}
${if_match "${lua get album}" != "unknown album"}\
<#-- vertical offset would normally be 3px between fields but in order to support optional fields and not introduce
     blank new lines, each field does have a line break.  Hence the use of 16px in order to compensate for this -->
${voffset 3}${offset 5}${color}${lua_parse truncate_string ${lua get album} 25}${lua increment_offsets 0 16}
${endif}\
${if_match "${lua get artist}" != "unknown artist"}\
${voffset 3}${offset 5}${color}${lua_parse truncate_string ${lua get artist} 25}${lua increment_offsets 0 16}
${endif}\
${if_match "${lua get genre}" != "unknown genre"}\
${voffset 3}${offset 5}${color}${lua_parse truncate_string ${lua get genre} 25}${lua increment_offsets 0 16}
${endif}\
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 0 0}\
# ------- panel | light blue | bottom  -------
${lua increment_offsets 0 [=gap * 2]}${voffset [= 4 + gap + sectionGap]}\
${endif}\
${else}\
# :::::::: error state | input files are missing
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-sound-wave.png 0 0}\
<@panel.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconHeight isDark=true color=image.secondaryColor  isFixed=false/>
${voffset 5}${offset 48}${color3}now playing
${voffset 2}${offset 48}${color4}missing files${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}\
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
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-torrents.png 0 0}\
${if_existing [=torrentsFile]}\
# ::: no active torrents
${if_match ${lua get activeNum ${lines [=torrentsFile]}} == 0}\
<@panel.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconheight isFixed=false/>
${voffset 5}${offset 48}${color1}transmission
${voffset 2}${offset 48}${color}no active torrents${voffset [= 5 + sectionGap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${else}\
# ::: active torrents
<@panel.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconheight isFixed=false isDark=true/>
${voffset 5}${offset 48}${color1}transmission
${voffset 2}${offset 48}${color}${lua get activeNum} active torrents${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconheight + gap]}\
<#assign header = 59,   <#-- section for the labels -->
         height = 55>
<@panel.verticalTable x=0 y=0 header=header body=width-header height=height isFixed=false/>
${voffset 3}${offset 5}${color1}swarm${alignr 21}${color}${if_existing [=peersFile]}${lines [=peersFile]} peers${else}file missing${endif}
${voffset 3}${offset 5}${color1}upload${color}${if_existing [=uploadFile]}${alignr 33}${cat [=uploadFile]}${else}file missing${endif}
${voffset 3}${offset 5}${color1}download${color}${if_existing [=downloadFile]}${alignr 33}${cat [=downloadFile]}${else}file missing${endif}${voffset [= 7 + gap]}
${lua increment_offsets 0 [=height + gap]}\
# ::: torrent uploads
# the torrent uploads table is composed of 2 columns: torrent name | upload
${if_match ${lines [=torrentsUpFile]} > 0}\
<#assign speedColWidth = 39,                          <#-- width of upload/download columns -->
         panelWidth = width - speedColWidth - colGap>
<@panel.table x=0 y=0 widths=[panelWidth, speedColWidth] header=titleHeight gap=colGap isFixed=false highlight=[2]/>
${lua increment_offsets 0 [=titleHeight]}\
${offset 5}${color1}torrent${alignr 4}${color3}up${voffset [=3+gap]}
${lua_parse head [=torrentsUpFile] [=totalLines-5]}${lua increase_y_offset [=torrentsUpFile]}${voffset [= 7 + gap]}
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 0 0}\
# ------- table | 2 column(s) | bottom    -------
${lua increment_offsets 0 [=gap]}\
${endif}\
# ::: torrent downloads
${if_match ${lines [=torrentsDownFile]} > 0}\
<@panel.table x=0 y=0 widths=[panelWidth, speedColWidth] header=titleHeight gap=colGap isFixed=false/>
${lua increment_offsets 0 [=titleHeight]}\
${offset 5}${color1}torrent${alignr 4}down${voffset [=3+gap]}
${color}${lua_parse head [=torrentsDownFile] [=totalLines]}${lua increase_y_offset [=torrentsDownFile]}
${lua_parse draw_image ~/conky/monochrome/images/common/blank-panel.png 0 0}\
# -------  table | [=image.primaryColor] 2 columns | bottom edge -------
${endif}\
${lua increment_offsets 0 [=sectionGap]}\
${endif}\
${else}\
# ::: error state
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-torrents.png 0 0}\
<@panel.panel x=iconWidth+gap y=0 width=width-iconWidth-gap height=iconheight color=image.secondaryColor isFixed=false isDark=true/>
${voffset 5}${offset 48}${color3}transmission
${voffset 2}${offset 48}${color4}missing files${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconheight + sectionGap]}${lua decrease_total_lines 2}\
${endif}\
]]
