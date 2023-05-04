package com.conky.musicplayer.examples;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.interfaces.DBus;
import org.freedesktop.dbus.interfaces.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Arrays;

/**
 * Connect to the dbus and list the current available music players
 */
public class ListMusicPlayers {
    private static Logger logger = LoggerFactory.getLogger(ListMusicPlayers.class);

    public static void main(String[] args) {
        try (DBusConnection conn = DBusConnectionBuilder.forSessionBus().build()) {
            DBus dbus = conn.getRemoteObject("org.freedesktop.DBus", "/org/freedesktop/DBus", DBus.class);
            logger.info("Available media players:");
            String[] names = dbus.ListNames();
            Arrays.stream(names)
                  .filter(name -> name.startsWith("org.mpris.MediaPlayer2"))
                  .forEach(name -> {
                      String owner = dbus.GetNameOwner(name);
                      logger.info("{} {}", name, owner);
                  });
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
