import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/image/unified_image_widget.dart';
import 'package:promsell_pos_ce/core/widgets/image_viewer_dialog.dart';

/// Product form avatar — delegates to [UnifiedImageWidget] for
/// skeleton loading, error states, and dark-mode-safe placeholders.
///
/// Adds an edit badge and loading overlay on top.
class ProductFormAvatar extends StatelessWidget {
  const ProductFormAvatar({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.isLoading = false,
    this.onTap,
  });

  final String? imagePath;
  final String? imageUrl;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UnifiedImageWidget(
      localPath: imagePath,
      networkUrl: imageUrl,
      size: 80,
      borderRadius: BorderRadius.circular(20),
      showEditBadge: onTap != null,
      isLoading: isLoading,
      onTap: onTap,
      onLongPress: () => _showPreview(context),
    );
  }

  void _showPreview(BuildContext context) {
    final path = imagePath;
    final url = imageUrl;
    if ((path == null || path.isEmpty) && (url == null || url.isEmpty)) {
      return;
    }

    ImageViewerDialog.showSingle(
      context,
      ImageViewerDialog.providerFromPaths(imagePath: path, imageUrl: url),
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
