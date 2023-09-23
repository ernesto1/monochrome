-- :::::: functions for music player conky ::::::

trackinfo = {}
trackinfo[1] = "title"
trackinfo[2] = "album"
trackinfo[3] = "artist"
trackinfo[4] = "genre"
  
function conky_load_track_info()
  for i, metadata in ipairs(trackinfo) do
    vars[metadata] = conky_parse("${cat /tmp/conky/musicplayer.".. metadata .."}")
  end
  
  return ''
end

function conky_assess_vertical_offset(offset, ...)
  local args = {...}
  local voffset = 0

  for i, metadata in ipairs(args) do
    --print(vars[metadata])
    if vars[metadata] == "unknown " .. metadata then voffset = voffset + tonumber(offset) end
  end

  conky_add_offsets(0, voffset)
  print(vars["xOffset"] .. ' ' .. vars["yOffset"] .. ' ' .. voffset)
  return ''
end
