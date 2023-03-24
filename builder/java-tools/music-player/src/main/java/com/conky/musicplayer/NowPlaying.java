package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.interfaces.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * Support application for the media player conky.<br>
 * Once launched, the application will run continuously while listening to the dbus for media player application signals.<br>
 * <br>
 * It uses the Media Player Remote Interfacing Specification (MPRIS) in order to detect song playback changes
 * by the user and retrieve song metadata for conky to display.
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/">Media Player Remote Interfacing Specification</a>
 */
public class NowPlaying {
    private static Logger logger = LoggerFactory.getLogger(NowPlaying.class);

    public static void main(String[] args) {
        try (DBusConnection dbus = DBusConnectionBuilder.forSessionBus().build()) {
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
            // TODO add shutdown hook for deleting output files
            dbus.addSigHandler(Properties.PropertiesChanged.class, new TrackUpdatesHandler());
            logger.info("listening to the dbus for media player activity");

            while(true) {
                TimeUnit.MINUTES.sleep(10);
            }
        } catch (Exception e) {
            logger.error("unable to interact with the dbus", e);
        }
    }
}
