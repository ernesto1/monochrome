package com.conky.musicplayer;

import org.freedesktop.dbus.DBusMap;
import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.exceptions.DBusException;
import org.freedesktop.dbus.handlers.AbstractPropertiesChangedHandler;
import org.freedesktop.dbus.interfaces.Properties;
import org.freedesktop.dbus.types.Variant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Map;

import static com.conky.musicplayer.MusicPlayerWriter.FILE_PREFIX;

/**
 * Handler for analyzing media player property change signals.<br>
 * Updates related to the currently playing track will be reflected in the conky music5 player files.
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html">MPRIS Player Inteface</a>
 */
public class TrackUpdatesHandler extends AbstractPropertiesChangedHandler {
    private static Logger logger = LoggerFactory.getLogger(TrackUpdatesHandler.class);

    private final String outputDirectory;
    private final DBusConnection dbus;
    private MusicPlayerDatabase playerDatabase;

    /**
     * Creates a new instance of this property change handler
     *
     * @param directory directory to write output files to
     * @param dBusConnection DBus connection
     * @param database  music player database to store running player details
     */
    public TrackUpdatesHandler(String directory,
                               DBusConnection dBusConnection,
                               MusicPlayerDatabase database) {
        outputDirectory = directory;
        dbus = dBusConnection;
        playerDatabase = database;
    }

    @Override
    public void handle(Properties.PropertiesChanged signal) {
        // ignore signals for interfaces we are not interested in
        if (!signal.getPath().equals("/org/mpris/MediaPlayer2")) {
            return;
        }

        // is this signal from a recognizer music player?
        logger.debug("signal: {} {}", signal.getSource(), signal.getPropertiesChanged());
        String playerName = getApplicationProperty(signal.getSource(),
                                                   MPRIS.Objects.MEDIAPLAYER2,
                                                   MPRIS.Interfaces.MEDIAPLAYER2,
                                                   MPRIS.Properties.IDENTITY);

        if (!playerDatabase.isMusicPlayer(playerName)) {
            logger.debug("media player '{}' is not supported, ignoring signal", playerName);
            return;
        }

        // retrieve available details from the signal
        Map<String, Variant<?>> properties = signal.getPropertiesChanged();

        String playbackStatus = null;
        Variant<String> status = (Variant<String>) properties.get("PlaybackStatus");
        if (status != null) {
            playbackStatus = status.getValue();
        }

        TrackInfo trackInfo = null;
        Variant<DBusMap> metadata = (Variant<DBusMap>) properties.get("Metadata");
        if (metadata != null) {
            trackInfo = getTrackInfo(metadata.getValue());
        }

        MusicPlayer player;

        // is this a known player or a new one?
        if (playerDatabase.contains(playerName)) {
            player = playerDatabase.getPlayer(playerName);
        } else {
            // brand new player
            // some signals may not contain the complete player state metadata (ex. playback status may come on its own)
            // so we have to individually query the missing bits
            logger.debug("registering new player: {}", playerName);

            if (playbackStatus == null) {
                playbackStatus = getApplicationProperty(signal.getSource(),
                                                        MPRIS.Objects.MEDIAPLAYER2,
                                                        MPRIS.Interfaces.MEDIAPLAYER2_PLAYER,
                                                        MPRIS.Properties.PLAYBACK_STATUS);
            }

            if (trackInfo == null) {
                trackInfo = getTrackInfo(getApplicationMetadata(signal.getSource(),
                                                                MPRIS.Objects.MEDIAPLAYER2,
                                                                MPRIS.Interfaces.MEDIAPLAYER2_PLAYER,
                                                                MPRIS.Properties.METADATA));
            }

            player = new MusicPlayer(playerName, signal.getSource());
        }

        player.setPlaybackStatus(playbackStatus);
        player.setTrackInfo(trackInfo);
        playerDatabase.save(player);
    }


    /**
     * Queries an application through the dbus for a specific property
     *
     * @param uniqueName unique name of the application under the dbus, ex. :1.146
     * @param object dbus object path
     * @param dbusInterface interface within the dbus object
     * @param property name of the property to query
     * @return the property as a <tt>String</tt>
     */
    private String getApplicationProperty(String uniqueName, String object, String dbusInterface, String property) {
        String value = "unknown";

        try {
            Properties properties = dbus.getRemoteObject(uniqueName, object, Properties.class);
            value = properties.Get(dbusInterface, property);
        } catch (Exception e) {
            // for some signals, the owning dbus object won't exist any more by the time we try to get its name
            // ex. closing a youtube tab, firefox send a final signal prior to unregistering the corresponding dbus name
            logger.warn("unable to determine the media player's name, the signal will be ignored");
        }

        return value;
    }

