--[[
:::::: functions for drawing panels with dynamic sizes ::::::

> how to use
  requires the common.lua library to be imported by conky

> library features

  1) dynamically drawing a panel's bottom edges based on the number of lines read from a file
]]

--[[
Increases the y offset by the number of pixels that correspond to the number of lines read from the given file.
This would allow a conky to draw a panel's bottom edges based on the number of lines read from a file.

::: table/panel implications
Usage of this method implies that a panel or table is being populated by reading the contents of a file.
Panels are expected to be populated with text with a 10px top border and a 7px bottom border.

In order to align the text in the panel properly:

  - the 'y' offset is expected to be at the start of the panel, see conky_increment_offsets(..)
  - lowercase text is expected to begin 10 pixels from the top of the panel
  - the 'y' offset is updated to the pixel where the bottom of the panel should be
    this will yield a 7 pixels border between the bottom of the text and the panel edge

arguments:
  filepath   absolute path to the file

requires:
  the file should have previously been read with the conky_head(..) or conky_paginate(..) method
]]
function conky_increase_y_offset(filepath)
  if (vars[filepath .. ".lines"] == nil) then
    print("file '" .. filepath .. "' has not been read yet")
    return ''
  end

  -- TODO this math has only been tested for text using a ${voffset 3}, improve it to handle any text voffset
  local lineMultiplier = 16
  conky_increment_offsets(0, (vars[filepath .. ".lines"] * lineMultiplier) + 7)

  return ''
end


function conky_calculate_voffset(filepath, max)
  local linesRead = lines(vars[filepath])
  max = tonumber(max)
  linesRead = (linesRead < max) and linesRead or max
  local emptyLines = max - linesRead
  local voffset = emptyLines * 16
  conky_increment_offsets(0, voffset)

  return ''
end

-- returns the number of lines in a string
function lines(string)
  local _, lines = string.gsub(string, "\n", "\n")
  return lines + 1    -- last line in the text file won't have a new line so we need to account for it
end
