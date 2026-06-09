import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ImageViewerDialog extends StatefulWidget {
  const ImageViewerDialog({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  final List<ImageProvider> images;
  final int initialIndex;

  static void showSingle(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => ImageViewerDialog(images: [image]),
    );
  }

  static void showMulti(
    BuildContext context, {
    required List<ImageProvider> images,
    int initialIndex = 0,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) =>
          ImageViewerDialog(images: images, initialIndex: initialIndex),
    );
  }

  static ImageProvider providerFromPaths({
    String? imagePath,
    String? imageUrl,
  }) {
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync()) {
      return FileImage(File(imagePath));
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImageProvider(imageUrl);
    }
    return const AssetImage('');
  }

  @override
  State<ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<ImageViewerDialog>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late int _currentIndex;
  final Map<int, _ZoomController> _zoomControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final zc in _zoomControllers.values) {
      zc.dispose();
    }
    super.dispose();
  }

  _ZoomController _getZoomController(int index) {
    return _zoomControllers.putIfAbsent(index, () => _ZoomController());
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    // Reset zoom on previous pages
    for (final entry in _zoomControllers.entries) {
      if (entry.key != index) {
        entry.value.reset?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.images.length > 1;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Main image viewer
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.images.length,
                itemBuilder: (_, index) {
                  return _ImagePage(
                    image: widget.images[index],
                    zoomController: _getZoomController(index),
                  );
                },
              ),

              // Close button
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom toolbar: share + info + page indicator
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        // Share button
                        _ToolbarButton(
                          icon: Icons.share,
                          onTap: () =>
                              _shareImage(widget.images[_currentIndex]),
                        ),
                        const SizedBox(width: 8),
                        // Info button
                        _ToolbarButton(
                          icon: Icons.info_outline,
                          onTap: () =>
                              _showInfo(context, widget.images[_currentIndex]),
                        ),
                        const Spacer(),
                        // Page indicator (only if multiple)
                        if (hasMultiple)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              widget.images.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: i == _currentIndex ? 10 : 6,
                                height: i == _currentIndex ? 10 : 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _currentIndex
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareImage(ImageProvider image) async {
    try {
      if (image is FileImage) {
        await Share.shareXFiles([XFile(image.file.path)]);
      } else if (image is CachedNetworkImageProvider) {
        // For network images, share the URL
        await Share.share(image.url);
      }
    } catch (_) {
      // Share cancelled or failed — silently ignore
    }
  }

  void _showInfo(BuildContext context, ImageProvider image) {
    String source = 'Unknown';
    String? path;
    int? fileSize;

    if (image is FileImage) {
      source = 'Local file';
      path = image.file.path;
      try {
        fileSize = image.file.lengthSync();
      } catch (_) {}
    } else if (image is CachedNetworkImageProvider) {
      source = 'Network';
      path = image.url;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Image Info',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'Source', value: source),
              if (path != null) _InfoRow(label: 'Path', value: path),
              if (fileSize != null)
                _InfoRow(
                  label: 'Size',
                  value: '${(fileSize / 1024).toStringAsFixed(1)} KB',
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePage extends StatefulWidget {
  const _ImagePage({required this.image, required this.zoomController});

  final ImageProvider image;
  final _ZoomController zoomController;

  @override
  State<_ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<_ImagePage>
    with SingleTickerProviderStateMixin {
  late final TransformationController _transformController;
  late final AnimationController _animationController;
  late Animation<Matrix4> _animation;
  final _key = GlobalKey();

  static const double _tapZoomScale = 2.5;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    widget.zoomController.reset = _animateReset;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _animateReset() {
    if (!mounted) return;
    _animateTo(Matrix4.identity());
  }

  void _animateTo(Matrix4 end) {
    _animation = Matrix4Tween(begin: _transformController.value, end: end)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController
      ..value = 0
      ..forward();
    _animation.addListener(() {
      _transformController.value = _animation.value;
    });
  }

  void _onDoubleTap() {
    final current = _transformController.value;
    final scale = current.getMaxScaleOnAxis();

    if (scale > 1.1) {
      // Zoomed in TO reset
      _animateTo(Matrix4.identity());
    } else {
      // Zoomed out TO zoom in to center
      final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      final size = renderBox.size;
      final center = Offset(size.width / 2, size.height / 2);

      final newTransform = Matrix4.identity()
        ..translateByDouble(
          -center.dx * (_tapZoomScale - 1),
          -center.dy * (_tapZoomScale - 1),
          0,
          0,
        )
        ..scaleByDouble(_tapZoomScale, _tapZoomScale, _tapZoomScale, 1.0);

      _animateTo(newTransform);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      // Absorb taps on the image so they don't propagate to the background
      behavior: HitTestBehavior.opaque,
      child: InteractiveViewer(
        key: _key,
        transformationController: _transformController,
        panEnabled: true,
        scaleEnabled: true,
        minScale: 0.5,
        maxScale: 5.0,
        boundaryMargin: const EdgeInsets.all(20),
        child: Center(
          child: Image(
            image: widget.image,
            fit: BoxFit.contain,
            frameBuilder: (_, child, frame, _) {
              if (frame != null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            },
            errorBuilder: (_, _, _) => const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoomController {
  VoidCallback? reset;

  void dispose() {}
}
