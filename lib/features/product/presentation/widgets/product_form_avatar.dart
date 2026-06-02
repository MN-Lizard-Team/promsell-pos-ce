import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/image_viewer_dialog.dart';

class ProductFormAvatar extends StatefulWidget {
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

    return InkWell(
      onTap: widget.onTap,
      onLongPress: () => _showPreview(context),
      borderRadius: BorderRadius.circular(radius),
      child: _buildImage(theme, size, radius),
    );
  }

  Widget _buildImage(ThemeData theme, double size, double radius) {
    final imageWidget = _buildImageContent(theme, size, radius);
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - 1),
            child: imageWidget,
          ),
        ),
        if (widget.onTap != null)
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
        if (widget.isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.scrim.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(radius),
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
  }

  Widget _buildImageContent(ThemeData theme, double size, double radius) {
    if (_localExists == true) {
      return Image.file(
        File(widget.imagePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _tryNetwork(theme, size),
      );
    }
    if (_localExists == null && widget.imagePath != null) {
      return _placeholder(theme);
    }
    return _tryNetwork(theme, size);
  }

  Widget _tryNetwork(ThemeData theme, double size) {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(theme),
        errorWidget: (_, _, _) => _placeholder(theme),
      );
    }
    return _placeholder(theme);
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
      child: Icon(
        Icons.add_a_photo_outlined,
        size: 32,
        color: theme.colorScheme.primary,
      ),
    );
  }

  void _showPreview(BuildContext context) {
    final imagePath = widget.imagePath;
    final imageUrl = widget.imageUrl;
    if ((imagePath == null || imagePath.isEmpty) &&
        (imageUrl == null || imageUrl.isEmpty)) {
      return;
    }

    ImageViewerDialog.showSingle(
      context,
      ImageViewerDialog.providerFromPaths(
        imagePath: imagePath,
        imageUrl: imageUrl,
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
