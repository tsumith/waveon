import 'package:on_audio_query/on_audio_query.dart';

class LocalSong {
  final int? id;
  final String path;
  final String title;
  final String artist;
  final String? coverPath;
  final String? uri;

  LocalSong({
    this.id,
    required this.path,
    required this.title,
    this.artist = "Unknown Artist",
    this.coverPath,
    this.uri,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'title': title,
      'artist': artist,
      'coverPath': coverPath,
      'uri': uri,
    };
  }

  factory LocalSong.fromSongModel(SongModel song) {
    return LocalSong(
      id: song.id,
      path: song.data,
      title: song.title,
      artist: song.artist ?? "Unknown Artist",
      uri: song.uri,
    );
  }
}
