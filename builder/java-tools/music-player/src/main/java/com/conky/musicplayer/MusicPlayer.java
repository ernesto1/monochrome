package com.conky.musicplayer;

import java.util.Objects;

/**
 * Data object to represent a music player's state.  State is defined by:
 * <ul>
 *     <li>Track playback status: paused, playing, stopped</li>
 *     <li>Current or last played song information</li>
 * </ul>
 * Upon boot a music player initializes some or all of its metadadata. When a song is played, all the metadata
 * is guarantied to be communicated through the dbus.
 */
public class MusicPlayer {
    public static final MusicPlayer DUMMY_PLAYER = new MusicPlayer("no player running", ":1.23", Status.OFF);
    /**
     * Unique connection name of the music player application under the dbus, ex. :1.23
     */
    private String dBusUniqueName;
    private String playerName;
    private PlaybackStatus playbackStatus;
    /**
     * Determines if the player is running or not
     */
    private Status status;
    private TrackInfo trackInfo;

    public MusicPlayer(String name, String dDusUniqueName, Status status) {
        playerName = name;
        this.dBusUniqueName = dDusUniqueName;
        playbackStatus = PlaybackStatus.STOPPED;
        this.status = status;
        trackInfo = new TrackInfo("000");
    }

    public MusicPlayer(MusicPlayer player) {
        dBusUniqueName = player.getDBusUniqueName();
        playerName = player.getPlayerName();
        playbackStatus = player.getPlaybackStatus();
        status = player.getStatus();
        trackInfo = new TrackInfo(player.getTrackId());
        trackInfo.setArtist(player.getArtist());
        trackInfo.setTitle(player.getTitle());
        trackInfo.setAlbum(player.getAlbum());
        trackInfo.setGenre(player.getGenre());
        trackInfo.setAlbumArtURL(player.getAlbumArtURL());
    }

    /**
     * Update the playback status of the music player
     * @param status new status
     */
    public void setPlaybackStatus(String status) {
        if (status != null) {
            try {
                playbackStatus = PlaybackStatus.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException e) {
                playbackStatus = PlaybackStatus.UNKNOWN;
            }
        }
    }

    /**
     * Update the music player's track details, ie. the song currently being played
     * @param trackInfo new track details
     */
    public void setTrackInfo(TrackInfo trackInfo) {
        if (trackInfo != null) {
            this.trackInfo = trackInfo;
        }
    }

    public String getPlayerName() {
        return playerName;
    }

    public PlaybackStatus getPlaybackStatus() {
        return playbackStatus;
    }

    public String getTitle() {
        return trackInfo.getTitle();
    }

    public String getArtist() {
        return trackInfo.getArtist();
    }

    public String getAlbum() {
        return trackInfo.getAlbum();
    }

    public String getGenre() {
        return trackInfo.getGenre();
    }

    public String getAlbumArtURL() {
        return trackInfo.getAlbumArtURL();
    }

    public String getDBusUniqueName() {
        return dBusUniqueName;
    }

    private String getTrackId() {
        return trackInfo.getTrackId();
    }

    public Status getStatus() {
        return status;
    }

    @Override
    public String toString() {
        return String.format("%s | %s | %s", playerName, playbackStatus, trackInfo);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        MusicPlayer that = (MusicPlayer) o;
        return Objects.equals(playerName, that.playerName);
    }

    @Override
    public int hashCode() {
        return Objects.hash(playerName);
    }

    /**
     * Determines if the given player has the same state as this player.<br>
     * A music player's state is considered the same if the following attributes are the equal:
     * <ul>
     *     <li>dbus unique name</li>
     *     <li>playback status</li>
     *     <li>track id</li>
     * </ul>
     * @param otherPlayer the other player to compare this player to
     * @return <code>true</code> if the state is the same, <code>false</code> otherwise
     */
    public boolean isSameState(MusicPlayer otherPlayer) {
        if (otherPlayer == null) return false;
        if (dBusUniqueName.compareTo(otherPlayer.getDBusUniqueName()) != 0) return false;
        if (playbackStatus != otherPlayer.getPlaybackStatus()) return false;
        if (trackInfo.getTrackId() != otherPlayer.getTrackId()) return false;

        return true;
    }

    public enum PlaybackStatus {
        PLAYING,
        PAUSED,
        STOPPED,
        /**
         * Only used if a new state not defined in this enum is received from a media player
         */
        UNKNOWN
    }

    public enum Status {
        /**
         * State when no player is running
         */
        OFF,
        /**
         * State when a player is running
         */
        ON
    }
}
