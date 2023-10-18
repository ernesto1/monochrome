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
  albumLines      number of lines to decrease when the track has album art
                  the music player conky window size will be the biggest in this state
]]
function conky_decrease_music_player_lines(noPlayerLines, albumLines)
  -- no player running
  local count = tonumber(conky_parse('${if_existing /tmp/conky/musicplayer.name Nameless}' .. noPlayerLines .. '${else}0${endif}'))

  if count == 0 then
    -- album art
    count = tonumber(conky_parse('${if_existing /tmp/conky/musicplayer.albumArtPath}' .. albumLines .. '${else}0${endif}'))
    conky_load_track_info()
    -- album/author/genre
    fields = {}
    fields[1] = 'album'
    fields[2] = 'artist'
    fields[3] = 'genre'
    count = count + 3 - assess_missing_metadata(fields)
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

function conky_apply_vertical_offset(offset, ...)
  local fields = {...}  
  local count = assess_missing_metadata(fields)
  local voffset = offset * count
  conky_add_offsets(0, voffset)
  --print(vars["xOffset"] .. ' ' .. vars["yOffset"] .. ' ' .. voffset)
  return ''
end
