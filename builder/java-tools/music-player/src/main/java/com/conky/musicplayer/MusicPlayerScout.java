package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.exceptions.DBusException;
import org.freedesktop.dbus.interfaces.DBus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Arrays;

/**
 * Detects currently running music players and adds them to the database
 */
public class MusicPlayerScout {
    private static final Logger logger = LoggerFactory.getLogger(MusicPlayerScout.class);

    private final Registrar registrar;
    /**
     * Connection to the dbus
     */
    private DBusConnection conn;

    public MusicPlayerScout(DBusConnection conn, Registrar registrar) {
        this.conn = conn;
        this.registrar = registrar;
    }

    /**
     * Scans the list of available application <i>well known names</i> in the dbus for entries
     * belonging to the <tt>org.mpris.MediaPlayer2</tt> family.  Any {@link MusicPlayerDatabase#isSupported(String) supported}
     * media players are registered in the database.
     */
    public void registerAvailablePlayers() {
        logger.info("detecting if any music players are already running");

        try {
            DBus dbus = conn.getRemoteObject("org.freedesktop.DBus", "/org/freedesktop/DBus", DBus.class);
            String[] names = dbus.ListNames();
            Arrays.stream(names)
                  .filter(name -> name.startsWith("org.mpris.MediaPlayer2"))
                  .forEach(name -> {
                      String uniqueName = dbus.GetNameOwner(name);
                      registrar.register(uniqueName);
                  });
        } catch (DBusException e) {
            logger.error("unable to register currently running music players", e);
        }
    }
}