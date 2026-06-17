import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audio_converter_native/audio_converter_native.dart';
import 'package:path_provider/path_provider.dart';

class AudioConversionService {
  Future<String?> compressTrack(String inputPath) async {
    try {
      final File inputFile = File(inputPath);
      if (!inputFile.existsSync()) return null;

      final String extension = inputPath.toLowerCase();

      if (extension.endsWith('.mp3') || extension.endsWith('.m4a')) {
        debugPrint("File is already compressed. Passing through: $inputPath");
        return inputPath;
      }

      debugPrint("Starting native hardware conversion for: $inputPath");

      final Directory tempDir = await getTemporaryDirectory();
      final String targetOutputPath =
          "${tempDir.path}/sync_track_${DateTime.now().millisecondsSinceEpoch}.m4a";

      final result = await AudioConverterService.instance.convertToM4A(
        inputPath: inputPath,
        outputPath: targetOutputPath,
        bitrate: 128,
        sampleRate: 44100, 
      );

      if (result.success && result.outputPath != null) {
        debugPrint(
          "Conversion complete! Temp file ready at: ${result.outputPath}",
        );
        return result.outputPath;
      } else {
        debugPrint("Native conversion pipeline failed: ${result.error}");
        return null;
      }
    } catch (e) {
      debugPrint("Error during audio transformation execution: $e");
      return null;
    }
  }

  Future<void> clearOrphanedCache() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();

      int deletedCount = 0;
      for (var file in files) {
        if (file is File && file.path.contains('sync_track_')) {
          file.deleteSync();
          deletedCount++;
        }
      }
      if (deletedCount > 0) {
        debugPrint("Purged $deletedCount orphaned audio cache files.");
      }
    } catch (e) {
      debugPrint("Warning: Failed to clear audio cache: $e");
    }
  }
}
