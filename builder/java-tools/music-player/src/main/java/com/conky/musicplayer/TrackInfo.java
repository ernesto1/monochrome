package com.conky.musicplayer;

/**
 * Data object representing a song on an album
 */
public class TrackInfo {
    /**
     * Unique id for this track as specified by the MPRIS specification
     */
    private final String id;
    private String title;
    private String artist;
    private String album;
    private String genre;
    /**
     * URL of the album art image
     */
    private String albumArtURL;

    public TrackInfo(String id) {
        if (id == null) {
            throw new IllegalArgumentException("track id cannot be null");
        }

        this.id = id;
        title = "unknown title";
        artist = "unknown artist";
        album = "unknown album";
        genre = "unknown genre";
        albumArtURL = null;
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
        if (isNotEmpty(genre) && isNotUnknown(genre)) {
            this.genre = genre;
        }
    }

    public void setAlbumArtURL(String albumArtURL) {
        if (isNotEmpty(albumArtURL)) {
            this.albumArtURL = albumArtURL;
        }
    }

    /**
     * Determines if the string actually has a value, ie. not empty or null
     * @param s string to analyze
     * @return <code>true</code> if the string has a value
     */
    private boolean isNotEmpty(String s) {
        return s != null && !s.isEmpty();
    }

    /**
     * Determines if the track metadata string contains an actual value and not a filler value
     * for missing details like <i>Unknown</i>
     * @param s string to analyze
     * @return <code>true</code> if the metadata is not some verbiage of 'unknown', <code>false</code> otherwise
     */
    private boolean isNotUnknown(String s) {
        return !s.toLowerCase().contains("unknown");
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

    public String getAlbumArtURL() {
        return albumArtURL;
    }

    public String getTrackId() {
        return id;
    }

    @Override
    public String toString() {
        final String art = (albumArtURL != null) ? albumArtURL : "no album art";
        return String.format("%s | %s | %s | %s | %s", artist, album, title, genre, art);
    }
}
