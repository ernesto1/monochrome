package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Catalog of running {@link MusicPlayer music players} in the system.  As new music players are "detected" through the dbus,
 * the dbus signal handlers will add them here.<br>
 * <br>
 * For each update performed on this music player catalog, the database will determine <i>what music player should be
 * considered {@link #activePlayer in focus}</i>, ie. what music player details should conky be displaying.
 */
public class MusicPlayerDatabase {
    private static final Logger logger = LoggerFactory.getLogger(MusicPlayerDatabase.class);

    /**
     * The player that is currently in focus, ie. being displayed by conky.<br>
     * <br>
     * This object is snapshot of the state of the underlying player when it became "active".  This will allow us
     * to detect changes in the player's state as interactions with this database take place.
     */
    private MusicPlayer activePlayer;
    /**
     * Map of available music players: <tt>unique dbus name (ex. :1.23)-> music player</tt>
     */
    private Map<String, MusicPlayer> musicPlayers;
    private MusicPlayerWriter writer;

    public MusicPlayerDatabase(MusicPlayerWriter writer) {
        this.writer = writer;
        musicPlayers = new HashMap<>(5);
    }

    public void init() {
        determineActivePlayer();
    }

    /**
     * Determine if the given application is registered as a music player in this database
     * @param uniqueName application's unique dbus name (ex. :1.23)
     * @return <tt>true</tt> if the application is registered, <tt>false</tt> otherwise
     */
    public boolean contains(String uniqueName) {
        return musicPlayers.containsKey(uniqueName);
    }

    /**
     * Retrieve the music player from the database
     * @param uniqueName application's unique dbus name (ex. :1.23)
     * @return the matching music player
     */
    public MusicPlayer getPlayer(String uniqueName) {
        return musicPlayers.get(uniqueName);
    }

    /**
     * Stores the music player in the database.  This action may update the current <i>in focus</i> player.
     * @param player music player to store in the db
     */
    public void save(MusicPlayer player) {
        musicPlayers.put(player.getDBusUniqueName(), player);
        determineActivePlayer();
    }

    /**
     * Assesses what is the current music player that should be "in focus" by conky.<br>
     * Priority is given to a player that is playing music at the moment.
     */
    private void determineActivePlayer() {
        // if there is no real player selected as active, pick any player available
        if (activePlayer == null || activePlayer.equals(MusicPlayer.DUMMY_PLAYER)) {
            Optional<MusicPlayer> mp = getBestAvailablePlayer();
            activePlayer = mp.isPresent() ? new MusicPlayer(mp.get()) : MusicPlayer.DUMMY_PLAYER;
            logger.info("'{}' is the new active player, writing to disk", activePlayer.getPlayerName());
            writer.writePlayerState(activePlayer);
            return;
        }

        // if an active player is available, then...
        // get the current state of the active player
        MusicPlayer newPlayerState = musicPlayers.get(activePlayer.getDBusUniqueName());

        // if the active player is no longer playing music
        if (newPlayerState.getPlaybackStatus() != MusicPlayer.PlaybackStatus.PLAYING) {
            // do we have another player that IS PLAYING music that we can replace it with?
            Optional<MusicPlayer> mp = getActivePlayer();

            if (mp.isPresent()) {
                newPlayerState = mp.get();
            }
        }

        if (!activePlayer.isSameState(newPlayerState)) {
            activePlayer = new MusicPlayer(newPlayerState);
            logger.info("new state for the active player '{}', writing to disk", activePlayer.getPlayerName());
            writer.writePlayerState(activePlayer);
        }
    }

    private Optional<MusicPlayer> getActivePlayer() {
        Optional<MusicPlayer> player = musicPlayers.values()
                                                   .stream()
                                                   .filter(p -> p.getPlaybackStatus() == MusicPlayer.PlaybackStatus.PLAYING)
                                                   .findFirst();
        return player;
    }

    private Optional<MusicPlayer> getBestAvailablePlayer() {
        Optional<MusicPlayer> player = getActivePlayer();

        if (player.isPresent()) {
            return player;
        }

        // if no music player is playing music, just pull any from the list
        player = musicPlayers.values()
                             .stream()
                             .findFirst();
        return player;
    }

    /**
     * Removes the music player from the database
     * @param dBusUniqueName application's unique dbus name (ex. :1.23)
     */
    public void removePlayer(String dBusUniqueName) {
        MusicPlayer removedPlayer = musicPlayers.remove(dBusUniqueName);

        if (removedPlayer != null) {
            logger.debug("removed the '{}' music player from the database", removedPlayer.getPlayerName());
        }

        // check if the active player (if available) is the player being removed
        if (activePlayer != null && activePlayer.getDBusUniqueName().compareTo(dBusUniqueName) == 0) {
            activePlayer = null;
        }

        determineActivePlayer();
    }

    /**
     * Returns a set of the paths to the album art images in use by the players available in this database
     * @return a <tt>Set</tt> containing the file path to the current album art in use
     */
    public Set<String> getAlbumArtPaths() {
        Set<String> images = musicPlayers.values()
                                         .stream()
                                         .map(player -> player.getAlbumArtPath())
                                         .collect(Collectors.toSet());
        return images;
    }
}
