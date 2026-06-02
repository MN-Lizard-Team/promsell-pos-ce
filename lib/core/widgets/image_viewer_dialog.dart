import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

              // Page indicator
              if (hasMultiple)
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
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
                ),
            ],
          ),
        ),
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
      // Zoomed in → reset
      _animateTo(Matrix4.identity());
    } else {
      // Zoomed out → zoom in to center
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
