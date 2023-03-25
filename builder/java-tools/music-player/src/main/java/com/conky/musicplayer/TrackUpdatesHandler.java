package com.conky.musicplayer;

import org.freedesktop.dbus.DBusMap;
import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.exceptions.DBusException;
import org.freedesktop.dbus.handlers.AbstractPropertiesChangedHandler;
import org.freedesktop.dbus.interfaces.Properties;
import org.freedesktop.dbus.types.Variant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Handler for analyzing media player property change signals.<br>
 * Updates related to the currently playing track will be reflected in the conky media player files.
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html">MPRIS Player Inteface</a>
 */
public class TrackUpdatesHandler extends AbstractPropertiesChangedHandler {
    private static Logger logger = LoggerFactory.getLogger(TrackUpdatesHandler.class);
    public static final String FILE_PREFIX = "musicplayer";
    private static final String ALBUM_ART_PATH = "albumArtPath";

    private final String outputDirectory;
    private final DBusConnection dbus;
    // TODO player list should be coming from a config file
    /**
     * List of recognized music players.  Only signals from these players will be processed
     */
    private List<String> allowedPlayers;
    private MusicPlayer activePlayer;

    /**
     * Creates a new instance of this property change handler
     *
     * @param dbus  DBus connection
     * @param directory directory to write output files to
     */
    public TrackUpdatesHandler(DBusConnection dbus, String directory) {
        this.dbus = dbus;
        outputDirectory = directory;
        allowedPlayers = new ArrayList<>();
        allowedPlayers.add("rhythmbox");
        allowedPlayers.add("spotify");
        activePlayer = MusicPlayer.DUMMY_PLAYER;
    }

    public void init() {
        writePlayerState(activePlayer);
    }

    // TODO if the player closes the track info should be deleted, otherwise the track info may remain in a playing state

    @Override
    public void handle(Properties.PropertiesChanged signal) {
        // ignore signals for interfaces we are not interested in
        if (!signal.getPath().equals("/org/mpris/MediaPlayer2")) {
            return;
        }

        // is this signal from a recognizer music player?
        logger.debug("signal: {} {}", signal.getSource(), signal.getPropertiesChanged());
        String playerName = getPlayerName(signal.getSource());

        if (!allowedPlayers.contains(playerName.toLowerCase())) {
            logger.debug("media player '{}' is not supported, ignoring signal", playerName);
            return;
        }

        // process the signal and update the player state
        MusicPlayer player = new MusicPlayer();
        player.setPlayerName(playerName);
        Map<String, Variant<?>> properties = signal.getPropertiesChanged();

        Variant<String> value = (Variant<String>) properties.get("PlaybackStatus");
        if (value != null) {
            player.setPlaybackStatus(value.getValue());
        }

        Variant<DBusMap> metadataProperty = (Variant<DBusMap>) properties.get("Metadata");
        TrackInfo trackInfo = getTrackInfo(metadataProperty);
        player.setTrackInfo(trackInfo);

        // is this update for the current

        logger.info("{}", player);
        writePlayerState(player);
        activePlayer = player;
    }

    private String getPlayerName(String uniqueId) {
        String identity = "unrecognized";

        try {
            Properties properties = dbus.getRemoteObject(uniqueId, "/org/mpris/MediaPlayer2", Properties.class);
            identity = properties.Get("org.mpris.MediaPlayer2", "Identity");
        } catch (DBusException e) {
            logger.error("unable to determine the media player's name", e);
        }

        return identity;
    }

