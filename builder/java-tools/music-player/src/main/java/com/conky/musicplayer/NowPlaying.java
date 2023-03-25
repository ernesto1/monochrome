package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.interfaces.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Support application for the music player conky.<br>
 * Once launched, the application will run continuously listening for any music player signals in the dbus.<br>
 * <br>
 * It uses the Media Player Remote Interfacing Specification (MPRIS) in order to detect song playback changes
 * by the user and retrieve said song metadata for conky to display.<br>
 * <br>
 * Song information is stored in separate files in the {@link #OUTPUT_DIR output directory}.  Output files are
 * {@link TrackUpdatesHandler#FILE_PREFIX prefixed}.
 * @see <a href="https://github.com/hypfvieh/dbus-java">Java DBus library</a>
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/">Media Player Remote Interfacing Specification</a>
 */
public class NowPlaying {
    private static Logger logger = LoggerFactory.getLogger(NowPlaying.class);
    /**
     * Directory to write the song track info files for conky to read
     */
    public static String OUTPUT_DIR = "/tmp";

    public static void main(String[] args) {
        try (DBusConnection dbus = DBusConnectionBuilder.forSessionBus().build()) {
            ScheduledExecutorService executorService = Executors.newSingleThreadScheduledExecutor();
            executorService.scheduleAtFixedRate(new AlbumArtHouseKeeper(OUTPUT_DIR, 20), 10, 10, TimeUnit.MINUTES);
            registerShutdownHooks(dbus, executorService);
            dbus.addSigHandler(Properties.PropertiesChanged.class, new TrackUpdatesHandler(dbus, OUTPUT_DIR));
            logger.info("listening to the dbus for media player activity");

            while(true) {
                // this will keep the program alive forever, we just wait for dbus signals to come in
                TimeUnit.MINUTES.sleep(10);
            }
        } catch (Exception e) {
            logger.error("unable to interact with the dbus", e);
        }
    }

    /**
     * House cleaning items for when the program is killed.  Closes all the given resources.
     *
     * @param dbus            dbus connection
     * @param executorService executor service used for deleting old album art images
     */
    private static void registerShutdownHooks(DBusConnection dbus, ScheduledExecutorService executorService) {
        // create a shutdown hook for closing the dbus connection
        Thread closeDbusConnectionHook = new Thread(() -> {
            try {
                logger.info("closing dbus connection");
                dbus.close();
            } catch (Exception e) {
                logger.error("unable to close resources", e);
            }

            logger.info("shutting down album housekeeper thread");
            executorService.shutdown();

            try {
                boolean isThreadShutdown = executorService.awaitTermination(600, TimeUnit.MILLISECONDS);
                if (isThreadShutdown) {
                    logger.debug("thread shut down");
                } else {
                    logger.warn("welp! the threads are still not done!");
                }
            } catch (InterruptedException e) {
                logger.error("was not able to wait for the thread pool to close", e);
            }
        });
        Runtime.getRuntime().addShutdownHook(closeDbusConnectionHook);

        // shut down hook for deleting the conky media player output files
        Thread deleteOutputFiles = new Thread(() -> {
            logger.info("deleting all output files");
            try {
                Files.list(Paths.get(OUTPUT_DIR))
                     .filter(p -> p.getFileName().toString().startsWith(TrackUpdatesHandler.FILE_PREFIX + "."))
                     .forEach(file -> {
                        try {
                            logger.debug("deleting the output file: {}", file);
                            Files.deleteIfExists(file);
                        } catch (IOException e) {
                            logger.error("unable to delete file", e);
                        }
                     });
            } catch (IOException e) {
                logger.error("unable to list the output directory contents", e);
            }
        });
        Runtime.getRuntime().addShutdownHook(deleteOutputFiles);
    }
}
