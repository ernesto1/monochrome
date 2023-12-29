package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.interfaces.DBus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.yaml.snakeyaml.Yaml;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.*;

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
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/">Media Player Remote Interfacing Specification (MPRIS)</a>
 */
public class NowPlaying {
    private static final Logger logger = LoggerFactory.getLogger(NowPlaying.class);
    /**
     * Directory to write the song track info files for conky to read
     */
    private static String OUTPUT_DIR = "/tmp/conky";
    private static String ALBUM_ART_DIR = OUTPUT_DIR + "/albumArt";
    private static int ALBUM_CACHE_SIZE = 1000000;
    private static List<String> SUPPORTED_PLAYERS;

    static {
        SUPPORTED_PLAYERS = new ArrayList<>();
        SUPPORTED_PLAYERS.add("rhythmbox");
        SUPPORTED_PLAYERS.add("spotify");
    }

    public static void main(String[] args) {
        loadConfigurationFile();

        try (DBusConnection conn = DBusConnectionBuilder.forSessionBus().build()) {
            // initialize data objects
            /*
             the thread pool for downloading album art has a queue size of only one item
             if a barrage of download tasks are submitted, only the last one will be performed

             this is to decrease the wait time experienced by the user to see album art in the conky
             while fast forwarding through multiple songs under a slow connection
             */
            ThreadPoolExecutor albumArtExecutor = new ThreadPoolExecutor(1,
                                                                         1,
                                                                         0L,
                                                                         TimeUnit.MILLISECONDS,
                                                                         new ArrayBlockingQueue<>(1),
                                                                         new ThreadPoolExecutor.DiscardOldestPolicy());
            MusicPlayerWriter writer = new MusicPlayerWriter(OUTPUT_DIR, ALBUM_ART_DIR, albumArtExecutor);
            writer.init();
            MusicPlayerDatabase playerDatabase = new MusicPlayerDatabase(writer);
            playerDatabase.init();
            ApplicationInquirer inquirer = new ApplicationInquirer(conn);
            MetadataRetriever metadataRetriever = new MetadataRetriever(inquirer);
            Registrar registrar = new Registrar(conn, metadataRetriever, playerDatabase, SUPPORTED_PLAYERS);
            // listen for dbus signals of interest
            // signal handlers run under a single thread, ie. signals are processed in the order they are received
            AvailabilityHandler availabilityHandler = new AvailabilityHandler(conn, registrar, playerDatabase);
            availabilityHandler.registerAvailablePlayers();     // register any music players already running
            conn.addSigHandler(DBus.NameOwnerChanged.class, availabilityHandler);
            logger.info("listening to the dbus for media player activity");
            // maintenance operations
            ExecutorService albumArtHouseKeeperExecutor = Executors.newSingleThreadExecutor();
            albumArtHouseKeeperExecutor.execute(new AlbumArtHouseKeeper(ALBUM_ART_DIR, ALBUM_CACHE_SIZE, playerDatabase));
            registerShutdownHooks(conn, albumArtExecutor, albumArtHouseKeeperExecutor);

            while(true) {
                // this will keep the program alive forever, we just wait for dbus signals to come in
                TimeUnit.HOURS.sleep(1);
            }
        } catch (Exception e) {
            logger.error("the application failed to start", e);
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
        ALBUM_ART_DIR = (String) config.getOrDefault("albumArtDir", ALBUM_ART_DIR);
        ALBUM_CACHE_SIZE = (Integer) config.getOrDefault("albumCacheSize", ALBUM_CACHE_SIZE);
        SUPPORTED_PLAYERS = (List<String>) config.getOrDefault("supportedPlayers", SUPPORTED_PLAYERS);
    }

    /**
     * House cleaning items for when the program is killed.  Closes all the resources used or produced by this app.
     *
     * @param conn      dbus connection
     * @param executors list of executor services to gracefully shutdown
     */
    private static void registerShutdownHooks(DBusConnection conn, ExecutorService... executors) {
        // create a shutdown hook for closing the dbus connection
        Thread closeDbusConnectionHook = new Thread(() -> {
            try {
                logger.info("closing dbus connection");
                conn.close();
            } catch (Exception e) {
                logger.error("unable to close resources", e);
            }

            logger.info("shutting down executor services");

            for (ExecutorService executor : executors) {
                executor.shutdown();

                try {
                    executor.shutdownNow();

                    if (!executor.awaitTermination(1300, TimeUnit.MILLISECONDS)) {
                        logger.warn("welp! an executor service was not able to shutdown after 1300ms");
                    }
                } catch (InterruptedException e) {
                    logger.error("was not able to wait for the thread pool to close", e);
                }
            }
        });
        Runtime.getRuntime().addShutdownHook(closeDbusConnectionHook);

        // shut down hook for deleting the conky music player output files
        Thread deleteOutputFiles = new Thread(() -> {
            logger.info("deleting all output files");
            try {
                Files.list(Path.of(OUTPUT_DIR))
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
