package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.exceptions.DBusException;
import org.freedesktop.dbus.interfaces.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Allows clients to register and unregister music players for this application to track via the dbus.<br>
 * For each registered player, the application will subscribe to messages from it through the dbus.
 */
public class Registrar {
    private static final Logger logger = LoggerFactory.getLogger(Registrar.class);

    /**
     * Connection to the dbus
     */
    private final DBusConnection conn;
    private final MetadataRetriever metadataRetriever;
    private final MusicPlayerDatabase playerDatabase;
    /**
     * Map of <tt>bus unique name</tt> to <tt>signal handler closeable</tt>.  Allows the registrar to unregister
     * signal handlers from the dbus.
     */
    private final Map<String, AutoCloseable> handlerMap;

    public Registrar(DBusConnection conn, MetadataRetriever metadataRetriever, MusicPlayerDatabase playerDatabase) {
        this.conn = conn;
        this.metadataRetriever = metadataRetriever;
        this.playerDatabase = playerDatabase;
        handlerMap = new HashMap<>();
    }

    /**
     * Registers the music player for tracking.<br>
     * In order for the player to be registered, it must be {@link MusicPlayerDatabase#isSupported(String) supported}
     * by this application.
     * @param busName dbus unique name, ex. :1.345
     */
    public void register(String busName) {
        String playerName;
        Optional<String> name = metadataRetriever.getPlayerName(busName);

        if (name.isPresent()) {
            playerName = name.get();
        } else {
            logger.warn("unable to determine the music player's name, the player will not be registered");
            return;
        }

        if (!playerDatabase.isSupported(playerName)) {
            logger.info("music player '{}' is not supported", playerName);
            return;
        }

        logger.info("registering new player: '{}'", playerName);
        MusicPlayer musicPlayer = new MusicPlayer(playerName, busName);
        musicPlayer = metadataRetriever.getPlayerState(musicPlayer);
        playerDatabase.save(musicPlayer);

        try {
            AutoCloseable unregisterHandler = conn.addSigHandler(Properties.PropertiesChanged.class,
                                                                 busName,
                                                                 new TrackUpdatesHandler(metadataRetriever, playerDatabase));
            handlerMap.put(busName, unregisterHandler);
        } catch (DBusException e) {
            logger.error("unable to register the signal handler for the '{}' music player", playerName);
        }
    }

    /**
     * Stops the music player from being tracked by this application
     * @param busName dbus unique name, ex. :1.345
     */
    public void unregister(String busName) {
        playerDatabase.removePlayer(busName);
        AutoCloseable unregisterHandler = handlerMap.remove(busName);

        if (unregisterHandler != null) {
            try {
                unregisterHandler.close();
            } catch (Exception e) {
                logger.error("unable to unregister the properties changed signal handler for the music player '{}'", busName, e);
            }
        } else {
            logger.warn("attempted to unregister the properties changed signal handler for a bus name that does not exist");
        }
    }
}