    /**
     * Extracts song track information <i>if it exists</i> from the metadata property of the <tt>MediaPlayer2.Player</tt> interface.<br>
     * Song details are defined using `xesam` ontology.
     *
     * @param metadataProperty the signal's metadata property as a map of key/value pairs
     * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Track_List_Interface.html#Mapping:Metadata_Map">Metadata map documentation</a>
     * @see <a href="https://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata/">MPRIS v2 metadata guidelines</a>
     */
    private TrackInfo getTrackInfo(Variant<DBusMap> metadataProperty) {
        if (metadataProperty == null) {
            return null;
        }

        TrackInfo trackInfo = new TrackInfo();
        DBusMap metadata = metadataProperty.getValue();

        Variant<String> value = (Variant<String>) metadata.get("xesam:title");
        if (value != null) {
            trackInfo.setTitle(value.getValue());
        }

        value = (Variant<String>) metadata.get("xesam:album");
        if (value != null) {
            trackInfo.setAlbum(value.getValue());
        }

        Variant<ArrayList<String>> values = (Variant<ArrayList<String>>) metadata.get("xesam:artist");
        if (values != null) {
            ArrayList<String> entries = values.getValue();
            trackInfo.setArtist(entries.get(0));
        }

        values = (Variant<ArrayList<String>>) metadata.get("xesam:genre");
        if (values != null) {
            ArrayList<String> entries = values.getValue();
            trackInfo.setGenre(entries.get(0));
        }

        value = (Variant<String>) metadata.get("mpris:artUrl");
        if (value != null) {
            String coverArtPath = value.getValue();

            // is the album art on the web or in the local file system?
            if (coverArtPath.startsWith("http")) {
                trackInfo.setAlbumArtPath(downloadAlbumArt(coverArtPath));
            } else {
                // imate is in the local file system (ex. file://folder/image.jpg), remove the uri notation
                trackInfo.setAlbumArtPath(coverArtPath.replaceFirst("file://", ""));
            }
        }

        return trackInfo;
    }

    /**
     * Attempts to download the album art from the web.  If an error occurs, no album art will be displayed
     * for this song.
     * @param url URL of the image to download
     * @return the location on disk of the downlaoded image
     */
    private String downloadAlbumArt(String url) {
        String id = url.substring(url.lastIndexOf('/') + 1);    // get the resource name
        Path albumArtPath = Paths.get(outputDirectory, FILE_PREFIX + ".albumArt." + id);

        if (Files.notExists(albumArtPath, LinkOption.NOFOLLOW_LINKS)) {
            try {
                ReadableByteChannel readableByteChannel = Channels.newChannel(new URL(url).openStream());
                FileOutputStream fileOutputStream = new FileOutputStream(albumArtPath.toFile());
                fileOutputStream.getChannel().transferFrom(readableByteChannel, 0, Long.MAX_VALUE);
                fileOutputStream.close();
            } catch (IOException e) {
                logger.error("unable to download the album art from the web");
                albumArtPath = null;
            }
        } else {
            logger.info("web album art is already part of the catalog, no need to download it again");
        }

        return albumArtPath != null ? albumArtPath.toString() : null;
    }

    private void writePlayerState(MusicPlayer player) {
        writeFile("name", player.getPlayerName());
        // convert playback status enum to 'Title Case'
        String playbackStatus = player.getPlaybackStatus().toString().toLowerCase();
        playbackStatus = playbackStatus.substring(0,1).toUpperCase() + playbackStatus.substring(1);
        writeFile("playbackStatus", playbackStatus);
        writeFile("artist", player.getArtist());
        writeFile("title", player.getTitle());
        writeFile("album", player.getAlbum());
        writeFile("genre", player.getGenre());

        if (player.getAlbumArtPath() != null) {
            writeFile(ALBUM_ART_PATH, player.getAlbumArtPath());
        } else {
            Path coverArt = Paths.get(outputDirectory, FILE_PREFIX + "." + ALBUM_ART_PATH);
            try {
                Files.deleteIfExists(coverArt);
            } catch (IOException e) {
                logger.error("unable to delete cover art file", e);
            }
        }
    }

    private void writeFile(String filename, String data) {
        try {
            Path artistPath = Paths.get(outputDirectory, FILE_PREFIX + "." + filename);
            BufferedWriter writer = Files.newBufferedWriter(artistPath,
                                                            StandardOpenOption.CREATE,
                                                            StandardOpenOption.WRITE,
                                                            StandardOpenOption.TRUNCATE_EXISTING);
            writer.write(data);
            writer.close();
        } catch (IOException e) {
            logger.error("unable to write '{}' file", filename, e);
        }
    }
}
