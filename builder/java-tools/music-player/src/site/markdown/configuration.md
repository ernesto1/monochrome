## Changing the default properties
Available settings to configure can be seen in the `application.properties` file.  
The file can be found under `~/conky/monochrome/java`.

### Supported Players
During testing it was discovered that not all media players implement the MPRIS specification in the same fashion.  
Therefore only players that have been tested so far are supported by this application.  The `supportedPlayers` property
is the list of whitelisted players.

To add a new player, simply write down the name the player uses to register itself under the dbus.  If you notice any
weird behaviour on the now playing conky, a new use case may have to be accounted for.

### Output file directory
By default the application will write its output files in the `/tmp/conky` directory.  The **now playing conky** reads
these files for displaying the current track details.
```bash
/tmp/conky$ ls musicplayer.*
musicplayer.name            musicplayer.status       musicplayer.track.albumArtPath  musicplayer.track.genre
musicplayer.playbackStatus  musicplayer.track.album  musicplayer.track.artist        musicplayer.track.title
```
You can change the output directory by modifying the `outputDir` property.  Do note that the now playing **conky configuration** 
will have to be **updated** to reflect the directory change as well.

### Image cache
See [album art](albumArt.html) for more context.