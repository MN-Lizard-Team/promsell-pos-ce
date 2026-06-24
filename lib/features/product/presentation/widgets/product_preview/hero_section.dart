import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/category_style_resolver.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryIcon;

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.product, this.category});

  final Product product;
  final Category? category;

  bool get _hasImage =>
      (product.imagePath != null && product.imagePath!.isNotEmpty) ||
      (product.imageUrl != null && product.imageUrl!.isNotEmpty);

  void _showFullImage(BuildContext context) {
    if (!_hasImage) return;
    ImageViewerDialog.showSingle(
      context,
      ImageViewerDialog.providerFromPaths(
        imagePath: product.imagePath,
        imageUrl: product.imageUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final style = category != null
        ? CategoryStyleResolver.resolve(category!.name)
        : null;

    return Stack(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _hasImage
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      style?.color.withValues(alpha: 0.3) ??
                          theme.colorScheme.primaryContainer,
                      style?.color.withValues(alpha: 0.1) ??
                          theme.colorScheme.tertiaryContainer,
                    ],
                  ),
          ),
          child: _hasImage
              ? GestureDetector(
                  onTap: () => _showFullImage(context),
                  child: _buildImage(),
                )
              : Center(
                  child: Icon(
                    Icons.inventory_2,
                    size: 80,
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (category != null) ...[
                      Icon(
                        parseCategoryIcon(category!.iconName),
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category!.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ] else
                      Text(
                        l10n.noCategory,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    const Spacer(),
                    StatusChip(active: product.isActive),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (product.imagePath != null && product.imagePath!.isNotEmpty) {
      return Image.file(
        File(product.imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return CachedNetworkImage(
      imageUrl: product.imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = active ? Colors.green : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle : Icons.visibility_off_outlined,
            size: 11,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            active ? l10n.productPreviewActive : l10n.inactive,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
