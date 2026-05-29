import 'package:flutter/material.dart';

class ProductAvatar extends StatelessWidget {
  const ProductAvatar({super.key, required this.imageUrl, this.size = 52});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = size * 0.27;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, err, st) => _iconBox(theme, radius),
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
        Icons.inventory_2_outlined,
        color: theme.colorScheme.primary,
        size: size * 0.48,
      ),
    );
  }
}
