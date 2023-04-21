package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.interfaces.DBus;
import org.freedesktop.dbus.interfaces.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.yaml.snakeyaml.Yaml;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Support application for the conky music player.<br>
 * Once launched, the application will run continuously listening for any music player signals in the dbus.<br>
 * <br>
 * It uses the Media Player Remote Interfacing Specification (MPRIS) in order to detect song playback changes
 * and retrieve said song metadata for conky to display.<br>
 * <br>
 * Song information is stored in separate {@link MusicPlayerWriter#FILE_PREFIX prefixed} files
 * in the {@link #OUTPUT_DIR output directory}.
 * @see <a href="https://github.com/hypfvieh/dbus-java">Java DBus library</a>
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/">Media Player Remote Interfacing Specification</a>
 */
public class NowPlaying {
    private static final Logger logger = LoggerFactory.getLogger(NowPlaying.class);
    /**
     * Directory to write the song track info files for conky to read
     */
    private static String OUTPUT_DIR = "/tmp";
    private static int ALBUM_CUTOFF = 30;
    private static List<String> SUPPORTED_PLAYERS;

    static {
        SUPPORTED_PLAYERS = new ArrayList<>();
        SUPPORTED_PLAYERS.add("rhythmbox");
        SUPPORTED_PLAYERS.add("spotify");
    }

    public static void main(String[] args) {
        loadConfigurationFile();

        try (DBusConnection conn = DBusConnectionBuilder.forSessionBus().build()) {
            // initialize utility classes
            MusicPlayerWriter writer = new MusicPlayerWriter(OUTPUT_DIR);
            writer.init();
            MusicPlayerDatabase playerDatabase = new MusicPlayerDatabase(writer, SUPPORTED_PLAYERS);
            playerDatabase.init();

            // maintenance operations
            ScheduledExecutorService executorService = Executors.newSingleThreadScheduledExecutor();
            executorService.scheduleAtFixedRate(new AlbumArtHouseKeeper(OUTPUT_DIR, ALBUM_CUTOFF, playerDatabase), 65, 30, TimeUnit.MINUTES);
            registerShutdownHooks(conn, executorService);

            // TODO upon boot can we identify what are the current available music players?

            // listen for dbus signals of interest
            // signal handlers run under a single thread, ie. signals are processed in the order they are received
            AvailabilityHandler availabilityHandler = new AvailabilityHandler(playerDatabase);
            conn.addSigHandler(DBus.NameOwnerChanged.class, availabilityHandler);
            TrackUpdatesHandler trackUpdatesHandler = new TrackUpdatesHandler(OUTPUT_DIR, conn, playerDatabase);
            conn.addSigHandler(Properties.PropertiesChanged.class, trackUpdatesHandler);
            logger.info("listening to the dbus for media player activity");

            while(true) {
                // this will keep the program alive forever, we just wait for dbus signals to come in
                TimeUnit.HOURS.sleep(1);
            }
        } catch (Exception e) {
            logger.error("unable to interact with the dbus", e);
        }
    }

    private static void loadConfigurationFile() {
        Map<String, Object> config = null;

        try {
            // fun fact: if reading the config file below fails, the i/o exception will skip the catch clause
            //           and terminate the program, not sure why this happens
            InputStream configFile = NowPlaying.class.getResourceAsStream("/config.yaml");
            Yaml yaml = new Yaml();
            config = yaml.load(configFile);
            configFile.close();
        } catch (IOException e) {
            logger.error("unable to close the config file", e);
        }

        logger.info("configuration: {}", config);
        OUTPUT_DIR = (String) config.getOrDefault("outputDir", OUTPUT_DIR);
        ALBUM_CUTOFF = (Integer) config.getOrDefault("albumCutoff", ALBUM_CUTOFF);
        SUPPORTED_PLAYERS = (List<String>) config.getOrDefault("supportedPlayers", SUPPORTED_PLAYERS);
    }

    /**
     * House cleaning items for when the program is killed.  Closes all the resources used or produced by this app.
     *
     * @param conn            dbus connection
     * @param executorService executor service used for deleting old album art images
     */
    private static void registerShutdownHooks(DBusConnection conn, ScheduledExecutorService executorService) {
        // create a shutdown hook for closing the dbus connection
        Thread closeDbusConnectionHook = new Thread(() -> {
            try {
                logger.info("closing dbus connection");
                conn.close();
            } catch (Exception e) {
                logger.error("unable to close resources", e);
            }

            logger.info("shutting down album housekeeper thread");
            executorService.shutdown();

            try {
                boolean isThreadShutdown = executorService.awaitTermination(600, TimeUnit.MILLISECONDS);
                if (!isThreadShutdown) {
                    logger.warn("welp! the threads are still not done!");
                }
            } catch (InterruptedException e) {
                logger.error("was not able to wait for the thread pool to close", e);
            }
        });
        Runtime.getRuntime().addShutdownHook(closeDbusConnectionHook);

        // shut down hook for deleting the conky music player output files
        Thread deleteOutputFiles = new Thread(() -> {
            logger.info("deleting all output files");
            try {
                Files.list(Paths.get(OUTPUT_DIR))
                     .filter(p -> p.getFileName().toString().startsWith(MusicPlayerWriter.FILE_PREFIX + "."))
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
