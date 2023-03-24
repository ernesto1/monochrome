--[[ generates an image conky variable, ex. ${image picture.jpg -s 100x100 -p 0,0}

arguments:
      expression    conky variable to parse, must yield an image path
      dimensions    image dimensions in WxH format, ex. 200x200
      position      image x,y coordinates, ex. 50,100
]]
function conky_album_art_image(expression, dimensions, position)
  local path = conky_parse(expression);
  local s = "${image " .. path .. " -s " .. dimensions .. " -p " .. position .."}"
  return s
end
