package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.exceptions.DBusException;
import org.freedesktop.dbus.interfaces.DBus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.core.env.PropertiesPropertySource;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Support application for the music player conky.<br>
 * Once launched, the application will run continuously listening for any music player signals in the dbus.<br>
 * <br>
 * It uses the <b>M</b>edia <b>P</b>layer <b>R</b>emote <b>I</b>nterfacing <b>S</b>pecification (MPRIS) in order to detect song playback changes
 * and retrieve said song metadata for conky to display.<br>
 * Song information is stored in separate {@link MusicPlayerWriter#FILE_PREFIX prefixed} files
 * in the configured output directory.
 * @see <a href="https://github.com/hypfvieh/dbus-java">Java DBus library</a>
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/">Media Player Remote Interfacing Specification (MPRIS)</a>
 */
public class NowPlaying {
    private static final Logger logger = LoggerFactory.getLogger(NowPlaying.class);

    public static void main(String[] args) throws IOException, DBusException, InterruptedException {
        // edit the output directories from the properties file: replace ~ with the user's home directory
        Properties properties = new Properties();
        properties.load(NowPlaying.class.getResourceAsStream("/application.properties"));
        String dir = properties.getProperty("outputDir");
        exitIfPropertyIsEmpty("outputDir", dir);
        dir = replaceTilde(dir);
        properties.put("outputDir", dir);
        dir = properties.getProperty("albumArtDir");
        exitIfPropertyIsEmpty("albumArtDir", dir);
        dir = replaceTilde(dir);
        properties.put("albumArtDir", dir);

        // create the output directories if they do not exist
        Path outputDir = Path.of(properties.getProperty("outputDir"));
        Files.createDirectories(outputDir);
        Path albumArtDir = Path.of(properties.getProperty("albumArtDir"));
        Files.createDirectories(albumArtDir);
        registerShutdownHook(outputDir, albumArtDir);

        // start the spring context
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext();
        PropertiesPropertySource propertiesSource = new PropertiesPropertySource("revised directories", properties);
        ctx.getEnvironment().getPropertySources().addLast(propertiesSource);
        ctx.register(NowPlayingConfig.class);
        ctx.refresh();
        ctx.registerShutdownHook();

        // start the program
        ExecutorService albumArtHouseKeeperExecutor = ctx.getBean("albumArtHouseKeeperExecutor", ExecutorService.class);
        AlbumArtHouseKeeper albumArtHouseKeeper = ctx.getBean("albumArtHouseKeeper", AlbumArtHouseKeeper.class);
        albumArtHouseKeeperExecutor.execute(albumArtHouseKeeper);
        logger.info("listening to the dbus for media player activity");
        DBusConnection dbus = ctx.getBean("dBusConnection", DBusConnection.class);
        AvailabilityHandler availabilityHandler = ctx.getBean("availabilityHandler", AvailabilityHandler.class);
        availabilityHandler.registerAvailablePlayers();     // register any music players already running
        dbus.addSigHandler(DBus.NameOwnerChanged.class, availabilityHandler);

        // keep the main thread alive forever, we just wait for dbus signals to come in
        while(true) {
            TimeUnit.HOURS.sleep(6);
        }
    }

    private static void exitIfPropertyIsEmpty(String key, String value) {
        if (value == null) {
            logger.error("the configuration property '{}' must be defined in the application.properties file", key);
            System.exit(1);
        }
    }

    /**
     * Replaces the tilde (if it exists) in the directory path with the user's home directory,
     * ex. <code>~/conky</code> becomes <code>/home/ernesto/conky</code>
     * @param albumArtDir directory path
     * @return the translated directory path as a <code>String</code>
     */
    private static String replaceTilde(String albumArtDir) {
        String homeDir = System.getProperty("user.home");
        albumArtDir = albumArtDir.replaceFirst("^~", homeDir);

        return albumArtDir;
    }

    /**
     * Adds a runtime shutdown hook to delete all the temporary files produced by this application
     */
    private static void registerShutdownHook(Path outputDir, Path albumArtDir) {
        // shut down hook for deleting the conky music player output files
        Thread deleteOutputFiles = new Thread(() -> {
            logger.info("deleting all output files");
            try {
                Files.list(outputDir)
                     .filter(p -> p.getFileName().toString().startsWith(MusicPlayerWriter.FILE_PREFIX + "."))
                     .forEach(file -> {
                        try {
                            logger.debug("deleting the output file: {}", file);
                            Files.deleteIfExists(file);
                        } catch (IOException e) {
                            logger.error("unable to delete file", e);
                        }
                     });

                Path symlink = albumArtDir.resolve(MusicPlayerWriter.ALBUM_ART_SYMLINK_FILENAME);
                logger.debug("deleting the now playing symlink file: {}", symlink);
                Files.deleteIfExists(symlink);
            } catch (IOException e) {
                logger.error("unable to list the output directory contents", e);
            }
        });

        Runtime.getRuntime().addShutdownHook(deleteOutputFiles);
    }
}
