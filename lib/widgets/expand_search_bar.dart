import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../home/library/player_provider.dart';
import '../models/local_song.dart';

class ExpandingMusicSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onQueryChanged;
  final List<Widget> Function(BuildContext context, SearchController controller)
  suggestionsBuilder;

  const ExpandingMusicSearchBar({
    super.key,
    this.hintText = "Search...",
    required this.onQueryChanged,
    required this.suggestionsBuilder,
  });

  @override
  State<ExpandingMusicSearchBar> createState() =>
      _ExpandingMusicSearchBarState();
}

class _ExpandingMusicSearchBarState extends State<ExpandingMusicSearchBar> {
  late final SearchController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = SearchController();

    _searchController.addListener(() {
      widget.onQueryChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _searchController,
      viewBackgroundColor: const Color(0xFF0D0D0D),
      viewHintText: widget.hintText,
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          hintText: widget.hintText,
          hintStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white38),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white),
          ),
          backgroundColor: WidgetStateProperty.all(
            Colors.white.withOpacity(0.05),
          ),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16),
          ),
          onTap: () => controller.openView(),
          onChanged: (_) => controller.openView(),
          leading: const Icon(Icons.search, color: Colors.white54),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        return widget.suggestionsBuilder(context, controller);
      },
    );
  }
}

class SearchSongTile extends StatelessWidget {
  final LocalSong song;
  final List<LocalSong> currentQueue;

  const SearchSongTile({
    super.key,
    required this.song,
    required this.currentQueue,
  });

  @override
  Widget build(BuildContext context) {
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
            ? QueryArtworkWidget(
                id: song.id!,
                type: ArtworkType.AUDIO,
                format: ArtworkFormat.JPEG,
                size: 60,
                artworkHeight: 40,
                artworkWidth: 40,
                artworkBorder: BorderRadius.circular(8),
                nullArtworkWidget: const Icon(
                  Icons.music_note,
                  color: Colors.blueAccent,
                  size: 24,
                ),
              )
            : const Icon(Icons.music_note, color: Colors.blueAccent, size: 24),
      ),
      onTap: () async {
        await context.read<PlayerProvider>().playLoadSong(song, currentQueue);

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          FocusScope.of(context).unfocus();
        }
      },
    );
  }
}
