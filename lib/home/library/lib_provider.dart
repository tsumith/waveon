import 'dart:async';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter/foundation.dart';
import 'package:waveon/core/services/permission_service.dart';
import '../../models/local_song.dart';

class LibProvider extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<LocalSong> _audioFiles = [];
  List<LocalSong> _masterAudioFiles = [];
  bool _isLoading = false;
  bool _hasPermission = false;
  bool _initialized = false;

  List<LocalSong> get audioFiles => _audioFiles;
  bool get isLoading => _isLoading;
  int get totalCount => _audioFiles.length;
  bool get hasPermission => _hasPermission;

  LibProvider();

  Future<void> initLibrary() async {
    if (_initialized) return;
    _initialized = true;
    _isLoading = true;
    notifyListeners();

    _hasPermission =
        await PermissionService.instance.requestLibraryPermission();
    if (_hasPermission) {
      await loadDeviceSongs();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryPermission() async {
    _initialized = false;
    await initLibrary();
  }

  Future<void> checkExistingPermission() async {
    _isLoading = true;
    notifyListeners();

    final isGranted = await PermissionService.instance.checkLibraryPermission();

    if (isGranted) {
      _hasPermission = true;
      await loadDeviceSongs();
    } else {
      _hasPermission = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDeviceSongs() async {
    try {
      final List<SongModel> deviceSongs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      _masterAudioFiles =
          deviceSongs
              .where((song) => song.isMusic == true)
              .map((song) => LocalSong.fromSongModel(song))
              .toList();
      _audioFiles = List.from(_masterAudioFiles);
    } catch (e) {
      debugPrint("Error loading songs from device: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    if (query.trim().isEmpty) {
      _audioFiles = List.from(_masterAudioFiles);
    } else {
      final lowercaseQuery = query.toLowerCase().trim();

      _audioFiles =
          _masterAudioFiles.where((song) {
            final matchesTitle = song.title.toLowerCase().contains(
              lowercaseQuery,
            );
            final matchesArtist = song.artist.toLowerCase().contains(
              lowercaseQuery,
            );
            return matchesTitle || matchesArtist;
          }).toList();
    }
    notifyListeners();
  }
}
