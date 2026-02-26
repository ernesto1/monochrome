package com.conky.musicplayer;

import org.freedesktop.dbus.DBusMap;
import org.freedesktop.dbus.types.Variant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Optional;

/**
 * Utility class for retrieving music player specific metadata through the dbus
 * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Player_Interface.html">MPRIS Player Inteface</a>
 * https://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata/
 */
public class MetadataRetriever {
    private static final Logger logger = LoggerFactory.getLogger(MetadataRetriever.class);
    private final ApplicationInquirer inquirer;

    public MetadataRetriever(ApplicationInquirer inquirer) {
        this.inquirer = inquirer;
    }

    public Optional<String> getPlayerName(String uniqueName) {
        Optional<String> playerName = inquirer.getApplicationProperty(uniqueName,
                                                                      MPRIS.Objects.MEDIAPLAYER2,
                                                                      MPRIS.Interfaces.MEDIAPLAYER2,
                                                                      MPRIS.Properties.IDENTITY);

        return playerName;
    }

    /**
     * Queries the music player through the dbus to get its current playback details, ex.
     * <ul>
     *     <li>Is it playing music or paused?</li>
     *     <li>What song is selected?</li>
     * </ul>
     *
     * @param player music player to query
     * @return the player's state as a <code>Music Player</code> object
     */
    public MusicPlayer getPlayerState(MusicPlayer player) {
        Optional<String> playback = inquirer.getApplicationProperty(player.getDBusUniqueName(),
                                                                    MPRIS.Objects.MEDIAPLAYER2,
                                                                    MPRIS.Interfaces.MEDIAPLAYER2_PLAYER,
                                                                    MPRIS.Properties.PLAYBACK_STATUS);
        playback.ifPresent(player::setPlaybackStatus);
        Optional<DBusMap> metadata = inquirer.getApplicationProperty(player.getDBusUniqueName(),
                                                                     MPRIS.Objects.MEDIAPLAYER2,
                                                                     MPRIS.Interfaces.MEDIAPLAYER2_PLAYER,
                                                                     MPRIS.Properties.METADATA);
        metadata.ifPresent(m -> player.setTrackInfo(getTrackInfo(m)));

        return player;
    }

    /**
     * Extracts song track information <i>if it exists</i> from the metadata property of the <code>MediaPlayer2.Player</code> interface.<br>
     * Song details are defined using <code>xesam</code> ontology.
     *
     * @param metadata the signal's metadata property as a map of key/value pairs
     * @see <a href="https://specifications.freedesktop.org/mpris-spec/latest/Track_List_Interface.html#Mapping:Metadata_Map">Metadata map documentation</a>
     * @see <a href="https://www.freedesktop.org/wiki/Specifications/mpris-spec/metadata/">MPRIS v2 metadata guidelines</a>
     */
    public TrackInfo getTrackInfo(DBusMap metadata) {
        TrackInfo trackInfo = null;
        Optional<String> property = extractProperty(metadata.get("mpris:trackid"));

        if (property.isPresent()) {
            trackInfo = new TrackInfo(property.get());
        } else {
            // if the track id is missing, there are no track details to update
            return null;
        }

        property = extractProperty(metadata.get("xesam:title"));
        property.ifPresent(trackInfo::setTitle);
        property = extractProperty(metadata.get("xesam:album"));
        property.ifPresent(trackInfo::setAlbum);
        property = extractArray(metadata.get("xesam:artist"));
        property.ifPresent(trackInfo::setArtist);
        property = extractArray(metadata.get("xesam:genre"));
        property.ifPresent(trackInfo::setGenre);
        property = extractProperty(metadata.get("mpris:artUrl"));
        property.ifPresent(trackInfo::setAlbumArtURL);

        return trackInfo;
    }

    /**
     * Extracts the java primitive type from the object wrapper used by the dbus API.<br>
     * The method abstracts the nuances of how the dbus library API returns data to us.
     * @param property raw property from the metadata map
     * @return the property in its java primitive equivalent
     * @param <T>
     */
    private <T> Optional<T> extractProperty(Object property) {
        /*
         n.b. the type of the values in the metadata map will differ based on what dbus interface is providing this data
              - metadata map from the 'properties changed signal' will wrap all values under the Variant<T> type
              - metadata map from the 'org.mpris.MediaPlayer2.Player' interface will use the regular java types
         */
        if (property != null) {
            if (property instanceof Variant) {
                return Optional.of(((Variant<T>) property).getValue());
            } else {
                return Optional.of((T) property);
            }
        }

        return Optional.empty();
    }

    /**
     * Extracts the first value within the array from the array object wrapper used by the dbus API.<br>
     * This method abstracts the nuances of how the dbus library API returns data to us.
     *
     * @param anArray array property from the metadata map
     * @return the first string in the array
     */
    private Optional<String> extractArray(Object anArray) {
        Optional<ArrayList<String>> array = extractProperty(anArray);

        if (array.isPresent()) {
            ArrayList<String> elements = array.get();

            // spotify may return an empty list :(
            if (!elements.isEmpty()) {
                // in case of multiple entries, we only pull the first one
                return Optional.of(elements.get(0));
            }
        }

        return Optional.empty();
    }
}