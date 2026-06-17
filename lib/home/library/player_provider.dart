import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:waveon/home/music_lib/audio_player.dart';
import 'package:waveon/models/data_model.dart';
import 'package:waveon/models/user_model.dart';
import 'package:waveon/network/socket_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../models/local_song.dart';
import 'package:waveon/core/enums.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayerService _player = AudioPlayerService.instance;
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<LocalSong> _queue = [];
  int _currentIndex = -1;
  Uint8List? _currentArtwork;

  AudioPlayerService get player => _player;
  List<LocalSong> get queue => _queue;

  Uint8List? get currentArtwork => _currentArtwork;
  LocalSong? get currentSong =>
      _currentIndex != -1 ? _queue[_currentIndex] : null;
  int get currentIndex => _currentIndex;

  bool get isPlaying => _player.playing;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  // --- Network Priming flags ---
  final bool _isNetworkSyncPrepared = false;
  bool get isNetworkSyncPrepared => _isNetworkSyncPrepared;

  StreamSubscription? _playingSub;
  StreamSubscription? _completedSub;
  StreamSubscription? _networkSub;
  // --------------------------------

  bool _isChangingTrack = false;

  // --- shuffle ----
  bool _isShuffle = false;
  List<LocalSong> _unshuffledQueue = [];
  bool get isShuffled => _isShuffle;

  // -- repeat mode ===
  RepeatingMode _repeatMode = RepeatingMode.off;
  RepeatingMode get repeatMode => _repeatMode;

  PlayerProvider() {
    _initListeners();
  }

  void _initListeners() {
    _playingSub = _player.playingStream.listen((state) => notifyListeners());
    _completedSub = _player.onTrackCompleted.listen((_) {
      if (_queue.isNotEmpty) {
        next();
      }
    });

    _networkSub = _player.networkTrackStream.listen((trackData) {
      // Proprietary network stream
      // Handles converting an incoming host audio stream into a playable local queue item.
    });
  }

  // --- LOCAL PLAYBACK ---

  Future<void> playLoadSong(
    LocalSong song,
    List<LocalSong> currentQueue, {
    bool autoPlay = true,
  }) async {
    if (_isChangingTrack) return;
    _isChangingTrack = true;

    _unshuffledQueue = List.from(currentQueue);
    _queue = List.from(currentQueue);
    if (_isShuffle) {
      _shuffleQueueAndPinSong(song);
    } else {
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    }

    await _loadCurrentTrack(autoPlay: autoPlay);
    _isChangingTrack = false;
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    if (index == _currentIndex) return;
    if (_isChangingTrack) return;

    _isChangingTrack = true;
    _currentIndex = index;
    await _loadCurrentTrack();
    _isChangingTrack = false;
  }

  Future<void> _loadCurrentTrack({bool autoPlay = true}) async {
    if (currentSong == null) return;
    final song = currentSong!;

    try {
      if (song.id != null) {
        _audioQuery.queryArtwork(song.id!, ArtworkType.AUDIO, size: 500).then((
          artwork,
        ) {
          _currentArtwork = artwork;
          notifyListeners();
        });
      } else {
        _currentArtwork = null;
      }
      await _player.loadLocalTrack(song: song, autoPlay: autoPlay);

      notifyListeners();
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      debugPrint("Playback Error: $e");
    }
  }

  // ---  Shuffle ---
  void _shuffleQueueAndPinSong(LocalSong song) {
    _queue.shuffle();

    final targetIndex = _queue.indexWhere((s) => s.id == song.id);

    if (targetIndex > 0) {
      final first = _queue[0];
      _queue[0] = _queue[targetIndex];
      _queue[targetIndex] = first;
    }

    _currentIndex = 0;
  }

  void toggleShuffle() {
    final activeSong = currentSong;
    _isShuffle = !_isShuffle;

    if (activeSong == null) {
      notifyListeners();
      return;
    }

    if (_isShuffle) {
      _unshuffledQueue = List.from(_queue);
      _shuffleQueueAndPinSong(activeSong);
    } else {
      _queue = List.from(_unshuffledQueue);
      _currentIndex = _queue.indexWhere((s) => s.id == activeSong.id);
    }

    notifyListeners();
  }

  // ---  Repeat --
  void toggleRepeat() {
    if (repeatMode == RepeatingMode.off) {
      _repeatMode = RepeatingMode.all;
    } else if (_repeatMode == RepeatingMode.all) {
      _repeatMode = RepeatingMode.one;
    } else {
      _repeatMode = RepeatingMode.off;
    }
    notifyListeners();
  }

  // ---  CONTROLS ---
  void togglePlay() {
    final isHost = UserModel.instance.role == UserRole.host;
    if (_player.playing) {
      if (isHost) {
        // Synchronized pause command broadcasting hidden.
      }
      pause();
    } else {
      if (isHost) {
        // Synchronized play command broadcasting hidden.
      }
      play();
    }
  }

  void pause() => _player.pause();
  void play() => _player.play();

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async => await _player.setSpeed(speed);

  Future<void> next() async {
    if (_queue.isEmpty || _isChangingTrack) return;
    _isChangingTrack = true;
    if (_repeatMode == RepeatingMode.one) {
      await _loadCurrentTrack();
      _isChangingTrack = false;
      return;
    }
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await _loadCurrentTrack();
    } else {
      if (_repeatMode == RepeatingMode.all) {
        _currentIndex = 0;
        await _loadCurrentTrack();
      } else {
        _player.stop();
        notifyListeners();
      }
    }
    _isChangingTrack = false;
  }

  Future<void> previous() async {
    if (_currentIndex > 0) {
      _isChangingTrack = true;
      _currentIndex--;
      await _loadCurrentTrack();
      _isChangingTrack = false;
    }
  }

  void stopAndClear() {
    _player.stop();
    _currentIndex = -1;
    _currentArtwork = null;
    _queue = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _completedSub?.cancel();
    _networkSub?.cancel();
    super.dispose();
  }
}
