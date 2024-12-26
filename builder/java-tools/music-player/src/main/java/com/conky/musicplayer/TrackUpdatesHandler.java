package com.conky.musicplayer;

import org.freedesktop.dbus.handlers.AbstractPropertiesChangedHandler;
import org.freedesktop.dbus.interfaces.Properties;
import org.freedesktop.dbus.types.Variant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * Handler for analyzing media player property change signals, ie. <tt>org.freedesktop.DBus.Properties.PropertiesChanged</tt>.<br>
 * Updates related to a music player's state (ex. song change, pausing, playing music) will be saved on the {@link MusicPlayerDatabase database}.
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html">MPRIS Player Inteface</a>
 */
public class TrackUpdatesHandler extends AbstractPropertiesChangedHandler {
    private static final Logger logger = LoggerFactory.getLogger(TrackUpdatesHandler.class);

    private MetadataRetriever metadataRetriever;
    private final MusicPlayerDatabase playerDatabase;
    private final ThreadPoolExecutor signalExecutor;

    /**
     * Creates a new instance of this property change handler
     *
     * @param retriever      music player dbus metadata retriever
     * @param database       music player database to store running player details
     */
    public TrackUpdatesHandler(MetadataRetriever retriever, MusicPlayerDatabase database, ThreadPoolExecutor signalExecutor) {
        this.metadataRetriever = retriever;
        playerDatabase = database;
        this.signalExecutor = signalExecutor;
    }

    @Override
    public void handle(Properties.PropertiesChanged signal) {
        logger.debug("signal: {} {}", signal.getSource(), signal.getPropertiesChanged());
        String playerName = signal.getSource();
        Map<String, Variant<?>> properties = signal.getPropertiesChanged();

        // is this signal for a registered player?
        if (playerDatabase.contains(playerName) && (properties.containsKey("PlaybackStatus") || properties.containsKey("Metadata"))) {
            // tread executor only has capacity for a single task, if we get a message burst
            // only the latest message (track update) will be kept
            signalExecutor.execute(new UpdateMusicPlayerTask(playerDatabase, metadataRetriever, signal));
        } else {
            logger.debug("signal was ignored");
        }
    }
}
