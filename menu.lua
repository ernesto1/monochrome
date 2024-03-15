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

3) drawing dynamic menu windows

      ╭──────────╮    a menu window is drawn by conky using a combination
      │──────────│    of several images imposed on top of each other
      │          │
      │          │    
      │          │    for menus populated with a variable amount of text (ex. based on the contents of a file)
      ╰──────────╯  < the position of the bottom edge images would be determined at runtime
                      based on the number of lines of the file

      see conky_add_offsets()
          conky_configure_menu()
          conky_populate_menu()
]]

-- resets the global variables, such as the x,y offsets
-- this method must be invoked by conky on each refresh cycle (use the lua_draw_hook_pre setting)
function conky_reset_state()
  vars["xOffset"] = 0
  vars["yOffset"] = 0
  vars["color"] = "burgundy"
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
add the 'x' offset to the conky variable's argument
call this method with the ${goto} or ${offset} conky variables
]]
function conky_add_x_offset(variable, x)
  local xOffset = vars["xOffset"] or 0
  return "${" .. variable .. " " .. tonumber(x) + xOffset .. "}"
end

--[[
add the 'y' offset to the conky variable's argument
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


--[[
Set up method to configure the basic properties of a menu window displayed by a conky client.
If all the menus within a conky are the same, this method only needs to be invoked once at the beginning of the conky.

Call this method prior to invoking conky_populate_menu() in your conky.

arguments:
    color     color image to use (a menu image set must exist for this color)
    value     light or dark
    width     width of the table
    voffset   vertical offset used for each line in the menu's body
              ie. if the text uses this notation
              
                      ${voffset 3} some text
                      ${voffset 3} bla bla bla
                                 \
                                 you have to provide this value here
    round     'true' if menu has round edges, false otherwise
              default is 'true'
]]
function conky_configure_menu(color, value, width, voffset, round)
  vars["color"] = color
  vars["value"] = value
  vars["width"] = tonumber(width)
  vars["textVOffset"] = tonumber(voffset)
  vars["roundEdges"] = (round == nil) and true or stringToBoolean(round)
  return ''
end


function stringToBoolean(s)
  local map={ ["true"]=true, ["false"]=false }
  return map[s]
end

--[[
Convenience method to populate the contents of a menu window by reading a file.
It performs two steps:

   - reads a file similar to the linux 'head' command
   - prints the menu's bottom edge images taking into account the number of text lines printed

n.b. the 'y' offset is updated to the pixel right after the table image ends

method dependency tree:

  conky_add_offsets(..) -> conky_configure_menu(..) -> conky_populate_menu(..)
        \
       place 'y' coordinate below the table's header
       
arguments:
    filepath  absolute path to the file
    max       [optional] maximun number of lines to print
    interval  [optional] number of seconds to wait between reads
]]
function conky_populate_menu(filepath, max, interval)
  max = (max ~= nil) and tonumber(max) or 30
  max = (vars["totalLines"] > max) and max or vars["totalLines"]
  local text, lines = conky_head(filepath, max, interval)
  conky_decrease_total_lines(lines)
  local y = calculate_bottom_edge_y_coordinate(lines)

  return text .. draw_round_bottom_edges(vars["xOffset"], y, vars["width"])
end

--[[
determines the y coordinate of a menu's bottom edges based on the number of lines printed inside of it

arguments:
    numLines   number of lines
]]
function calculate_bottom_edge_y_coordinate(numLines)
  local lineMultiplier = 15
  
  if vars["textVOffset"] > 2 then
    lineMultiplier = lineMultiplier + vars["textVOffset"] - 2
  end

  numLines = (numLines > 0) and numLines or 0
  y = vars["yOffset"] + (numLines * lineMultiplier) - vars["textVOffset"]

  return y
end

--[[
Creates the ${image} variables of the two menu bottom edges

arguments:
    x       image x coordinate
    y       image y coordinate
    width   width of the menu
    color   menu color, default is the color defined by a prior 'conky_configure_menu()' invocation
]]
function draw_round_bottom_edges(x, y, width, color)
  local imageRoot = "~/conky/monochrome/images/common/"
  local s = ''
  color = (color ~= nil) and color or vars["color"]
    
  if vars["roundEdges"] then
    local imagePath = imageRoot .. color .. "-menu-" .. vars["value"] .. "-edge-bottom"
    local image = imagePath .. "-left.png"
    s = build_image_variable(image, x, y)
    image = imagePath .. "-right.png"
    -- bottom edge images are 7x7px
    s = s .. build_image_variable(image, x + width - 7, y)
    -- add a blank image right below the bottom edge images
  end
  
  y = y + 7
  s = s .. build_image_variable(imageRoot .. "menu-blank.png", x, y)
  vars["yOffset"] = y
  
  return s
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


--[[
complementary method to the populate_menu() function

it allows the client to print the bottom edges of a table next to the one already populated
by a prior invocation to the populate_menu() method

use this when you are splitting the columns of a table into individual table images

                 x coordinate (will internally account for the available xoffset)
                     |
        table 1      |  table 2
      ╭──────────╮   ╭──────────╮
      │──────────│   │──────────│
      │          │   │          │
      │          │   │          │
      │          │               
      ╰──────────╯   ╰ ──────── ╯ < you want to print the edges for the 2nd table (column)
           \
            \
           a prior call to the populate_menu() method would have determined
           the height of the table, ie. the 'y' coordinate is known

arguments:
    x       x coordinate
    width   width of this table
]]
function conky_draw_bottom_edges(x, width, color)
  return draw_round_bottom_edges(vars["xOffset"] + tonumber(x), vars["yOffset"] - 7, tonumber(width), color)
end


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

-- :::::::: experimental API ::::::::

function conky_read_file(file)
  vars[file] = conky_parse('${cat ' .. file .. '}')
  return ''
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

function lines(string)
  local _, lines = string.gsub(string, "\n", "\n")
  return lines + 1    -- last line in the text file won't have a new line so we need to account for it
end

function conky_populate_menu_from_file(filepath, max, x, y)
  conky_read_file(filepath)
  return conky_populate_menu_from_mem(filepath, max, x, y)
end

function conky_populate_menu_from_mem(filepath, max, x, y)
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
  
  local y = calculate_bottom_edge_y_coordinate(lines)

  return text .. draw_round_bottom_edges(vars["xOffset"], y, vars["width"])
end

function conky_cat(filepath, max, x, y)
  conky_read_file(filepath)
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
