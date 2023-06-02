package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.time.Duration;
import java.time.Instant;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Periodically deletes any downloaded album art that has not been loaded
 * by the media player conky in a given amount of time.
 */
public class AlbumArtHouseKeeper implements Runnable {
    private static final Logger logger = LoggerFactory.getLogger(AlbumArtHouseKeeper.class);
    private String directory;
    private int threshold;
    private MusicPlayerDatabase db;

    /**
     * Creates a new instance of this album housekeeper thread
     *
     * @param directory      directory where album art is stored
     * @param threshold      cutoff in minutes to determine old files
     * @param playerDatabase database of available music players
     */
    public AlbumArtHouseKeeper(String directory, int threshold, MusicPlayerDatabase playerDatabase) {
        this.directory = directory;
        this.threshold = threshold;
        this.db = playerDatabase;
    }

    @Override
    public void run() {
        logger.debug("deleting old album art");
        // get current music player images in use, we don't want to delete this
        Set<String> imagesInUse = db.getAlbumArtPaths();
        Instant now = Instant.now();

        try {
            Files.list(Path.of(directory))
                 .filter(p -> p.getFileName().toString().startsWith(MusicPlayerWriter.ALBUM_ART))
                 .collect(Collectors.toList())
                 .stream()
                 .forEach(image -> {
                    try {
                        BasicFileAttributes attributes = Files.readAttributes(image, BasicFileAttributes.class);
                        Instant lastAccessTime = attributes.lastAccessTime().toInstant();
                        long minutes = Duration.between(lastAccessTime, now).toMinutes();

                        if (minutes > threshold && !imagesInUse.contains(image.toString())) {
                            logger.debug("deleting file: {}", image.getFileName());
                            logger.debug("last access time was: {}, ie. {} minutes ago", lastAccessTime, minutes);
                            Files.deleteIfExists(image);
                        }
                    } catch (IOException e) {
                        logger.error("unable to delete image file", e);
                    }
                 });
        } catch (IOException e) {
            logger.error("unable to iterate through the output folder for old image files", e);
        }
    }
}
