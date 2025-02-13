The `Music Player D-Bus listener` serves as a middle layer between conky and the media players running in the system.  
It listens on the **d**esktop **bus** (dbus) for any media player activity and writes the metadata of the
currently playing music track into files for conky to read.  This keeps the conky presentation layer relatively simple,
while offloading all the media player state processing to this application.

![architecture](images/architecture.png)

If multiple media players are running, the one currently playing a song is selected for conky to display.