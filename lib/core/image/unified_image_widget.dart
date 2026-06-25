import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:promsell_pos_ce/core/image/image_error_placeholder.dart';
import 'package:promsell_pos_ce/core/image/image_skeleton.dart';

/// Unified image widget that handles local files, network URLs, thumbnails,
/// skeleton loading, error states, and dark-mode-safe placeholders.
///
/// Replaces: ProductAvatar, ProductFormAvatar (partially)
class UnifiedImageWidget extends StatelessWidget {
  const UnifiedImageWidget({
    super.key,
    this.localPath,
    this.networkUrl,
    this.thumbnailPath,
    required this.size,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.onTap,
    this.onLongPress,
    this.showEditBadge = false,
    this.isLoading = false,
    this.heroTag,
  });

  final String? localPath;
  final String? networkUrl;
  final String? thumbnailPath;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showEditBadge;
  final bool isLoading;
  final String? heroTag;

  bool get _useThumbnail => size <= 100;

  String? get _effectiveLocalPath {
    if (_useThumbnail) {
      return (thumbnailPath?.isNotEmpty == true)
          ? thumbnailPath
          : (localPath?.isNotEmpty == true)
          ? localPath
          : null;
    }
    return (localPath?.isNotEmpty == true) ? localPath : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = shape == BoxShape.circle
        ? size / 2
        : (borderRadius?.topLeft.x ?? size / 2);
    final effectiveRadius = shape == BoxShape.circle
        ? null
        : BorderRadius.circular(radius);

    Widget imageWidget = _buildImageContent(context, radius);

    if (heroTag != null) {
      imageWidget = Hero(tag: heroTag!, child: imageWidget);
    }

    Widget content = Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: shape == BoxShape.rectangle ? effectiveRadius : null,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: shape == BoxShape.rectangle
                ? (effectiveRadius ?? BorderRadius.circular(radius))
                : BorderRadius.circular(radius),
            child: imageWidget,
          ),
        ),
        if (showEditBadge)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.edit,
                size: 14,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.scrim.withValues(alpha: 0.4),
                borderRadius: shape == BoxShape.rectangle
                    ? (effectiveRadius ?? BorderRadius.circular(radius))
                    : BorderRadius.circular(radius),
              ),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (onTap != null || onLongPress != null) {
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: shape == BoxShape.rectangle
            ? (effectiveRadius ?? BorderRadius.circular(radius))
            : null,
        customBorder: shape == BoxShape.circle ? const CircleBorder() : null,
        child: content,
      );
    }

    return content;
  }

  Widget _buildImageContent(BuildContext context, double radius) {
    final effectivePath = _effectiveLocalPath;

    if (effectivePath != null && effectivePath.isNotEmpty) {
      return _LocalImage(
        path: effectivePath,
        size: size,
        fit: fit,
        borderRadius: BorderRadius.circular(radius),
        fallback: (ctx) => _tryNetwork(ctx, radius),
      );
    }

    return _tryNetwork(context, radius);
  }

  Widget _tryNetwork(BuildContext context, double radius) {
    final url = networkUrl;
    if (url != null && url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: fit,
        placeholder: (ctx, url) => ImageSkeleton(
          size: size,
          borderRadius: BorderRadius.circular(radius),
        ),
        errorWidget: (ctx, url, err) => ImageErrorPlaceholder(
          size: size,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }
    return _fallbackPlaceholder(context, radius);
  }

  Widget _fallbackPlaceholder(BuildContext context, double radius) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        Icons.image_outlined,
        color: theme.colorScheme.secondary,
        size: size * 0.45,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Local image with async existence check
// ---------------------------------------------------------------------------

class _LocalImage extends StatefulWidget {
  const _LocalImage({
    required this.path,
    required this.size,
    required this.fit,
    required this.borderRadius,
    required this.fallback,
  });

  final String path;
  final double size;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final WidgetBuilder fallback;

  @override
  State<_LocalImage> createState() => _LocalImageState();
}

class _LocalImageState extends State<_LocalImage> {
  bool? _exists;

  @override
  void initState() {
    super.initState();
    _checkExists();
  }

  @override
  void didUpdateWidget(covariant _LocalImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _exists = null;
      _checkExists();
    }
  }

  Future<void> _checkExists() async {
    final exists = await File(widget.path).exists();
    if (mounted) setState(() => _exists = exists);
  }

  @override
  Widget build(BuildContext context) {
    if (_exists == null) {
      return ImageSkeleton(
        size: widget.size,
        borderRadius: widget.borderRadius,
      );
    }

    if (_exists == true) {
      final cacheWidth = widget.size.isFinite
          ? (widget.size * 2).toInt()
          : null;
      return Image.file(
        File(widget.path),
        width: widget.size.isFinite ? widget.size : null,
        height: widget.size.isFinite ? widget.size : null,
        fit: widget.fit,
        cacheWidth: cacheWidth,
        errorBuilder: (ctx, err, st) => widget.fallback(ctx),
        frameBuilder: (ctx, child, frame, wasSync) {
          if (frame != null) return child;
          return ImageSkeleton(
            size: widget.size.isFinite ? widget.size : 56,
            borderRadius: widget.borderRadius,
          );
        },
      );
    }

    return widget.fallback(context);
  }
}
