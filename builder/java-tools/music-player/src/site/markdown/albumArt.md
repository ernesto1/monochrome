## Album art
Album art can come in one of two forms:

1. The image is available on the local disk
1. The image is available on the web

In case of (2) the application will download the image from the web and store it in the image cache.  
The `musicplayer.track.albumArtPath` output file will have the full path to the file on disk  (see [file interface](interface.html)).

### Image cache
The location of the cache directory is driven by the `albumArtDir` property in the [configuration file](configuration.html).  
The `albumCacheSize` property controls the maximum size the cache is allowed to reach.  By default, the max size is 1GB.  
Once the maximum size is breached, album art image files will be deleted at random in order to keep to directory size 
within the limit. 