package com.conky.musicplayer;

import java.util.Objects;

/**
 * Data object to represent a music player's state.  State is defined by:
 * <ul>
 *     <li>Track playback status: paused, playing, stopped</li>
 *     <li>Current or last played song information</li>
 * </ul>
 * Depending on how the player communicates through the dbus, some are initialized with no details until a song
 * is played.  Others already have a pre selected track upon boot.
 */
public class MusicPlayer {
    public static final MusicPlayer DUMMY_PLAYER = new MusicPlayer("Nameless Player", ":1.23");
    /**
     * DBus unique name for this music player
     */
    private String dBusUniqueName;
    private String playerName;
    private PlaybackStatus playbackStatus;
    private TrackInfo trackInfo;

    public MusicPlayer(String name, String dDusUniqueName) {
        playerName = name;
        this.dBusUniqueName = dDusUniqueName;
        playbackStatus = PlaybackStatus.STOPPED;
        trackInfo = new TrackInfo("000");
    }

    public MusicPlayer(MusicPlayer player) {
        dBusUniqueName = player.getDBusUniqueName();
        playerName = player.getPlayerName();
        playbackStatus = player.getPlaybackStatus();
        trackInfo = new TrackInfo(player.getTrackId());
        trackInfo.setArtist(player.getArtist());
        trackInfo.setTitle(player.getTitle());
        trackInfo.setAlbum(player.getAlbum());
        trackInfo.setGenre(player.getGenre());
        trackInfo.setAlbumArtPath(player.getAlbumArtPath());
    }

    public boolean setPlaybackStatus(String status) {
        if (status != null) {
            try {
                playbackStatus = PlaybackStatus.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException e) {
                playbackStatus = PlaybackStatus.UNKNOWN;
            }

            return true;
        }

        return false;
    }

    public boolean setTrackInfo(TrackInfo trackInfo) {
        if (trackInfo != null) {
            this.trackInfo = trackInfo;

            return true;
        }

        return false;
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

    public String getAlbumArtPath() {
        return trackInfo.getAlbumArtPath();
    }

    public String getDBusUniqueName() {
        return dBusUniqueName;
    }

    private String getTrackId() {
        return trackInfo.getTrackId();
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
     * Determines if the given player has the same state as this player.
     * A music player's state is considered the same if the following attributes are the same:
     * <ul>
     *     <li>dbus unique name</li>
     *     <li>playback status</li>
     *     <li>track id</li>
     * </ul>
     * @param otherPlayer
     * @return
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
        UNKNOWN
    }
}
