--[[ 
:::::: common functions ::::::

> how to use
  the method conky_reset_state() must be invoked by the conky's 'lua_draw_hook_pre' setting

> library features

  1) dynamically change the position of an image by taking into account runtime x,y offsets to alter
     an image's original x,y coordinates
     
     see conky_increment_offsets()
         conky_draw_image()

  2) dynamically update ${goto x} or ${offset x} variables with an offset at runtime
                                     ${voffset y}

     see conky_increment_offsets()
         conky_add_x_offset()
         conky_add_y_offset()

  3) ...
]]

-- table to hold global variables
vars = {}

-- resets the global variables, such as the x,y offsets
-- this method must be invoked by conky on each refresh cycle (use the lua_draw_hook_pre setting)
function conky_reset_state()
  vars["xOffset"] = 0
  vars["yOffset"] = 0
  vars["totalLines"] = 1000   -- total lines to print for dynamic text, ie. files read within the conky
  return ''
end

--[[
parses the given conky expression and stores its value for future use
if the 'expression' is not provided, the current value stored for the variable is returned

arguments:
    name          name of the variable
    expression    conky variable to parse (optional argument)
]]
function conky_get(name, expression)
  if expression ~= nil then vars[name] = conky_parse(expression) end
  if vars[name] == nil then print("variable '" .. name .. "' does not exist") end

  return vars[name]
end

--[[
store a variable in memory

arguments:
    name     name of the variable
    value    value stored as a string
]]
function conky_set(name, value)
  vars[name] = value
  return ''
end

--[[
Increments the current offset for the x & y coordinates.
The client can then call the following methods which will take these offsets into account:

  - conky_draw_image(..)
  - conky_add_x_offset(..)
  - conky_add_y_offset(..)

This method is cumulative, ie. the numbers are increased each times the method is called.
On each conky session the offsets are meant to be reset to 0 (see the conky_reset_state() method).
]]
function conky_increment_offsets(xOffset, yOffset)
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
    path        path to image file
    x           image x coordinate
    y           image y coordinate
    dimensions  [optional] image dimensions in WxH format, ex. 200x200

@see the 'conky_increment_offsets(..)' method
]]
function conky_draw_image(path, x, y, dimensions)
  dimensions = (dimensions ~= nil) and " -s " .. dimensions or ""
  return "${image " .. path .. " -p " .. tonumber(x) + vars["xOffset"] .. "," .. tonumber(y) + vars["yOffset"] .. dimensions .. "}"
end


function conky_set_total_lines(totalLines)
  vars["totalLines"] = tonumber(totalLines)
  return ''
end


function conky_decrease_total_lines(lines)
  vars["totalLines"] = vars["totalLines"] - tonumber(lines);
  return ''
end


function conky_pad(expression)
    local text = conky_parse(expression)
    return string.format('%3s', text)
end


function stringToBoolean(s)
  local map={ ["true"]=true, ["false"]=false }
  return map[s]
end

--[[ 
prints the value provided by the conky variable after a applying a 'threshold' check to it.
If the threshhold is breached, the conky color variable is used to highlight the text, ex:

  ${lua_parse print_resource_usage ${cpu cpu0} 90 ${color3}}
  would yield: 87
               ${color3}96

use this method when you want to higlight high usage of a resource

arguments:
      expression      conky variable to parse, must yield a numeric value (no units)
      threshold       threshold to compare against
      colorVariable   conky color variable to print the expression under if the threshold is exceeded, ex. ${color4}
]]
function conky_print_resource_usage(expression, threshold, colorVariable)
  local value = tonumber(conky_parse(expression))
  local threshold = tonumber(threshold)
  local s = (value < threshold) and value or colorVariable .. value
  
  return s
end

--[[ 
generates an image conky variable from a conky expression which yields an image file path in the filesystem, 
ex. if the image path is in a file that must be read; you can use this method to extract said path
by using the conky ${cat} variable on the file

arguments:
  expression    conky variable to parse, must yield an image file path, ex. ${cat /dir/somefile.txt}
  dimensions    image dimensions in WxH format, ex. 200x200
  x             image x coordinate
  y             image y coordinate
returns:
  ${image picture.jpg -s 100x100 -p 0,0}
]]
function conky_load_image(expression, dimensions, x, y)
  local path = conky_parse(expression)
  return conky_draw_image(path, x, y, dimensions)
end

--[[ 
evaluates a conky variable (ex. ${cat someFile}) and prints its value;
if the character limit is breached, the string is truncated

arguments:
  expression    conky variable to parse
  charLimit     [optional] maximun number of characters to print, use to truncate text if too long
                default is 20 characters
]]
function conky_truncate_string(expression, charLimit)  
  local text = conky_parse(expression)
  -- if the expression evaluates to nothing use a default error message
  text = (text ~= '') and text or "empty conky expression"
  charLimit = tonumber(charLimit) or 20
  
  return string.sub(text,1,charLimit)
end

--[[
lua improved version of the conky ${head} variable, it provides:

- no line cap
- content of the file can be parsed if invoked with ${lua_parse}, same effect as using ${catp}
  so you can insert things like ${color red}hi!${color} in your file and have it correctly parsed by conky
- if the text contains a new line on its last line, it will be removed

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

-- reads a file into memory
function conky_read_file(filepath)
  vars[filepath] = conky_parse('${cat ' .. filepath .. '}')
  return ''
end


function conky_head_mem(filepath, max, x, y)
  -- apply sensible defaults
  max = (max ~= nil) and tonumber(max) or 30
  
  if vars["totalLines"] ~= nil then     -- global variable use by the menu.lua library
    max = (max < vars["totalLines"]) and max or vars["totalLines"]
  end
  
  x = (x ~= nil) and tonumber(x) or 5
  y = (y ~= nil) and tonumber(y) or 3
  
  local text, lines = cutText(vars[filepath], max)
  conky_decrease_total_lines(lines)
  
  if x ~=nil then
    x = x + vars["xOffset"]
    text = '${voffset ' .. y .. '}' .. '${offset ' .. x .. '}' .. text
    text = string.gsub(text, "\n", "\n" .. '${voffset ' .. y .. '}' .. '${offset ' .. x .. '}')
  end
  
  vars[filepath .. ".lines"] = lines
  
  return text
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
