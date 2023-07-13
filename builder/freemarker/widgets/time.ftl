conky.config = {
  update_interval = 1,  -- update interval in seconds
  xinerama_head = 0,    -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = true, -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'bottom_left',  -- top|middle|bottom_left|right
  gap_x = 65,
  gap_y = 6,

  -- window settings
  minimum_width = 202,
  own_window = true,
  own_window_type = 'desktop',  -- values: desktop (background), panel (bar)
  own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',

  -- transparency configuration
  own_window_transparent = false,
  own_window_argb_visual = false,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)
  own_window_colour = '[=colors.windowColor]',

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 1,         -- width of border window in pixels
  stippled_borders = 0,     -- border stippling (dashing) in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels

  -- font settings
  use_xft = true,
  xftalpha = 1,
  draw_shades = false,   -- black shadow on text (not good if text is black)
  draw_outline = false, -- black outline around text (not good if text is black)
  default_color = 'white'
};

conky.text = [[
#  ${time} uses the same parsing as 'strftime', see the man page for available options
#  %I hour in 12 hour format
#  %H hour in 24 hour format
#  %a abbreviated day
#  %A day 
#  %B month (full)
#  %d day of the month (1-31)
${offset 13}${color}${font Promenade de la Croisette:size=40}${time %I}${font Promenade de la Croisette:size=37}:${time %M}${voffset -22}${goto 62}${color}${font URW Gothic:size=12}${time %A}
${voffset 3}${goto 62}${time %B %d %Y}${voffset -5}
]];
