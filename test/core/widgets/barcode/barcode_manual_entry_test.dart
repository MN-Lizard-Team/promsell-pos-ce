import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_manual_entry.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('BarcodeManualEntry', () {
    testWidgets('renders text field and buttons', (tester) async {
      final controller = TextEditingController();
      await tester.pumpApp(
        BarcodeManualEntry(
          controller: controller,
          onSubmit: () {},
          onCancel: () {},
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      controller.dispose();
    });

    testWidgets('calls onCancel when cancel button tapped', (tester) async {
      final controller = TextEditingController();
      var cancelled = false;
      await tester.pumpApp(
        BarcodeManualEntry(
          controller: controller,
          onSubmit: () {},
          onCancel: () => cancelled = true,
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      expect(cancelled, isTrue);
      controller.dispose();
    });

    testWidgets('calls onSubmit when submit button tapped', (tester) async {
      final controller = TextEditingController();
      var submitted = false;
      await tester.pumpApp(
        BarcodeManualEntry(
          controller: controller,
          onSubmit: () => submitted = true,
          onCancel: () {},
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(submitted, isTrue);
      controller.dispose();
    });
  });
}
