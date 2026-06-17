import 'dart:math';

import 'package:flutter/material.dart';
import 'package:waveon/core/enums.dart';
import 'package:waveon/widgets/queue_sheet.dart';
import 'package:waveon/widgets/scrolling_text.dart';
import 'package:waveon/widgets/players/wiggle_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../home/library/player_provider.dart';
import 'package:waveon/session/session_provider.dart';
import 'package:waveon/models/user_model.dart';

class FullPlayerView extends StatefulWidget {
  const FullPlayerView({super.key});

  @override
  State<FullPlayerView> createState() => _FullPlayerViewState();
}

class _FullPlayerViewState extends State<FullPlayerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final song = playerProvider.currentSong;
    final bool isGuest = sessionProvider.role == UserRole.guest;
    if (song == null) return const SizedBox.shrink();

    onSwipeLeftright(details) {
      if (isGuest) return;
      final velocity = details.primaryVelocity ?? 0;
      if (velocity < -300) {
        playerProvider.next();
      } else if (velocity > 300) {
        playerProvider.previous();
      }
    }

    onSwipeDown(details) {
      if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
        context.pop();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isSmallScreen = constraints.maxHeight < 700;
            final double albumArtSize = min(
              constraints.maxWidth * 0.82,
              constraints.maxHeight * 0.45,
            );

            return Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 30,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GestureDetector(
                      onVerticalDragEnd: onSwipeDown,
                      onHorizontalDragEnd: onSwipeLeftright,
                      child: Column(
                        children: [
                          const Spacer(flex: 1),
                          // Album Art - Responsive Size
                          Hero(
                            tag: 'song_art',
                            child: Container(
                              width: albumArtSize,
                              height: albumArtSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: playerProvider.currentArtwork != null
                                  ? Image.memory(
                                      playerProvider.currentArtwork!,
                                      width: albumArtSize,
                                      height: albumArtSize,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                    )
                                  : const _FallbackCover(),
                            ),
                          ),
                          const Spacer(flex: 1),
                          ScrollingText(
                            text: song.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 22 : 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ScrollingText(
                            text: song.artist,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                          ),
                          const Spacer(flex: 1),
                          if (isGuest)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.greenAccent,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Controlled by Host",
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          StreamBuilder<Duration>(
                            stream: playerProvider.positionStream,
                            builder: (context, snapshot) {
                              final position = snapshot.data ?? Duration.zero;
                              final duration =
                                  playerProvider.player.duration ??
                                  Duration.zero;
                              final double progress =
                                  duration.inMilliseconds > 0
                                  ? position.inMilliseconds /
                                        duration.inMilliseconds
                                  : 0.0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: [
                                    AnimatedBuilder(
                                      animation: _waveController,
                                      builder: (context, child) {
                                        return IgnorePointer(
                                          ignoring: isGuest,
                                          child: WiggleSlider(
                                            value: progress,
                                            isPlaying: playerProvider.isPlaying,
                                            phase:
                                                _waveController.value * 2 * pi,
                                            onScrub: (percent) {
                                              playerProvider.player.seek(
                                                duration * percent,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(position),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _formatDuration(duration),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const Spacer(flex: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.shuffle_rounded,
                                  color: playerProvider.isShuffled
                                      ? Colors.blueAccent
                                      : Colors.white54,
                                  size: isSmallScreen ? 24 : 28,
                                ),
                                onPressed: isGuest
                                    ? null
                                    : playerProvider.toggleShuffle,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.skip_previous_rounded,
                                  color: isGuest
                                      ? Colors.white24
                                      : Colors.white,
                                  size: isSmallScreen ? 35 : 45,
                                ),
                                onPressed: isGuest
                                    ? null
                                    : playerProvider.previous,
                              ),
                              IconButton(
                                iconSize: isSmallScreen ? 70 : 85,
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  playerProvider.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: isGuest
                                      ? Colors.white38
                                      : Colors.white,
                                ),
                                onPressed: isGuest
                                    ? null
                                    : () => playerProvider.togglePlay(),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.skip_next_rounded,
                                  color: isGuest
                                      ? Colors.white24
                                      : Colors.white,
                                  size: isSmallScreen ? 35 : 45,
                                ),
                                onPressed: isGuest ? null : playerProvider.next,
                              ),
                              IconButton(
                                icon: Icon(
                                  playerProvider.repeatMode == RepeatingMode.one
                                      ? Icons.repeat_one_rounded
                                      : Icons.repeat_rounded,
                                  color:
                                      playerProvider.repeatMode !=
                                          RepeatingMode.off
                                      ? Colors.blueAccent
                                      : Colors.white54,
                                  size: isSmallScreen ? 24 : 28,
                                ),
                                onPressed: isGuest
                                    ? null
                                    : playerProvider.toggleRepeat,
                              ),
                            ],
                          ),

                          const Spacer(flex: 1),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.queue_music_rounded,
                                    color: Colors.white54,
                                    size: 28,
                                  ),

                                  onPressed: () =>
                                      showQueueSheet(context, playerProvider),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.05),
      alignment: Alignment.center,
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.blueAccent,
        size: 80,
      ),
    );
  }
}
