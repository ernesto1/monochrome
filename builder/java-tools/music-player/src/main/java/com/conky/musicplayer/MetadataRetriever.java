package com.conky.musicplayer;

import org.freedesktop.dbus.DBusMap;
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
import java.util.Optional;

import static com.conky.musicplayer.MusicPlayerWriter.ALBUM_ART;

/**
 * Utility class for retrieving music player specific metadata through the dbus
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html">MPRIS Player Inteface</a>
 * https://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata/
 */
public class MetadataRetriever {
    private static final Logger logger = LoggerFactory.getLogger(MetadataRetriever.class);
    private ApplicationInquirer inquirer;
    private final String outputDirectory;

    public MetadataRetriever(ApplicationInquirer inquirer, String outputDirectory) {
        this.inquirer = inquirer;
        this.outputDirectory = outputDirectory;
    }

    public Optional<String> getPlayerName(String uniqueName) {
        Optional<String> playerName = inquirer.getApplicationProperty(uniqueName,
                                                                      MPRIS.Objects.MEDIAPLAYER2,
                                                                      MPRIS.Interfaces.MEDIAPLAYER2,
                                                                      MPRIS.Properties.IDENTITY);

        return playerName;
    }

    public MusicPlayer getPlayerState(MusicPlayer player) {
        Optional<String> playback = inquirer.getApplicationProperty(player.getDBusUniqueName(),
                                                                    MPRIS.Objects.MEDIAPLAYER2,
                                                                    MPRIS.Interfaces.MEDIAPLAYER2_PLAYER,
                                                                    MPRIS.Properties.PLAYBACK_STATUS);
        playback.ifPresent(p -> player.setPlaybackStatus(p));
        Optional<DBusMap> metadata = inquirer.getApplicationMetadata(player.getDBusUniqueName(),
                                                                     MPRIS.Objects.MEDIAPLAYER2,
                                                                     MPRIS.Interfaces.MEDIAPLAYER2_PLAYER,
                                                                     MPRIS.Properties.METADATA);
        metadata.ifPresent(m -> player.setTrackInfo(getTrackInfo(m)));

        return player;
    }

    /**
     * Extracts song track information <i>if it exists</i> from the metadata property of the <tt>MediaPlayer2.Player</tt> interface.<br>
     * Song details are defined using <tt>xesam</tt> ontology.
     *
     * @param metadata the signal's metadata property as a map of key/value pairs
     * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Track_List_Interface.html#Mapping:Metadata_Map">Metadata map documentation</a>
     * @see <a href="https://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata/">MPRIS v2 metadata guidelines</a>
     */
    public TrackInfo getTrackInfo(DBusMap metadata) {
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

            // TODO album art should be done on a separate thread, if the internet connection is VERY slow it delays the availability of the other track info.  If you forward multiple songs, you slowly see the queue in conky
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
        Path albumArtPath = Paths.get(outputDirectory, ALBUM_ART + "." + id);
        String path = albumArtPath.toString();

        if (Files.notExists(albumArtPath, LinkOption.NOFOLLOW_LINKS)) {
            try {
                ReadableByteChannel readableByteChannel = Channels.newChannel(new URL(url).openStream());
                FileOutputStream fileOutputStream = new FileOutputStream(albumArtPath.toFile());
                fileOutputStream.getChannel().transferFrom(readableByteChannel, 0, Long.MAX_VALUE);
                fileOutputStream.close();
            } catch (IOException e) {
                logger.error("unable to download album art from the web");
                path = null;
            }
        } else {
            logger.info("album art already available on disk, no need to download it again from the web");
        }

        return path;
    }
}