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
        trackInfo = new TrackInfo();
    }

    public void setPlaybackStatus(String status) {
        if (status != null) {
            try {
                playbackStatus = PlaybackStatus.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException e) {
                playbackStatus = PlaybackStatus.UNKNOWN;
            }
        }
    }

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

    public String getAlbumArtPath() {
        return trackInfo.getAlbumArtPath();
    }

    public String getDBusUniqueName() {
        return dBusUniqueName;
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

    public enum PlaybackStatus {
        PLAYING,
        PAUSED,
        STOPPED,
        UNKNOWN
    }
}
