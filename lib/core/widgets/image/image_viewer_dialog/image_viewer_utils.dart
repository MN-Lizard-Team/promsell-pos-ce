import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Resolves an [ImageProvider] from a local path or URL asynchronously.
///
/// Prefer this over the synchronous [providerFromPaths] to avoid blocking
/// the UI thread with file I/O (e.g. [File.existsSync]).
Future<ImageProvider> providerFromPathsAsync({
  String? imagePath,
  String? imageUrl,
}) async {
  if (imagePath != null && imagePath.isNotEmpty) {
    final file = File(imagePath);
    if (await file.exists()) {
      return FileImage(file);
    }
  }
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CachedNetworkImageProvider(imageUrl);
  }
  return const AssetImage('');
}

/// Synchronous variant — only use inside [State.build] where async is
/// not available. Prefer [providerFromPathsAsync] for event handlers.
ImageProvider providerFromPaths({String? imagePath, String? imageUrl}) {
  if (imagePath != null &&
      imagePath.isNotEmpty &&
      File(imagePath).existsSync()) {
    return FileImage(File(imagePath));
  }
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CachedNetworkImageProvider(imageUrl);
  }
  return const AssetImage('');
}

Future<void> shareImage(ImageProvider image) async {
  try {
    if (image is FileImage) {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(image.file.path)]),
      );
    } else if (image is CachedNetworkImageProvider) {
      await SharePlus.instance.share(ShareParams(text: image.url));
    }
  } catch (_) {}
}

class ZoomController {
  VoidCallback? reset;
  void dispose() {}
}
