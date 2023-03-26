package com.conky.musicplayer;

import java.util.Objects;

public class MusicPlayer {
    /**
     * DBus unique name for this music player
     */
    private String uniqueName;
    private String playerName;
    private PlaybackStatus playbackStatus;
    private TrackInfo trackInfo;

    public MusicPlayer(String name, String uniqueName) {
        playerName = name;
        this.uniqueName = uniqueName;
        playbackStatus = PlaybackStatus.STOPPED;
        trackInfo = new TrackInfo();
    }

    public void setPlayerName(String playerName) {
        this.playerName = playerName;
    }

    public void setPlaybackStatus(String playbackStatus) {
        if (playbackStatus != null) {
            try {
                this.playbackStatus = PlaybackStatus.valueOf(playbackStatus.toUpperCase());
            } catch (IllegalArgumentException e) {
                this.playbackStatus = PlaybackStatus.UNKNOWN;
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
