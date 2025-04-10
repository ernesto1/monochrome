## Overview
The `Music Player D-Bus listener` serves as a middle layer between conky and the media players running in the system.  
It listens on the **d**esktop **bus** (dbus) for any media player activity and writes the metadata of the
currently playing music track into files for conky to read.  This keeps the conky presentation layer relatively simple,
while offloading all the media player state processing to this application.

![architecture](images/architecture.png)

The application is able to listen to any media player that implements the [MPRIS specification](https://www.freedesktop.org/wiki/Specifications/mpris-spec/).  All the popular
players should support it.  
Developers looking to write a conky that interacts with this application should read the [file interface](interface.html)
page.

## Running the application
From the terminal run the following command:
```commandline
$ java -jar ~/conky/monochrome/java/music-player-*.jar
```