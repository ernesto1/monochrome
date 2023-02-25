--[[ table to hold conky variable computations within a cycle, ie. compute/parse the value once
and reuse many times ]]
computations = {}

function conky_compute_and_save(key, expression)
  computations[key] = conky_parse(expression)
  return computations[key]
end

function conky_bottom_edge_load_value(theme, filename, x, y, voffset, key)
  if not computations[key] then
    print("the key: '" .. key .. "' does not exist, image '" .. filename .. "' to be drawn in the incorrect location")
  end
  
  -- if the key does not exist default to '1'
  local lines = tonumber(computations[key]) or 1; 
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
--  print("y: " .. y .. " voffset: " .. voffset .. " lines: " .. lines)
  local lineMultiplier = 15
  
  if tonumber(voffset) > 2 then
    lineMultiplier = lineMultiplier + tonumber(voffset) - 2
  end

--  print ("line multiplier: " .. lineMultiplier)
  -- decrease by one line since the image's y coordinate is hard coded for the single line scenario
  lines = (lines > 0) and (lines - 1) or 0
  y = tonumber(y) + 14 + (lines * lineMultiplier)
  local path = "~/conky/monochrome/images/" .. theme .. "/" .. filename
  local s = "${image " .. path .. " -p " .. x .. "," .. y .. "}"
  -- add a blank image right below the bottom edge image, assume bottom edges will never be greater than 15px
  s = s .. "${image ~/conky/monochrome/images/widgets-dock/menu-blank.png -p " .. x .. "," .. y + 15 .. "}"
--  print(s)
  return s
end
