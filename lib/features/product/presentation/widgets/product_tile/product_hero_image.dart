import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/category_style_resolver.dart';

class ProductHeroImage extends StatelessWidget {
  const ProductHeroImage({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.categoryName,
    this.isLoading = false,
    this.onTap,
  });

  final String? imagePath;
  final String? imageUrl;
  final String? categoryName;
  final bool isLoading;
  final VoidCallback? onTap;

  bool get _hasImage =>
      (imagePath != null && imagePath!.isNotEmpty) ||
      (imageUrl != null && imageUrl!.isNotEmpty);

  void _showPreview(BuildContext context) {
    if (!_hasImage) return;
    ImageViewerDialog.showSingle(
      context,
      ImageViewerDialog.providerFromPaths(
        imagePath: imagePath,
        imageUrl: imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = categoryName != null
        ? CategoryStyleResolver.resolve(categoryName!)
        : null;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _hasImage
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    style?.color.withValues(alpha: 0.25) ??
                        theme.colorScheme.primaryContainer,
                    style?.color.withValues(alpha: 0.08) ??
                        theme.colorScheme.tertiaryContainer,
                  ],
                ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_hasImage)
              GestureDetector(
                onLongPress: () => _showPreview(context),
                child: _buildHeroImage(),
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 56,
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add image',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            if (isLoading)
              Container(
                color: Theme.of(
                  context,
                ).colorScheme.scrim.withValues(alpha: 0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: onTap,
                heroTag: 'product_image_fab',
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return const SizedBox.shrink();
  }
}
