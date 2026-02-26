package com.conky.musicplayer;

import org.freedesktop.dbus.DBusMap;
import org.freedesktop.dbus.interfaces.Properties;
import org.freedesktop.dbus.types.Variant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

public class UpdateMusicPlayerTask implements Runnable {
    private static final Logger logger = LoggerFactory.getLogger(UpdateMusicPlayerTask.class);

    private final MetadataRetriever metadataRetriever;
    private final MusicPlayerDatabase playerDatabase;
    private final Properties.PropertiesChanged trackDetailsMsg;

    public UpdateMusicPlayerTask(MusicPlayerDatabase playerDatabase, MetadataRetriever metadataRetriever, Properties.PropertiesChanged trackDetailsMsg) {
        this.playerDatabase = playerDatabase;
        this.metadataRetriever = metadataRetriever;
        this.trackDetailsMsg = trackDetailsMsg;
    }

    @Override
    public void run() {
        String playerName = trackDetailsMsg.getSource();
        MusicPlayer musicPlayer = playerDatabase.getPlayer(playerName);
        // retrieve available details from the signal
        Map<String, Variant<?>> properties = trackDetailsMsg.getPropertiesChanged();
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
