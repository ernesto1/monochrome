package com.conky.musicplayer.examples;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.interfaces.Properties;
import org.freedesktop.dbus.types.Variant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

/**
 * Sample code to connect to the dbus and retrieve information from the <b>Rhythmbox</b> player:
 * <ul>
 *     <li>media player name</li>
 *     <li>playback status</li>
 *     <li>currently playing song details</li>
 * </ul>
 */
public class QueryPlayerState {
    private static Logger logger  = LoggerFactory.getLogger(QueryPlayerState.class);

    public static void main(String[] args) {
        try (DBusConnection dbus = DBusConnectionBuilder.forSessionBus().build()) {
            // get current player state, you could use the unique bus name as well (ex. 1.1468)
            Properties properties = dbus.getRemoteObject("org.mpris.MediaPlayer2.rhythmbox", "/org/mpris/MediaPlayer2", Properties.class);
            String identity = properties.Get("org.mpris.MediaPlayer2", "Identity");
            logger.info("identity: {}", identity);
            String playbackStatus = properties.Get("org.mpris.MediaPlayer2.Player", "PlaybackStatus");
            logger.info("playback status: {}", playbackStatus);
            Map<String, Variant> metadata = properties.Get("org.mpris.MediaPlayer2.Player", "Metadata");
            logger.info("metadata: {}", metadata);
        } catch (Exception e) {
            logger.error("unable to interact with the dbus", e);
        }
    }
}
