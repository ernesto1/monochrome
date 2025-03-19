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

/**
 * Writes the state of a music player object to disk
 */
public class MusicPlayerWriter {
    private static final Logger logger = LoggerFactory.getLogger(MusicPlayerWriter.class);
    /**
     * File prefix to use for the output files: {@value}
     */
    public static final String FILE_PREFIX = "musicplayer.";
    public static final String TRACK_PREFIX = "track.";
    public static final String ALBUM_ART = "albumArt";
    /**
     * Name of the file that contains the location on disk of the track's cover art
     */
    public static final String ALBUM_ART_PATH_FILENAME = "albumArtPath";
    public static final String ALBUM_ART_SYMLINK_FILENAME = "nowPlaying";

    /**
     * Directory to write all music player track info metadata files to
     */
    private final Path outputDir;
    /**
     * Album art image cache directory
     */
    private final Path albumArtDir;
    private final ExecutorService webArtExecutor;

    public MusicPlayerWriter(String outputDirectory, String albumArtDirectory, ExecutorService webArtExecutor) {
        outputDir = Path.of(outputDirectory);
        albumArtDir = Path.of(albumArtDirectory);
        this.webArtExecutor = webArtExecutor;
    }

    /**
     * Writes the state of the given player to disk.<br>
     * This will create/overwrite the individual music player files that conky reads.
     * @param player music player metadata
     */
    public void writePlayerState(MusicPlayer player) {
        String albumArtFilePath = resolveAlbumArt(player.getAlbumArtURL());
        logger.debug("writing track details for {}", player.getTitle());

        if (player.getStatus().equals(MusicPlayer.Status.OFF)) {
            deleteMetadataFiles(outputDir);
            writeFile("status", player.getStatus().toString().toLowerCase());
        } else {
            writeFile("name", player.getPlayerName());
            // convert playback status enum to 'Title Case'
            String playbackStatus = player.getPlaybackStatus().toString().toLowerCase();
            playbackStatus = playbackStatus.substring(0,1).toUpperCase() + playbackStatus.substring(1);
            writeFile("playbackStatus", playbackStatus);
            writeFile("status", player.getStatus().toString().toLowerCase());
            writeFile(TRACK_PREFIX + "artist", player.getArtist());
            writeFile(TRACK_PREFIX + "title", player.getTitle());
            writeFile(TRACK_PREFIX + "album", player.getAlbum());
            writeFile(TRACK_PREFIX + "genre", player.getGenre());
            writeFile(TRACK_PREFIX + ALBUM_ART_PATH_FILENAME, albumArtFilePath);
        }

        logger.debug("wrote track info to disk");
    }

    /**
     * Returns the location of the album art on disk.<br>
     * If the album art is available on the web, the file will be downloaded to disk.
     * @param url URL of the album image file
     * @return the full file path on disk to the album art image file, otherwise <code>null</code> if no album art
     * is available for this track
     */
    private String resolveAlbumArt(String url) {
        // is the album art in the local file system or on the web?
        String albumArtFilePath = null;

        try {
            if (url != null) {
                URL coverArtURL = new URL(url);

                // image is in the local file system (ex. file://folder/image.jpg)
                if (coverArtURL.getProtocol().equals("file")) {
                    albumArtFilePath = coverArtURL.getFile();
                } else {
                    // image is on the web                         the id
                    //                                              /
                    // ex. https://i.scdn.co/image/ab67616d0000b273bbf0146981704a073405b6c2
                    String resourceLocation = coverArtURL.getFile();
                    String id = resourceLocation.substring(resourceLocation.lastIndexOf('/') + 1);    // get the resource name
                    Path imagePath = albumArtDir.resolve(ALBUM_ART + "." + id);
                    webArtExecutor.submit(new ImageDownloadTask(coverArtURL, imagePath));
                    albumArtFilePath = imagePath.toString();
                }

                createSymbolicLink(albumArtFilePath);
            } else {
                // if no album art is available, delete the conky album art files
                try {
                    logger.debug("track has no album art, deleting cover art related files");
                    Path file = outputDir.resolve(FILE_PREFIX + TRACK_PREFIX + ALBUM_ART_PATH_FILENAME);
                    Files.deleteIfExists(file);
                    file = albumArtDir.resolve(ALBUM_ART_SYMLINK_FILENAME);
                    Files.deleteIfExists(file);
                } catch (IOException e) {
                    logger.error("unable to delete the album art file", e);
                }
            }
        } catch (MalformedURLException e) {
            logger.error("incorrect album art URL given by the music player", e);
        }

        return albumArtFilePath;
    }

    /**
     * Creates a symbolic link pointing to the current track's album art.<br>
     * This is a conveniance feature for conkys that are unable to use lua functions and require a hardcoded file path.
     * @param albumArtFilePath full path to the image file
     */
    private void createSymbolicLink(String albumArtFilePath) {
        logger.debug("updating image symbolic link to {}", albumArtFilePath);
        Path slCoverArt = albumArtDir.resolve(ALBUM_ART_SYMLINK_FILENAME);

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

        Path filePath = outputDir.resolve(FILE_PREFIX + filename);
        try (BufferedWriter writer = Files.newBufferedWriter(filePath,
                                                             StandardOpenOption.CREATE,
                                                             StandardOpenOption.WRITE,
                                                             StandardOpenOption.TRUNCATE_EXISTING)) {
            writer.write(data);
        } catch (IOException e) {
            logger.error("unable to write to the '{}' file", filename, e);
        }
    }

    /**
     * Deletes all the music player metadata files in the given directory
     * @param dir directory to delete files from
     */
    public static void deleteMetadataFiles(Path dir) {
        try {
            Files.list(dir)
                 .filter(p -> p.getFileName().toString().startsWith(MusicPlayerWriter.FILE_PREFIX))
                 .forEach(file -> {
                    try {
                        logger.debug("deleting the output file: {}", file);
                        Files.deleteIfExists(file);
                    } catch (IOException e) {
                        logger.error("unable to delete file", e);
                    }
                 });
        } catch (IOException e) {
            logger.error("unable to list the output directory {} contents", dir, e);
        }
    }
}