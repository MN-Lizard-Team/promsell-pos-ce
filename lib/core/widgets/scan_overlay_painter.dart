import 'package:flutter/material.dart';

/// Darkens the screen outside a centered square cutout with corner markers.
class ScanOverlayPainter extends CustomPainter {
  const ScanOverlayPainter({
    required this.cutoutSize,
    required this.borderRadius,
    this.borderColor,
  });

  final double cutoutSize;
  final double borderRadius;
  final Color? borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final cutout = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: cutoutSize, height: cutoutSize),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRect(rect);
    path.addRRect(cutout);
    canvas.drawPath(path..fillType = PathFillType.evenOdd, paint);

    // Corner markers
    final markerPaint = Paint()
      ..color = borderColor ?? Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const markerLength = 24.0;
    final cornerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: cutoutSize, height: cutoutSize),
      Radius.circular(borderRadius),
    );

    _drawCorner(canvas, cornerRect, markerPaint, markerLength, true, true);
    _drawCorner(canvas, cornerRect, markerPaint, markerLength, false, true);
    _drawCorner(canvas, cornerRect, markerPaint, markerLength, true, false);
    _drawCorner(canvas, cornerRect, markerPaint, markerLength, false, false);
  }

  void _drawCorner(
    Canvas canvas,
    RRect rect,
    Paint paint,
    double length,
    bool left,
    bool top,
  ) {
    final x = left ? rect.left : rect.right;
    final y = top ? rect.top : rect.bottom;
    final dx = left ? length : -length;
    final dy = top ? length : -length;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(covariant ScanOverlayPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
