package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.interfaces.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.concurrent.TimeUnit;

/**
 * Support application for the media player conky.<br>
 * Once launched, the application will run continuously listening for any media player signals in the dbus.<br>
 * <br>
 * It uses the Media Player Remote Interfacing Specification (MPRIS) in order to detect song playback changes
 * by the user and retrieve said song metadata for conky to display.
 * @see <a href="https://github.com/hypfvieh/dbus-java">Java DBus library</a>
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/">Media Player Remote Interfacing Specification</a>
 */
public class NowPlaying {
    private static Logger logger = LoggerFactory.getLogger(NowPlaying.class);

    public static void main(String[] args) {
        try (DBusConnection dbus = DBusConnectionBuilder.forSessionBus().build()) {
            registerShutdownHooks(dbus);
            dbus.addSigHandler(Properties.PropertiesChanged.class, new TrackUpdatesHandler());
            logger.info("listening to the dbus for media player activity");

            while(true) {
                TimeUnit.MINUTES.sleep(10);
            }
        } catch (Exception e) {
            logger.error("unable to interact with the dbus", e);
        }
    }

    /**
     * House cleaning items for when the program is killed
     * @param dbus dbus connection
     */
    private static void registerShutdownHooks(DBusConnection dbus) {
        // create a shutdown hook for closing the dbus connection
        Thread closeDbusConnectionHook = new Thread(() -> {
            try {
                logger.info("closing dbus connection");
                dbus.close();
            } catch (IOException e) {
                logger.error("unable to close the dbus connection", e);
            }
        });
        Runtime.getRuntime().addShutdownHook(closeDbusConnectionHook);

        // shut down hook for deleting the conky media player output files
        Thread deleteOutputFiles = new Thread(() -> {
            try {
                Files.list(Paths.get("/tmp"))
                        .filter(p -> p.getFileName().toString().startsWith("mediaplayer."))
                        .forEach(file -> {
                            try {
                                logger.info("deleting the output file: {}", file);
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
