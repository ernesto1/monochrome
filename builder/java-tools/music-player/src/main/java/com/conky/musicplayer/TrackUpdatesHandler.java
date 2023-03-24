package com.conky.musicplayer;

import org.freedesktop.dbus.DBusMap;
import org.freedesktop.dbus.handlers.AbstractPropertiesChangedHandler;
import org.freedesktop.dbus.interfaces.Properties;
import org.freedesktop.dbus.types.Variant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Map;

/**
 * Handler for analyzing media player property change signals.<br>
 * Updates related to the currently playing track will be reflected in the conky media player files.
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html">MPRIS Player Inteface</a>
 */
public class TrackUpdatesHandler extends AbstractPropertiesChangedHandler {
    private static Logger logger = LoggerFactory.getLogger(TrackUpdatesHandler.class);
    private String title;
    private String artist;
    private String album;
    private String genre;
    private String playbackStatus;
    /**
     * File path of the cover art image
     */
    private String coverArtPath;

    public TrackUpdatesHandler() {
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

            // TODO if a different player is introduced, it will not send a "current state" track message, you need to pull this yourself
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

        // TODO add support for images on the web (spotify)
        value = (Variant<String>) metadata.get("mpris:artUrl");
        if (value != null) {
            coverArtPath = value.getValue();
            coverArtPath = coverArtPath.replaceFirst("file://", "");   // remove file uri notation
        }

        logger.info("track change: {} | {} | {} | {} | {}", artist, title, album, genre, coverArtPath);
        writeTrackInfo();
    }

    private void writeTrackInfo() {
        writeFile("artist", artist);
        writeFile("title", title);
        writeFile("album", album);
        writeFile("genre", genre);

        if (coverArtPath != null) {
            writeFile("albumArtPath", coverArtPath);
        } else {
            Path coverArt = Paths.get("/tmp", "mediaplayer.albumArtPath");
            try {
                Files.deleteIfExists(coverArt);
            } catch (IOException e) {
                logger.error("unable to delete cover art file", e);
            }
        }
    }

    private void writeFile(String filename, String data) {
        try {
            Path artistPath = Paths.get("/tmp", "mediaplayer." + filename);
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
