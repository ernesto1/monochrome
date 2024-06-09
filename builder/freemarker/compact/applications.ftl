<#import "/lib/panel-round.ftl" as panel>
--[[
this conky requires the following supporting scripts running in the background:

 - dnfPackageLookup.bash
 - the music-player java app
 - transmission.bash
   requires the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote

output files from these supporting apps are read from /tmp/conky
]]

conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_right',  -- top|middle|bottom_left|right
  gap_x = 3,
  gap_y = 142,

  -- window settings
  <#assign width = 189>
  minimum_width = [=width],      -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = 1351,
  own_window = true,
  own_window_type = 'desktop',   -- values: desktop (background), panel (bar)

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
  max_user_text = 26000,    -- max size of user text buffer in bytes, i.e. text inside conky.text section 
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
<#assign totalLines = 72,
         packageLines = 25
         gap = 3>             <#-- empty space between panels of the same context -->
${lua set_total_lines [=totalLines]}\
${lua increment_offsets 0 0}\
#
# :::::::::::::::: package updates ::::::::::::::::
#
<#assign y = 0,
         iconHeight = 38, <#-- icon is a square -->
         sectionGap = 5>      <#-- empty space between panels of different applications -->
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-packages.png 0 0}\
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted">
${if_existing [=packagesFile]}\
# :::::: updates vailable
<@panel.panel x=iconHeight+gap y=0 width=189-(iconHeight+3) height=iconHeight isFixed=false isDark=true/>
${voffset 5}${lua_parse add_x_offset offset 48}${color1}dandified yum
${voffset 2}${lua_parse add_x_offset offset 48}${color}${lines [=packagesFile]} package updates${voffset 10}
${lua increment_offsets 0 [=iconHeight + gap]}\
<#assign packageCol = 134, colGap = gap, versionCol = width - packageCol - colGap>
<@panel.panels x=0 y=0 widths=[packageCol,versionCol] gap=colGap isFixed=false/>
# optional dnf branding, can be removed or won't matter if the image does not exist
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-dnf.png [=packageCol-35-2] 5}\
${color}${lua_parse paginate [=packagesFile] [=packageLines]}${lua increase_y_offset [=packagesFile]}${voffset [= 7 + sectionGap]}
<@panel.panelsBottom x=0 y=0 widths=[packageCol,versionCol] gap=colGap isFixed=false/>
${lua increment_offsets 0 [=sectionGap]}\
${else}\
# :::::: no package updates
<@panel.panel x=iconHeight+3 y=0 width=189-(iconHeight+3) height=iconHeight isFixed=false/>
${voffset 5}${lua_parse add_x_offset offset 48}${color1}dandified yum
${voffset 2}${lua_parse add_x_offset offset 48}${color}no package updates${voffset [= 7 + sectionGap]}
${lua increment_offsets 0 [=iconHeight + sectionGap]}\
${endif}\
#
# :::::::::::::::: now playing ::::::::::::::::
# the UI of this conky has four states: song with album art
#                                       song with no album art
#                                       no music player is running
#                                       dependent java dbus listener application is not running
# :::::: no player available
${if_existing /tmp/conky/musicplayer.name}\
${if_existing /tmp/conky/musicplayer.name Nameless}\
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-sound-wave.png 0 0}\
<@panel.panel x=41 y=0 width=189-41 height=iconHeight isFixed=false/>
${voffset 3}${lua_parse add_x_offset offset 48}${color1}now playing
${voffset 2}${lua_parse add_x_offset offset 48}${color}no player running${voffset [= 8 + sectionGap]}
${lua increment_offsets 0 [=iconHeight + sectionGap]}\
${else}\
# :::::: player status
${lua increment_offsets 0 [=gap]}${voffset [=gap]}\
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-sound-wave.png 0 0}\
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
<@panel.panel x=41 y=0 width=189-41 height=iconHeight isFixed=false color=image.secondaryColor/>
${voffset 3}${lua_parse add_x_offset offset 48}${color3}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}
${voffset 2}${lua_parse add_x_offset offset 48}${color4}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${else}\
<@panel.panel x=41 y=0 width=189-41 height=iconHeight isFixed=false/>
${voffset 3}${lua_parse add_x_offset offset 48}${color1}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}
${voffset 2}${lua_parse add_x_offset offset 48}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${endif}\
${lua increment_offsets 0 [=iconHeight + gap]}\
${voffset [= 6 + gap]}\
# :::::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
<#assign body = 189,    <#-- size of the current window without the header -->
         border = 4>
