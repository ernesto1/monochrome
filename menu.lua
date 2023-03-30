-- :::::: functions for drawing menus with dynamic sizes ::::::

--[[ table to hold parsed conky variables ]]
computations = {}

--[[ parses the given conky expression and stores it for future use in a table

arguments:
      key           key to store the expression as
      expression    conky variable to parse
]]
function conky_compute_and_save(key, expression)
  computations[key] = conky_parse(expression)
  return computations[key]
end

--[[ wrapper method for the 'bottom_edge' function
allows the client to provide a 'key' which can be used to retrieve the total number of lines in the body
of the menu from a previously computed conky variable 

arguments:
    key         string used to store the previously computed number of lines computation
                see the conky_compute_and_save() function
    maxLines    optional | maximun number of lines, will override the expression line count if it computes
                to a bigger number
]]
function conky_bottom_edge_load_value(theme, filename, x, y, voffset, key, maxLines)
  if not computations[key] then
    print("the key: '" .. key .. "' does not exist, image '" .. filename .. "' will not be drawn")
    return ''
  end
  
  local lines = tonumber(computations[key])
  maxLines = tonumber(maxLines) or 1000
  lines = (lines > maxLines) and maxLines or lines
  return conky_bottom_edge(theme, filename, x, y, voffset, lines)
end

--[[ wrapper method for the 'bottom_edge' function
allows the client to provide a conky expression/variable that when computed/parsed will return the number of lines
in the body of the menu

arguments:
    expression  conky expression to evaluate, must return a number representing the number of lines
    maxLines    optional | maximun number of lines, will override the expression line count if it computes
                to a bigger number
]]
function conky_bottom_edge_parse(theme, filename, x, y, voffset, expression, maxLines)
  maxLines = tonumber(maxLines) or 1000
  local lines = tonumber(conky_parse(expression))
  lines = (lines > maxLines) and maxLines or lines
  
  return conky_bottom_edge(theme, filename, x, y, voffset, lines)
end

--[[ this method will print the ${image} variable required for conky to print the menu's bottom edge image based on the number of lines in the menu's body

arguments:
    theme     conky theme: compact, widets, glass, etc...
    filename  image file name
    x         image x coordinate
    y         starting y coordinate of the menu's body image
    voffset   vertical offset used for each line in the menu's body
    lines     number of lines the body will contain
]]
function conky_bottom_edge(theme, filename, x, y, voffset, lines)
  local lineMultiplier = 15
  
  if tonumber(voffset) > 2 then
    lineMultiplier = lineMultiplier + tonumber(voffset) - 2
  end

  -- decrease by one line since the image's y coordinate is hard coded for the single line scenario
  lines = (lines > 0) and (lines - 1) or 0
  y = tonumber(y) + 14 + (lines * lineMultiplier)
  local path = "~/conky/monochrome/images/" .. theme .. "/" .. filename
  local s = build_image_variable(path, x, y)
  -- add a blank image right below the bottom edge image, assume bottom edges will never be greater than 15px
  s = s .. "${image ~/conky/monochrome/images/menu-blank.png -p " .. x .. "," .. y + 15 .. "}"
  
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

function conky_reset_state()
  computations["yOffset"] = 0
end

--[[ adds an offset to the 'y' coordinate
the client can then call the 'conky_draw_image()' method in order to draw an image at the current y coordinate

on each conky session the y offset starts at 0, this number is increased depending on the number of times
this method is called
]]
function conky_image_offset(offset)
  local yOffset = computations["yOffset"]
  yOffset = yOffset + tonumber(offset)
  computations["yOffset"] = yOffset
  return ''
end

--[[ creates a conky image variable string at the current y coordinate position, ex. ${image /directory/image.jpg -p 0,55}
see the 'conky_image_offset()' method

arguments:
    path  path to image file
    x     image x coordinate
]]
function conky_draw_image(path, x)
  local y = computations["yOffset"]  
  return build_image_variable(path, x, y)
end
