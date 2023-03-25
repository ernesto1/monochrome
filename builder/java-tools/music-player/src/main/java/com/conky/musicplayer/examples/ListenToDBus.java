package com.conky.musicplayer.examples;

import com.conky.musicplayer.TrackUpdatesHandler;
import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.handlers.AbstractPropertiesChangedHandler;
import org.freedesktop.dbus.interfaces.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * Sample code to listen to the dbus for any signals related to media player activity.<br>
 * <br>
 * The program runs indefinitely, use a kill signal to terminate it.
 */
public class ListenToDBus {
    private static Logger logger  = LoggerFactory.getLogger(ListenToDBus.class);

    public static void main(String[] args) {
        try (DBusConnection dbus = DBusConnectionBuilder.forSessionBus().build()) {
            registerShutdownHooks(dbus);
            dbus.addSigHandler(Properties.PropertiesChanged.class, new PropertiesChangedHandler());

            while(true) {
                TimeUnit.MINUTES.sleep(10);
            }
        } catch (Exception e) {
            logger.error("unable to interact with the dbus", e);
        }
    }

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
    }

    private static class PropertiesChangedHandler extends AbstractPropertiesChangedHandler {
        @Override
        public void handle(Properties.PropertiesChanged signal) {
            String dbusObject = signal.getPath();

            if (dbusObject.equals("/org/mpris/MediaPlayer2")) {
                logger.info("signal: {} | {} | {}",
                            signal.getSource(),
                            signal.getPropertiesChanged(),
                            signal.getPropertiesRemoved());
            }
        }
    }
}
