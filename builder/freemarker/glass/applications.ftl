<#import "/lib/menu-square.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/panel.lua ~/conky/monochrome/musicPlayer.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'top_left',  -- top|middle|bottom_left|right
  gap_x = 123,
  gap_y = 427,

  -- window settings
  minimum_width = 245,      -- conky will add an extra pixel to this  
  maximum_width = 245,
  minimum_height = 1150,
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
  default_color = '[=colors.systemText]', -- regular text
  color1 = '[=colors.systemLabels]',
  color2 = '[=colors.highlight]',        -- highlight important packages
  color3 = '[=colors.secondary.labels]',         -- secondary menu labels
  color4 = '[=colors.secondary.text]'         -- secondary menu text
};

conky.text = [[
<#assign totalLines = 61><#-- total lines is calculated for the scenario where no active torrents (0) are running,
so the package update list will take all the space.  If torrents are running, each use case will start reducing
the total lines available in order to account for the addtional menu space plus menu spacing -->
${lua set_total_lines [=totalLines]}\
# decrease the total number of lines depending on the window size of the music player conky placed below this conky
${lua decrease_music_player_lines 1 3 13}\
<#assign y = 0,
         header = 75,
         height = 87,
         gap = 3>     <#-- empty space between menus -->
<@menu.verticalTable x=0 y=y header=header body=159-header height=height/>
<#assign y += height + gap>
${lua increment_offsets 0 [= height + gap]}\
<#assign inputDir = "/tmp/conky/"
         peersFile = inputDir + "transmission.peers.raw",
         seedingFile = inputDir + "transmission.torrents.up"
         downloadingFile = inputDir + "transmission.torrents.down",
         idleFile = inputDir + "transmission.idle",
         activeTorrentsFile = inputDir + "transmission.active">
${voffset [=2 + gap]}${offset 5}${color1}swarm${goto 81}${color}${if_existing [=peersFile]}${lua pad ${lua get peers ${lines [=peersFile]}}} peers${else}file missing${endif}
${voffset 3}${offset 5}${color1}active${goto 81}${color}${if_existing [=activeTorrentsFile]}${lua pad ${lua get active ${lines [=activeTorrentsFile]}}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}seeding${goto 81}${color}${if_existing [=seedingFile]}${lua pad ${lines [=seedingFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}downloading${goto 81}${color}${if_existing [=downloadingFile]}${lua pad ${lines [=downloadingFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}idle${goto 81}${color}${if_existing [=idleFile]}${lua pad ${lines [=idleFile]}} torrents${else}file missing${endif}
${voffset [= 7 + gap]}\
# :::::::::::: active torrents
${if_existing [=activeTorrentsFile]}\
${if_match ${lua get active} > 0}\
${lua decrease_total_lines 1}\
<#assign header = 19, width = 159, speedCol = 39, colGap = 1>
<@menu.table x=0 y=y widths=[width, speedCol, speedCol] gap=colGap header=header highlight=[2]/>
${lua increment_offsets 0 [=header]}\
${offset 5}${color1}active torrents${goto 184}${color3}up${offset 16}${color1}down${voffset 3}
${color}${lua_parse head [=activeTorrentsFile] [=totalLines - 5]}${lua increase_y_offset [=activeTorrentsFile]}${voffset [= 7 + gap]}
${lua increment_offsets 0 -3}\<#-- hack: text is not 10px from its top edge, you must fix the spacing with the music player conky again :S -->
${lua_parse draw_image ~/conky/monochrome/images/common/menu-blank.png 0 0}${lua_parse draw_image ~/conky/monochrome/images/common/menu-blank.png [=width+colGap] 0}\
# ------- table | 3 column(s) | bottom    -------
${lua increment_offsets 0 [=gap]}\
${endif}\
${else}\
<#assign body = 36>
${lua decrease_total_lines 1}\
<@menu.panel x=0 y=y width=width height=body/>
${lua increment_offsets 0 [=body + gap]}\
${offset 5}${color}active torrents input
${voffset 3}${offset 5}file is missing
${voffset [= 7 + gap]}\
${endif}\
# ::::::::::::::::: package updates :::::::::::::::::
${if_existing /tmp/conky/dnf.packages.formatted}\
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted", 
         header = 27,
         height = 22>
<@menu.verticalTable x=0 y=0 header=header body=159-header height=height isFixed=false/>
${lua increment_offsets 0 [= height + gap]}\
${voffset 2}${offset 5}${color1}dnf${goto 33}${color}${lines [=packagesFile]} package updates
${voffset [= 7 + gap]}\
<#assign header = 19, versionCol = 51>
<@menu.table x=0 y=0 widths=[width, versionCol] gap=colGap header=header isFixed=false/>
${lua increment_offsets 0 [=header]}\
${offset 5}${color1}package${goto 166}version${voffset 3}
${color}${lua_parse head [=packagesFile] [=totalLines]}${lua increase_y_offset [=packagesFile]}
${lua increment_offsets 0 -3}\<#-- hack: text is not 10px from its top edge, you must fix the spacing with the music player conky again :S -->
${lua_parse draw_image ~/conky/monochrome/images/common/menu-blank.png 0 0}\
# ------- table | 2 column(s) | bottom -------
${endif}\
]]