<@panel.panel x=0 y=0 width=width height=body isFixed=false/>
${lua increment_offsets 0 [=border]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-album-placeholder.png [=border+8] 8}\
${lua_parse load_image ${cat /tmp/conky/musicplayer.albumArtPath} 181x181 4 0}\
${lua increment_offsets 0 [=body-border + gap]}${lua decrease_total_lines 12}\
${voffset 192}\
${endif}\
# :::::: track details
# panel expands based on the track metadata fields available
# the position of the bottom edge images is shifted down 16px for each field
<#-- 3 px top border | 16 px text | 3 px bottom border -->
# -------  vertical table image top -------
<#assign header = 45, height = 22>
<@panel.verticalMenuHeader x=0 y=0 header=header body=width-header isFixed=false/>
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-sound-wave.png [=width-53-7] 0}\
${endif}\
# --------- end of table image top ---------
${lua increment_offsets 0 [=height - 7]}\<#-- edges are 7x7 px, therefore reduce the height of the bottom edges from the panel -->
${voffset 3}${lua_parse add_x_offset offset 5}${color1}title${lua_parse add_x_offset goto 50}${color}${cat /tmp/conky/musicplayer.title}${lua decrease_total_lines 2}
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
${lua increment_offsets 0 [=7 + sectionGap]}\<#-- edges are 7x7 px -->
${voffset [= 8 + sectionGap]}\
${lua increment_offsets 0 [=gap]}${voffset [=gap]}\
${endif}\
${else}\
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-sound-wave.png 0 0}\
<@panel.panel x=41 y=0 width=189-41 height=iconHeight isFixed=false color=image.secondaryColor/>
${voffset 3}${lua_parse add_x_offset offset 48}${color3}now playing
${voffset 2}${lua_parse add_x_offset offset 48}${color4}input files are missing${voffset [= 8 + sectionGap]}
${lua increment_offsets 0 [=iconHeight + sectionGap]}\
${endif}\
#
# :::::::::::::::: torrents ::::::::::::::::
#
<#assign inputDir = "/tmp/conky/",
         torrentsFile = inputDir + "transmission.torrents",
         torrentsUpFile = inputDir + "transmission.torrents.up",
         torrentsDownFile = inputDir + "transmission.torrents.down",
         peersFile = inputDir + "transmission.peers.raw",
         peersUpFile = inputDir + "transmission.peers.up",
         peersDownFile = inputDir + "transmission.peers.down",
         torrentLines = totalLines - packageLines>
${lua_parse draw_image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-torrents.png 0 0}\
# :::::: transmission script running
${if_existing [=torrentsFile]}\
${voffset 2}${lua_parse add_x_offset offset 48}${color1}transmission
# ::: no active torrents
${if_match ${lua get activeNum ${lines [=torrentsFile]}} == 0}\
<@panel.panel x=iconHeight+3 y=0 width=189-(iconHeight+3) height=iconHeight isFixed=false/>
${voffset 2}${lua_parse add_x_offset offset 48}${color}no active torrents${voffset [= 8 + sectionGap]}
${lua increment_offsets 0 [=iconHeight + sectionGap]}\
${else}\
# ::: torrents overview
<@panel.panel x=iconHeight+3 y=0 width=189-(iconHeight+3) height=iconHeight isFixed=false isDark=true/>
${voffset 2}${lua_parse add_x_offset offset 48}${color}${lines [=torrentsFile]} active torrents ${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconHeight + gap]}\
# ::: torrent uploads
# the torrent uploads table is composed of 2 columns: upload | torrent name
${if_match ${lines [=torrentsUpFile]} > 0}\
<#assign speedColWidth = 39,                          <#-- width of upload/download columns -->
         panelWidth = width - speedColWidth - colGap>
