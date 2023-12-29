package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.nio.file.*;

import static com.conky.musicplayer.MusicPlayerWriter.ALBUM_ART;

/**
 * Runnable task to download a single album art from the web
 */
public class ImageDownloadTask implements Runnable {
    private static final Logger logger = LoggerFactory.getLogger(ImageDownloadTask.class);
    private URL url;
    private Path imagePath;

    /**
     * Create a new instance of this image download task
     *
     * @param url          URL of the image to download, ex. <tt>https://i.scdn.co/image/ab67616d0000b</tt>
     * @param albumArtPath file path on disk of where to save the image to
     */
    public ImageDownloadTask(URL url, Path albumArtPath) {
        this.url = url;
        imagePath = albumArtPath;
    }

    @Override
    public void run() {
        if (Files.exists(imagePath, LinkOption.NOFOLLOW_LINKS)) {
            logger.info("album art available in the local cache: {}", imagePath);
            return;
        }

        try {
            // album art is downloaded to a temporary file and then renamed to the actual file name
            // this is to prevent conky from loading an incomplete image
            ReadableByteChannel readableByteChannel = Channels.newChannel(url.openStream());
            Path tempFile = Path.of(imagePath.getParent().toString(), ALBUM_ART + ".temp");
            FileOutputStream fileOutputStream = new FileOutputStream(tempFile.toFile());
            fileOutputStream.getChannel().transferFrom(readableByteChannel, 0, Long.MAX_VALUE);
            fileOutputStream.close();
            Files.move(tempFile, imagePath, StandardCopyOption.REPLACE_EXISTING);
            logger.info("downloaded album art to cache: {}", imagePath);
        } catch (IOException e) {
            logger.error("unable to download album art from the web", e);
        }
    }
}