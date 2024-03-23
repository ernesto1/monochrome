<#import "/lib/menu-round.ftl" as menu>
conky.config = {
  lua_load = '~/conky/monochrome/common.lua ~/conky/monochrome/menu.lua ~/conky/monochrome/musicPlayer.lua',
  lua_draw_hook_pre = 'reset_state',
  
  update_interval = 3,    -- update interval in seconds
  xinerama_head = 1,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true,   -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',  -- top|middle|bottom_left|right
  gap_x = 142,
  gap_y = -175,

  -- window settings
  <#assign width = 169>
  minimum_width = [=width],      -- conky will add an extra pixel to this  
  maximum_width = [=width],
  <#if system == "desktop"><#assign windowHeight=1317><#else><#assign windowHeight=20></#if>
  minimum_height = [=windowHeight?c],
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
  default_color = '[=colors.menuText]', -- regular text
  color1 = '[=colors.labels]',
  color2 = '[=colors.highlight]',        -- highlight important packages
  color3 = '[=colors.secondary.text]'         -- error text (secondary color menu)
};

conky.text = [[
<#if system == "desktop"><#assign totalLines = 75><#else><#assign totalLines = 48></#if>
${lua set_total_lines [=totalLines]}\
# decrease the total number of lines depending on the window size of the music player conky placed below this conky
${lua decrease_music_player_lines 3 4 16}\
${voffset 2}\
<#if system == "desktop">
# :::::::::::: transmission bittorrent client
# this panel requires:
# - the 'remote control' feature enabled in the transmission bittorrent client: edit > preferences > remote
# - the transmission.bash script running in the background
<#assign y = 0,
         header = 75, <#-- menu header -->
         body = 71,   <#-- menu window without the header -->
         gap = 5>     <#-- empty space between windows -->
<@menu.verticalTable x=0 y=y header=header body=width-header height=body isFixed=true/>
<#assign y += body + gap>
${lua add_offsets 0 [=body + gap]}\
<#assign inputDir = "/tmp/conky"
         peersFile = inputDir + "/transmission.peers",
         seedingFile = inputDir + "/transmission.seeding"
         downloadingFile = inputDir + "/transmission.downloading",
         idleFile = inputDir + "/transmission.idle",
         activeTorrentsFile = inputDir + "/transmission.active">
${voffset 3}${offset 5}${color1}swarm${goto 81}${color}${if_existing [=peersFile]}${lua pad ${lua get peers ${lines [=peersFile]}}} peers${else}file missing${endif}
${voffset 3}${offset 5}${color1}seeding${goto 81}${color}${if_existing [=seedingFile]}${lua pad ${lines [=seedingFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}downloading${goto 81}${color}${if_existing [=downloadingFile]}${lua pad ${lines [=downloadingFile]}} torrents${else}file missing${endif}
${voffset 3}${offset 5}${color1}idle${goto 81}${color}${if_existing [=idleFile]}${lua pad ${lines [=idleFile]}} torrents${else}file missing${endif}
${voffset [= 7 + gap]}\
# :::::::::::: active torrents
${if_existing [=activeTorrentsFile]}\
${if_match ${lua get activeNum ${lines [=activeTorrentsFile]}} > 0}\
${lua decrease_total_lines 1}\
<#assign header = 19>
<@menu.table x=0 y=0 width=width header=header isFixed=false/>
${lua add_offsets 0 [=header]}\
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-peers.png [=((width-112)/2)?round] 22}\
${alignc}${color1}active torrents ${color}(${color}${lua get activeNum}${color})${color1}${voffset 6}
${color}${lua_parse head [=activeTorrentsFile] [=totalLines-5]}${lua increase_y_offset [=activeTorrentsFile]}${voffset [=7 + gap]}
<@menu.panelBottomCorners x=0 y=0 width=width isFixed=false/>
${lua add_offsets 0 [=gap]}\
${else}\
<#assign body = 20>
<@menu.panel x=0 y=71 + gap width=width height=body color=image.secondaryColor/>
${lua add_offsets 0 [=body + gap]}${lua decrease_total_lines 1}\
${alignc}${color3}no active torrents${voffset [=7 + gap]}
${endif}\
${else}\
<#assign body = 36>
<@menu.panel x=0 y=0 width=width height=body isFixed=false color=image.secondaryColor/>
${lua add_offsets 0 [=body + gap]}${lua decrease_total_lines 2}\
${offset 5}${alignc}${color3}active torrents input file
${voffset 3}${alignc}is missing${voffset [= 7 + gap]}
${endif}\
</#if>
# :::::::::::: package updates
<#assign packagesFile = "/tmp/conky/dnf.packages.formatted",
         header = 19>
${if_existing [=packagesFile]}\
<@menu.table x=0 y=0 width=width header=header isFixed=false/>
${lua add_offsets 0 [=header]}\
# optional dnf branding, can be removed or won't matter if the image does not exist
${lua_parse draw_image ~/conky/monochrome/images/common/[=image.primaryColor]-menu-dnf.png 111 2}\
${offset 5}${color1}package${alignr 4}version${voffset 6}
${color}${lua_parse head [=packagesFile] [=totalLines]}${lua increase_y_offset [=packagesFile]}${voffset 5}
<@menu.panelBottomCorners x=0 y=0 width=width isFixed=false/>
${endif}\
]]
