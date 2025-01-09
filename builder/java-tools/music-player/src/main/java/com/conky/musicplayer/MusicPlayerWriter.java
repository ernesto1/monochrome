package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedWriter;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.concurrent.ExecutorService;

public class MusicPlayerWriter {
    private static final Logger logger = LoggerFactory.getLogger(MusicPlayerWriter.class);
    public static final String FILE_PREFIX = "musicplayer";
    public static final String ALBUM_ART = FILE_PREFIX + ".albumArt";
    /**
     * Name of the file that contains the location on disk of the track's cover art
     */
    public static final String ALBUM_ART_PATH_FILENAME = "albumArtPath";
    public static final String ALBUM_ART_SYMLINK_FILENAME = "nowPlaying";

    /**
     * Directory to write all music player track info files to
     */
    private final String outputDirectory;
    private final String albumArtDirectory;
    private final ExecutorService webArtExecutor;

    public MusicPlayerWriter(String outputDirectory, String albumArtDir, ExecutorService webArtExecutor) {
        this.outputDirectory = outputDirectory;
        this.albumArtDirectory = albumArtDir;
        this.webArtExecutor = webArtExecutor;
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

    /**
     * Writes the state of the given player to disk.<br>
     * This will create/overwrite the individual music player files that conky reads.
     * @param player music player metadata
     */
    public void writePlayerState(MusicPlayer player) {
        String albumArtFilePath = null;    // the album art file path has to be figured out
        // is the album art in the local file system or on the web?
        try {
            if (player.getAlbumArtURL() != null) {
                URL coverArtURL = new URL(player.getAlbumArtURL());

                // image is in the local file system (ex. file://folder/image.jpg)
                if (coverArtURL.getProtocol().equals("file")) {
                    albumArtFilePath = coverArtURL.getFile();
                } else {
                    // image is on the web                         the id
                    //                                              /
                    // ex. https://i.scdn.co/image/ab67616d0000b273bbf0146981704a073405b6c2
                    String resourceLocation = coverArtURL.getFile();
                    String id = resourceLocation.substring(resourceLocation.lastIndexOf('/') + 1);    // get the resource name
                    Path imagePath = Path.of(albumArtDirectory, ALBUM_ART + "." + id);
                    webArtExecutor.submit(new ImageDownloadTask(coverArtURL, imagePath));
                    albumArtFilePath = imagePath.toString();
                }

                createSymbolicLink(albumArtFilePath);
            } else {
                // if no album art is available, delete the conky album art files
                try {
                    logger.debug("track has no album art, deleting cover art related files");
                    Path file = Path.of(outputDirectory, FILE_PREFIX + "." + ALBUM_ART_PATH_FILENAME);
                    Files.deleteIfExists(file);
                    file = Paths.get(albumArtDirectory, ALBUM_ART_SYMLINK_FILENAME);
                    Files.deleteIfExists(file);
                } catch (IOException e) {
                    logger.error("unable to delete the album art file", e);
                }
            }
        } catch (MalformedURLException e) {
            logger.error("incorrect album art URL given by the music player", e);
        }

        logger.debug("writing track details for {}", player.getTitle());
        writeFile("name", player.getPlayerName());
        // convert playback status enum to 'Title Case'
        String playbackStatus = player.getPlaybackStatus().toString().toLowerCase();
        playbackStatus = playbackStatus.substring(0,1).toUpperCase() + playbackStatus.substring(1);
        writeFile("playbackStatus", playbackStatus);
        writeFile("artist", player.getArtist());
        writeFile("title", player.getTitle());
        writeFile("album", player.getAlbum());
        writeFile("genre", player.getGenre());
        writeFile(ALBUM_ART_PATH_FILENAME, albumArtFilePath);
        logger.debug("wrote track info to disk");
    }

    /**
     * Creates a symbolic link pointing to the current track's album art.<br>
     * This is a conveniance feature for conkys that are unable to use lua functions and require a hardcoded file path.
     * @param albumArtFilePath full path to the image file
     */
    private void createSymbolicLink(String albumArtFilePath) {
        logger.debug("updating image symbolic link to {}", albumArtFilePath);
        Path slCoverArt = Paths.get(albumArtDirectory, ALBUM_ART_SYMLINK_FILENAME);

        try {
            Files.deleteIfExists(slCoverArt);
            Files.createSymbolicLink(slCoverArt, Path.of(albumArtFilePath));
        } catch (IOException e) {
            logger.error("unable to create symbolic link for the currently playing track album, the cover art image is now stale");
        }

        logger.debug("symlink has been refreshed");
    }

    private void writeFile(String filename, String data) {
        if (data == null) {
            return;
        }

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