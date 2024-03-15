--[[
:::::: functions for drawing menus with dynamic sizes ::::::
methods to allow a conky client to manipulate x,y positions of images or text at runtime.

> how to use
  - requires the common.lua library to be imported by conky
  - the method conky_reset_state() must be invoked by the conky's 'lua_draw_hook_pre' setting

> library features

1) dynamically change the position of an image by taking into account runtime x,y offsets to alter
   an image's original x,y coordinates
   
   see conky_add_offsets()
       conky_draw_image()

2) dynamically update ${goto x} or ${offset x} variables with an offset at runtime
                                   ${voffset y}

   see conky_add_offsets()
       conky_add_x_offset()
       conky_add_y_offset()
]]

-- resets the global variables, such as the x,y offsets
-- this method must be invoked by conky on each refresh cycle (use the lua_draw_hook_pre setting)
function conky_reset_state()
  vars["xOffset"] = 0
  vars["yOffset"] = 0
  vars["totalLines"] = 1000   -- total lines to print for dynamic text, ie. files read within the conky
  return ''
end


--[[
adds an offset to the x & y coordinates
the client can then call the following methods which will take these offsets into account:

  - conky_draw_image(..)
  - conky_add_x_offset(..)
  - conky_add_y_offset(..)

on each conky session the offsets are reset to 0 (see the conky_reset_state() method)
this methoed is cumulative, ie. the numbers are increased each times the method is called
]]
function conky_add_offsets(xOffset, yOffset)
  local x = vars["xOffset"] or 0
  x = x + tonumber(xOffset)
  vars["xOffset"] = x

  local y = vars["yOffset"] or 0
  y = y + tonumber(yOffset)
  vars["yOffset"] = y
  
  return ''
end

--[[
add the 'x' offset to the given conky variable argument
call this method with the ${goto} or ${offset} conky variables
]]
function conky_add_x_offset(variable, x)
  local xOffset = vars["xOffset"] or 0
  return "${" .. variable .. " " .. tonumber(x) + xOffset .. "}"
end

--[[
add the 'y' offset to the given conky variable argument
call this method with the ${voffset} conky variable
]]
function conky_add_y_offset(variable, y)
  local yOffset = vars["yOffset"] or 0
  return "${" .. variable .. " " .. tonumber(y) + yOffset .. "}"
end

--[[
creates a conky image variable string at the x,y coordinate position after any available offsets are applied,
ex. calling conky_draw_image(/directory/image.jpg, 0, 50)
    with the current offsets being x = 10, y = 50
    would yield the image variable: ${image /directory/image.jpg -p 10,100}

arguments:
    path  path to image file
    x     image x coordinate
    y     image y coordinate

@see the 'conky_add_offsets()' method
]]
function conky_draw_image(path, x, y)
  return build_image_variable(path, tonumber(x) + vars["xOffset"], tonumber(y) + vars["yOffset"])
end


function conky_set_total_lines(totalLines)
  vars["totalLines"] = tonumber(totalLines)
  return ''
end


function conky_decrease_total_lines(lines)
  vars["totalLines"] = vars["totalLines"] - tonumber(lines);
  return ''
end


function stringToBoolean(s)
  local map={ ["true"]=true, ["false"]=false }
  return map[s]
end


--[[ creates a conky image variable string, ex. ${image /directory/image.jpg -p 0,0}

arguments:
    path  path to image file
    x     image x coordinate
    y     image y coordinate
]]
function build_image_variable(path, x, y)
  return "${image " .. path .. " -p " .. x .. "," .. y .. "}"
end


function conky_calculate_voffset(file, max)
  local linesRead = lines(vars[file])
  max = tonumber(max)
  linesRead = (linesRead < max) and linesRead or max
  local emptyLines = max - linesRead
  local voffset = emptyLines * 16
  conky_add_offsets(0, voffset)

  return ''
end

-- returns the number of lines in a string
function lines(string)
  local _, lines = string.gsub(string, "\n", "\n")
  return lines + 1    -- last line in the text file won't have a new line so we need to account for it
end


--[[
lua improved version of the conky ${head} variable, it provides:

- no line cap
- content of the file can be parsed if invoked with ${lua_parse}, same effect as using ${catp}
  so you can insert things like ${color red}hi!${color} in your file and have it correctly parsed by conky
- if the text contains a new line on its last line, it will be removed

::: table/panel implications
usage of this method implies that a panel or table is being populated by reading the contents of a file.
in order to align the text in a panel properly:

  - the 'y' offset is expected to be at the start of the panel
  - lowercase text is expected to begin 10 pixels from the top of the panel
  - the 'y' offset is updated to the pixel where the bottom of the panel should be
    this will yield a 7 pixels border between the bottom of the text and the panel edge

arguments:
    filepath  absolute path to the file
    max       [optional] maximun number of lines to print
    x         [optional] ${offset}  to apply to every line of text, default is 5 pixels
    y         [optional] ${voffset} to apply to every line of text, default is 3 pixels
]]
function conky_head(filepath, max, x, y)
  conky_read_file(filepath)
  return conky_head_mem(filepath, max, x, y)
end

function conky_head_mem(filepath, max, x, y)
  -- apply sensible defaults
  max = (max ~= nil) and tonumber(max) or 30
  max = (vars["totalLines"] > max) and max or vars["totalLines"]
  x = (x ~= nil) and tonumber(x) or 5
  y = (y ~= nil) and tonumber(y) or 3
  
  local text, lines = cutText(vars[filepath], max)
  conky_decrease_total_lines(lines)
  
  if x ~=nil then
    x = x + vars["xOffset"]
    text = '${voffset ' .. y .. '}' .. '${offset ' .. x .. '}' .. text
    text = string.gsub(text, "\n", "\n" .. '${voffset ' .. y .. '}' .. '${offset ' .. x .. '}')
  end
  
  adjust_y_offset_for_bottom_edges(lines)
  return text
end

-- reads a file into memory
function conky_read_file(filepath)
  vars[filepath] = conky_parse('${cat ' .. filepath .. '}')
  return ''
end

-- trims the number of lines in the string up to the desired amount
function cutText(text, max)
  local linesRead, position = 0, 0, 0
  
  while linesRead < max do
    linesRead = linesRead + 1
    position = string.find(text, "\n", position+1)
    if position == nil then break end
  end
  
  text = string.sub(text, 1, position)
  text = string.gsub(text, '\n$', '')     -- remove last new line (if any)
  
  return text, linesRead
end

--[[
adjusts the y offset in order to draw a menu's bottom edges based on the number of lines read from a file

arguments:
    numLines   number of lines
]]
function adjust_y_offset_for_bottom_edges(numLines)
  -- TODO this math has only been tested for text using a ${voffset 3}, improve it to handle any text voffset
  lineMultiplier = 16
  numLines = (numLines > 0) and numLines or 0
  vars["yOffset"] = vars["yOffset"] + (numLines * lineMultiplier) + 7

  return ''
end
