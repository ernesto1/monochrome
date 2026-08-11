<#if device == "desktop">
conky.config = {
  update_interval = 1.5,  -- update interval in seconds
  xinerama_head = 0,      -- for multi monitor setups, select monitor to run on: 0,1,2
  double_buffer = false,  -- use double buffering (reduces flicker, may not work for everyone)

  -- window alignment
  alignment = 'middle_left',     -- top|middle|bottom_left|middle|right
  gap_x = 0,                  -- same as passing -x at command line
  gap_y = 0,

  -- window settings
  minimum_width = 202,      -- panel width should be 1px less than the sidebar
  minimum_height = 60,
  own_window = true,
  own_window_type = 'panel',    -- values: desktop (background), panel (bar)

  -- transparency configuration
  draw_blended = false,
  own_window_transparent = true,
  own_window_argb_visual = true,  -- turn on transparency
  own_window_argb_value = 255,    -- range from 0 (transparent) to 255 (opaque)

  -- window borders
  draw_borders = false,     -- draw borders around the conky window
  border_width = 0,         -- width of border window in pixels
  stippled_borders = 0,     -- border stippling (dashing) in pixels
  border_inner_margin = 0,  -- margin between the border and text in pixels
  border_outer_margin = 0,  -- margin between the border and the edge of the window in pixels

};

conky.text = [[
# empty conky
# used to create the panel effect (with no 1px gap) between the sidebar conky and a maximized window
]]
</#if>
