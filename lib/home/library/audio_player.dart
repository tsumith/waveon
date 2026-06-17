import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:waveon/core/services/history_service.dart';
import 'package:waveon/core/enums.dart';
import 'package:waveon/models/local_song.dart';
import 'package:waveon/models/user_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioPlayerService {
  static final AudioPlayerService instance = AudioPlayerService._internal();
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  void play() => _player.play();
  void pause() => _player.pause();
  void stop() => _player.stop();

  bool get playing => _player.playing;
  Duration? get duration => _player.duration;

  Future<void> seek(Duration position) async => await _player.seek(position);
  Future<void> setSpeed(double speed) async => await _player.setSpeed(speed);
  Future<void> dispose() async => await _player.dispose();

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;

  // callback for sending song to sessionprovider
  Future<void> Function(LocalSong)? onHostTrackLoaded;

  void togglePlay() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Stream<void> get onTrackCompleted => _player.playerStateStream.where(
    (state) => state.processingState == ProcessingState.completed,
  );

  final _networkTrackController =
      StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get networkTrackStream =>
      _networkTrackController.stream;

  Future<void> loadLocalTrack({
    required LocalSong song,
    bool autoPlay = true,
  }) async {
    try {
      await _player.stop();
      final source = AudioSource.uri(
        Uri.file(song.path),
        tag: MediaItem(
          id: song.path,
          title: song.title,
          artist: song.artist,
          artUri: song.coverPath != null ? Uri.file(song.coverPath!) : null,
        ),
      );
      await _player.setAudioSource(source);
      if (song.id != null) {
        await HistoryService.saveSong(song.id!);
      }

      if (UserModel.instance.role == UserRole.host) {
        if (onHostTrackLoaded != null) {
          await onHostTrackLoaded!(song);
        }
      } else {
        if (autoPlay) _player.play();
      }
    } catch (e) {
      debugPrint("AudioPlayerService Error: $e");
    }
  }

  // ============ Load From Media Server ==============
  Future<void> loadSyncTrackFromUrl(String url, String? title) async {
    try {
      await _player.stop();
      final trackTitle = title ?? "Party Sync Track";
      _networkTrackController.add({'url': url, 'title': trackTitle});

      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(id: url, title: trackTitle, artist: "Shared via Host"),
      );
      await _player.setAudioSource(source, preload: true);

      // Waits for the network buffer to be fully primed before proceeding
      await _player.processingStateStream.firstWhere(
        (state) => state == ProcessingState.ready,
      );
      debugPrint("Network track buffered and ready.");
    } catch (e) {
      debugPrint("Network Sync Buffer Error: $e");
    }
  }

  void schedulePlay(int playAtMs) {
    // Proprietary hardware execution trigger hidden.
    // Calculates the delta against the synchronized timestamp and
    // fires the native audio playback command at the exact required millisecond.
  }
}
