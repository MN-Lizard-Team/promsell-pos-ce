import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/scan_overlay_painter.dart';

void main() {
  group('ScanOverlayPainter', () {
    test('can be instantiated with all parameters', () {
      const painter = ScanOverlayPainter(
        cutoutWidth: 200,
        cutoutHeight: 120,
        borderRadius: 12,
        borderColor: Colors.green,
        laserY: 0.5,
        laserColor: Colors.red,
      );
      expect(painter, isA<ScanOverlayPainter>());
    });

    test('shouldRepaint returns true when borderColor changes', () {
      const painter1 = ScanOverlayPainter(
        cutoutWidth: 200,
        cutoutHeight: 120,
        borderRadius: 12,
        borderColor: Colors.white,
      );
      const painter2 = ScanOverlayPainter(
        cutoutWidth: 200,
        cutoutHeight: 120,
        borderRadius: 12,
        borderColor: Colors.green,
      );
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when laserY changes', () {
      const painter1 = ScanOverlayPainter(
        cutoutWidth: 200,
        cutoutHeight: 120,
        borderRadius: 12,
        laserY: 0.3,
        laserColor: Colors.red,
      );
      const painter2 = ScanOverlayPainter(
        cutoutWidth: 200,
        cutoutHeight: 120,
        borderRadius: 12,
        laserY: 0.7,
        laserColor: Colors.red,
      );
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when laserColor changes', () {
      const painter1 = ScanOverlayPainter(
        cutoutWidth: 200,
        cutoutHeight: 120,
        borderRadius: 12,
        laserY: 0.5,
        laserColor: Colors.red,
      );
      const painter2 = ScanOverlayPainter(
        cutoutWidth: 200,
        cutoutHeight: 120,
        borderRadius: 12,
        laserY: 0.5,
        laserColor: Colors.blue,
      );
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns false when nothing changes', () {
      const painter1 = ScanOverlayPainter(
        cutoutWidth: 200,
        cutoutHeight: 120,
        borderRadius: 12,
        borderColor: Colors.white,
        laserY: 0.5,
        laserColor: Colors.red,
      );
      const painter2 = ScanOverlayPainter(
        cutoutWidth: 200,
        cutoutHeight: 120,
        borderRadius: 12,
        borderColor: Colors.white,
        laserY: 0.5,
        laserColor: Colors.red,
      );
      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    testWidgets('renders on a CustomPaint without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: Size(300, 400),
              painter: ScanOverlayPainter(
                cutoutWidth: 200,
                cutoutHeight: 120,
                borderRadius: 12,
                borderColor: Colors.white,
                laserY: 0.5,
                laserColor: Colors.red,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsNWidgets(2));
    });

    testWidgets('renders without laser when laserY is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: Size(300, 400),
              painter: ScanOverlayPainter(
                cutoutWidth: 200,
                cutoutHeight: 120,
                borderRadius: 12,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsNWidgets(2));
    });
  });
}