<@panel.panels x=0 y=0 widths=[speedColWidth, panelWidth] gap=colGap isFixed=false highlight=[1]/>
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-peers.png [=speedColWidth + colGap + 17] 22}\
${lua_parse head [=torrentsUpFile] [=torrentLines - 5]}${lua increase_y_offset [=torrentsUpFile]}${voffset [= 7 + gap]}
<@panel.panelsBottom x=0 y=0 widths=[speedColWidth, panelWidth] gap=colGap isFixed=false highlight=[1]/>
${lua increment_offsets 0 [=gap]}\
${endif}\
# ::: torrent downloads
${if_match ${lines [=torrentsDownFile]} > 0}\
<@panel.panels x=0 y=0 widths=[speedColWidth, panelWidth] gap=colGap isFixed=false/>
${lua_parse head [=torrentsDownFile] [=torrentLines - 5]}${lua increase_y_offset [=torrentsDownFile]}${voffset [= 7 + gap]}
<@panel.panelsBottom x=0 y=0 widths=[speedColWidth, panelWidth] gap=colGap isFixed=false/>
${lua increment_offsets 0 [=gap]}\
${endif}\
# ::: no peers
${if_match ${lines [=peersFile]} == 0}\
<@panel.panel x=speedColWidth + colGap y=0 width=panelWidth height=22 isFixed=false/>
${voffset 2}${lua_parse add_x_offset offset 48}${color}no peers connected${voffset [= 8 + sectionGap]}
${else}\
<@panel.panel x=speedColWidth + colGap y=0 width=panelWidth height=22 isFixed=false isDark=true/>
${voffset 2}${lua_parse add_x_offset offset 48}${color}${lines [=peersFile]} peers in the swarm${voffset [= 7 + gap]}
${lua increment_offsets 0 [=22 + gap]}\
# ::: peers upload
# the peers table is composed of 3 columns: upload | ip | client
${if_match ${lines [=peersUpFile]} > 0}\
<#assign ipCol = 99, clientCol = 87>
<@panel.panels x=0 y=0 widths=[speedColWidth,ipCol,panelWidth-ipCol-colGap] gap=colGap isFixed=false highlight=[1]/>
${lua_parse head [=peersUpFile] [=torrentLines]}${lua increase_y_offset [=peersUpFile]}${voffset [= 7 + gap]}
<@panel.panelsBottom x=0 y=0 widths=[speedColWidth,ipCol,panelWidth-ipCol-colGap] gap=colGap isFixed=false highlight=[1]/>
${lua increment_offsets 0 [=gap]}\
${endif}\
${if_match ${lines [=peersDownFile]} > 0}\
<@panel.panels x=0 y=0 widths=[speedColWidth,ipCol,panelWidth-ipCol-colGap] gap=colGap isFixed=false/>
${lua_parse head [=peersDownFile] [=torrentLines]}${lua increase_y_offset [=peersDownFile]}
<@panel.panelsBottom x=0 y=0 widths=[speedColWidth,ipCol,panelWidth-ipCol-colGap] gap=colGap isFixed=false/>
${lua increment_offsets 0 [=gap]}\
${endif}\
${endif}\
${endif}\
${else}\
# :::::: error state: input file not available
<@panel.panel x=iconHeight+3 y=0 width=189-(iconHeight+3) height=iconHeight isFixed=false color=image.secondaryColor/>
${voffset 3}${lua_parse add_x_offset offset 48}${color3}transmission
${voffset 2}${lua_parse add_x_offset offset 48}${color4}input files are missing${voffset [= 8 + sectionGap]}
${lua increment_offsets 0 [=iconHeight + sectionGap]}\
${endif}\
]];
