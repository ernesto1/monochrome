-- :::::: lua functions for the media player conky ::::::

--[[ generates an image conky variable from a conky expression, ex. the image path is in a file
that must be read; you can use this method to extract said path by using the conky ${cat} variable

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

--[[ wrapper function meant for the ${cat someFile} conky variable
     if the file does not exist, it will print a default error message]]
function conky_read_file(expression)
  local text = conky_parse(expression)
  -- if the expression evaluates to nothing use a default error message
  text = (text ~= '') and text or "missing input file"
  
  return text
end
