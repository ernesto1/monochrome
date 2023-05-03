package com.conky.musicplayer;

import org.freedesktop.dbus.handlers.AbstractSignalHandlerBase;
import org.freedesktop.dbus.interfaces.DBus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Optional;

/**
 * <b>DBus signal handler</b><br>
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
    private static final Logger logger = LoggerFactory.getLogger(AvailabilityHandler.class);
    private MusicPlayerDatabase playerDatabase;
    private MetadataRetriever metadataRetriever;

    public AvailabilityHandler(MetadataRetriever metadataRetriever, MusicPlayerDatabase playerDatabase) {
        this.metadataRetriever = metadataRetriever;
        this.playerDatabase = playerDatabase;
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

        // application has started
        if (!signal.newOwner.isEmpty() && signal.oldOwner.isEmpty()) {
            logger.info("new music player has been launched");
            String playerName;
            Optional<String> name = metadataRetriever.getPlayerName(signal.newOwner);

            if (name.isPresent()) {
                playerName = name.get();
            } else {
                // for some signals, the owning dbus object won't exist any more by the time we try to get its name
                // ex. when closing a youtube tab, firefox sends a last signal prior to unregistering the object from the dbus
                logger.warn("unable to determine the music player's name, the signal will be ignored");
                return;
            }

            // is this signal from a music player supported by this application?
            if (!playerDatabase.isMusicPlayer(playerName)) {
                logger.debug("music player '{}' is not supported, ignoring signal", playerName);
                return;
            }

            // some signals may not contain the complete player state metadata (ex. playback status may come on its own)
            // so we pull all the player details from the dbus
            logger.debug("registering new player: {}", playerName);
            MusicPlayer musicPlayer = new MusicPlayer(playerName, signal.newOwner);
            musicPlayer = metadataRetriever.getPlayerState(musicPlayer);
            playerDatabase.save(musicPlayer);
            // TODO register for properties changed signal for this application
        } else if (!signal.oldOwner.isEmpty() && signal.newOwner.isEmpty()) {
            // application has shutdown
            String playerName = signal.name.substring(signal.name.lastIndexOf('.') + 1);

            if (playerDatabase.isMusicPlayer(playerName)) {
                logger.info("the '{}' music player is no longer running", playerName);
                playerDatabase.removePlayer(signal.oldOwner);
            }
        }
    }
}
