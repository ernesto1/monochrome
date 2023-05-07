-- :::::: lua functions for the media player conky ::::::

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

--[[ wrapper function to complement the ${cat someFile} conky variable
prints the contents of the file but if the file does not exist it will print a default error message

arguments:
  expression    conky 'cat' variable to parse
  charLimit     [optional] maximun number of characters to print, use to truncate text if too long
]]
function conky_read_file(expression, charLimit)
  charLimit = tonumber(charLimit) or 1000
  local text = conky_parse(expression)
  -- if the expression evaluates to nothing use a default error message
  text = (text ~= '') and text or "missing input file"
  
  return string.sub(text,1,charLimit)
end
