package com.conky.musicplayer;

import org.freedesktop.dbus.handlers.AbstractSignalHandlerBase;
import org.freedesktop.dbus.interfaces.DBus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Detects when a music player is closed by the user by analyzing the <tt>dbus name owner changed</tt> signal.<br>
 * <br>
 * The signal contains three arguments:
 * <pre>
 * bus name                             old owner   new owner
 * --------------------------------     ---------   ---------
 * org.mpris.MediaPlayer2.rhythmbox                 :3.456      app was opened
 * org.mpris.MediaPlayer2.rhythmbox     :3.456                  app was closed
 * </pre>
 *
 * Closed music players are removed from the {@link MusicPlayerDatabase database of available players}.
 *
 * @see <a href="https://dbus.freedesktop.org/doc/dbus-specification.html#bus-messages-name-owner-changed">Name owner changed signal</a>
 */
public class AvailabilityHandler extends AbstractSignalHandlerBase<DBus.NameOwnerChanged> {
    private static Logger logger  = LoggerFactory.getLogger(AvailabilityHandler.class);
    private MusicPlayerDatabase playerDatabase;
    private MusicPlayerWriter writer;

    public AvailabilityHandler(MusicPlayerDatabase playerDatabase, MusicPlayerWriter writer) {
        this.playerDatabase = playerDatabase;
        this.writer = writer;
    }

    @Override
    public Class<DBus.NameOwnerChanged> getImplementationClass() {
        return DBus.NameOwnerChanged.class;
    }

    @Override
    public void handle(DBus.NameOwnerChanged signal) {
        // weed out signals for bus names we are not interested in
        if (!signal.name.startsWith("org.mpris.MediaPlayer2")) {
            return;
        }

        logger.debug("signal: {} | {} | {} | '{}' | '{}'",
                     signal.getSource(),
                     signal.getPath(),
                     signal.name,
                     signal.oldOwner,
                     signal.newOwner);

        if (!signal.oldOwner.isEmpty() && signal.newOwner.isEmpty()) {
            String playerName = signal.name.substring(signal.name.lastIndexOf('.') + 1);

            if (playerDatabase.isMusicPlayer(playerName)) {
                logger.info("the '{}' music player is no longer running", playerName);
                playerDatabase.removePlayer(signal.oldOwner);
                writer.writePlayerState(playerDatabase.getActivePlayer());
            }
        }
    }
}
