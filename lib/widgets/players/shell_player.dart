import 'package:flutter/material.dart';
import 'package:waveon/core/enums.dart';
import 'package:waveon/models/user_model.dart';
import 'package:waveon/session/session_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../home/library/player_provider.dart';
import 'custom_progress_bar.dart';

class ShellPlayer extends StatefulWidget {
  const ShellPlayer({super.key});

  @override
  State<ShellPlayer> createState() => _ShellPlayerState();
}

class _ShellPlayerState extends State<ShellPlayer> {
  late final PageController _pageController;
  bool _isProgrammaticChange = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final currentSong = playerProvider.currentSong;

    final isGuest = sessionProvider.role == UserRole.guest;

    if (currentSong == null) return const SizedBox.shrink();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        final targetPage = playerProvider.currentIndex;
        final currentPage = _pageController.page?.round() ?? 0;

        if (targetPage != currentPage && targetPage >= 0) {
          _isProgrammaticChange = true;
          if ((targetPage - currentPage).abs() > 1) {
            _pageController.jumpToPage(targetPage);
            _isProgrammaticChange = false;
          } else {
            _pageController
                .animateToPage(
                  targetPage,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                )
                .then((_) => _isProgrammaticChange = false);
          }
        }
      }
    });

    return GestureDetector(
      onTap: () => context.push('/player'),
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < -300) {
          context.push('/player');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 65,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 49,
              height: 49,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'song_art',
                    child: Container(
                      padding: EdgeInsets.all(2),
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: playerProvider.currentArtwork != null
                          ? ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(8),
                              child: Image.memory(
                                playerProvider.currentArtwork!,
                                fit: BoxFit.cover,
                                width: 60,
                                gaplessPlayback: true,
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.music_note,
                                color: Colors.blueAccent.withOpacity(0.8),
                                size: 20,
                              ),
                            ),
                    ),
                  ),

                  StreamBuilder<Duration>(
                    stream: playerProvider.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration =
                          playerProvider.player.duration ?? Duration.zero;
                      double progress = 0.0;
                      if (duration.inMilliseconds > 0) {
                        progress =
                            position.inMilliseconds / duration.inMilliseconds;
                      }

                      return RepaintBoundary(
                        child: CustomPaint(
                          size: const Size(47, 49),
                          painter: RoundedRectProgressPainter(
                            progress: progress,
                            color: Colors.blueAccent,
                            strokeWidth: 2.5,
                            borderRadius: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: playerProvider.queue.length,
                onPageChanged: (index) {
                  if (!_isProgrammaticChange) {
                    playerProvider.playAt(index);
                  }
                },
                itemBuilder: (context, index) {
                  final song = playerProvider.queue[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.artist,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            IconButton(
              icon: Icon(
                playerProvider.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: isGuest ? Colors.white54 : Colors.white,
                size: 35,
              ),
              onPressed: isGuest ? null : () => playerProvider.togglePlay(),
            ),
          ],
        ),
      ),
    );
  }
}
