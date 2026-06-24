import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form/receipt_content_section.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('ReceiptContentSection', () {
    testWidgets('renders section title and switch', (tester) async {
      await tester.pumpApp(
        ReceiptContentSection(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('shows dash when note is empty', (tester) async {
      await tester.pumpApp(
        ReceiptContentSection(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('shows note preview when not empty', (tester) async {
      await tester.pumpApp(
        ReceiptContentSection(
          settings: const Settings().copyWith(receiptNote: 'Thank you'),
          onUpdate: (_) {},
        ),
      );

      expect(find.text('Thank you'), findsOneWidget);
    });

    testWidgets('opens note dialog on tap', (tester) async {
      await tester.pumpApp(
        ReceiptContentSection(settings: const Settings(), onUpdate: (_) {}),
      );

      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