    // TODO use generics and combine these two methods into one
    private DBusMap  getApplicationMetadata(String uniqueName, String object, String dbusInterface, String property) {
        DBusMap  metadata = null;

        try {
            Properties properties = dbus.getRemoteObject(uniqueName, object, Properties.class);
            metadata = properties.Get(dbusInterface, property);
        } catch (DBusException e) {
            logger.error("unable to determine the media player's name", e);
        }

        return metadata;
    }

    /**
     * Extracts song track information <i>if it exists</i> from the metadata property of the <tt>MediaPlayer2.Player</tt> interface.<br>
     * Song details are defined using <tt>xesam</tt> ontology.
     *
     * @param metadata the signal's metadata property as a map of key/value pairs
     * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Track_List_Interface.html#Mapping:Metadata_Map">Metadata map documentation</a>
     * @see <a href="https://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata/">MPRIS v2 metadata guidelines</a>
     */
    private TrackInfo getTrackInfo(DBusMap metadata) {
        /*
         n.b. the type of the values in the metadata map will differ based on what dbus interface was queried
              for the metadata property
                 - metadata from the properties changed signal will wrap all values under the Variant<?> type
                 - metadata from the 'org.mpris.MediaPlayer2.Player' interface will use the regular java types
         */

        TrackInfo trackInfo = null;

        Object value = metadata.get("mpris:trackid");
        if (value != null) {
            if (value instanceof Variant) {
                trackInfo = new TrackInfo(((Variant<String>) value).getValue());
            } else {
                trackInfo = new TrackInfo((String) value);
            }
        }

        value = metadata.get("xesam:title");
        if (value != null) {
            if (value instanceof Variant) {
                trackInfo.setTitle(((Variant<String>) value).getValue());
            } else {
                trackInfo.setTitle((String) value);
            }
        }

        value = metadata.get("xesam:album");
        if (value != null) {
            if (value instanceof Variant) {
                trackInfo.setAlbum(((Variant<String>) value).getValue());
            } else {
                trackInfo.setAlbum((String) value);
            }
        }

        value = metadata.get("xesam:artist");
        if (value != null) {
            if (value instanceof Variant) {
                ArrayList<String> entries = ((Variant<ArrayList<String>>) value).getValue();
                trackInfo.setArtist(entries.get(0));
            } else {
                trackInfo.setArtist(((ArrayList<String>) value).get(0));
            }

        }

        value = metadata.get("xesam:genre");
        if (value != null) {
            if (value instanceof Variant) {
                ArrayList<String> entries = ((Variant<ArrayList<String>>) value).getValue();
                trackInfo.setGenre(entries.get(0));
            } else {
                trackInfo.setGenre(((ArrayList<String>) value).get(0));
            }

        }

        value = metadata.get("mpris:artUrl");
        if (value != null) {
            String coverArtPath;

            if (value instanceof Variant) {
                coverArtPath = ((Variant<String>) value).getValue();
            } else {
                coverArtPath = (String) value;
            }

            // is the album art on the web or in the local file system?
            if (coverArtPath.startsWith("http")) {
                trackInfo.setAlbumArtPath(downloadAlbumArt(coverArtPath));
            } else {
                // image is in the local file system (ex. file://folder/image.jpg), remove the uri notation
                trackInfo.setAlbumArtPath(coverArtPath.replaceFirst("file://", ""));
            }
        }

        return trackInfo;
    }

    /**
     * Attempts to download the album art from the web.  If an error occurs, no album art will be associated
     * with this song.
     * @param url URL of the image to download
     * @return the location/path on disk of the downloaded image
     */
    private String downloadAlbumArt(String url) {
        String id = url.substring(url.lastIndexOf('/') + 1);    // get the resource name
        Path albumArtPath = Paths.get(outputDirectory, FILE_PREFIX + ".albumArt." + id);

        if (Files.notExists(albumArtPath, LinkOption.NOFOLLOW_LINKS)) {
            try {
                ReadableByteChannel readableByteChannel = Channels.newChannel(new URL(url).openStream());
                FileOutputStream fileOutputStream = new FileOutputStream(albumArtPath.toFile());
                fileOutputStream.getChannel().transferFrom(readableByteChannel, 0, Long.MAX_VALUE);
                fileOutputStream.close();
            } catch (IOException e) {
                logger.error("unable to download album art from the web");
                albumArtPath = null;
            }
        } else {
            logger.info("album art already available on disk, no need to download it again from the web");
        }

        return albumArtPath != null ? albumArtPath.toString() : null;
    }
}
