package com.conky.musicplayer;

/**
 * Data object representing a song on an album
 */
public class TrackInfo {
    private String title;
    private String artist;
    private String album;
    private String genre;

    /**
     * File path of the cover art image
     */
    private String albumArtPath;

    public TrackInfo() {
        title = "unknown title";
        artist = "unknown artist";
        album = "unknown album";
        genre = "unknown genre";
        albumArtPath = null;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public void setAlbum(String album) {
        this.album = album;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public void setAlbumArtPath(String albumArtPath) {
        this.albumArtPath = albumArtPath;
    }

    public String getTitle() {
        return title;
    }

    public String getArtist() {
        return artist;
    }

    public String getAlbum() {
        return album;
    }

    public String getGenre() {
        return genre;
    }

    public String getAlbumArtPath() {
        return albumArtPath;
    }

    @Override
    public String toString() {
        return String.format("%s | %s | %s | %s | %s", artist, album, title, genre, albumArtPath);
    }
}
