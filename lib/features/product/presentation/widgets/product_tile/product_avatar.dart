import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/image/unified_image_widget.dart';

/// Product avatar — thin wrapper around [UnifiedImageWidget].
///
/// Provides the same API as before but delegates to the unified
/// image system for skeleton loading, error states, and dark-mode
/// safe placeholders.
class ProductAvatar extends StatelessWidget {
  const ProductAvatar({
    super.key,
    this.imagePath,
    this.imageThumbnailPath,
    this.imageUrl,
    this.size = 52,
  });

  final String? imagePath;
  final String? imageThumbnailPath;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return UnifiedImageWidget(
      localPath: imagePath,
      thumbnailPath: imageThumbnailPath,
      networkUrl: imageUrl,
      size: size,
      shape: BoxShape.circle,
    );
  }
}
