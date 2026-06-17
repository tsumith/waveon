import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/carousel_item.dart';

class CarouselCard extends StatefulWidget {
  final CarouselItem item;

  const CarouselCard({super.key, required this.item});

  @override
  State<CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<CarouselCard> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  Future<Uint8List?>? _artworkFuture;
  @override
  void initState() {
    super.initState();
    if (widget.item.id != null) {
      _artworkFuture = _audioQuery.queryArtwork(
        widget.item.id!,
        ArtworkType.AUDIO,
        size: 200,
        format: ArtworkFormat.JPEG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.item.onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.item.gradient[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.item.id != null
                    ? FutureBuilder<Uint8List?>(
                        future: _artworkFuture,
                        builder: (context, snapshot) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeOut,
                            child: _buildArtworkContent(snapshot),
                          );
                        },
                      )
                    : _buildFallbackGradient(
                        key: const ValueKey('no-id'),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.item.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackGradient({required Key key, Widget? child}) {
    return Container(
      key: key,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.item.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }

  Widget _buildArtworkContent(AsyncSnapshot<Uint8List?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildFallbackGradient(key: const ValueKey('loading'));
    }
    if (snapshot.hasData && snapshot.data != null) {
      return Image.memory(
        snapshot.data!,
        key: ValueKey(widget.item.id),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return _buildFallbackGradient(
      key: const ValueKey('no-art'),
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white54, size: 40),
      ),
    );
  }
}

class RecentlyPlayedCarousel extends StatelessWidget {
  final List<CarouselItem> items;

  const RecentlyPlayedCarousel({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        cacheExtent: 500,
        itemBuilder: (context, index) =>
            CarouselCard(key: ValueKey(items[index].id), item: items[index]),
      ),
    );
  }
}

List<Color> getGradientForSong(int index) {
  final gradients = [
    [const Color(0xFF8E2DE2), const Color.fromARGB(255, 73, 129, 136)],
    [
      const Color.fromARGB(255, 255, 121, 94),
      const Color.fromARGB(255, 109, 10, 148),
    ],
    [const Color(0xFF1D976C), const Color.fromARGB(255, 151, 89, 151)],
    [
      const Color.fromARGB(255, 17, 31, 153),
      const Color.fromARGB(255, 41, 173, 92),
    ],
    [const Color(0xFF2193b0), const Color.fromARGB(255, 50, 60, 112)],
  ];
  return gradients[index % gradients.length];
}
