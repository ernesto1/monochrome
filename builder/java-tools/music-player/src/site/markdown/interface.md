## File interface
This applications uses **files** for inter process communication with the now playing conky.  
As music player activity is detected over the dbus, the application will write the details into these files.  
Conky can read the files to get the music player and track info metadata.  
Files are only updated when the media player state changes.

The files are written to the `/tmp/conky` directory.

| No media player running    | A media player is running                               |
|----------------------------|---------------------------------------------------------|
|                            | `musicplayer.name = Spotify`                            |
|                            | `musicplayer.playbackStatus = Playing`                  |
| `musicplayer.status = off` | `musicplayer.status = on`                               |
|                            | `musicplayer.track.album = Coming Home`                 |
|                            | `musicplayer.track.albumArtPath = /some/path/image.png` |
|                            | `musicplayer.track.artist = Alex Boychuk`               |
|                            | `musicplayer.track.genre = Synthwave`                   |
|                            | `musicplayer.track.title = Coming Home`                 |

Media player metadata:

- The `name`, `status` and `playbackStatus` files relay media player details.
- The `status` can be used to determine if a music player is running or not.  
  It is `off` when no player is available, `on` otherwise.
- The playback status values are: `Playing`, `Stopped`, `Paused`.

Track info metadata:

- Files with the `track` prefix are the current song details.
- The `albumArtPath` file is optional, if no album art is available the file will not exist.

### Album art symbolic link
For songs with album art, a symbolic link is created in the image cache.  This allows conkys that don't want to use the
lua functions, to still be able to load the image file by using vanilla conky variables.

By default the file is available under `~/conky/monochrome/java/albumArt/nowPlaying`.  
If the track has no album art, this file will not exist.