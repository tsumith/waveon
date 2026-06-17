import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waveon/core/enums.dart';
import 'package:waveon/home/music_lib/player_provider.dart';
import 'package:waveon/session/session_provider.dart';
import 'package:waveon/models/user_model.dart';
import 'package:waveon/models/local_song.dart';

class AmbientSessionCard extends StatefulWidget {
  const AmbientSessionCard({super.key});

  @override
  State<AmbientSessionCard> createState() => _AmbientSessionCardState();
}

class _AmbientSessionCardState extends State<AmbientSessionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  List<Color> _getAuraColors(UserRole role) {
    switch (role) {
      case UserRole.host:
        return [
          const Color(0xFF00C6FF),
          const Color(0xFF0072FF),
          const Color(0xFF7B2CBF),
          const Color(0xFF00C6FF),
        ];
      case UserRole.guest:
        return [
          const Color(0xFF00E676),
          const Color(0xFF1DE9B6),
          const Color.fromARGB(255, 1, 145, 125),
          const Color.fromARGB(255, 201, 247, 0),
        ];
      default:
        return [
          const Color(0xFFE0EAFC),
          const Color(0xFFFF4E50),
          const Color(0xFF3F2B96),
          const Color(0xFFE0EAFC),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final player = context.watch<PlayerProvider>();
    final isPlaying = player.isPlaying;

    if (isPlaying && !_spinController.isAnimating) {
      _spinController.repeat();
    } else if (!isPlaying && _spinController.isAnimating) {
      _spinController.stop();
    }

    final auraColors = _getAuraColors(session.role);

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -100,
            top: -50,
            bottom: -50,
            child: RotationTransition(
              turns: _spinController,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(colors: auraColors),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(color: const Color(0xFF0D0D0D).withOpacity(0.6)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _buildStatusBadge(session.role, auraColors.first),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.85,
                          end: 1.0,
                        ).animate(animation),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    key: ValueKey(session.role),
                    width: double.infinity,
                    child: _buildStateContent(
                      session.role,
                      session,
                      player,
                      auraColors.first,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateContent(
    UserRole role,
    SessionProvider session,
    PlayerProvider player,
    Color accent,
  ) {
    if (role == UserRole.host) {
      return _buildHostUplink(session.connectedNodes, accent);
    }
    if (role == UserRole.guest) return _buildGuestTether(accent);
    return _buildLocalBuffer(player);
  }

  Widget _buildLocalBuffer(PlayerProvider player) {
    final queue = player.queue;
    final currentIndex = player.currentIndex;
    LocalSong? nextSong;

    if (queue.isNotEmpty &&
        currentIndex >= 0 &&
        currentIndex + 1 < queue.length) {
      nextSong = queue[currentIndex + 1];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Up Next",
          style: TextStyle(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          nextSong?.title ?? "Queue is empty",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          nextSong?.artist ?? "Add songs to keep playing",
          style: const TextStyle(color: Colors.white38, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHostUplink(int nodes, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Broadcasting...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.wifi_tethering_rounded,
                    color: accent.withOpacity(0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Ensure Hotspot is turned on",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                nodes.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: accent,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Connected",
                style: TextStyle(
                  color: accent,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuestTether(Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          "Synced to Host",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: accent.withOpacity(0.8),
              size: 14,
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                "Playback controlled by Host",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(UserRole role, Color accent) {
    String label = role == UserRole.host
        ? "Hosting Session"
        : (role == UserRole.guest ? "Synced to Host" : "Local Playback");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
