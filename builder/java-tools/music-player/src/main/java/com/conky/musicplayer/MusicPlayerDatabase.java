package com.conky.musicplayer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

public class MusicPlayerDatabase {
    private static Logger logger = LoggerFactory.getLogger(MusicPlayerDatabase.class);
    /**
     * List of recognized music players.  Only signals from these players will be processed.<br>
     * These are music players that comply with the "protocol" expected from this app, ex.
     * <ul>
     *     <li>Provides proper song metadata</li>
     *     <li>Provides album art</li>
     *     <li>The way it sends status update messages is supported by this app</li>
     * </ul>
     */
    private List<String> recognizedPlayers;
    /**
     * The player that is currently in focus, ie. being displayed by conky
     */
    private MusicPlayer activePlayer;
    /**
     * Map of available music players
     */
    private Map<String, MusicPlayer> musicPlayers;

    public MusicPlayerDatabase() {
        // TODO player list should be coming from a config file
        recognizedPlayers = new ArrayList<>();
        recognizedPlayers.add("rhythmbox");
        recognizedPlayers.add("spotify");
        musicPlayers = new HashMap<>();
    }

    public boolean isMusicPlayer(String playerName) {
        return recognizedPlayers.contains(playerName.toLowerCase());
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

    private void removePlayer(String dBusUniqueName) {
        Optional<MusicPlayer> player = musicPlayers.values()
                                                   .stream()
                                                   .filter(p -> p.getDBusUniqueName().equals(dBusUniqueName))
                                                   .findFirst();
        player.ifPresent(p -> musicPlayers.remove(p));

        if (activePlayer.getDBusUniqueName().equals(dBusUniqueName)) {
            activePlayer = null;
        }

        determineActivePlayer();
    }
}
