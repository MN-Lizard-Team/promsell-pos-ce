import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

/// Lightweight image cache manager.
///
/// Tracks cache directory size and evicts oldest files when limit is exceeded.
@LazySingleton()
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
    } catch (e, stack) {
      AppLogger.warning(
        'image_cache_service: getCacheSize failed',
        error: e,
        stack: stack,
      );
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
    } catch (e, stack) {
      AppLogger.warning(
        'image_cache_service: clearCache failed',
        error: e,
        stack: stack,
      );
    }
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
    } catch (e, stack) {
      AppLogger.warning(
        'image_cache_service: evictIfNeeded listing failed',
        error: e,
        stack: stack,
      );
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
      } catch (e, stack) {
        AppLogger.warning(
          'image_cache_service: evictIfNeeded delete failed',
          error: e,
          stack: stack,
        );
      }
    }
  }

  /// Deletes a specific image and its thumbnail.
  ///
  /// Only deletes files under the app `images/` directory (path sandbox).
  Future<void> deleteImage(String? imagePath, String? thumbnailPath) async {
    final root = await _cacheDir;
    await _deleteIfUnderImages(imagePath, root);
    await _deleteIfUnderImages(thumbnailPath, root);
  }

  Future<void> _deleteIfUnderImages(String? path, Directory imagesRoot) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      final resolved = p.normalize(file.absolute.path);
      final rootPath = p.normalize(imagesRoot.absolute.path);
      final sep = p.separator;
      final underRoot =
          resolved == rootPath || resolved.startsWith('$rootPath$sep');
      if (!underRoot) return;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, stack) {
      AppLogger.warning(
        'image_cache_service: _deleteIfUnderImages failed',
        error: e,
        stack: stack,
      );
    }
  }
}
