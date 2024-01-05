<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 2,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 142,
  gap_y = 120,

  -- window settings
  <#if system == "desktop"><#assign width = 189><#else><#assign width = 169></#if>
  minimum_width = [=width],      -- conky will add an extra pixel to this
  maximum_width = [=width],
  minimum_height = 22,      -- conky will add an extra pixel to this height
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
  default_color = '[=colors.menuText]',  -- regular text
  color1 = '[=colors.labels]'
  
  -- n.b. this conky requires the music-player java app to be running in the background
  --      it generates input files under /tmp/conky/musicplayer.* which this conky will read
};

conky.text = [[
# the UI of this conky changes as per one of these states: no music player is running
#                                                          song with album art
#                                                          song with no album art
# :::: no player available
${if_existing /tmp/conky/musicplayer.name Nameless}\
<#assign y = 0>
${image ~/conky/monochrome/images/common/[=image.primaryColor]-rhythmbox.png -p 0,[=y]}\
<@menu.menu x=58 y=33 width=111 height=38/>
${voffset 36}${offset 63}${color1}now playing
${voffset 4}${offset 63}${color}no player running${voffset 5}
${else}\
# :::: album art
${if_existing /tmp/conky/musicplayer.albumArtPath}\
<#if system == "desktop"><#assign innerBorder = 4><#else><#assign innerBorder = 2></#if><#-- border width between the window and the album art -->
<#assign header = 19,   <#-- menu header -->
         body = width - innerBorder,    <#-- size of the album art window without the header and no top border -->
         gap = 5>       <#-- empty space between windows -->
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
<@menu.menu x=0 y=y width=width height=header+body isDark=true/>
${color1}\
${else}\
<@menu.menu x=0 y=y width=width height=header+body/>
${color}\
${endif}\
${voffset 2}${alignc}${lua_parse truncate_string ${cat /tmp/conky/musicplayer.name}} ${color}: ${lua_parse truncate_string ${cat /tmp/conky/musicplayer.playbackStatus}}
<#if system == "desktop"><#assign offset = 16><#else><#assign offset = 0></#if><#-- offset for pc due to placeholder image being smaller for the laptop version -->
${image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-album-placeholder.png -p [=innerBorder + offset],[=header + offset]}\
${lua_parse album_art_image ${cat /tmp/conky/musicplayer.albumArtPath} [=width-innerBorder*2]x[=width-innerBorder*2] [=innerBorder],[=(header)?c]}\
<#assign y += header + body + gap>
${voffset [=body + 4 + gap]}${lua add_offsets 0 [=y]}\
${endif}\
# :::: track details
# menu expands based on the track metadata fields available
# the position of the bottom edge images is shifted down 16px for each field
<#-- 3 px top border | 16 px text | 2 px bottom border -->
# -------  vertical table image top -------
<#assign header = 45, height = 21>
<@menu.verticalMenuHeader x=0 y=0 header=header body=width-header fixed=false/>
${if_existing /tmp/conky/musicplayer.playbackStatus Playing}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-sound-wave.png [=width-53-7] 0}\
${endif}\
# --------- end of table image top ---------
<#assign y = height - 7><#-- edges are 7x7 px -->
${lua add_offsets 0 [=y]}\
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
