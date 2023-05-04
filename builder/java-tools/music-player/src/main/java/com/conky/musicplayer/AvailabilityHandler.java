package com.conky.musicplayer;

import org.freedesktop.dbus.handlers.AbstractSignalHandlerBase;
import org.freedesktop.dbus.interfaces.DBus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * <b>DBus signal handler</b><br>
 * Detects when a music player is launched or closed by the user by listening
 * to the <tt>dbus name owner changed</tt> signal.<br>
 * <br>
 * The signal contains three arguments:
 * <pre>
 * bus name                             old owner   new owner
 * --------------------------------     ---------   ---------
 * org.mpris.MediaPlayer2.rhythmbox                 :3.456      app was opened
 * org.mpris.MediaPlayer2.rhythmbox     :3.456                  app was closed
 * </pre>
 *
 * New music players are registered into the system for status updates tracking.<br>
 * While closed players are deregistered from the system.
 *
 * @see <a href="https://dbus.freedesktop.org/doc/dbus-specification.html#bus-messages-name-owner-changed">Name owner changed signal</a>
 */
public class AvailabilityHandler extends AbstractSignalHandlerBase<DBus.NameOwnerChanged> {
    private static final Logger logger = LoggerFactory.getLogger(AvailabilityHandler.class);

    private MusicPlayerDatabase playerDatabase;
    private final Registrar registrar;


    public AvailabilityHandler(Registrar registrar, MusicPlayerDatabase playerDatabase) {
        this.registrar = registrar;
        this.playerDatabase = playerDatabase;
    }

    @Override
    public Class<DBus.NameOwnerChanged> getImplementationClass() {
        return DBus.NameOwnerChanged.class;
    }

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
}
