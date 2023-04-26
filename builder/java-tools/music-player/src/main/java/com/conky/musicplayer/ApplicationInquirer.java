package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.exceptions.DBusException;
import org.freedesktop.dbus.interfaces.Properties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Optional;

public class ApplicationInquirer {
    private static final Logger logger = LoggerFactory.getLogger(ApplicationInquirer.class);

    private final DBusConnection dbus;

    public ApplicationInquirer(DBusConnection dbus) {
        this.dbus = dbus;
    }

    /**
     * Queries an application through the dbus for a specific property
     *
     * @param uniqueName unique connection name of the application under the dbus, ex. :1.146
     * @param object dbus object path
     * @param dbusInterface interface within the dbus object
     * @param property name of the property to query
     * @return the property as a <tt>String</tt>
     */
    public <T> Optional<T> getApplicationProperty(String uniqueName, String object, String dbusInterface, String property) {
        T value = null;

        try {
            Properties properties = dbus.getRemoteObject(uniqueName, object, Properties.class);
            value = properties.Get(dbusInterface, property);
        } catch (DBusException e) {
            logger.warn("unable to retrieve the property '{}' from the object '{}'", property, uniqueName);
            Optional<String> playerName;
        }

        return Optional.of(value);
    }
}
