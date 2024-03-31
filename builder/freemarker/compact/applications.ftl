<#import "/lib/menu-round.ftl" as menu>
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
  <#assign width = 189, 
           gap = 3,             <#-- empty space between menus of the same context -->
           speedColWidth = 39,  <#-- width of upload/download columns -->
           columnOffset = speedColWidth + gap>   <#-- additional left handed empty width added by the transmission down/up columns -->
  minimum_width = [=columnOffset + width],      -- conky will add an extra pixel to this
  maximum_width = [=columnOffset + width],
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
  max_user_text = 22000,    -- max size of user text buffer in bytes, i.e. text inside conky.text section 
                            -- default is 16,384 bytes

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
<#assign totalLines = 74,
         packageLines = 25>
${lua set_total_lines [=totalLines]}\
${lua increment_offsets [=columnOffset] 0}\
#
# :::::::::::::::: package updates ::::::::::::::::
#
<#assign y = 0,
         iconHeight = 38, <#-- icon is a square -->
         bigGap = 5>      <#-- empty space between menus of different applications -->
${lua_parse draw_image ~/conky/monochrome/images/compact/[=image.secondaryColor]-packages.png 0 0}\
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted">
${if_existing [=packagesFile]}\
# :::::: updates vailable
<@menu.panel x=iconHeight+gap y=0 width=189-(iconHeight+3) height=iconHeight isFixed=false isDark=true/>
${voffset 5}${lua_parse add_x_offset offset 48}${color1}dandified yum
${voffset 2}${lua_parse add_x_offset offset 48}${color}${lines [=packagesFile]} package updates${voffset 10}
${lua increment_offsets 0 [=iconHeight + gap]}\
<#assign packageCol = 134, colGap = gap, versionCol = width - packageCol - colGap>
<@menu.panels x=0 y=0 widths=[packageCol,versionCol] gap=colGap isFixed=false/>
# optional dnf branding, can be removed or won't matter if the image does not exist
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-dnf.png [=packageCol-35-2] 5}\
${color}${lua_parse paginate [=packagesFile] [=packageLines]}${lua increase_y_offset [=packagesFile]}${voffset [= 7 + bigGap]}
<@menu.panelsBottom x=0 y=0 widths=[packageCol,versionCol] gap=colGap isFixed=false/>
${lua increment_offsets 0 [=bigGap]}\
${else}\
# :::::: no package updates
<@menu.panel x=iconHeight+3 y=0 width=189-(iconHeight+3) height=iconHeight isFixed=false/>
${voffset 5}${lua_parse add_x_offset offset 48}${color1}dandified yum
${voffset 2}${lua_parse add_x_offset offset 48}${color}no package updates${voffset [= 7 + bigGap]}
${lua increment_offsets 0 [=iconHeight + bigGap]}\
${endif}\
#
# :::::::::::::::: now playing ::::::::::::::::
#
# the UI of this conky has three states: no music player is running
#                                        song with album art
#                                        song with no album art
# :::::: no player available
${if_existing /tmp/conky/musicplayer.name Nameless}\
${lua_parse draw_image ~/conky/monochrome/images/compact/[=image.secondaryColor]-sound-wave.png 0 0}\
<@menu.panel x=41 y=0 width=189-41 height=iconHeight isFixed=false/>
${voffset 3}${lua_parse add_x_offset offset 48}${color1}now playing
${voffset 2}${lua_parse add_x_offset offset 48}${color}no player running${voffset [= 8 + bigGap]}
${lua increment_offsets 0 [=iconHeight + bigGap]}\
${else}\
# :::::: player status
${lua increment_offsets 0 [=gap]}${voffset [=gap]}\
${lua_parse draw_image ~/conky/monochrome/images/compact/[=image.secondaryColor]-sound-wave.png 0 0}\
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
<@menu.panel x=41 y=0 width=189-41 height=iconHeight isFixed=false color=image.secondaryColor/>
${voffset 3}${lua_parse add_x_offset offset 48}${color3}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}
${voffset 2}${lua_parse add_x_offset offset 48}${color4}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${else}\
<@menu.panel x=41 y=0 width=189-41 height=iconHeight isFixed=false/>
${voffset 3}${lua_parse add_x_offset offset 48}${color1}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}
${voffset 2}${lua_parse add_x_offset offset 48}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${endif}\
${lua increment_offsets 0 [=iconHeight + gap]}\
${voffset [= 6 + gap]}\
# :::::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
<#assign body = 189,    <#-- size of the current window without the header -->
         border = 4>
<@menu.panel x=0 y=0 width=width height=body isFixed=false/>
${lua increment_offsets 0 [=border]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-album-placeholder.png [=border+8] 8}\
${lua_parse load_image ${cat /tmp/conky/musicplayer.albumArtPath} 181x181 4 0}\
${lua increment_offsets 0 [=body-border + gap]}${lua decrease_total_lines 12}\
${voffset 192}\
${endif}\
# :::::: track details
# menu expands based on the track metadata fields available
# the position of the bottom edge images is shifted down 16px for each field
<#-- 3 px top border | 16 px text | 3 px bottom border -->
# -------  vertical table image top -------
<#assign header = 45, height = 22>
<@menu.verticalMenuHeader x=0 y=0 header=header body=width-header isFixed=false/>
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-sound-wave.png [=width-53-7] 0}\
${endif}\
# --------- end of table image top ---------
${lua increment_offsets 0 [=height - 7]}\<#-- edges are 7x7 px, therefore reduce the height of the bottom edges from the menu -->
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
<@menu.verticalMenuBottom x=0 y=0 header=header body=width-header isFixed=false/>
# -------- end of table image bottom -------
${lua increment_offsets 0 [=7 + bigGap]}\<#-- edges are 7x7 px -->
${voffset [= 8 + bigGap]}\
${lua increment_offsets 0 [=gap]}${voffset [=gap]}\
${endif}\
#
# :::::::::::::::: torrents ::::::::::::::::
#
<#assign inputDir = "/tmp/conky/",
         statusFile = inputDir + "transmission.status",
         activeTorrentsFile = inputDir + "transmission.active.flipped",
         peersFile = inputDir + "transmission.peers.flipped",
         torrentLines = totalLines - packageLines>
