--[[ table to hold conky variable computations within a cycle, ie. compute/parse the value once
and reuse many times ]]
computations = {}

function conky_compute_and_save(key, expression)
  computations[key] = conky_parse(expression)
  return computations[key]
end

function conky_bottom_edge_load_value(theme, filename, x, y, offset, key)
  if not computations[key] then
    print("the key: '" .. key .. "' does not exist, image '" .. filename .. "' to be drawn in the incorrect location")
  end
  
  -- if the key does not exist default to '1'
  local lines = tonumber(computations[key]) or 1; 
  return conky_bottom_edge(theme, filename, x, y, offset, lines)
end

function conky_bottom_edge_parse(theme, filename, x, y, offset, expression)
  return conky_bottom_edge(theme, filename, x, y, offset, tonumber(conky_parse(expression)))
end

-- given the number of lines it will calculate the total height for the block
-- up to the bottom edge
function conky_bottom_edge(theme, filename, x, y, offset, lines)
  local lineMultiplier = 15
  
  if tonumber(offset) > 2 then
    lineMultiplier = lineMultiplier + tonumber(offset) - 2
  end

  -- decrease by one line since the image's y coordinate is hard coded for the single line scenario
  lines = (tonumber(lines) > 0) and (tonumber(lines) - 1) or 0
  y = tonumber(y) + 14 + (lines * lineMultiplier)
  local path = "~/conky/monochrome/images/" .. theme .. "/" .. filename
  local s = "${image " .. path .. " -p " .. x .. "," .. y .. "}"
--  print(s)
  return s
end
