package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

/**
 * Catalog of running music players in the system.  As new music players are "detected" through the dbus,
 * they will be added here.<br>
 * <br>
 * The database is responsible for determining at any point in time <i>what music player should be
 * considered {@link #activePlayer in focus}</i>, ie. what music player details should conky be displaying.<br>
 * <br>
 * Music players don't follow a standard when it comes to dbus integration.  Therefore, those that have been tested
 * for and supported by this app are registered here as {@link #supportedPlayers supported players}.
 */
public class MusicPlayerDatabase {
    private static Logger logger = LoggerFactory.getLogger(MusicPlayerDatabase.class);
    /**
     * List of recognized music players.  Only signals from these players will be processed.<br>
     * These are music players that comply with the "protocol" expected from this app, ie.
     * <ul>
     *     <li>Provides proper song metadata</li>
     *     <li>Provides album art</li>
     *     <li>The way it sends status update messages is supported by this app</li>
     * </ul>
     */
    private List<String> supportedPlayers;
    /**
     * The player that is currently in focus, ie. being displayed by conky
     */
    private MusicPlayer activePlayer;
    /**
     * Map of available music players: <tt>player name -> music player</tt>
     */
    private Map<String, MusicPlayer> musicPlayers;

    public MusicPlayerDatabase() {
        // TODO player list should be coming from a config file
        supportedPlayers = new ArrayList<>();
        supportedPlayers.add("rhythmbox");
        supportedPlayers.add("spotify");
        musicPlayers = new HashMap<>();
    }

    /**
     * Determine if the given player is a "supported" music player
     * @param playerName the player's name
     * @return <tt>true</tt> if the player is supported
     */
    public boolean isMusicPlayer(String playerName) {
        return supportedPlayers.contains(playerName.toLowerCase());
    }

    public boolean contains(String playerName) {
        return musicPlayers.containsKey(playerName);
    }

    public MusicPlayer getActivePlayer() {
        return activePlayer;
    }

    public MusicPlayer getPlayer(String playerName) {
        return musicPlayers.get(playerName);
    }

    public void save(MusicPlayer player) {
        musicPlayers.put(player.getPlayerName(), player);
        logger.info("{}", player);
        determineActivePlayer();
    }

    private void determineActivePlayer() {
        // if there is no currently active player, pick any player available
        if (activePlayer == null) {
            Optional<MusicPlayer> player = musicPlayers.values()
                                                       .stream()
                                                       .findFirst();
            // if there are no players available, fall back to the 'initial' dummy state
            player.ifPresentOrElse(p -> activePlayer = p, () -> activePlayer = MusicPlayer.DUMMY_PLAYER);
        }

        // if the currently selected player is not actually playing music, try to find one that is
        if (activePlayer.getPlaybackStatus() != MusicPlayer.PlaybackStatus.PLAYING) {
            Optional<MusicPlayer> player = musicPlayers.values()
                                                       .stream()
                                                       .filter(p -> p.getPlaybackStatus() == MusicPlayer.PlaybackStatus.PLAYING)
                                                       .findFirst();
            player.ifPresent(p -> activePlayer = p);
        }
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
}
