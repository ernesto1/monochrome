package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.exceptions.DBusException;
import org.freedesktop.dbus.interfaces.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Allows clients to register and unregister music players to subscribe to.<br>
 * For each registered player, the application will subscribe to dbus messages from it.<br>
 * <br>
 * Since music players implement the MPRIS specification differently, only those players that
 * have been tested will be supported by this application.  The registrar performs this gate keeping role.
 *
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/">Media Player Remote Interfacing Specification (MPRIS)</a>
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
     * List of compatible music players.  Only signals from these players will be processed.<br>
     * These are music players that comply with the "protocol" expected from this app, ie.
     * <ul>
     *     <li>Player provides complete song metadata</li>
     *     <li>The way it sends status update messages is supported</li>
     * </ul>
     */
    private List<String> supportedPlayers;
    /**
     * Map of <code>bus unique name</code> to <code>signal handler closeable</code>.  Allows the registrar to unregister
     * signal handlers from the dbus.
     */
    private final Map<String, AutoCloseable> handlerMap;
    private final TrackUpdatesHandler trackUpdatesHandler;

    public Registrar(DBusConnection conn,
                     MetadataRetriever metadataRetriever,
                     MusicPlayerDatabase playerDatabase,
                     List<String> supportedPlayers, TrackUpdatesHandler trackUpdatesHandler) {
        this.conn = conn;
        this.metadataRetriever = metadataRetriever;
        this.playerDatabase = playerDatabase;
        this.supportedPlayers = supportedPlayers;
        handlerMap = new HashMap<>();
        this.trackUpdatesHandler = trackUpdatesHandler;
    }

    /**
     * Registers the music player for tracking.<br>
     * In order for the player to be registered, it must be {@link #isSupported(String) supported} by this application.
     *
     * @param busName dbus unique name, ex. :1.345
     */
    public void register(String busName) {
        String playerName;
        Optional<String> name = metadataRetriever.getPlayerName(busName);

        if (name.isPresent()) {
            playerName = name.get();
        } else {
            logger.warn("unable to determine the media player's name, the player will be ignored");
            return;
        }

        if (!isSupported(playerName)) {
            logger.info("'{}' is not a supported music player, it will not be registered", playerName);
            return;
        }

        logger.info("registering a new music player: '{}'", playerName);
        MusicPlayer musicPlayer = new MusicPlayer(playerName, busName, MusicPlayer.PlayerStatus.ON);
        musicPlayer = metadataRetriever.getPlayerState(musicPlayer);
        playerDatabase.save(musicPlayer);

        try {
            AutoCloseable unregisterHandler = conn.addSigHandler(Properties.PropertiesChanged.class,
                                                                 busName,
                                                                 trackUpdatesHandler);
            handlerMap.put(busName, unregisterHandler);
        } catch (DBusException e) {
            logger.error("unable to subscribe to dbus signals from the '{}' music player", playerName);
        }
    }

    /**
     * Determines if the given player is a compatible/tested music player.<br>
     * This would allow a client to filter out other media players on the dbus like a firefox youtube window for example.
     * @param playerName the player's name
     * @return <code>true</code> if the player is supported
     */
    public boolean isSupported(String playerName) {
        return supportedPlayers.contains(playerName.toLowerCase());
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
