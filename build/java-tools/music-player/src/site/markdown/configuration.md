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
By default the application will write its output files in the `/tmp/conky` directory.  
You can change the output directory by modifying the `outputDir` property.
```bash
/tmp/conky$ ls musicplayer.*
musicplayer.name            musicplayer.status       musicplayer.track.art     musicplayer.track.genre
musicplayer.playbackStatus  musicplayer.track.album  musicplayer.track.artist  musicplayer.track.title
```

### Image cache
[Album art](albumArt.html) downloaded from the web is stored in the image cache.

- The location of the image cache directory is driven by the `albumArtDir` property.  
- The `albumCacheSize` property controls the maximum size the cache is allowed to reach.  Its value is in `kb`.