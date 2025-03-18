## File interface
This applications uses **files** for inter process communication with the now playing conky.  
As music player activity is detected over the dbus, the application will write the details into these files.  
Conky can read the files to get the music player and track info metadata.  
Files are only updated when the media player state changes.

The files are written to the `/tmp/conky` directory.

| No media player running              | Media player running                            |
|--------------------------------------|-------------------------------------------------|
| `musicplayer.album:unknown album`    | `musicplayer.album:Coming Home`                 |
|                                      | `musicplayer.albumArtPath:/some/path/image.png` |
| `musicplayer.artist:unknown artist`  | `musicplayer.artist:Alex Boychuk`               |
| `musicplayer.genre:unknown genre`    | `musicplayer.genre:unknown genre`               |
| `musicplayer.name:no player running` | `musicplayer.name:Spotify`                      |
| `musicplayer.playbackStatus:Stopped` | `musicplayer.playbackStatus:Playing`            |
| `musicplayer.status:off`             | `musicplayer.status:on`                        |
| `musicplayer.title:unknown title`    | `musicplayer.title:Coming Home`                 |

Media player metadata:

- The `name`, `status` and `playbackStatus` files relay media player details.
- The `status` can be used to determine if a music player is running or not.  
  It is `off` when no player is available, `on` otherwise.
- The playback status values are: `Playing`, `Stopped`, `Paused`.

Track info metadata:

- The remaining files are the current song details.
- The `albumArtPath` file is optional, if no album art is available the file will not exist.