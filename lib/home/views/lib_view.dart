import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:waveon/home/music_lib/lib_provider.dart';
import 'package:waveon/home/music_lib/player_provider.dart';
import 'package:waveon/widgets/expand_search_bar.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../models/local_song.dart';

class LibView extends StatefulWidget {
  const LibView({super.key});

  @override
  State<LibView> createState() => _LibViewState();
}

class _LibViewState extends State<LibView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LibProvider>();
      if (!provider.hasPermission || provider.audioFiles.isEmpty) {
        provider.initLibrary();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LibProvider>();
    final audioFiles = provider.audioFiles;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          surfaceTintColor: const Color(0xFF0D0D0D),
          backgroundColor: const Color(0xFF0D0D0D),
          title: const Text(
            "Your Library",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        body: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              )
            : !provider.hasPermission
            ? _buildPermissionState(context)
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    ExpandingMusicSearchBar(
                      hintText: "Search your music...",
                      onQueryChanged: (query) {
                        context.read<LibProvider>().updateSearchQuery(query);
                      },
                      suggestionsBuilder: (context, searchController) {
                        final filteredSongs = provider.audioFiles;

                        if (filteredSongs.isEmpty) {
                          return const [
                            Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  "No tracks found buddy.",
                                  style: TextStyle(color: Colors.white38),
                                ),
                              ),
                            ),
                          ];
                        }
                        return filteredSongs.map((song) {
                          return SearchSongTile(
                            song: song,
                            currentQueue: filteredSongs,
                          );
                        }).toList();
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Total Tracks: ${provider.totalCount}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: audioFiles.isEmpty
                          ? const _EmptyState()
                          : _PlayList(
                              controller: _scrollController,
                              audioFiles: audioFiles,
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPermissionState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_off, size: 60, color: Colors.white54),
            const SizedBox(height: 16),
            const Text(
              "Media permission is required to find music. You can enable it anytime in your device settings.",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LibProvider>().retryPermission();
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text("Grant Permission"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                context.read<LibProvider>().checkExistingPermission();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text(
                "I've already granted it",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off_outlined,
            size: 60,
            color: Colors.white.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          const Text(
            "No music found on device.",
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _PlayList extends StatelessWidget {
  final List<LocalSong> audioFiles;
  final ScrollController controller;

  static const double _itemHeight = 72.0;
  static const double _topPadding = 10.0;

  const _PlayList({required this.audioFiles, required this.controller});

  void _scrollToLetter(String letter) {
    final index = audioFiles.indexWhere(
      (song) => song.title.toUpperCase().startsWith(letter),
    );
    if (index != -1) {
      final offset = (index * _itemHeight) + _topPadding;
      controller.animateTo(
        offset,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alphabet = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

    return Stack(
      children: [
        RawScrollbar(
          controller: controller,
          thumbColor: Colors.blueAccent.withOpacity(0.5),
          radius: const Radius.circular(20),
          thickness: 4,
          child: ListView.builder(
            controller: controller,
            itemCount: audioFiles.length,
            itemExtent: _itemHeight,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              top: _topPadding,
              right: 30,
              bottom: 40,
            ),
            itemBuilder: (context, index) {
              return _buildSongTile(context, audioFiles[index], audioFiles);
            },
          ),
        ),
        Positioned(
          right: 0,
          top: 40,
          bottom: 40,
          child: Container(
            width: 30,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: alphabet
                    .map(
                      (letter) => GestureDetector(
                        onTap: () => _scrollToLetter(letter),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            letter,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSongTile(
    BuildContext context,
    LocalSong song,
    List<LocalSong> queue,
  ) {
    triggerPlay() async {
      final player = context.read<PlayerProvider>();
      await player.playLoadSong(song, queue);
    }

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white54),
      ),
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: song.id != null
            ? AnimatedListArtwork(id: song.id!)
            : const Icon(Icons.music_note, color: Colors.blueAccent, size: 24),
      ),
      onTap: triggerPlay,
    );
  }
}

class AnimatedListArtwork extends StatefulWidget {
  final int id;

  const AnimatedListArtwork({super.key, required this.id});

  @override
  State<AnimatedListArtwork> createState() => _AnimatedListArtworkState();
}

class _AnimatedListArtworkState extends State<AnimatedListArtwork> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  Future<Uint8List?>? _artworkFuture;

  @override
  void initState() {
    super.initState();
    _artworkFuture = _audioQuery.queryArtwork(
      widget.id,
      ArtworkType.AUDIO,
      size: 100,
      quality: 50,
      format: ArtworkFormat.JPEG,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _artworkFuture,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          child: _buildContent(snapshot),
        );
      },
    );
  }

  Widget _buildContent(AsyncSnapshot<Uint8List?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(key: ValueKey('loading'), width: 40, height: 40);
    }

    if (snapshot.hasData && snapshot.data != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          snapshot.data!,
          key: ValueKey(widget.id),
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      key: const ValueKey('no-art'),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note, color: Colors.blueAccent, size: 24),
    );
  }
}
