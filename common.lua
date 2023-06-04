-- :::::: common functions ::::::

function conky_pad(expression)
    local text = conky_parse(expression)
    text = (text ~= '') and text or '0'

    return string.format('%3s', text)
end

--[[ prints the value provided by the conky variable after a applying a 'threshold' check to it.
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

--[[ generates an image conky variable from a conky expression which yields an image file path, 
ex. if the image path is in a file that must be read; you can use this method to extract said path
by using the conky ${cat} variable

arguments:
  expression    conky variable to parse, must yield an image file path
  dimensions    image dimensions in WxH format, ex. 200x200
  position      image x,y coordinates, ex. 50,100
returns:
  ${image picture.jpg -s 100x100 -p 0,0}
]]
function conky_album_art_image(expression, dimensions, position)
  local path = conky_parse(expression)
  local s = "${image " .. path .. " -s " .. dimensions .. " -p " .. position .."}"
  
  return s
end

--[[ evaluates a conky variable (ex. ${cat someFile}) and prints its value
if the character limit is breached, the string is truncated

arguments:
  expression    conky 'cat' variable to parse
  charLimit     [optional] maximun number of characters to print, use to truncate text if too long
]]
function conky_truncate_string(expression, charLimit)  
  local text = conky_parse(expression)
  -- if the expression evaluates to nothing use a default error message
  text = (text ~= '') and text or "empty conky expression"
  charLimit = tonumber(charLimit) or 1000
  
  return string.sub(text,1,charLimit)
end
