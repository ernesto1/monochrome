--[[  :::::: functions for drawing menus with dynamic sizes ::::::

all these methods allow a conky client to manipulate x,y positions
for images or text dynamically at runtime, examples:

1) drawing menu windows

      +----------+    a menu window is drawn by conky using a combination
      |----------|    of several images imposed on top of each other
      |          |
      |          |    
      |          |    for menu's with a variable amount of text
      +----------+  < the position of the bottom edge image is determined at runtime based
                      on the amount of text/lines in the body of the menu

2) draw an image taking into account a x,y offsets to alter the image's original x,y coordinates
3) alter text ${goto x} or ${offset x} statements with a runtime x offset

]]

--[[ table to hold parsed conky variables ]]
computations = {}

--[[ call this method to execute a linux command whose output you don't care about, ex. create a file
in the local file system

the method returns an empty string

arguments:
      expression    conky variable to parse
]]
function conky_compute(expression)
  conky_parse(expression)
  return ''
end

--[[ parses the given conky expression and stores its value in the 'computations' table for future use
within the conky cycle

this will allow you to run an expensive command once and then use its output multiple times within a session

arguments:
    key           key to store the expression as
    expression    conky variable to parse
]]
function conky_compute_and_save(key, expression)
  computations[key] = conky_parse(expression)
  return computations[key]
end

function conky_retrieve(key)
  return computations[key]
end

function conky_pad_lines(key, required)
  local lines = tonumber(computations[key])
  local required = tonumber(required)
  local s = ''

  if lines < required then
    local i = required - lines
    repeat
      s = s .. '${voffset 3}\n'
      i = i-1
    until i == 0
  end

  return s
end

--[[ prints the menu's bottom edge ${image} variables based on the number of lines in the body

arguments:
    theme     conky theme: compact, widets, glass, etc...
    filename  image file name
    x         image x coordinate
    y         starting y coordinate of the menu's body image
    voffset   vertical offset used for each line in the menu's body
              ie. if the text uses this notation
              
                      ${voffset 3} some text
                      ${voffset 3} bla bla bla
                                 \
                                 you have to provide this value here
                                 
    lines     number of lines in the body
]]
function draw_round_bottom_edges(theme, filename, x, y, width, voffset, lines)
  local lineMultiplier = 15
  
  if voffset > 2 then
    lineMultiplier = lineMultiplier + voffset - 2
  end

  lines = (lines > 0) and lines or 0
  y = y + (lines * lineMultiplier) - 1
  local imageDir = "~/conky/monochrome/images/"
  local path = imageDir .. theme .. "/" .. filename .. "-left.png"
  local s = build_image_variable(path, x, y)
  path = imageDir .. theme .. "/" .. filename .. "-right.png"
  s = s .. build_image_variable(path, x+width-7, y)
  -- add a blank image right below the bottom edge image, bottom edges are 7px
  s = s .. build_image_variable(imageDir .. "menu-blank.png", x, y + 7)
  
  return s
end

--[[ wrapper method for the 'bottom_edge' function
allows the client to provide a conky expression/variable that when computed/parsed will return the number of lines in the body of the menu

arguments:
    ...         same arguments as draw_round_bottom_edges(..)
    expression  conky expression to evaluate, must return a number representing the number of lines
    maxLines    optional | maximun number of lines, will override the expression line count if it computes
                to a bigger number
]]
function conky_bottom_edge_parse(theme, filename, x, y, width, voffset, expression, maxLines)
  maxLines = tonumber(maxLines) or 1000
  local lines = tonumber(conky_parse(expression))
  lines = (lines > maxLines) and maxLines or lines
  
  return draw_round_bottom_edges(theme, filename, tonumber(x), tonumber(y), tonumber(width), tonumber(voffset), lines)
end

--[[ wrapper method for the 'bottom_edge' function
allows the client to provide a 'key' which can be used to retrieve the total number of lines in the body
of the menu from a previously computed conky variable, see the method conky_compute_and_save()

arguments:
    ...         same arguments as draw_round_bottom_edges(..)
    key         string used to store the previously computed number of lines computation
                see the conky_compute_and_save() function
    maxLines    optional | maximum number of lines, will override the cached line count if it 
                is greater than this threshold
]]
function conky_bottom_edge_load_value(theme, filename, x, y, width, voffset, key, maxLines)
  if not computations[key] then
    print("the key: '" .. key .. "' does not exist, image '" .. filename .. "' will not be drawn")
    return ''
  end
  
  local lines = tonumber(computations[key])
  maxLines = tonumber(maxLines) or 1000
  lines = (lines > maxLines) and maxLines or lines
  
  return draw_round_bottom_edges(theme, filename, tonumber(x), tonumber(y), tonumber(width), tonumber(voffset), lines)
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

-- resets the x,y offsets
-- this method should be invoked by conky on each refresh cycle
function conky_reset_state()
  computations["xOffset"] = 0
  computations["yOffset"] = 0
end

--[[ adds an offset to the x & y coordinates
the client can then call the following methods which will take these offsets into account:

  - conky_draw_image(..)
  - conky_add_x_offset(..)

on each conky session the offsets are reset to 0 (see the conky_reset_state() method)
this methoed is cumulative, ie. the numbers are increased each times the method is called
]]
function conky_add_offsets(xOffset, yOffset)
  local x = computations["xOffset"] or 0
  x = x + tonumber(xOffset)
  computations["xOffset"] = x

  local y = computations["yOffset"] or 0
  y = y + tonumber(yOffset)
  computations["yOffset"] = y
  return ''
end

--[[ update the conky variable with the current 'x' offset
call this method with ${goto} or ${offset} conky variables]]
function conky_add_x_offset(variable, x)
  local xOffset = computations["xOffset"] or 0
  return "${" .. variable .. " " .. tonumber(x) + xOffset .. "}"
end

--[[ creates a conky image variable string at the x,y coordinate position after any available offsets are applied, ex. calling conky_draw_image(/directory/image.jpg, 0, 50) 
             with the current offsets being x = 10, y = 50
             would yield this image variable: ${image /directory/image.jpg -p 10,100}

arguments:
    path  path to image file
    x     image x coordinate
    y     image y coordinate

@see the 'conky_add_offsets()' method
]]
function conky_draw_image(path, x, y)
  local xOffset = computations["xOffset"] or 0
  local yOffset = computations["yOffset"] or 0
  return build_image_variable(path, tonumber(x) + xOffset, tonumber(y) + yOffset)
end
