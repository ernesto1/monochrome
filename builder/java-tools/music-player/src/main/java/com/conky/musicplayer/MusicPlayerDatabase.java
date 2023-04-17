package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;
import java.util.stream.Collectors;

/**
 * <h2>Overview</h2>
 * Catalog of running {@link MusicPlayer music players} in the system.  As new music players are "detected" through the dbus,
 * the dbus signal handlers will add them here.<br>
 * <br>
 * For each update performed on this music player catalog, the database will determine <i>what music player should be
 * considered {@link #activePlayer in focus}</i>, ie. what music player details should conky be displaying.<br>
 * <br>
 * <h2>Supported players</h2>
 * Music players don't follow a standard when it comes to dbus integration.  Therefore, those players that
 * are supported by this app are registered here as {@link #supportedPlayers supported players}.<br>
 * <br>
 * Signal handlers can {@link #isMusicPlayer(String) query the database} in order to filter out messages from media players that
 * are not supported by this application.
 */
public class MusicPlayerDatabase {
    private static final Logger logger = LoggerFactory.getLogger(MusicPlayerDatabase.class);
    /**
     * List of compatible music players.  Only signals from these players will be processed.<br>
     * These are music players that comply with the "protocol" expected from this app, ie.
     * <ul>
     *     <li>Player provides complete song metadata</li>
     *     <li>The way it sends status update messages is supported by this app</li>
     * </ul>
     */
    private List<String> supportedPlayers;
    /**
     * The player that is currently in focus, ie. being displayed by conky.<br>
     * <br>
     * This object is snapshot of the state of the underlying player when it became "active".  This will allow us
     * to detect changes in the player's state as interactions with this database take place.
     */
    private MusicPlayer activePlayer;
    /**
     * Map of available music players: <tt>player name -> music player</tt>
     */
    private Map<String, MusicPlayer> musicPlayers;
    private MusicPlayerWriter writer;

    public MusicPlayerDatabase(MusicPlayerWriter writer, List<String> supportedPlayers) {
        this.writer = writer;
        this.supportedPlayers = supportedPlayers;
        musicPlayers = new HashMap<>();
    }

    public void init() {
        determineActivePlayer();
    }

    /**
     * Determine if the given player is a "supported" music player by this database.<br>
     * This would allow a client to filter out other media players on the dbus like a firefox youtube window for example.
     * @param playerName the player's name
     * @return <tt>true</tt> if the player is supported
     */
    public boolean isMusicPlayer(String playerName) {
        return supportedPlayers.contains(playerName.toLowerCase());
    }

    public boolean contains(String playerName) {
        return musicPlayers.containsKey(playerName);
    }

    public MusicPlayer getPlayer(String playerName) {
        return musicPlayers.get(playerName);
    }

    public void save(MusicPlayer player) {
        musicPlayers.put(player.getPlayerName(), player);
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
        MusicPlayer newPlayerState = musicPlayers.get(activePlayer.getPlayerName());

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

        // if no music player are playing music, just pull any from the list
        player = musicPlayers.values()
                             .stream()
                             .findFirst();
        return player;
    }

    public void removePlayer(String dBusUniqueName) {
        Optional<MusicPlayer> player = musicPlayers.values()
                                                   .stream()
                                                   .filter(p -> p.getDBusUniqueName().equals(dBusUniqueName))
                                                   .findFirst();
        player.ifPresent(p -> {
            MusicPlayer mp = musicPlayers.remove(p.getPlayerName());
            logger.debug("removed the '{}' music player from the database", mp.getPlayerName());
        });

        // check if the active player (if available) is the player being removed
        if (activePlayer != null && activePlayer.getDBusUniqueName().compareTo(dBusUniqueName) == 0) {
            activePlayer = null;
        }

        determineActivePlayer();
    }

    /**
     * Returns a set of the current album art images in use by the players available in this database
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