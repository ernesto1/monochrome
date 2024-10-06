-- :::::: functions for the music player conky ::::::

trackinfo = {}
trackinfo[1] = "title"
trackinfo[2] = "album"
trackinfo[3] = "artist"
trackinfo[4] = "genre"

-- loads all the music player track info metadata into memory
function conky_load_track_info()
  for i, metadata in ipairs(trackinfo) do
    vars[metadata] = conky_parse("${cat /tmp/conky/musicplayer.".. metadata .."}")
  end
  
  return ''
end
