import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

class MediaServer {
  static final MediaServer instance = MediaServer._internal();
  MediaServer._internal();
  HttpServer? _server;
  String? _servingFilePath;

  Future<int> startServer() async {
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(_handleFileRequest);

    try {
      _server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
      debugPrint(
        "File streaming server live on port ${_server!.port} and ip: ${InternetAddress.anyIPv4}",
      );
      return _server!.port;
    } catch (e) {
      debugPrint(
        "MediaServer Error: Could not bind to port 8080. Is it in use? $e",
      );
      return -1;
    }
  }

  void setTrackSource(String absoluteFilePath) {
    _servingFilePath = absoluteFilePath;
  }

  Response _handleFileRequest(Request request) {
    if (_servingFilePath == null) {
      return Response.notFound('No audio track selected.');
    }

    final file = File(_servingFilePath!);
    if (!file.existsSync()) {
      return Response.notFound('Audio file missing from storage.');
    }

    return Response.ok(
      file.openRead(),
      headers: {
        'content-type': 'audio/mpeg',
        'content-length': file.lengthSync().toString(),
        'accept-ranges': 'bytes',
      },
    );
  }

  void _cleanupOldFile() {
    if (_servingFilePath != null) {
      final oldFile = File(_servingFilePath!);
      if (oldFile.existsSync()) {
        try {
          oldFile.deleteSync();
          debugPrint(
            "MediaServer: Successfully deleted old cached track -> $_servingFilePath",
          );
        } catch (e) {
          debugPrint("MediaServer Warning: Could not delete old track: $e");
        }
      }
    }
  }

  Future<void> stopServer() async {
    try {
      await _server?.close(force: true);
    } catch (e) {
      debugPrint(
        "MediaServer Warning: Server closed forcefully with error: $e",
      );
    } finally {
      _server = null;
      _cleanupOldFile();
      _servingFilePath = null;
      debugPrint("File streaming server stopped.");
    }
  }
}
