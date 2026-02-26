package com.conky.musicplayer;

import org.freedesktop.dbus.connections.impl.DBusConnection;
import org.freedesktop.dbus.connections.impl.DBusConnectionBuilder;
import org.freedesktop.dbus.exceptions.DBusException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;

import java.util.List;
import java.util.concurrent.*;

/**
 * Main spring configuration class.  All beans will be instantiated in this class.
 */
@Configuration
@PropertySource("classpath:application.properties")
public class NowPlayingConfig {
    @Autowired
    private Environment env;
    @Bean
    public ThreadPoolExecutor albumArtExecutor() {
        /*
         the thread pool for downloading album art has a queue size of only one item.
         if a barrage of download tasks are submitted, only the last one will be performed.

         this is to decrease the wait time experienced by the user to see album art in the now playing conky
         while fast forwarding through multiple songs under a slow connection
         */
        ThreadPoolExecutor albumArtExecutor = new ThreadPoolExecutor(   1,
                                                                        1,
                                                                        0L,
                                                                        TimeUnit.MILLISECONDS,
                                                                        new ArrayBlockingQueue<>(1),
                                                                        new ThreadPoolExecutor.DiscardOldestPolicy());
        return albumArtExecutor;
    }

    @Bean
    public MusicPlayerDatabase playerDatabase() {
        MusicPlayerWriter writer = new MusicPlayerWriter(   env.getRequiredProperty("outputDir"),
                                                            env.getRequiredProperty("albumArtDir"),
                                                            albumArtExecutor());
        MusicPlayerDatabase playerDatabase = new MusicPlayerDatabase(writer);

        return playerDatabase;
    }

    @Bean
    public ThreadPoolExecutor signalExecutor() {
        // similar to the album art executor, there is only 1 thread
        // if a barrage of media player signals come, only the latest one is processed
        ThreadPoolExecutor signalExecutor = new ThreadPoolExecutor( 1,
                                                                    1,
                                                                    0L,
                                                                    TimeUnit.MILLISECONDS,
                                                                    new ArrayBlockingQueue<>(1),
                                                                    new ThreadPoolExecutor.DiscardOldestPolicy());

        return signalExecutor;
    }

    @Bean
    public DBusConnection dBusConnection() throws DBusException {
        DBusConnection conn = DBusConnectionBuilder.forSessionBus().build();
        return conn;
    }

    @Bean
    public AvailabilityHandler availabilityHandler() throws DBusException {
        ApplicationInquirer inquirer = new ApplicationInquirer(dBusConnection());
        MetadataRetriever metadataRetriever = new MetadataRetriever(inquirer);
        TrackUpdatesHandler trackUpdatesHandler = new TrackUpdatesHandler(  metadataRetriever,
                                                                            playerDatabase(),
                                                                            signalExecutor());
        List<String> supportedPlayers = env.getRequiredProperty("supportedPlayers", List.class);
        Registrar registrar = new Registrar(dBusConnection(),
                                            metadataRetriever,
                                            playerDatabase(),
                                            supportedPlayers,
                                            trackUpdatesHandler);
        AvailabilityHandler availabilityHandler = new AvailabilityHandler(dBusConnection(), registrar, playerDatabase());

        return availabilityHandler;
    }

    @Bean
    public ExecutorService albumArtHouseKeeperExecutor() {
        ExecutorService albumArtHouseKeeperExecutor = Executors.newSingleThreadExecutor();
        return albumArtHouseKeeperExecutor;
    }

    @Bean
    public AlbumArtHouseKeeper albumArtHouseKeeper() {
        return new AlbumArtHouseKeeper( env.getRequiredProperty("albumArtDir"),
                                        env.getRequiredProperty("albumCacheSize", Integer.class),
                                        playerDatabase());
    }
}
