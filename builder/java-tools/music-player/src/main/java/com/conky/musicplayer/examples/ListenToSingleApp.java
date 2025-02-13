package com.conky.musicplayer.examples;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.interfaces.Properties;

import java.util.concurrent.TimeUnit;

/**
 * Registers for the <code>properties changed</code> signal of a specific application
 * @see ListenToDBus
 */
public class ListenToSingleApp {
    public static void main(String[] args) {
        try (DBusConnection conn = DBusConnectionBuilder.forSessionBus().build()) {
            // you must get a valid dbus unique name of a music player app, run 'ListMusicPlayers' to get a list of choices
            conn.addSigHandler(Properties.PropertiesChanged.class, ":1.182", new ListenToDBus.PropertiesChangedHandler());

            // keep the app alive or it will close
            while(true) {
                TimeUnit.MINUTES.sleep(10);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
