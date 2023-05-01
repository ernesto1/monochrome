package com.conky.musicplayer;

import org.freedesktop.dbus.DBusMap;
import org.freedesktop.dbus.handlers.AbstractPropertiesChangedHandler;
import org.freedesktop.dbus.interfaces.Properties;
import org.freedesktop.dbus.types.Variant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;
import java.util.Optional;

/**
 * Handler for analyzing media player property change signals, ie. <tt>org.freedesktop.DBus.Properties.PropertiesChanged</tt>.<br>
 * Updates related to a music player's state (ex. song change, pausing, playing music) will be saved on the {@link MusicPlayerDatabase database}.
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html">MPRIS Player Inteface</a>
 */
public class TrackUpdatesHandler extends AbstractPropertiesChangedHandler {
    private static final Logger logger = LoggerFactory.getLogger(TrackUpdatesHandler.class);

    private MetadataRetriever metadataRetriever;
    private final MusicPlayerDatabase playerDatabase;

    /**
     * Creates a new instance of this property change handler
     *
     * @param retriever      music player dbus metadata retriever
     * @param database       music player database to store running player details
     */
    public TrackUpdatesHandler(MetadataRetriever retriever, MusicPlayerDatabase database) {
        this.metadataRetriever = retriever;
        playerDatabase = database;
    }

    @Override
    public void handle(Properties.PropertiesChanged signal) {
        // TODO can we use signal matcher rules instead?
        // ignore signals for interfaces we are not interested in
        if (!signal.getPath().equals("/org/mpris/MediaPlayer2")) {
            return;
        }
        
        logger.debug("signal: {} {}", signal.getSource(), signal.getPropertiesChanged());
        String uniqueName = signal.getSource();

        // is this signal for a known player or a new one?
        if (playerDatabase.contains(uniqueName)) {
            MusicPlayer musicPlayer = playerDatabase.getPlayer(uniqueName);
            // retrieve available details from the signal
            Map<String, Variant<?>> properties = signal.getPropertiesChanged();
            boolean isPlayerStatusChanged = false;

            Variant<String> status = (Variant<String>) properties.get("PlaybackStatus");
            if (status != null) {
                musicPlayer.setPlaybackStatus(status.getValue());
                isPlayerStatusChanged = true;
            }

            Variant<DBusMap> metadata = (Variant<DBusMap>) properties.get("Metadata");
            if (metadata != null) {
                musicPlayer.setTrackInfo(metadataRetriever.getTrackInfo(metadata.getValue()));
                isPlayerStatusChanged = true;
            }

            if (isPlayerStatusChanged) {
                logger.info("{}", musicPlayer);
                playerDatabase.save(musicPlayer);
            }
        } else {
            // TODO detecting a brand new player should be the responsibility of the AvailabilityHandler, track updates should only deal with players we care about
            // brand new player
            String playerName;
            Optional<String> name = metadataRetriever.getPlayerName(signal.getSource());

            if (name.isPresent()) {
                playerName = name.get();
            } else {
                // for some signals, the owning dbus object won't exist any more by the time we try to get its name
                // ex. when closing a youtube tab, firefox sends a last signal prior to unregistering the object from the dbus
                logger.warn("unable to determine the media player's name, the signal will be ignored");
                return;
            }

            // is this signal from a music player supported by this application?
            if (!playerDatabase.isMusicPlayer(playerName)) {
                logger.debug("media player '{}' is not supported, ignoring signal", playerName);
                return;
            }

            // some signals may not contain the complete player state metadata (ex. playback status may come on its own)
            // so we pull all the player details from the dbus
            logger.debug("registering new player: {}", playerName);
            MusicPlayer musicPlayer = new MusicPlayer(playerName, signal.getSource());
            musicPlayer = metadataRetriever.getPlayerState(musicPlayer);
            playerDatabase.save(musicPlayer);
        }
    }
}
