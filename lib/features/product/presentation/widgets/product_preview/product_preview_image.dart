import 'dart:async';

import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/category_style_resolver.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryColor;
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Full-width product image for the preview page.
///
/// Features:
/// - Shimmer skeleton loading (not spinner)
/// - Error placeholder with broken-image icon + retry
/// - Tap-to-zoom hint icon (shown once per session)
/// - Full-resolution image (no ResizeImage, no thumbnail)
/// - Responsive no-image placeholder with category icon
/// - Semantics for accessibility
///
/// Use [PreviewOverlay] as a sibling inside `FlexibleSpaceBar.background`
/// so that both image and overlay collapse together when the app bar shrinks.
class ProductPreviewImage extends StatefulWidget {
  const ProductPreviewImage({
    super.key,
    required this.product,
    this.category,
    this.height = 260,
  });

  final Product product;
  final Category? category;
  final double height;

  static bool hasImage(Product product) =>
      (product.imagePath != null && product.imagePath!.isNotEmpty) ||
      (product.imageUrl != null && product.imageUrl!.isNotEmpty);

  @override
  State<ProductPreviewImage> createState() => _ProductPreviewImageState();
}

class _ProductPreviewImageState extends State<ProductPreviewImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hintController;
  bool _imageLoaded = false;
  bool _showSkeleton = false;
  int _retryKey = 0;
  static bool _hintShown = false;
  Timer? _skeletonTimer;

  bool get _hasImage => ProductPreviewImage.hasImage(product);

  Product get product => widget.product;
  Category? get category => widget.category;
  double get height => widget.height;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scheduleSkeletonDelay();
  }

  void _scheduleSkeletonDelay() {
    _showSkeleton = false;
    _skeletonTimer?.cancel();
    _skeletonTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted && !_imageLoaded) {
        setState(() => _showSkeleton = true);
      }
    });
  }

  void _retryImageLoad() {
    setState(() {
      _imageLoaded = false;
      _retryKey++;
      _hintController.reset();
      _scheduleSkeletonDelay();
    });
  }

  @override
  void didUpdateWidget(covariant ProductPreviewImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id ||
        oldWidget.product.imagePath != widget.product.imagePath ||
        oldWidget.product.imageUrl != widget.product.imageUrl) {
      _imageLoaded = false;
      _hintController.reset();
      _scheduleSkeletonDelay();
    }
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
    _hintController.dispose();
    super.dispose();
  }

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
    final resolvedStyle = category != null
        ? CategoryStyleResolver.resolve(category!.name)
        : null;
    final style =
        resolvedStyle != null && resolvedStyle.color != Colors.transparent
        ? resolvedStyle
        : null;

    return SizedBox.expand(
      child: DecoratedBox(
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
        child: ClipRect(
          child: _hasImage
              ? _buildImageArea(context)
              : _buildNoImagePlaceholder(context, theme, style),
        ),
      ),
    );
  }

  // Image area
  Widget _buildImageArea(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: Semantics(
        label: l10n.productImageSemantics,
        button: true,
        child: Stack(
          fit: StackFit.expand,
          children: [_buildImage(context), _buildTapHint(l10n)],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Image(
      key: ValueKey(_retryKey),
      image: ImageViewerDialog.providerFromPaths(
        imagePath: product.imagePath,
        imageUrl: product.imageUrl,
      ),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      frameBuilder: (_, child, frame, _) {
        if (frame != null) {
          if (!_imageLoaded) {
            _imageLoaded = true;
            if (!_hintShown) {
              _hintShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _hintController.forward();
              });
            }
          }
          return child;
        }
        return _showSkeleton
            ? _PreviewSkeleton(height: height)
            : const SizedBox.expand();
      },
      errorBuilder: (_, _, _) => _PreviewError(
        height: height,
        theme: theme,
        label: l10n.imageError,
        onRetry: _retryImageLoad,
      ),
    );
  }

  Widget _buildTapHint(AppLocalizations l10n) {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Center(
        child: Semantics(
          label: l10n.tapToZoom,
          child: FadeTransition(
            opacity: _hintController,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.zoom_out_map,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.tapToZoom,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // No-image placeholder
  Widget _buildNoImagePlaceholder(
    BuildContext context,
    ThemeData theme,
    CategoryStyle? style,
  ) {
    final l10n = context.l10n;
    return Semantics(
      label: l10n.noProductImageSemantics,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: height * 0.37,
              height: height * 0.37,
              decoration: BoxDecoration(
                color: (style?.color ?? theme.colorScheme.primary).withValues(
                  alpha: 0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category != null
                    ? parseCategoryIcon(category!.iconName)
                    : Icons.inventory_2,
                size: height * 0.17,
                color:
                    style?.color ??
                    theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            if (category != null) ...[
              const SizedBox(height: 12),
              Text(
                category!.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Overlay for the preview image — category name + status chip.
///
/// Place this as a sibling of [ProductPreviewImage] inside
/// `FlexibleSpaceBar.background` so both collapse together.
class PreviewOverlay extends StatelessWidget {
  const PreviewOverlay({
    super.key,
    required this.product,
    this.category,
    required this.hasImage,
  });

  final Product product;
  final Category? category;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: hasImage
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.surfaceContainerLow.withValues(
                      alpha: 0.9,
                    ),
                  ],
                ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasImage)
              Row(
                children: [
                  if (category != null) ...[
                    _CategoryChip(category: category!, onDark: true),
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
              )
            else
              Row(
                children: [
                  if (category != null) ...[
                    _CategoryChip(category: category!, onDark: false),
                  ] else
                    Text(
                      l10n.noCategory,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  const Spacer(),
                  StatusChip(active: product.isActive),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Skeleton — shimmer loading for full-width hero
class _PreviewSkeleton extends StatefulWidget {
  const _PreviewSkeleton({required this.height});

  final double height;

  @override
  State<_PreviewSkeleton> createState() => _PreviewSkeletonState();
}

class _PreviewSkeletonState extends State<_PreviewSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surfaceContainerLowest;

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(-1.0 + _controller.value * 2.0, 0),
                end: Alignment(-0.5 + _controller.value * 2.0, 0),
                colors: [baseColor, highlightColor, baseColor],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Container(
              width: double.infinity,
              height: widget.height,
              color: baseColor,
            ),
          );
        },
      ),
    );
  }
}

// Error — broken image placeholder for full-width hero
class _PreviewError extends StatelessWidget {
  const _PreviewError({
    required this.height,
    required this.theme,
    required this.label,
    this.onRetry,
  });

  final double height;
  final ThemeData theme;
  final String label;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: height * 0.18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Status chip
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final color = active
        ? theme.colorScheme.primary
        : theme.colorScheme.secondaryContainer;
    final onColor = active
        ? Colors.white
        : theme.colorScheme.onSecondaryContainer;

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
            color: onColor,
          ),
          const SizedBox(width: 3),
          Text(
            active ? l10n.productPreviewActive : l10n.inactive,
            style: TextStyle(
              color: onColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onDark});

  final Category category;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDbColor = category.color != null && category.color!.isNotEmpty;
    final dbColor = parseCategoryColor(category.color);
    final resolvedStyle = CategoryStyleResolver.resolve(category.name);
    final hasResolvedColor = resolvedStyle.color != Colors.transparent;

    final color = hasDbColor
        ? dbColor
        : hasResolvedColor
        ? resolvedStyle.color
        : null;

    final icon = parseCategoryIcon(category.iconName);

    if (color == null) {
      final fallbackColor = onDark
          ? Colors.white.withValues(alpha: 0.8)
          : theme.colorScheme.secondary;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fallbackColor),
          const SizedBox(width: 4),
          Text(
            category.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: fallbackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final chipColor = onDark
        ? color.withValues(alpha: 0.25)
        : color.withValues(alpha: 0.12);
    final borderColor = onDark
        ? color.withValues(alpha: 0.6)
        : color.withValues(alpha: 0.4);
    final textColor = onDark ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            category.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
