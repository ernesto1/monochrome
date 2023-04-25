package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.exceptions.DBusException;
import org.freedesktop.dbus.interfaces.DBus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Arrays;
import java.util.Optional;

/**
 * Detects currently running music players and adds them to the database
 */
public class MusicPlayerScout {
    private static final Logger logger = LoggerFactory.getLogger(MusicPlayerScout.class);
    private MusicPlayerDatabase playerDatabase;
    private MetadataRetriever metadataRetriever;
    /**
     * Connection to the dbus
     */
    private DBusConnection conn;

    public MusicPlayerScout(DBusConnection conn, MetadataRetriever retriever, MusicPlayerDatabase playerDatabase) {
        this.conn = conn;
        this.metadataRetriever = retriever;
        this.playerDatabase = playerDatabase;
    }

    /**
     * Scans the list of available application <i>well known names</i> in the dbus for entries
     * belonging to the <tt>org.mpris.MediaPlayer2</tt> family.  Any {@link MusicPlayerDatabase#isMusicPlayer(String) supported}
     * media players are registered in the database.
     */
    public void registerAvailablePlayers() {
        logger.info("detecting if any music players are already running");

        try {
            DBus dbus = conn.getRemoteObject("org.freedesktop.DBus", "/org/freedesktop/DBus", DBus.class);
            String[] names = dbus.ListNames();
            Arrays.stream(names)
                  .filter(name -> name.startsWith("org.mpris.MediaPlayer2"))
                  .filter(name -> playerDatabase.isMusicPlayer(name.substring(name.lastIndexOf('.') + 1).toLowerCase()))
                  .forEach(name -> {
                      Optional<String> playerName = metadataRetriever.getPlayerName(name);

                      if(playerName.isPresent()) {
                          String wellKnownName = playerName.get();
                          String uniqueName = dbus.GetNameOwner(name);
                          logger.info("{} ({}) music player is running", wellKnownName, uniqueName);
                          MusicPlayer musicPlayer = new MusicPlayer(wellKnownName, uniqueName);
                          musicPlayer = metadataRetriever.getPlayerState(musicPlayer);
                          playerDatabase.save(musicPlayer);
                      } else {
                          logger.warn("unable to get {}'s name, ignoring this music player", name);
                      }
                  });
        } catch (DBusException e) {
            logger.error("unable to register currently running music players", e);
        }
    }
}