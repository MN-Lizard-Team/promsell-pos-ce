import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductFormAvatar extends StatefulWidget {
  const ProductFormAvatar({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.onTap,
  });

  final String? imagePath;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  State<ProductFormAvatar> createState() => _ProductFormAvatarState();
}

class _ProductFormAvatarState extends State<ProductFormAvatar> {
  bool? _localExists;

  @override
  void initState() {
    super.initState();
    _checkLocal();
  }

  @override
  void didUpdateWidget(covariant ProductFormAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _checkLocal();
    }
  }

  Future<void> _checkLocal() async {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      if (mounted) setState(() => _localExists = false);
      return;
    }
    final exists = await File(widget.imagePath!).exists();
    if (mounted) setState(() => _localExists = exists);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 80.0;
    const radius = 20.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: _buildImage(theme, size, radius),
    );
  }

  Widget _buildImage(ThemeData theme, double size, double radius) {
    if (_localExists == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.file(
          File(widget.imagePath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _tryNetwork(theme, size, radius),
        ),
      );
    }
    if (_localExists == null && widget.imagePath != null) {
      return _placeholder(theme, size, radius);
    }
    return _tryNetwork(theme, size, radius);
  }

  Widget _tryNetwork(ThemeData theme, double size, double radius) {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, _) => _placeholder(theme, size, radius),
          errorWidget: (_, _, _) => _placeholder(theme, size, radius),
        ),
      );
    }
    return _placeholder(theme, size, radius);
  }

  Widget _placeholder(ThemeData theme, double size, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        Icons.add_a_photo_outlined,
        size: 32,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

class ProductSectionLabel extends StatelessWidget {
  const ProductSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
