<#import "/lib/panel-round.ftl" as panel>
-- n.b. this conky requires the music-player java app to be running in the background
--      it generates input files under /tmp/conky/musicplayer.* which this conky will read

conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  <#if conky == "widgets-dock"><#assign monitor = 1><#else><#assign monitor = 0></#if>
  xinerama_head = [=monitor],      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 195,
  gap_y = 5,

  -- window settings
  <#assign width = 189>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  minimum_height = 38,      -- conky will add an extra pixel to this height
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
  own_window_argb_visual = true,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)
  
  -- images
  imlib_cache_flush_interval = 250,

  -- font settings
  use_xft = false,
  draw_shades = false,      -- black shadow on text (not good if text is black)
  draw_outline = false,     -- black outline around text (not good if text is black)
  -- colors
  default_color = '[=colors.panelText]',  -- regular text
  color1 = '[=colors.labels]',
  color3 = '[=colors.secondary.labels]',         -- secondary panel labels
  color4 = '[=colors.secondary.text]'         -- secondary panel text
};

conky.text = [[
# the UI of this conky has three states: no music player is running
#                                        song with album art
#                                        song with no album art
# :::::::: no player available
${if_existing /tmp/conky/musicplayer.name Nameless}\
<#assign y = 0>
${image ~/conky/monochrome/images/compact/[=image.secondaryColor]-sound-wave.png -p 0,[=y]}\
<@panel.panel x=41 y=0 width=189-41 height=38/>
${voffset 4}${offset 48}${color1}now playing
${voffset 2}${offset 48}${color}no player running${voffset 5}
${else}\
# :::::::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
<#assign top = 19,    <#-- panel header -->
         body = 185,  <#-- size of the current window without the header -->
         gap = 3>     <#-- empty space between windows -->
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
<@panel.panel x=0 y=y width=width height=top+body isDark=false color=image.secondaryColor/>
${voffset 2}${alignc}${color3}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}} ${color4}: ${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${image ~/conky/monochrome/images/common/[=image.secondaryColor]-panel-album-placeholder.png -p [=4+8],[=19+8]}\
${else}\
<@panel.panel x=0 y=y width=width height=top+body/>
${voffset 2}${alignc}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}} ${color}: ${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
${image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-album-placeholder.png -p [=4+8],[=19+8]}\
${color}\
${endif}\
${lua_parse load_image ${cat /tmp/conky/musicplayer.albumArtPath} 181x181 4 [=(top)?c]}\
<#assign y += y + top + body + gap>
${lua increment_offsets 0 [=y]}\
${voffset 193}\
${else}\
# :::::::: no album art available
<#assign y = 0>
${image ~/conky/monochrome/images/common/[=image.primaryColor]-rhythmbox.png -p 0,[=y]}\
<@panel.panel x=55 y=33 width=width-55 height=38 isDark=true/>
${voffset 36}${offset 61}${color1}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}}
${voffset 4}${offset 61}${color}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
<#assign y += 71 + gap>
${lua increment_offsets 0 [=y]}\
${voffset 9}\
${endif}\
# :::::::: track details
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
${lua increment_offsets 0 [=height - 7]}\<#-- edges are 7x7 px -->
${voffset 3}${offset 5}${color1}title${goto 50}${color}${cat /tmp/conky/musicplayer.title}
${if_match "${lua get album ${cat /tmp/conky/musicplayer.album}}" != "unknown album"}\
${voffset 3}${offset 5}${color1}album${goto 50}${color}${lua get album}${lua increment_offsets 0 16}
${endif}\
${if_match "${lua get artist ${cat /tmp/conky/musicplayer.artist}}" != "unknown artist"}\
${voffset 3}${offset 5}${color1}artist${goto 50}${color}${lua get artist}${lua increment_offsets 0 16}
${endif}\
${if_match "${lua get genre ${cat /tmp/conky/musicplayer.genre}}" != "unknown genre"}\
${voffset 3}${offset 5}${color1}genre${goto 50}${color}${lua get genre}${lua increment_offsets 0 16}
${endif}\
${voffset -7}\
# ------  vertical table image bottom ------
<@panel.verticalMenuBottom x=0 y=0 header=header body=width-header isFixed=false/>
# -------- end of table image bottom -------
${endif}\
]];
