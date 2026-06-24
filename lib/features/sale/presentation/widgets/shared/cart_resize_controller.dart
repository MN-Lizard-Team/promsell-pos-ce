import 'package:flutter/widgets.dart';

class CartResizeController extends ChangeNotifier {
  CartResizeController() {
    cartHeight = ValueNotifier(280);
    cartWidth = ValueNotifier(390);
    isDragging = ValueNotifier(false);
  }

  late final ValueNotifier<double> cartHeight;
  late final ValueNotifier<double> cartWidth;
  late final ValueNotifier<bool> isDragging;

  static const double _minCartHeightPortrait = 320;
  static const double _minCartHeightLandscape = 280;
  static const double _maxCartHeightRatioPortrait = 0.95;
  static const double _maxCartHeightRatioLandscape = 0.90;

  static const double _minCartWidth = 300;
  static const double _maxCartWidth = 560;
  static const double _snapTolerance = 18;

  double minCartHeight(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return isLandscape ? _minCartHeightLandscape : _minCartHeightPortrait;
  }

  double _maxCartHeightRatio(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return isLandscape
        ? _maxCartHeightRatioLandscape
        : _maxCartHeightRatioPortrait;
  }

  double maxCartHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height * _maxCartHeightRatio(context);

  void onVerticalDrag(BuildContext context, DragUpdateDetails details) {
    final minH = minCartHeight(context);
    final maxH = maxCartHeight(context);
    cartHeight.value = (cartHeight.value - details.delta.dy).clamp(minH, maxH);
  }

  void onHorizontalDrag(BuildContext context, DragUpdateDetails details) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final dxAdjusted = isRtl ? -details.delta.dx : details.delta.dx;
    cartWidth.value = (cartWidth.value - dxAdjusted).clamp(
      _minCartWidth,
      _maxCartWidth,
    );
  }

  void onDragStart() => isDragging.value = true;
  void onDragEnd() => isDragging.value = false;

  void onVerticalDragEnd(BuildContext context, DragEndDetails details) {
    final maxH = maxCartHeight(context);
    final minH = minCartHeight(context);
    final presets = <double>[minH, maxH];
    for (final p in presets) {
      if ((cartHeight.value - p).abs() < _snapTolerance) {
        cartHeight.value = p;
        break;
      }
    }
    onDragEnd();
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    const presets = <double>[320, 500];
    for (final p in presets) {
      if ((cartWidth.value - p).abs() < _snapTolerance) {
        cartWidth.value = p;
        break;
      }
    }
    onDragEnd();
  }

  void onSizePresetChanged(BuildContext context, double value) {
    if (value <= 0.0) {
      cartHeight.value = minCartHeight(context);
    } else {
      cartHeight.value = maxCartHeight(context);
    }
  }

  void onWidthPresetChanged(double value) {
    if (value <= 0.0) {
      cartWidth.value = 320;
    } else {
      cartWidth.value = 500;
    }
  }

  double? currentSizePreset(BuildContext context) {
    if (cartHeight.value <= minCartHeight(context) + 1) return 0.0;
    if (cartHeight.value >= maxCartHeight(context) - 1) return 1.0;
    return null;
  }

  double? currentWidthPreset() {
    if ((cartWidth.value - 320).abs() < 10) return 0.0;
    if ((cartWidth.value - 500).abs() < 10) return 1.0;
    return null;
  }

  @override
  void dispose() {
    cartHeight.dispose();
    cartWidth.dispose();
    isDragging.dispose();
    super.dispose();
  }
}
