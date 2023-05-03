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
        logger.debug("signal: {} {}", signal.getSource(), signal.getPropertiesChanged());
        String uniqueName = signal.getSource();

        // is this signal for a known player?
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
        }
    }
}
