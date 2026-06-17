import 'package:flutter/material.dart';
import 'package:waveon/core/services/history_service.dart';
import 'package:waveon/home/music_lib/lib_provider.dart';
import 'package:waveon/home/music_lib/player_provider.dart';
import 'package:waveon/models/carousel_item.dart';
import 'package:waveon/models/local_song.dart';
import 'package:waveon/widgets/carousel_card.dart';
import 'package:waveon/widgets/expand_search_bar.dart';
import 'package:waveon/session/session_widget.dart';
import 'package:provider/provider.dart';
import 'package:waveon/widgets/session_buttons.dart';
import 'package:shimmer/shimmer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final libProvider = context.read<LibProvider>();
      if (!libProvider.hasPermission && libProvider.audioFiles.isEmpty) {
        libProvider.checkExistingPermission();
      }
    });
  }

  List<LocalSong>? _cachedRecentSongs;

  Future<List<LocalSong>> _getRecentSongs(List<LocalSong> library) async {
    final ids = await HistoryService.getRecentIds();
    final Map<int, LocalSong> songMap = {
      for (var song in library) song.id!: song,
    };
    List<LocalSong> recent = [];
    for (final id in ids) {
      if (songMap.containsKey(id)) {
        recent.add(songMap[id]!);
      }
    }
    return recent;
  }

  @override
  Widget build(BuildContext context) {
    final libProvider = context.watch<LibProvider>();
    final playerProvider = context.read<PlayerProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Recently Played",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<int>(
                  valueListenable: HistoryService.historyUpdated,
                  builder: (context, _, __) {
                    if (libProvider.isLoading) {
                      return _buildSkeletonLoader();
                    }

                    if (libProvider.audioFiles.isEmpty) {
                      return _buildEmptyRecentState();
                    }

                    return FutureBuilder<List<LocalSong>>(
                      future: _getRecentSongs(libProvider.audioFiles),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _cachedRecentSongs = snapshot.data;
                        }

                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            _cachedRecentSongs == null) {
                          return _buildSkeletonLoader();
                        }

                        final songs = _cachedRecentSongs;

                        if (snapshot.hasError) {
                          return const SizedBox(
                            height: 190,
                            child: Center(
                              child: Text(
                                'Error loading recent songs',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        }

                        if (songs == null || songs.isEmpty) {
                          return _buildEmptyRecentState();
                        }

                        final items = songs.asMap().entries.map((e) {
                          return CarouselItem(
                            id: e.value.id,
                            title: e.value.title,
                            subtitle: e.value.artist,
                            gradient: getGradientForSong(e.key),
                            onTap: () => playerProvider.playLoadSong(
                              e.value,
                              libProvider.audioFiles,
                            ),
                          );
                        }).toList();

                        return RecentlyPlayedCarousel(items: items);
                      },
                    );
                  },
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: const [
                      Expanded(child: HostButton()),
                      SizedBox(width: 12),
                      Expanded(child: JoinButton()),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const AmbientSessionCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecentState() {
    return const SizedBox(
      height: 190,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, color: Colors.white24, size: 40),
            SizedBox(height: 12),
            Text(
              "No recent songs played",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final libProvider = context.watch<LibProvider>();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ExpandingMusicSearchBar(
        hintText: "Search music...",
        onQueryChanged: (query) {
          context.read<LibProvider>().updateSearchQuery(query);
        },
        suggestionsBuilder: (context, searchController) {
          final filteredSongs = libProvider.audioFiles;
          if (filteredSongs.isEmpty) {
            return const [
              Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No Tracks found buddy',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            ];
          }
          return filteredSongs.map((song) {
            return SearchSongTile(song: song, currentQueue: filteredSongs);
          }).toList();
        },
      ),
    );
  }
}

Widget _buildSkeletonLoader() {
  return SizedBox(
    height: 190,
    child: Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
