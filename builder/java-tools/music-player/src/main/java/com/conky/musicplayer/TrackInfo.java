package com.conky.musicplayer;

/**
 * Data object representing a song on an album
 */
public class TrackInfo {
    /**
     * Unique id for this track as specified by the MPRIS specification
     */
    private String id;
    private String title;
    private String artist;
    private String album;
    private String genre;

    /**
     * File path of the cover art image
     */
    private String albumArtPath;

    public TrackInfo(String id) {
        if (id == null) {
            throw new IllegalArgumentException("track id cannot be null");
        }

        this.id = id;
        title = "unknown title";
        artist = "unknown artist";
        album = "unknown album";
        genre = "unknown genre";
        albumArtPath = null;
    }

    public void setTitle(String title) {
        if (isNotEmpty(title)) {
            this.title = title;
        }
    }

    public void setArtist(String artist) {
        if (isNotEmpty(artist)) {
            this.artist = artist;
        }
    }

    public void setAlbum(String album) {
        if (isNotEmpty(album)) {
            this.album = album;
        }
    }

    public void setGenre(String genre) {
        if (isNotEmpty(genre)) {
            this.genre = genre;
        }
    }

    public void setAlbumArtPath(String albumArtPath) {
        if (isNotEmpty(albumArtPath)) {
            this.albumArtPath = albumArtPath;
        }
    }

    /**
     * Dertermines if the string actually has a value, ie. not empty or null
     * @param s string to analyze
     * @return <tt>true</tt> if the string has a value
     */
    private boolean isNotEmpty(String s) {
        return s != null && !s.isEmpty();
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

    public String getId() {
        return id;
    }

    @Override
    public String toString() {
        return String.format("%s | %s | %s | %s | %s", artist, album, title, genre, albumArtPath);
    }
}
