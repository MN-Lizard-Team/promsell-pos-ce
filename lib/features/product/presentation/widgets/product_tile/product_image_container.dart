import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/image/image_skeleton.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/category_style_resolver.dart';

class ProductImageContainer extends StatelessWidget {
  const ProductImageContainer({
    super.key,
    this.imagePath,
    this.imageThumbnailPath,
    this.imageUrl,
    this.categoryName,
    this.size,
    this.borderRadius,
    this.heroTag,
  });

  final String? imagePath;
  final String? imageThumbnailPath;
  final String? imageUrl;
  final String? categoryName;
  final double? size;
  final BorderRadius? borderRadius;
  final String? heroTag;

  bool get _hasImage =>
      (imagePath != null && imagePath!.isNotEmpty) ||
      (imageThumbnailPath != null && imageThumbnailPath!.isNotEmpty) ||
      (imageUrl != null && imageUrl!.isNotEmpty);

  String? get _effectivePath {
    if (imageThumbnailPath != null && imageThumbnailPath!.isNotEmpty) {
      return imageThumbnailPath;
    }
    if (imagePath != null && imagePath!.isNotEmpty) {
      return imagePath;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = categoryName != null
        ? CategoryStyleResolver.resolve(categoryName!)
        : null;
    final br = borderRadius ?? BorderRadius.circular(16);

    Widget imageWidget;

    if (_hasImage) {
      imageWidget = _buildImage(context);
    } else {
      imageWidget = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              style?.color.withValues(alpha: 0.25) ??
                  theme.colorScheme.primaryContainer,
              style?.color.withValues(alpha: 0.08) ??
                  theme.colorScheme.tertiaryContainer,
            ],
          ),
          borderRadius: br,
        ),
        child: Center(
          child: Icon(
            Icons.inventory_2,
            size: (size ?? 64) * 0.35,
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.4),
          ),
        ),
      );
    }

    if (heroTag != null && heroTag!.isNotEmpty) {
      imageWidget = Hero(
        tag: 'product_image_$heroTag',
        child: ClipRRect(borderRadius: br, child: imageWidget),
      );
    } else {
      imageWidget = ClipRRect(borderRadius: br, child: imageWidget);
    }

    if (size != null) {
      return SizedBox(width: size, height: size, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildImage(BuildContext context) {
    final local = _effectivePath;
    if (local != null && local.isNotEmpty) {
      return Image.file(
        File(local),
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (ctx, err, st) => _fallback(ctx),
        frameBuilder: (ctx, child, frame, wasSync) {
          if (frame != null) return child;
          return _skeleton();
        },
      );
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        placeholder: (ctx, url) => _skeleton(),
        errorWidget: (ctx, url, err) => _fallback(ctx),
      );
    }
    return _fallback(context);
  }

  Widget _skeleton() {
    return ImageSkeleton(
      size: size ?? 64,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
    );
  }

  Widget _fallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
