<#import "/lib/panel-round.ftl" as panel>
-- n.b. this conky requires the music-player java app to be running in the background
--      it generates input files under /tmp/conky/musicplayer.* which this conky will read

conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_right',  -- top|middle|bottom_left|right
  gap_x = 3,
  <#if system == "desktop"><#assign yOffset = 162><#else><#assign yOffset = 0></#if>
  gap_y = [=3+yOffset],

  -- window settings
  <#assign width = 169>
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
  own_window_argb_visual = true,    -- turn on transparency
  own_window_argb_value = 255,      -- range from 0 (transparent) to 255 (opaque)
  
  -- miscellanous settings
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
# the UI of this conky has four states: song with album art
#                                       song with no album art
#                                       no music player is running
#                                       dependent java dbus listener application is not running
<#assign iconWidth = 38,       <#-- icon is a square -->
         iconheight = 38,
         gap = 3>              <#-- empty space between panels -->
${if_existing /tmp/conky/musicplayer.name}\
# :::: no music player available
${if_existing /tmp/conky/musicplayer.name Nameless}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sound-wave-small.png -p 0,0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight/>
${voffset 5}${offset 45}${color1}now playing
${voffset 2}${offset 45}${color}no player running
${else}\
# :::: music player available
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-sound-wave-small.png -p 0,0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight color=image.secondaryColor/>
${voffset 5}${goto 50}${color3}${cat /tmp/conky/musicplayer.name}
${voffset 2}${goto 50}${color4}${cat /tmp/conky/musicplayer.playbackStatus}${voffset [= 5 + gap]}
${else}\
${image ~/conky/monochrome/images/[=conky]/[=image.primaryColor]-sound-wave-small.png -p 0,0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight/>
${voffset 5}${goto 50}${color1}${cat /tmp/conky/musicplayer.name}
${voffset 2}${goto 50}${color}${cat /tmp/conky/musicplayer.playbackStatus}${voffset [= 5 + gap]}
${endif}\
${lua increment_offsets 0 [=iconheight + gap]}\
# :::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
<#assign innerBorder = 2>   <#-- border width between the window and the album art -->
<@panel.panel x=0 y=0 width=width height=width isFixed=false/>
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-panel-album-placeholder.png [=innerBorder] 0}\
${lua_parse load_image ${cat /tmp/conky/musicplayer.albumArtPath} [=width-innerBorder*2]x[=width-innerBorder*2] [=innerBorder] [=innerBorder]}\
${voffset [=width + gap]}${lua increment_offsets 0 [=width + gap]}\
${endif}\
# :::: track details
# panel expands based on the track metadata fields available
# the position of the bottom edge images is shifted down 16px for each field
<#-- 3 px top border | 16 px text | 2 px bottom border -->
# -------  vertical table image top -------
<#assign header = 45, height = 21>
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
${voffset -9}\
# ------  vertical table image bottom ------
<@panel.verticalMenuBottom x=0 y=0 header=header body=width-header isFixed=false/>
# -------- end of table image bottom -------
${endif}\
${else}\
${image ~/conky/monochrome/images/[=conky]/[=image.secondaryColor]-sound-wave-small.png -p 0,0}\
<@panel.noLeftEdgePanel x=0+iconWidth y=0 width=width-iconWidth height=iconheight isDark=true color=image.secondaryColor/>
${voffset 5}${offset 45}${color3}now playing
${voffset 2}${offset 45}${color4}input files missing
${endif}\
]];
