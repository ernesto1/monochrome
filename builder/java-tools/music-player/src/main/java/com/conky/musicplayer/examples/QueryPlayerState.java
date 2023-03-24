package com.conky.musicplayer.examples;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.interfaces.Properties;
import org.freedesktop.dbus.types.Variant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

/**
 * Sample code to connect to the dbus and retrieve the currently playing song in <b>Rhythmbox</b>
 */
public class QueryPlayerState {
    private static Logger logger  = LoggerFactory.getLogger(QueryPlayerState.class);

    public static void main(String[] args) {
        try (DBusConnection dbus = DBusConnectionBuilder.forSessionBus().build()) {
            // get current player state
            Properties properties = dbus.getRemoteObject("org.mpris.MediaPlayer2.rhythmbox", "/org/mpris/MediaPlayer2", Properties.class);
            String playbackStatus = properties.Get("org.mpris.MediaPlayer2.Player", "PlaybackStatus");
            logger.info("playback status: {}", playbackStatus);
            Map<String, Variant> metadata = properties.Get("org.mpris.MediaPlayer2.Player", "Metadata");
            logger.info("metadata: {}", metadata);
        } catch (Exception e) {
            logger.error("unable to interact with the dbus", e);
        }
    }
}
