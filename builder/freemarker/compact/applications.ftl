<#import "/lib/menu-round.ftl" as menu>
-- n.b. this conky requires the music-player java app to be running in the background
--      it generates input files under /tmp/conky/musicplayer.* which this conky will read

conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua ~/conky/monochrome/musicPlayer.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,  -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_right',  -- top|middle|bottom_left|right
  gap_x = 5,
  gap_y = 39,

  -- window settings
  <#assign width = 189>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  minimum_height = 930,
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
  default_color = '[=colors.menuText]',  -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.highlight]',         -- highlight important packages
  color3 = '[=colors.secondary.labels]',         -- secondary menu labels
  color4 = '[=colors.secondary.text]'         -- secondary menu text
};

conky.text = [[
<#assign totalLines = 52>
${lua set_total_lines [=totalLines]}\
# decrease the total number of lines depending on the window size of the music player conky placed below this conky
${lua decrease_music_player_lines 0 7 15}\
# :::::::::::::::: package updates ::::::::::::::::
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted">
${if_existing [=packagesFile]}\
<#assign y = 0, 
         header = 51, <#-- menu header -->
         body = 20,   <#-- menu window without the header -->
         gap = 3,     <#-- empty space between menus of the same context -->
         bigGap = 5>  <#-- empty space between menus of different applications -->
<@menu.verticalTable x=0 y=y header=header body=width-header height=body/>
${voffset 2}${offset 5}${color1}dnf${goto 57}${color}${lines [=packagesFile]} package updates
<#assign y += body + gap>
<#assign header = 19, packageCol = 136, colGap = 1, versionCol = width - packageCol - colGap>
<@menu.table x=0 y=y header=header width=packageCol bottomEdges=false/>
${lua configure_menu [=image.primaryColor] light [=packageCol] 3}\
<@menu.table x=packageCol + colGap y=y width=versionCol header=header bottomEdges=false/>
<#assign y += header>
${lua add_offsets 0 [=y]}\
# optional dnf branding, can be removed or won't matter if the image does not exist
${image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-dnf.png -p [=packageCol-35-2],[=(y+2)?c]}\
${voffset 10}${offset 5}${color1}package${alignr 5}version${voffset 3}
${color}${lua_parse populate_menu [=packagesFile] [=totalLines] 900}${voffset [= 7 + bigGap]}
${lua_parse draw_bottom_edges [=packageCol + colGap] [=versionCol]}\
${lua add_offsets 0 [=bigGap]}\
${else}\
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-packages.png -p 0,0}\
<@menu.menu x=41 y=0 width=189-41 height=38/>
${lua add_offsets 0 [=38 + bigGap]}\
${voffset 4}${offset 48}${color1}dandified yum
${voffset 2}${offset 48}${color}no package updates${voffset [= 8 + bigGap]}
${endif}\
#
# :::::::::::::::: now playing ::::::::::::::::
# the UI of this conky has three states: no music player is running
#                                        song with album art
#                                        song with no album art
# :::::::: no player available
${if_existing /tmp/conky/musicplayer.name Nameless}\
${lua_parse draw_image ~/conky/monochrome/images/compact/[=image.secondaryColor]-sound-wave.png 0 0}\
<@menu.menu x=41 y=0 width=189-41 height=38 fixed=false/>
${lua add_offsets 0 [=38 + bigGap]}\
${voffset 2}${offset 48}${color1}now playing
${voffset 2}${offset 48}${color}no player running${voffset [= 8 + bigGap]}
${else}\
# :::::::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
<#assign top = 19,    <#-- menu header -->
         body = 185>  <#-- size of the current window without the header -->
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
<@menu.menu x=0 y=0 width=width height=top+body isDark=false color=image.secondaryColor fixed=false/>
${lua add_offsets 0 [=top]}\
${alignc}${color3}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}} ${color4}: ${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.secondaryColor]-menu-album-placeholder.png [=4+8] 8}\
${else}\
<@menu.menu x=0 y=0 width=width height=top+body fixed=false/>
${lua add_offsets 0 [=top]}\
${alignc}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}} ${color}: ${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-album-placeholder.png [=4+8] 8}\
${color}\
${endif}\
${lua_parse album_art_image ${cat /tmp/conky/musicplayer.albumArtPath} 181x181 4 0}\
${lua add_offsets 0 [=body + gap]}\
${voffset 193}\
${else}\
# :::::::: no album art available
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-rhythmbox.png 0 0}\
<@menu.menu x=55 y=33 width=width-55 height=38 isDark=true fixed=false/>
${lua add_offsets 0 [=71 + gap]}\
${voffset 34}${offset 61}${color1}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}
${voffset 4}${offset 61}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${voffset 9}\
${endif}\
# :::::::: track details
# menu expands based on the track metadata fields available
# the position of the bottom edge images is shifted down 16px for each field
<#-- 3 px top border | 16 px text | 3 px bottom border -->
# -------  vertical table image top -------
<#assign header = 45, height = 22>
<@menu.verticalMenuHeader x=0 y=0 header=header body=width-header fixed=false/>
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-sound-wave.png [=width-53-7] 0}\
${endif}\
# --------- end of table image top ---------
${lua add_offsets 0 [=height - 7]}\<#-- edges are 7x7 px -->
${voffset 3}${offset 5}${color1}title${goto 50}${color}${cat /tmp/conky/musicplayer.title}
${if_match "${lua get album ${cat /tmp/conky/musicplayer.album}}" != "unknown album"}\
${voffset 3}${offset 5}${color1}album${goto 50}${color}${lua get album}${lua add_offsets 0 16}
${endif}\
${if_match "${lua get artist ${cat /tmp/conky/musicplayer.artist}}" != "unknown artist"}\
${voffset 3}${offset 5}${color1}artist${goto 50}${color}${lua get artist}${lua add_offsets 0 16}
${endif}\
${if_match "${lua get genre ${cat /tmp/conky/musicplayer.genre}}" != "unknown genre"}\
${voffset 3}${offset 5}${color1}genre${goto 50}${color}${lua get genre}${lua add_offsets 0 16}
${endif}\
${voffset -7}\
# ------  vertical table image bottom ------
<@menu.verticalMenuBottom x=0 y=0 header=header body=width-header fixed=false/>
# -------- end of table image bottom -------
${endif}\
]];
