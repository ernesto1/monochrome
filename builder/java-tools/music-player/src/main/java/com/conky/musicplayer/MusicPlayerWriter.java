package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;

public class MusicPlayerWriter {
    private static final Logger logger = LoggerFactory.getLogger(MusicPlayerWriter.class);
    public static final String FILE_PREFIX = "musicplayer";
    public static final String ALBUM_ART = FILE_PREFIX + ".albumArt";
    private static final String ALBUM_ART_PATH = "albumArtPath";
    private final String outputDirectory;

    public MusicPlayerWriter(String outputDirectory) {
        this.outputDirectory = outputDirectory;
    }

    /**
     * Creates the output directory if it does not exist
     * @throws IOException
     */
    public void init() throws IOException {
        Path outputDirPath = Paths.get(outputDirectory);

        if (!Files.isDirectory(outputDirPath)) {
            logger.info("creating the output directory: {}", outputDirPath);
            Files.createDirectories(outputDirPath);
        }
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

        if (player.getAlbumArtPath() != null) {
            writeFile(ALBUM_ART_PATH, player.getAlbumArtPath());
        } else {
            // if no album art is available, delete the corresponding album art file
            Path coverArt = Paths.get(outputDirectory, FILE_PREFIX + "." + ALBUM_ART_PATH);
            try {
                Files.deleteIfExists(coverArt);
            } catch (IOException e) {
                logger.error("unable to delete the album art file", e);
            }
        }

        logger.debug("writing track info to files completed");
    }

    private void writeFile(String filename, String data) {
        try {
            Path filePath = Paths.get(outputDirectory, FILE_PREFIX + "." + filename);
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
