package com.conky.musicplayer;

import org.freedesktop.dbus.DBusMap;
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
import java.util.Map;

/**
 * Handler for analyzing media player property change signals.<br>
 * Updates related to the currently playing track will be reflected in the conky media player files.
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html">MPRIS Player Inteface</a>
 */
public class TrackUpdatesHandler extends AbstractPropertiesChangedHandler {
    private static Logger logger = LoggerFactory.getLogger(TrackUpdatesHandler.class);
    public static final String FILE_PREFIX = "mediaplayer";
    private static final String ALBUM_ART_PATH = "albumArtPath";

    private final String outputDirectory;

    private String title;
    private String artist;
    private String album;
    private String genre;
    private String playbackStatus;
    /**
     * File path of the cover art image
     */
    private String coverArtPath;

    /**
     * Creates a new instance of this property change handler
     * @param directory directory to write output files to
     */
    public TrackUpdatesHandler(String directory) {
        outputDirectory = directory;
        resetState();
        writeTrackInfo();
        playbackStatus = "Stopped";
        writeFile("playbackStatus", playbackStatus);
    }

    private void resetState() {
        title = "unknown title";
        artist = "unknown artist";
        album = "unknown album";
        genre = "unknown genre";
        coverArtPath = null;
    }

    @Override
    public void handle(Properties.PropertiesChanged signal) {
        String dbusObject = signal.getPath();

        if (dbusObject.equals("/org/mpris/MediaPlayer2")) {
            logger.debug("signal: {} {}", signal.getSource(), signal.getPropertiesChanged());
            Map<String, Variant<?>> properties = signal.getPropertiesChanged();
            Variant<DBusMap> metadataProperty = (Variant<DBusMap>) properties.get("Metadata");
            updateTrackInfo(metadataProperty);

            // playback status may arrive on its own if the player was paused/stopped
            Variant<String> value = (Variant<String>) properties.get("PlaybackStatus");
            if (value != null) {
                playbackStatus = value.getValue();
                logger.info("playback status: {}", playbackStatus);
                writeFile("playbackStatus", playbackStatus);
            }

            // TODO if a different player sends a 'playing' msg, it will not send a "current state" track message, you need to pull this yourself
            // TODO if the player closes the track info should be deleted, otherwise the track info may remain in a playing state
        }
    }

    /**
     * Extracts song track information from the metadata property of the <tt>MediaPlayer2.Player</tt> interface.<br>
     * Song details are defined using `xesam` ontology.
     * @param metadataProperty metadata property as a map of key/value pairs
     * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Track_List_Interface.html#Mapping:Metadata_Map">Metadata map documentation</a>
     * @see <a href="https://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata/">MPRIS v2 metadata guidelines</a>
     */
    private void updateTrackInfo(Variant<DBusMap> metadataProperty) {
        if (metadataProperty == null) {
            return;
        }

        // assumption: if the metadata property is populated, there is a song change
        resetState();
        DBusMap metadata = metadataProperty.getValue();
        Variant<String> value = (Variant<String>) metadata.get("xesam:title");
        if (value != null) {
            title = value.getValue();
        }

        value = (Variant<String>) metadata.get("xesam:album");
        if (value != null) {
            album = value.getValue();
        }

        Variant<ArrayList<String>> values = (Variant<ArrayList<String>>) metadata.get("xesam:artist");
        if (values != null) {
            ArrayList<String> entries = values.getValue();
            artist = entries.get(0);
        }

        values = (Variant<ArrayList<String>>) metadata.get("xesam:genre");
        if (values != null) {
            ArrayList<String> entries = values.getValue();
            genre = entries.get(0);
        }

        value = (Variant<String>) metadata.get("mpris:artUrl");
        if (value != null) {
            coverArtPath = value.getValue();

            // is the album art on the web or in the local file system?
            if (coverArtPath.startsWith("http")) {
                coverArtPath = downloadAlbumArt(coverArtPath);
            } else {
                coverArtPath = coverArtPath.replaceFirst("file://", "");   // remove file uri notation
            }
        }

        logger.info("track change: {} | {} | {} | {} | {}", artist, title, album, genre, coverArtPath);
        writeTrackInfo();
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

    private void writeTrackInfo() {
        writeFile("artist", artist);
        writeFile("title", title);
        writeFile("album", album);
        writeFile("genre", genre);

        if (coverArtPath != null) {
            writeFile(ALBUM_ART_PATH, coverArtPath);
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
