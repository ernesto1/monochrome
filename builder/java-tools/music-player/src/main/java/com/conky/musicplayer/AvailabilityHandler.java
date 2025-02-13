package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.exceptions.DBusException;
import org.freedesktop.dbus.handlers.AbstractSignalHandlerBase;
import org.freedesktop.dbus.interfaces.DBus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Arrays;

/**
 * Module responsible for detecting music player life cycle related events, ie:
 * <ul>
 *     <li>A music player being launched</li>
 *     <li>A music player being closed</li>
 *     <li>Music players already running upon application boot</li>
 * </ul>
 * Music players of interest are registered into the system for status updates tracking.
 */
public class AvailabilityHandler extends AbstractSignalHandlerBase<DBus.NameOwnerChanged> {
    private static final Logger logger = LoggerFactory.getLogger(AvailabilityHandler.class);

    /**
     * Connection to the dbus
     */
    private DBusConnection conn;
    private MusicPlayerDatabase playerDatabase;
    private final Registrar registrar;

    public AvailabilityHandler(DBusConnection conn, Registrar registrar, MusicPlayerDatabase playerDatabase) {
        this.conn = conn;
        this.registrar = registrar;
        this.playerDatabase = playerDatabase;
    }

    @Override
    public Class<DBus.NameOwnerChanged> getImplementationClass() {
        return DBus.NameOwnerChanged.class;
    }

    /**
     * Detects when a music player is launched or closed by the user by listening
     * to the <code>dbus name owner changed</code> signal.<br>
     * <br>
     * The signal contains three attributes:
     * <pre>
     * bus name                             old owner   new owner
     * --------------------------------     ---------   ---------
     * org.mpris.MediaPlayer2.rhythmbox                 :3.456      app was opened
     * org.mpris.MediaPlayer2.rhythmbox     :3.456                  app was closed
     * </pre>
     *
     * New music players are registered into the system for status updates tracking.<br>
     * Closed players are deregistered from the system.
     *
     * @see <a href="https://dbus.freedesktop.org/doc/dbus-specification.html#bus-messages-name-owner-changed">Name owner changed signal</a>
     */
    @Override
    public void handle(DBus.NameOwnerChanged signal) {
        // weed out signals for well known names we are not interested in
        if (!signal.name.startsWith("org.mpris.MediaPlayer2")) {
            return;
        }

        logger.debug("signal: {} | {} | {} | '{}' | '{}'",
                     signal.getSource(),
                     signal.getPath(),
                     signal.name,
                     signal.oldOwner,
                     signal.newOwner);

        // application has started
        if (!signal.newOwner.isEmpty() && signal.oldOwner.isEmpty()) {
            logger.info("a new media player has been launched");
            registrar.register(signal.newOwner);
        } else if (signal.newOwner.isEmpty() && !signal.oldOwner.isEmpty()) {
            // application has shutdown
            String playerName = signal.name.substring(signal.name.lastIndexOf('.') + 1);

            if (playerDatabase.contains(signal.oldOwner)) {
                logger.info("the '{}' music player is no longer running", playerName);
                registrar.unregister(signal.oldOwner);
            }
        }
    }

    /**
     * Scans the list of available application <i>well known names</i> in the dbus for entries
     * belonging to the <code>org.mpris.MediaPlayer2</code> family.  Any {@link Registrar#isSupported(String) supported}
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
