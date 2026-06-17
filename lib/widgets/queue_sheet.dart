import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waveon/home/music_lib/player_provider.dart';

void showQueueSheet(BuildContext context, PlayerProvider provider) {
  const double itemHeight = 72.0;

  double initialOffset =
      (provider.currentIndex * itemHeight) - (itemHeight / 2);
  if (initialOffset < 0) initialOffset = 0;

  final ScrollController scrollController = ScrollController(
    initialScrollOffset: initialOffset,
  );
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.7,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Playing Queue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemExtent: itemHeight,
                  physics: const BouncingScrollPhysics(),
                  itemCount: provider.queue.length,
                  itemBuilder: (context, index) {
                    final song = provider.queue[index];
                    final isPlaying = index == provider.currentIndex;
                    return ListTile(
                      leading: Icon(
                        isPlaying
                            ? Icons.volume_up_rounded
                            : Icons.music_note_rounded,
                        color: isPlaying ? Colors.blueAccent : Colors.white54,
                      ),
                      title: Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying ? Colors.blueAccent : Colors.white,
                          fontWeight: isPlaying
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      onTap: () {
                        provider.playAt(index);
                        context.pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
