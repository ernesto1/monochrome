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

function conky_compute(name, expression)
  if expression ~= nil then vars[name] = conky_parse(expression) end
  if vars[name] == nil then print("variable '" .. name .. "' does not exist") end
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

--[[
pads a string with spaces to the desired amount of characters

arguments:
  expression  conky expression to evaluate which yields the string to pad, ex. ${cat valueInsideThisFile}
  n           number of characters to pad to
]]
function conky_pad(expression, n)
  n = (n ~= nil) and n or 3
  local text = conky_parse(expression)
  return string.format('%' .. n .. 's', text)
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
      colorVariable   conky color variable to use if the threshold is exceeded, ex. ${color4}
]]
function conky_print_resource_usage(expression, threshold, colorVariable)
  local value = tonumber(conky_parse(expression))
  local threshold = tonumber(threshold)
  local s = (value < threshold) and value or colorVariable .. value
  
  return s
end

function conky_print_max_resource_usage(threshold, colorVariable, ...)
  local threshold = tonumber(threshold)
  local max = 0
  local arg = {...}

  for i = 1, select("#",...) do
    local value =  tonumber(conky_parse(arg[i]))
    max = (value > max) and value or max
  end
  
  local s = (max < threshold) and max or colorVariable .. max

  return s
end

function conky_get_max_resource_usage(...)
  local max = 0
  local arg = {...}

  for i = 1, select("#",...) do
    local value =  tonumber(conky_parse(arg[i]))
    max = (value > max) and value or max
  end
  
  return max
end

function conky_get_usage_percentage(max, var)
  if vars[var] > max then
    print("get_usage_percentage: max value of " .. max .. " is lower than actual " .. vars[var])
    return 100
  end
  
  perc = math.floor(((vars[var] / max) * 100) + 0.5)    -- lua does not provide a rounding function
  return perc
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
    max       [optional] maximun number of lines to print, default is 25 lines
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

--[[
head method similar to the conky_head(..) function except that the file has already been read by a prior
invocation of the conky_read_file(..) method

meant for cases where the file needs to be read ahead of time in order to make ui decisions based
on the number of lines in the file, the file text is then displayed later on in the conky

arguments:
    filepath  absolute path to the file which has already been read
    max       [optional] maximun number of lines to print, default is 25 lines
    x         [optional] ${offset}  to apply to every line of text, default is 5 pixels
    y         [optional] ${voffset} to apply to every line of text, default is 3 pixels
    startLine [optional] starting line to begin printing the 'max' amount of lines, default is 1 (the first line)
]]
function conky_head_mem(filepath, max, x, y, startLine)
  x = (x ~= nil) and tonumber(x) or 5
  y = (y ~= nil) and tonumber(y) or 3
  max = (max ~= nil) and tonumber(max) or 25
  
  -- adjust the 'max' if the global total conky lines is smaller
  if vars["totalLines"] ~= nil then
    max = (max < vars["totalLines"]) and max or vars["totalLines"]
  end
  
  local text, linesRead = cutText(vars[filepath], max, startLine)
  vars[filepath .. ".lines"] = linesRead
  conky_decrease_total_lines(linesRead)
  x = x + vars["xOffset"]
  text = '${voffset ' .. y .. '}' .. '${offset ' .. x .. '}' .. text
  text = string.gsub(text, "\n", "\n" .. '${voffset ' .. y .. '}' .. '${offset ' .. x .. '}')
  
  return text, linesRead
end

--[[
trims the number of lines in the string up to the desired amount

arguments:
    text      string to parse
    max       maximun number of lines to print
    startLine [optional] line to begin printing the 'max' amount of lines from, default is 1 (the first line)
]]
function cutText(text, max, startLine)
  startLine = startLine or 1
  startLine = (startLine < 1) and 1 or startLine
  local linesRead, i, startPosition, counter = 0, 0, 0, startLine
  
  while linesRead < max do
    if counter == 1 then 
      startPosition = i + 1
      --print("captured head at " .. startPosition) 
    end
    i = string.find(text, "\n", i+1)    -- first character is at index 1
    counter = counter - 1
    if counter < 1 then linesRead = linesRead + 1 end
    --print("counter: " .. counter .. " start position: " .. startPosition .. " lines read: " .. linesRead)
    if i == nil then break end
  end

  text = string.sub(text, startPosition, i)
  text = string.gsub(text, '\n$', '')     -- remove last new line (if any)
  
  return text, linesRead
end

--[[
Allows conky to display a long text file by printing a fixed amount of lines at a time (page).
If the text file is longer than the 'max' size, pagination will be performed.
Each page will consist of 'max' amount of lines.  This keeps the 'text block' consistent in size accross all pages.

arguments:
    filepath    absolute path to the file
    max         [optional] maximun number of lines to print per page, default is 25 lines
    iterations  [optional] number of conky iterations to loop through per page, default is 3
    x           [optional] ${offset}  to apply to every line of text, default is 5 pixels
    y           [optional] ${voffset} to apply to every line of text, default is 3 pixels
]]
function conky_paginate(filepath, max, iterations, x, y)
  max = (max ~= nil) and tonumber(max) or 25
  iterations = (iterations ~= nil) and tonumber(iterations) or 3
  local fileTotalLines, startLine
  local isPaginationComplete = (vars[filepath .. ".isPaginationComplete"] == nil) and true or vars[filepath .. ".isPaginationComplete"]
  
  -- do we need to read the file or are we currently paginating it (ie. recover the state)?
  if isPaginationComplete then
    conky_read_file(filepath)
    fileTotalLines = tonumber(conky_parse("${lines " .. filepath .. "}"))
    startLine = 1
    vars[filepath .. ".isPaginationComplete"] = false
    vars[filepath .. ".totalLines"] = fileTotalLines
  else
    startLine = vars[filepath .. ".startLine"]
    fileTotalLines = vars[filepath .. ".totalLines"]
  end

  local text, linesRead
  -- determine if you are reading new lines for the next page or loading the current page from memory
  if vars[filepath .. ".text"] == nil then
    text, linesRead = conky_head_mem(filepath, max, x, y, startLine)
    vars[filepath .. ".text"] = text
    vars[filepath .. ".linesRead"] = linesRead
  else
    text = vars[filepath .. ".text"]
    linesRead = vars[filepath .. ".linesRead"]
    conky_decrease_total_lines(linesRead)
  end
  
  -- if we've completed all the iterations for the current page, determine your state for the next iteration
  if conky_parse("${updates}") % iterations == 0 then
    vars[filepath .. ".text"] = nil
    vars[filepath .. ".linesRead"] = nil
    startLine = startLine + linesRead   -- compute the start line for the next page
    
    -- the new start line determines if there are more pages to show or if we are done displaying the file
    if startLine <= fileTotalLines then
      local linesLeft = fileTotalLines - startLine
      -- if the last page does not have 'max' amount of lines, adjust the pointer so we can be consistent
      -- and return 'max' number of lines for the last page as well
      if linesLeft < max then
        startLine = fileTotalLines - max + 1
      end
    else
      -- file has been displayed in full
      vars[filepath .. ".isPaginationComplete"] = true
    end
  end
  
  vars[filepath .. ".startLine"] = startLine
  return text
end
