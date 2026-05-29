import 'dart:io';

import 'package:flutter/material.dart';

class ProductFormAvatar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 80.0;
    const radius = 20.0;

    return GestureDetector(
      onTap: onTap,
      child: _buildImage(theme, size, radius),
    );
  }

  Widget _buildImage(ThemeData theme, double size, double radius) {
    if (imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _placeholder(theme, size, radius),
          ),
        );
      }
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _placeholder(theme, size, radius),
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
