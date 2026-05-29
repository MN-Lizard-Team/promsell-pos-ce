import 'package:flutter/material.dart';

class ProductFormAvatar extends StatelessWidget {
  const ProductFormAvatar({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 80.0;
    const radius = 20.0;

    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, err, st) => _placeholder(theme),
        ),
      );
    }
    return _placeholder(theme);
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 36,
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
