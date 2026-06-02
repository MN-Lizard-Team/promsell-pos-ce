import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

  bool get _useThumbnail => size <= 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = size / 2;

    final localPath = _useThumbnail
        ? (imageThumbnailPath ?? imagePath)
        : imagePath;

    if (localPath != null && localPath.isNotEmpty) {
      return _LocalImage(
        path: localPath,
        size: size,
        radius: radius,
        fallback: (_) => _tryNetwork(theme, radius),
      );
    }
    return _tryNetwork(theme, radius);
  }

  Widget _tryNetwork(ThemeData theme, double radius) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, _) => _iconBox(theme, radius),
          errorWidget: (_, _, _) => _iconBox(theme, radius),
        ),
      );
    }
    return _iconBox(theme, radius);
  }

  Widget _iconBox(ThemeData theme, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        Icons.image_outlined,
        color: theme.colorScheme.primary,
        size: size * 0.48,
      ),
    );
  }
}

class _LocalImage extends StatefulWidget {
  const _LocalImage({
    required this.path,
    required this.size,
    required this.radius,
    required this.fallback,
  });

  final String path;
  final double size;
  final double radius;
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

  Future<void> _checkExists() async {
    final exists = await File(widget.path).exists();
    if (mounted) setState(() => _exists = exists);
  }

  @override
  Widget build(BuildContext context) {
    if (_exists == null) {
      final theme = Theme.of(context);
      return _iconBox(theme);
    }
    if (_exists == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Image.file(
          File(widget.path),
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => widget.fallback(context),
        ),
      );
    }
    return widget.fallback(context);
  }

  Widget _iconBox(ThemeData theme) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: Icon(
        Icons.image_outlined,
        color: theme.colorScheme.primary,
        size: widget.size * 0.48,
      ),
    );
  }
}
