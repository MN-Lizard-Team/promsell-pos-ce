import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Lightweight image cache manager.
///
/// Tracks cache directory size and evicts oldest files when limit is exceeded.
class ImageCacheService {
  static const _defaultMaxSizeMB = 50;

  /// Returns the app's image cache directory.
  Future<Directory> get _cacheDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Returns current cache size in bytes.
  Future<int> getCacheSize() async {
    final dir = await _cacheDir;
    int total = 0;
    try {
      await for (final entity in dir.list()) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    } catch (_) {
      // Directory might not exist or be inaccessible
    }
    return total;
  }

  /// Clears all cached images.
  Future<void> clearCache() async {
    final dir = await _cacheDir;
    try {
      await for (final entity in dir.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }

  /// Evicts oldest files if cache exceeds [maxSizeMB].
  Future<void> evictIfNeeded({int maxSizeMB = _defaultMaxSizeMB}) async {
    final maxBytes = maxSizeMB * 1024 * 1024;
    var currentSize = await getCacheSize();

    if (currentSize <= maxBytes) return;

    final dir = await _cacheDir;
    final files = <File, DateTime>{};

    try {
      await for (final entity in dir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          files[entity] = stat.modified;
        }
      }
    } catch (_) {
      return;
    }

    // Sort by modification time (oldest first)
    final sorted = files.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final entry in sorted) {
      if (currentSize <= maxBytes) break;
      try {
        final size = await entry.key.length();
        await entry.key.delete();
        currentSize -= size;
      } catch (_) {}
    }
  }

  /// Deletes a specific image and its thumbnail.
  Future<void> deleteImage(String? imagePath, String? thumbnailPath) async {
    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    if (thumbnailPath != null && thumbnailPath.isNotEmpty) {
      final file = File(thumbnailPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
