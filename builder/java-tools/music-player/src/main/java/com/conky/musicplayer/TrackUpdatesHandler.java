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

        // is this signal from a supported music player?
        logger.debug("signal: {} {}", signal.getSource(), signal.getPropertiesChanged());
        String playerName;
        Optional<String> name = metadataRetriever.getPlayerName(signal.getSource());

        if (name.isPresent()) {
            playerName = name.get();
        } else {
            // for some signals, the owning dbus object won't exist any more by the time we try to get its name
            // ex. when closing a youtube tab, firefox sends a last signal prior to unregistering the corresponding dbus name
            logger.warn("unable to determine the media player's name, the signal will be ignored");
            return;
        }

        if (!playerDatabase.isMusicPlayer(playerName)) {
            logger.debug("media player '{}' is not supported, ignoring signal", playerName);
            return;
        }

        MusicPlayer musicPlayer;

        // is this a known player or a new one?
        if (playerDatabase.contains(playerName)) {
            musicPlayer = playerDatabase.getPlayer(playerName);
            // retrieve available details from the signal
            Map<String, Variant<?>> properties = signal.getPropertiesChanged();

            String playbackStatus = null;
            Variant<String> status = (Variant<String>) properties.get("PlaybackStatus");
            if (status != null) {
                playbackStatus = status.getValue();
            }

            TrackInfo trackInfo = null;
            Variant<DBusMap> metadata = (Variant<DBusMap>) properties.get("Metadata");
            if (metadata != null) {
                trackInfo = metadataRetriever.getTrackInfo(metadata.getValue());
            }

            boolean isPlayerStatusChanged = musicPlayer.setPlaybackStatus(playbackStatus);
            isPlayerStatusChanged = musicPlayer.setTrackInfo(trackInfo) || isPlayerStatusChanged;

            if (isPlayerStatusChanged) {
                logger.info("{}", musicPlayer);
            }
        } else {
            // brand new player
            // some signals may not contain the complete player state metadata (ex. playback status may come on its own)
            // so we pull all the player details from the dbus
            logger.debug("registering new player: {}", playerName);
            musicPlayer = new MusicPlayer(playerName, signal.getSource());
            musicPlayer = metadataRetriever.getPlayerState(musicPlayer);
            playerDatabase.save(musicPlayer);
        }

        playerDatabase.save(musicPlayer);
    }
}
