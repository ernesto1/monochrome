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

--[[
decreases the available "total number of lines" variable based on the current state of the music player conky.

this is a "special" use case for sidebar conkys positioned on top of the music player conky that want to make
best use of space for displaying information, since the size of the music player conky changes depending on how much track metadata is available.

arguments:
  noPlayerLines   number of lines to decrease when no 'active' player is available
                  the music player conky window size will be the smallest in this state
  noAlbumLines    number of lines to decrease when the track has no album art
  albumLines      number of lines to decrease when the track has album art
                  the music player conky window size will be the biggest in this state
]]
function conky_decrease_music_player_lines(noPlayerLines, noAlbumLines, albumLines)
  local count = 0
  local isNoPlayer = conky_parse('${if_existing /tmp/conky/musicplayer.name Nameless}true${else}false${endif}')
  --print(isNoPlayer)
  
  if isNoPlayer == 'true' then
    --print('no player available')
    count = tonumber(noPlayerLines)
  else
    -- is there album art?
    count = tonumber(conky_parse('${if_existing /tmp/conky/musicplayer.albumArtPath}' .. albumLines .. '${else}' .. noAlbumLines .. '${endif}'))
    conky_load_track_info()
    -- album/author/genre
    fields = {}
    fields[1] = 'album'
    fields[2] = 'artist'
    fields[3] = 'genre'
    count = count - assess_missing_metadata(fields)
  end
  
  --print(count)
  conky_decrease_total_lines(count)
  
  return ''
end

--[[
returns the number of track info metadata missing from the current active player, these are the fields with "unknown ..." values

arguments:
    fields    array of track info fields to check for
]]
function assess_missing_metadata(fields)
  local count = 0
  
  for i, metadata in ipairs(fields) do
    if vars[metadata] == "unknown " .. metadata then count = count + 1 end
  end
  
  return count
end
