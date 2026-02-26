package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.FileChannel;
import java.nio.channels.ReadableByteChannel;
import java.nio.file.*;
import java.util.Random;

import static com.conky.musicplayer.MusicPlayerWriter.ALBUM_ART;

/**
 * Runnable task to download an image album art file from the web
 */
public class ImageDownloadTask implements Runnable {
    private static final Logger logger = LoggerFactory.getLogger(ImageDownloadTask.class);
    private URL url;
    private Path imagePath;

    /**
     * Create a new instance of this image download task
     *
     * @param url          URL of the image to download, ex. <code>https://i.scdn.co/image/ab67616d0000b</code>
     * @param albumArtPath file path on disk of where to save the image to
     */
    public ImageDownloadTask(URL url, Path albumArtPath) {
        this.url = url;
        imagePath = albumArtPath;
    }

    @Override
    public void run() {
        if (Files.exists(imagePath, LinkOption.NOFOLLOW_LINKS)) {
            logger.debug("album art is available in the local cache: {}", imagePath);
            return;
        }

        logger.debug("downloading album art at {}", url);
        // album art is downloaded to a temporary file and then renamed to the actual file name
        // this prevents conky from loading an incomplete image
        Path tempFile = imagePath.getParent().resolve(ALBUM_ART + ".temp." + new Random().nextLong());

        try (ReadableByteChannel readableByteChannel = Channels.newChannel(url.openStream());
             FileChannel fileChannel = FileChannel.open( tempFile,
                                                         StandardOpenOption.CREATE,
                                                         StandardOpenOption.WRITE,
                                                         StandardOpenOption.TRUNCATE_EXISTING)) {
            fileChannel.transferFrom(readableByteChannel, 0, Long.MAX_VALUE);
            Files.move(tempFile, imagePath, StandardCopyOption.REPLACE_EXISTING);
            logger.info("album art downloaded to disk: {}", imagePath);
        } catch (IOException e) {
            logger.error("unable to download album art from the web", e);
        }
    }
}