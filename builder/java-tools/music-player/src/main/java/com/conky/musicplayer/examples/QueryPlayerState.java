package com.conky.musicplayer.examples;

import com.conky.musicplayer.MPRIS;
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
            Properties object = dbus.getRemoteObject("org.mpris.MediaPlayer2.rhythmbox",
                                                         MPRIS.Objects.MEDIAPLAYER2,
                                                         Properties.class);
            String identity = object.Get(MPRIS.Interfaces.MEDIAPLAYER2, MPRIS.Properties.IDENTITY);
            logger.info("identity: {}", identity);
            String playbackStatus = object.Get(MPRIS.Interfaces.MEDIAPLAYER2_PLAYER, MPRIS.Properties.PLAYBACK_STATUS);
            logger.info("playback status: {}", playbackStatus);
            Map<String, Variant> metadata = object.Get(MPRIS.Interfaces.MEDIAPLAYER2_PLAYER, MPRIS.Properties.METADATA);
            logger.info("metadata: {}", metadata);
            logger.info("{}", metadata.get("xesam:artist"));
        } catch (Exception e) {
            logger.error("unable to interact with the dbus", e);
        }
    }
}
