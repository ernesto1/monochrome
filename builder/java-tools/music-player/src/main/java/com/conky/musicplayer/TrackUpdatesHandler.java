package com.conky.musicplayer;

import org.freedesktop.dbus.DBusMap;
import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.exceptions.DBusException;
import org.freedesktop.dbus.handlers.AbstractPropertiesChangedHandler;
import org.freedesktop.dbus.interfaces.Properties;
import org.freedesktop.dbus.types.Variant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.nio.file.*;
import java.util.*;

/**
 * Handler for analyzing media player property change signals.<br>
 * Updates related to the currently playing track will be reflected in the conky media player files.
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html">MPRIS Player Inteface</a>
 */
public class TrackUpdatesHandler extends AbstractPropertiesChangedHandler {
    private static Logger logger = LoggerFactory.getLogger(TrackUpdatesHandler.class);
    public static final String FILE_PREFIX = "musicplayer";
    private static final String ALBUM_ART_PATH = "albumArtPath";

    private final String outputDirectory;
    private final DBusConnection dbus;
    // TODO player list should be coming from a config file
    /**
     * List of recognized music players.  Only signals from these players will be processed
     */
    private List<String> allowedPlayers;
    private MusicPlayer activePlayer;
    private Map<String, MusicPlayer> availablePlayers;

    /**
     * Creates a new instance of this property change handler
     *
     * @param dbus  DBus connection
     * @param directory directory to write output files to
     */
    public TrackUpdatesHandler(DBusConnection dbus, String directory) {
        this.dbus = dbus;
        outputDirectory = directory;
    }

    public void init() {
        allowedPlayers = new ArrayList<>();
        allowedPlayers.add("rhythmbox");
        allowedPlayers.add("spotify");
        availablePlayers = new HashMap<>();
        writePlayerState(new MusicPlayer("nameless player", ":123"));
    }

    // TODO if the player closes the track info should be deleted, otherwise the track info may remain in a playing state

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

        if (!allowedPlayers.contains(playerName.toLowerCase())) {
            logger.debug("media player '{}' is not supported, ignoring signal", playerName);
            return;
        }

        // retrieve details from the signal
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

        // do we know about this player already?
        if (availablePlayers.containsKey(playerName)) {
            player = availablePlayers.get(playerName);
            player.setPlaybackStatus(playbackStatus);
            player.setTrackInfo(trackInfo);
        } else {
            // this is a brand new player
            // get missing details (if any)
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
            player.setPlaybackStatus(playbackStatus);
            player.setTrackInfo(trackInfo);
            availablePlayers.put(playerName, player);
        }

        determineActivePlayer(player);
        logger.info("{}", player);
        writePlayerState(activePlayer);
    }

    private void determineActivePlayer(MusicPlayer newPlayer) {
        // if there is no currently active player, make this the active player
        if (activePlayer == null) {
            activePlayer = newPlayer;
            return;
        }

        // if the active player is not playing any music, replace it with one that is
        if (activePlayer.getPlaybackStatus() != MusicPlayer.PlaybackStatus.PLAYING) {
            Optional<MusicPlayer> player = availablePlayers.values()
                                                           .stream()
                                                           .filter(p -> p.getPlaybackStatus() == MusicPlayer.PlaybackStatus.PLAYING)
                                                           .findFirst();
            if (player.isPresent()) {
                activePlayer = player.get();
            }
        }
    }

    /**
     * Queries an application through the dbus for a specific property
     *
     * @param uniqueName unique name of the application under the dbus, ex. :1.146
     * @param object dbus object path
     * @param dbusInterface interface within the dbus object
     * @param property name of the property to query
     * @return
     */
    private String getApplicationProperty(String uniqueName, String object, String dbusInterface, String property) {
        String value = "unknown";

        try {
            Properties properties = dbus.getRemoteObject(uniqueName, object, Properties.class);
            value = properties.Get(dbusInterface, property);
        } catch (Exception e) {
            // when closing a youtube firefox tab, for some signals the dbus object won't exist anymore
            logger.warn("unable to determine the media player's name, will be ignored");
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
     * Song details are defined using `xesam` ontology.
     *
     * @param metadata the signal's metadata property as a map of key/value pairs
     * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Track_List_Interface.html#Mapping:Metadata_Map">Metadata map documentation</a>
     * @see <a href="https://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata/">MPRIS v2 metadata guidelines</a>
     */
    private TrackInfo getTrackInfo(DBusMap metadata) {
//        if (metadataProperty == null) {
//            return null;
//        }

        /*
         n.b. the type of the values in the metadata map will differ based on how the metadata was extracted :(
         - metadata from the properties changes signal will wrap all values under the Variant<?> type
         - metadata from the 'org.mpris.MediaPlayer2.Player' interface will use the regular java types
         */
        TrackInfo trackInfo = new TrackInfo();

        Object value = metadata.get("xesam:title");
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
                // imate is in the local file system (ex. file://folder/image.jpg), remove the uri notation
                trackInfo.setAlbumArtPath(coverArtPath.replaceFirst("file://", ""));
            }
        }

        return trackInfo;
    }

    /**
     * Attempts to download the album art from the web.  If an error occurs, no album art will be displayed
     * for this song.
     * @param url URL of the image to download
     * @return the location on disk of the downlaoded image
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
                logger.error("unable to download the album art from the web");
                albumArtPath = null;
            }
        } else {
            logger.info("web album art is already part of the catalog, no need to download it again");
        }

        return albumArtPath != null ? albumArtPath.toString() : null;
    }

    private void writePlayerState(MusicPlayer player) {
        writeFile("name", player.getPlayerName());
        // convert playback status enum to 'Title Case'
        String playbackStatus = player.getPlaybackStatus().toString().toLowerCase();
        playbackStatus = playbackStatus.substring(0,1).toUpperCase() + playbackStatus.substring(1);
        writeFile("playbackStatus", playbackStatus);
        writeFile("artist", player.getArtist());
        writeFile("title", player.getTitle());
        writeFile("album", player.getAlbum());
        writeFile("genre", player.getGenre());

        if (player.getAlbumArtPath() != null) {
            writeFile(ALBUM_ART_PATH, player.getAlbumArtPath());
        } else {
            Path coverArt = Paths.get(outputDirectory, FILE_PREFIX + "." + ALBUM_ART_PATH);
            try {
                Files.deleteIfExists(coverArt);
            } catch (IOException e) {
                logger.error("unable to delete cover art file", e);
            }
        }
    }

    private void writeFile(String filename, String data) {
        try {
            Path artistPath = Paths.get(outputDirectory, FILE_PREFIX + "." + filename);
            BufferedWriter writer = Files.newBufferedWriter(artistPath,
                                                            StandardOpenOption.CREATE,
                                                            StandardOpenOption.WRITE,
                                                            StandardOpenOption.TRUNCATE_EXISTING);
            writer.write(data);
            writer.close();
        } catch (IOException e) {
            logger.error("unable to write '{}' file", filename, e);
        }
    }
}