${lua_parse draw_image ~/conky/monochrome/images/compact/[=image.secondaryColor]-torrents.png 0 0}\
# :::::: transmission script running
${if_existing [=activeTorrentsFile]}\
${voffset 2}${lua_parse add_x_offset offset 48}${color1}transmission
# ::: no active torrents
${if_match ${lua get activeNum ${lines [=activeTorrentsFile]}} == 0}\
<@menu.panel x=iconHeight+3 y=0 width=189-(iconHeight+3) height=iconHeight isFixed=false/>
${voffset 2}${lua_parse add_x_offset offset 48}${color}no active torrents${voffset [= 8 + bigGap]}
${lua increment_offsets 0 [=iconHeight + bigGap]}\
${else}\
# ::: torrenting files
# the active torrent table is composed of 3 columns: down | up | torrent details
# the 'down' column is hidden unless data is actually being downloaded
# offsets are used to move things around accross the x axis
<@menu.panel x=iconHeight+3 y=0 width=189-(iconHeight+3) height=iconHeight+15 isFixed=false isDark=true/>
${voffset 2}${lua_parse add_x_offset offset 48}${color}${lines [=activeTorrentsFile]} active torrents
${voffset 2}${lua_parse add_x_offset offset 48}${color}${lines [=peersFile]} peers in the swarm${voffset [= 7 + gap]}
${lua increment_offsets 0 [=iconHeight + 15 + gap]}\
${if_existing [=statusFile] torrents}${lua set isTorrentDownloading true}${else}${lua set isTorrentDownloading false}${endif}\
${if_match "${lua get isTorrentDownloading}" == "true"}\
${lua increment_offsets [=-1 * columnOffset] 0}\
<@menu.panels x=0 y=0 widths=[speedColWidth] gap=colGap isFixed=false/>
${lua increment_offsets [=columnOffset] 0}\
${endif}\
<#assign menuWidth = width - speedColWidth - colGap>
<@menu.panels x=0 y=0 widths=[speedColWidth, menuWidth] gap=colGap isFixed=false highlight=[1]/>
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-peers.png [=speedColWidth + colGap + 17] 22}\
${if_match "${lua get isTorrentDownloading}" == "true"}${lua increment_offsets [=-1 * columnOffset] 0}${endif}\
${lua_parse head [=activeTorrentsFile] [=torrentLines - 5]}${lua increase_y_offset [=activeTorrentsFile]}${voffset [= 7 + gap]}
${if_match "${lua get isTorrentDownloading}" == "true"}\
<@menu.panelsBottom x=0 y=0 widths=[speedColWidth] gap=colGap isFixed=false/>
${lua increment_offsets [=columnOffset] 0}\
${endif}\
<@menu.panelsBottom x=0 y=0 widths=[speedColWidth, menuWidth] gap=colGap isFixed=false highlight=[1]/>
${lua increment_offsets 0 [=gap]}\
# ::: no peers
${if_match ${lua get activeNum ${lines [=peersFile]}} == 0}\
<@menu.panel x=speedColWidth + colGap y=0 width=menuWidth height=22 isFixed=false/>
${voffset 2}${lua_parse add_x_offset offset 48}${color}no peers connected${voffset [= 8 + bigGap]}
${else}\
# ::: peers connected
# the peers table is composed of 4 columns: down | up | ip | client
# similar to the active torrent table above, the 'down' column is hidden unless data is being downloaded
${if_existing [=statusFile] peers}${lua set isPeerDownloading true}${else}${lua set isPeerDownloading false}${endif}\
${if_match "${lua get isPeerDownloading}" == "true"}\
${lua increment_offsets [=-1 * columnOffset] 0}\
<@menu.panels x=0 y=0 widths=[speedColWidth] gap=colGap isFixed=false/>
${lua increment_offsets [=columnOffset] 0}\
${endif}\
<#assign ipCol = 99, clientCol = 87>
<@menu.panels x=0 y=0 widths=[speedColWidth,ipCol,menuWidth-ipCol-colGap] gap=colGap isFixed=false highlight=[1]/>
${if_match "${lua get isTorrentDownloading}" == "true"}${lua increment_offsets [=-1 * columnOffset] 0}${endif}\
${lua_parse head [=peersFile] [=torrentLines]}${lua increase_y_offset [=peersFile]}
${if_match "${lua get isPeerDownloading}" == "true"}\
<@menu.panelsBottom x=0 y=0 widths=[speedColWidth] gap=colGap isFixed=false/>
${lua increment_offsets [=columnOffset] 0}\
${endif}\
<@menu.panelsBottom x=0 y=0 widths=[speedColWidth,ipCol,menuWidth-ipCol-colGap] gap=colGap isFixed=false highlight=[1]/>
${lua increment_offsets 0 [=gap]}\
${endif}\
${endif}\
${else}\
# :::::: error state: input file not available
<@menu.panel x=iconHeight+3 y=0 width=189-(iconHeight+3) height=iconHeight isFixed=false color=image.secondaryColor/>
${voffset 3}${lua_parse add_x_offset offset 48}${color3}transmission
${voffset 2}${lua_parse add_x_offset offset 48}${color4}input files are missing${voffset [= 8 + bigGap]}
${lua increment_offsets 0 [=iconHeight + bigGap]}\
${endif}\
]];
