import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
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
        constraints: const BoxConstraints(minHeight: 84, maxHeight: 220),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 32,
                        color: theme.colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          context.l10n.tapToAddImage,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
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
              bottom: _hasImage ? null : 4,
              top: _hasImage ? 4 : null,
              right: 4,
              child: FloatingActionButton.small(
                onPressed: onTap,
                heroTag: 'product_image_fab',
                child: Icon(
                  _hasImage ? Icons.edit : Icons.add_a_photo_outlined,
                ),
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
