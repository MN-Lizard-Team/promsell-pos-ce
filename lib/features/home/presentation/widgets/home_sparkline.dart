import 'dart:math' as math;
import 'package:flutter/material.dart';

class HomeSparkline extends StatelessWidget {
  const HomeSparkline({
    super.key,
    required this.data,
    this.color = Colors.white,
    this.lineWidth = 2.5,
    this.fillAlpha = 0.15,
  });

  final List<double> data;
  final Color color;
  final double lineWidth;
  final double fillAlpha;

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return CustomPaint(
        size: const Size(double.infinity, 48),
        painter: _BarPainter(data: data, color: color),
      );
    }
    return CustomPaint(
      size: const Size(double.infinity, 48),
      painter: _SparklinePainter(
        data: data,
        color: color,
        lineWidth: lineWidth,
        fillAlpha: fillAlpha,
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final h = size.height;
    final w = size.width;
    final barWidth = w / (data.length * 2);
    final maxVal = data.reduce(math.max);
    if (maxVal == 0) {
      for (int i = 0; i < data.length; i++) {
        final barWidth = w / (data.length * 2);
        final x = i * (w / data.length) + (w / data.length - barWidth) / 2;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, h - 4, barWidth, 4),
          const Radius.circular(2),
        );
        canvas.drawRRect(
          rect,
          Paint()
            ..color = color.withValues(alpha: 0.2)
            ..style = PaintingStyle.fill,
        );
      }
      return;
    }

    for (int i = 0; i < data.length; i++) {
      final barH = (data[i] / maxVal) * h * 0.8;
      final x = i * (w / data.length) + (w / data.length - barWidth) / 2;
      final y = h - barH;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barH),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_BarPainter oldDelegate) =>
      data != oldDelegate.data || color != oldDelegate.color;
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.color,
    required this.lineWidth,
    required this.fillAlpha,
  });

  final List<double> data;
  final Color color;
  final double lineWidth;
  final double fillAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final h = size.height;
    final w = size.width;
    final stepX = w / (data.length - 1);

    double normalize(double v) {
      if (range == 0) return h * 0.5;
      return h - ((v - minVal) / range) * h * 0.8 - h * 0.1;
    }

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      points.add(Offset(i * stepX, normalize(data[i])));
    }

    final path = Path();
    final fillPath = Path();

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      final midY1 = prev.dy;
      final midY2 = curr.dy;
      path.quadraticBezierTo(
        midX,
        midY1,
        (midX + curr.dx) / 2,
        (midY1 + curr.dy) / 2,
      );
      path.quadraticBezierTo(curr.dx, midY2, curr.dx, curr.dy);
      fillPath.quadraticBezierTo(
        midX,
        midY1,
        (midX + curr.dx) / 2,
        (midY1 + curr.dy) / 2,
      );
      fillPath.quadraticBezierTo(curr.dx, midY2, curr.dx, curr.dy);
    }

    fillPath.lineTo(w, h);
    fillPath.lineTo(0, h);
    fillPath.close();

    final fillPaint = Paint()
      ..color = color.withValues(alpha: fillAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final gradient = LinearGradient(
      colors: [color.withValues(alpha: 0.4), color],
    );
    final linePaint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    final lastPoint = points.last;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 4, dotPaint);
    canvas.drawCircle(
      lastPoint,
      4,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      data != oldDelegate.data || color != oldDelegate.color;
}
