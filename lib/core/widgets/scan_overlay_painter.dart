import 'package:flutter/material.dart';

/// Darkens the screen outside a centered rectangular cutout with corner markers
/// and an optional animated laser line.
class ScanOverlayPainter extends CustomPainter {
  const ScanOverlayPainter({
    required this.cutoutWidth,
    required this.cutoutHeight,
    required this.borderRadius,
    this.borderColor,
    this.laserY,
    this.laserColor,
  });

  final double cutoutWidth;
  final double cutoutHeight;
  final double borderRadius;
  final Color? borderColor;
  final double? laserY;
  final Color? laserColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final cutoutRect = Rect.fromCenter(
      center: center,
      width: cutoutWidth,
      height: cutoutHeight,
    );
    final cutout = RRect.fromRectAndRadius(
      cutoutRect,
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

    _drawCorner(canvas, cutout, markerPaint, markerLength, true, true);
    _drawCorner(canvas, cutout, markerPaint, markerLength, false, true);
    _drawCorner(canvas, cutout, markerPaint, markerLength, true, false);
    _drawCorner(canvas, cutout, markerPaint, markerLength, false, false);

    // Laser line
    if (laserY != null && laserColor != null) {
      final ly = cutoutRect.top + cutoutRect.height * laserY!;
      final linePaint = Paint()
        ..color = laserColor!
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // Main laser line
      canvas.drawLine(
        Offset(cutoutRect.left + 8, ly),
        Offset(cutoutRect.right - 8, ly),
        linePaint,
      );

      // Glow gradient above and below the line
      final glowPaint = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                laserColor!.withValues(alpha: 0.0),
                laserColor!.withValues(alpha: 0.25),
              ],
            ).createShader(
              Rect.fromLTWH(cutoutRect.left + 8, ly - 20, cutoutWidth - 16, 20),
            );
      canvas.drawRect(
        Rect.fromLTWH(cutoutRect.left + 8, ly - 20, cutoutWidth - 16, 20),
        glowPaint,
      );
    }
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
      oldDelegate.borderColor != borderColor ||
      oldDelegate.laserY != laserY ||
      oldDelegate.laserColor != laserColor;
}
