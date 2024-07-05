package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedWriter;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.concurrent.ExecutorService;

public class MusicPlayerWriter {
    private static final Logger logger = LoggerFactory.getLogger(MusicPlayerWriter.class);
    public static final String FILE_PREFIX = "musicplayer";
    public static final String ALBUM_ART = FILE_PREFIX + ".albumArt";
    /**
     * Name of the file that contains the location on disk of the track's cover art
     */
    private static final String ALBUM_ART_PATH_FILENAME = "albumArtPath";
    /**
     * Directory to write all music player track info files to
     */
    private final String outputDirectory;
    private final String albumArtDirectory;
    private final ExecutorService executor;

    public MusicPlayerWriter(String outputDirectory, String albumArtDir, ExecutorService executor) {
        this.outputDirectory = outputDirectory;
        this.albumArtDirectory = albumArtDir;
        this.executor = executor;
    }

    /**
     * Creates the output directories if they do not exist
     * @throws IOException if a failure occurs while creating the directories
     */
    public void init() throws IOException {
        Path outputDir = Path.of(outputDirectory);
        Files.createDirectories(outputDir);
        Path albumArtDir = Path.of(albumArtDirectory);
        Files.createDirectories(albumArtDir);
    }

    public void writePlayerState(MusicPlayer player) {
        writeFile("name", player.getPlayerName());
        // convert playback status enum to 'Title Case'
        String playbackStatus = player.getPlaybackStatus().toString().toLowerCase();
        playbackStatus = playbackStatus.substring(0,1).toUpperCase() + playbackStatus.substring(1);
        writeFile("playbackStatus", playbackStatus);
        writeFile("artist", player.getArtist());
        writeFile("title", player.getTitle());
        writeFile("album", player.getAlbum());
        writeFile("genre", player.getGenre());

        try {
            if (player.getAlbumArtURL() != null) {
                URL coverArtURL = new URL(player.getAlbumArtURL());
                String albumArtFilePath;
                // is the album art in the local file system or on the web?
                if (coverArtURL.getProtocol().equals("file")) {
                    // image is in the local file system (ex. file://folder/image.jpg)
                    albumArtFilePath = coverArtURL.getFile();
                } else {
                    //                                             the id
                    //                                              /
                    // ex. https://i.scdn.co/image/ab67616d0000b273bbf0146981704a073405b6c2
                    String resourceLocation = coverArtURL.getFile();
                    String id = resourceLocation.substring(resourceLocation.lastIndexOf('/') + 1);    // get the resource name
                    Path imagePath = Path.of(albumArtDirectory, ALBUM_ART + "." + id);
                    executor.execute(new ImageDownloadTask(coverArtURL, imagePath));
                    albumArtFilePath = imagePath.toString();
                }

                writeFile(ALBUM_ART_PATH_FILENAME, albumArtFilePath);
            } else {
                // if no album art is available, delete the conky album art path file
                Path coverArt = Path.of(outputDirectory, FILE_PREFIX + "." + ALBUM_ART_PATH_FILENAME);
                try {
                    Files.deleteIfExists(coverArt);
                } catch (IOException e) {
                    logger.error("unable to delete the album art file", e);
                }
            }
        } catch (MalformedURLException e) {
            logger.error("incorrect album art URL given by the music player", e);
        }

        logger.debug("wrote track info to disk");
    }

    private void writeFile(String filename, String data) {
        try {
            Path filePath = Path.of(outputDirectory, FILE_PREFIX + "." + filename);
            BufferedWriter writer = Files.newBufferedWriter(filePath,
                                                            StandardOpenOption.CREATE,
                                                            StandardOpenOption.WRITE,
                                                            StandardOpenOption.TRUNCATE_EXISTING);
            writer.write(data);
            writer.close();
        } catch (IOException e) {
            logger.error("unable to write to the '{}' file", filename, e);
        }
    }
}