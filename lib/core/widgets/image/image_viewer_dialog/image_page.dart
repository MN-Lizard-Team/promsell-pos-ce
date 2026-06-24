import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog/image_viewer_utils.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({
    super.key,
    required this.image,
    required this.zoomController,
  });

  final ImageProvider image;
  final ZoomController zoomController;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage>
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
      _animateTo(Matrix4.identity());
    } else {
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
