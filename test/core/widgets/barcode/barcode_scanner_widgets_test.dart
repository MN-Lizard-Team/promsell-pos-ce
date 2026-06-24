import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_error_banner.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_scan_result.dart';

void main() {
  group('BarcodeErrorBanner', () {
    testWidgets('renders error text and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [BarcodeErrorBanner(errorText: 'Camera error')],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Camera error'), findsOneWidget);
    });
  });

  group('BarcodeScanResult', () {
    testWidgets('renders scanned value and success label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BarcodeScanResult(
              scannedValue: '8851234567890',
              successLabel: 'Found product',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('8851234567890'), findsOneWidget);
      expect(find.text('Found product'), findsOneWidget);
    });

    testWidgets('renders empty string when scannedValue is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BarcodeScanResult(
              scannedValue: null,
              successLabel: 'Success',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });
  });
}
