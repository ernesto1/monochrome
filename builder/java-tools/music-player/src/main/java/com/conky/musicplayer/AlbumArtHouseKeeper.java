package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.*;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static com.conky.musicplayer.MusicPlayerWriter.FILE_PREFIX;
import static java.nio.file.StandardWatchEventKinds.ENTRY_CREATE;
import static java.nio.file.StandardWatchEventKinds.OVERFLOW;

/**
 * Periodically deletes any downloaded album art that has not been loaded
 * by the media player conky in a given amount of time.
 */
public class AlbumArtHouseKeeper implements Runnable {
    private static final Logger logger = LoggerFactory.getLogger(AlbumArtHouseKeeper.class);
    private String directory;
    private int sizeLimit;
    private MusicPlayerDatabase db;
    private Pattern pattern;

    /**
     * Creates a new instance of this album housekeeper thread
     *
     * @param directory      directory where album art is stored
     * @param albumCacheSize
     * @param playerDatabase database of available music players
     */
    public AlbumArtHouseKeeper(String directory, int albumCacheSize, MusicPlayerDatabase playerDatabase) {
        this.directory = directory;
        sizeLimit = albumCacheSize;
        this.db = playerDatabase;
        pattern = Pattern.compile(FILE_PREFIX + "\\.albumArt"+ "\\.(?:(?!temp))");
    }

    @Override
    public void run() {
        logger.debug("watching the image cache directory: {}", directory);
        FileSystem fs = FileSystems.getDefault();
        WatchService ws;
        Path dir = fs.getPath(directory);

        try {
            ws = fs.newWatchService();
            dir.register(ws, ENTRY_CREATE);
        } catch (IOException e) {
            logger.error("unable to start the directory watch service for the album art cache", e);
            return;
        }

        while(true) {
            WatchKey key;

            try {
                key = ws.take();    // blocks until a new file is created in the directory
            } catch (InterruptedException e) {
                logger.debug("thread interrupted while listening for directory activity, shutting down");
                return;
            }

            for(WatchEvent event : key.pollEvents()) {
                WatchEvent.Kind kind = event.kind();
                // edge case: some events were lost
                if (kind == OVERFLOW) {
                    logger.error("event overflow :(");
                    continue;
                }

                Path filename = (Path) event.context();
                // do not perform cache size verification for the temporary image files
                Matcher matcher = pattern.matcher(filename.toString());

                if (!matcher.find()) {
                    continue;
                }

                logger.debug("{}: {}", event.kind(), filename);

                try {
                    long size = getDirectorySize(dir);
                    logger.info("image cache size: {}kb | max allowed size: {}kb", String.format("%,d", size), String.format("%,d", sizeLimit));

                    if (size > sizeLimit) {
                        logger.info("album art cache maximum size of {}kb has been breached, deleting some images to free up space", String.format("%,d", sizeLimit));
                        deleteImages(dir, size - sizeLimit);
                    }
                } catch (IOException e) {
                    logger.error("unable to perform cache size enforcement, cache size may be greater than the user configured limit", e);
                }
            }

            boolean isValid = key.reset();

            if(!isValid) {
                break;
            }
        }
    }

    private void deleteImages(Path dir, long sizeToDelete) throws IOException {
        List<Path> images = Files.list(dir)
                                 .collect(Collectors.toList());

        for (Path image : images) {
            logger.debug("size left to delete: {}kb", sizeToDelete);
            Set<String> imagesInUse = getCurrentAlbums();
            logger.debug("images in use: {} | image: {}", imagesInUse, image);
            String coverArt = image.toString();

            if (imagesInUse.contains(coverArt.substring(coverArt.lastIndexOf('.') + 1))) {
                logger.debug("not deleting the current album art in use :P");
                continue;
            }

            long size = Files.size(image) / 1000l;
            logger.debug("deleting image: {}", image);
            Files.deleteIfExists(image);
            sizeToDelete -= size;

            if (sizeToDelete < 0) {
                logger.info("cache size maintenance operation completed");
                break;
            }
        }

    }

    private Set<String> getCurrentAlbums() {
        return db.getAlbumArtPaths()
                 .stream()
                 .map(i -> i.substring(i.lastIndexOf('/') + 1))
                 .collect(Collectors.toSet());
    }

    private long getDirectorySize(Path dir) throws IOException {
        // get size in bytes
        long size = Files.walk(dir)
                        .filter(Files::isRegularFile)
                        .mapToLong(p -> {
                            try {
                                return Files.size(p);
                            } catch (IOException e) {
                                // ignore file in the size count
                                return 0;
                            }
                        })
                        .sum();
        size = size / 1000l;    // convert to kb
        return size;
    }
}
