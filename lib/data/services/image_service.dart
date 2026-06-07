import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImagePickResult {
  const ImagePickResult({required this.path, required this.originalBytes});

  final String path;
  final int originalBytes;
}

/// Picks, compresses, stores, and deletes activity images.
class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const int maxImageBytes = 250 * 1024;

  /// Returns null if the user cancelled; throws on failure.
  Future<ImagePickResult?> pickAndStore(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return null;

    final originalBytes = await File(picked.path).length();
    // Re-encoding an already-small image can grow it, so only compress when over the cap.
    final savedPath = originalBytes <= maxImageBytes
        ? await _copyToDocuments(picked.path)
        : await _compressAndSave(picked.path);

    return ImagePickResult(path: savedPath, originalBytes: originalBytes);
  }

  int? sizeOf(String? path) {
    if (path == null || path.isEmpty) return null;
    try {
      final file = File(path);
      return file.existsSync() ? file.lengthSync() : null;
    } catch (_) {
      return null;
    }
  }

  /// Deletes the file only if it's inside our documents dir (never gallery originals).
  Future<void> deleteOwned(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      if (!p.isWithin(dir.path, path)) return;
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } catch (_) {}
  }

  Future<String> _copyToDocuments(String srcPath) async {
    final targetPath = await _newTargetPath(p.extension(srcPath));
    await File(srcPath).copy(targetPath);
    return targetPath;
  }

  /// Binary-searches JPEG quality (then scales down) for the largest result
  /// still under the cap, so it lands near ~250 KB.
  Future<String> _compressAndSave(String srcPath) async {
    final targetPath = await _newTargetPath('.jpg');

    int minWidth = 1920;
    int minHeight = 1080;
    Uint8List? smallest; // fallback if nothing ever fits under the cap

    for (var tier = 0; tier < 4; tier++) {
      var lo = 10;
      var hi = 95;
      Uint8List? bestFit; // largest result that still fits at this resolution

      while (lo <= hi) {
        final quality = (lo + hi) ~/ 2;
        final bytes = await FlutterImageCompress.compressWithFile(
          srcPath,
          minWidth: minWidth,
          minHeight: minHeight,
          quality: quality,
        );
        if (bytes == null) {
          throw StateError('Image compression returned null for $srcPath');
        }

        if (smallest == null || bytes.length < smallest.length) {
          smallest = bytes;
        }

        if (bytes.length <= maxImageBytes) {
          bestFit = bytes; // fits — try a higher quality to get closer to cap
          lo = quality + 1;
        } else {
          hi = quality - 1; // too big — lower the quality
        }
      }

      if (bestFit != null) {
        await File(targetPath).writeAsBytes(bestFit, flush: true);
        return targetPath;
      }

      // Nothing fit even at the lowest quality; shrink resolution and retry.
      minWidth = (minWidth * 0.7).round();
      minHeight = (minHeight * 0.7).round();
    }

    // Could not get under the cap; persist the smallest attempt produced.
    await File(targetPath).writeAsBytes(smallest!, flush: true);
    return targetPath;
  }

  /// Builds a unique destination path in the documents directory.
  Future<String> _newTargetPath(String extension) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = extension.isNotEmpty ? extension : '.jpg';
    return p.join(
      dir.path,
      'drilling_${DateTime.now().millisecondsSinceEpoch}$ext',
    );
  }
}
