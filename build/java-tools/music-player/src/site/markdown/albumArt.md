## Album art
Album art in a music track can come in one of two forms:

1. The image is available on the local disk
1. The image is available on the web

In case of (2) the application will download the image from the web and write it to the disk.  The directory where the 
file is stored is called the **image cache**.  
For the currently playing track, a symbolic link is created which points to the album art image file.
See [file interface](interface.html) for more details.

### Image cache
By default the image cache directory is `~/conky/monochrome/java/albumArt`.  
Its maximum size is **1GB**.  Once the maximum size is breached, album art image files will be deleted at random 
in order to keep to directory size within the limit.

Both of these properties are configurable, see [Changing the default properties](configuration.html).