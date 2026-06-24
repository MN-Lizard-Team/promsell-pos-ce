import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form/receipt_tax_section.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('ReceiptTaxSection', () {
    testWidgets('renders NONE mode', (tester) async {
      await tester.pumpApp(
        ReceiptTaxSection(settings: const Settings(), onUpdate: (s) {}),
      );

      expect(find.byType(ChoiceChip), findsNWidgets(3));
    });

    testWidgets('renders INCLUSIVE mode with VAT rate tile', (tester) async {
      const settings = Settings(
        taxConfig: TaxConfig(vatMode: 'INCLUSIVE', vatRate: 7),
      );
      await tester.pumpApp(
        ReceiptTaxSection(settings: settings, onUpdate: (s) {}),
      );

      expect(find.text('7.0%'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('renders EXCLUSIVE mode with VAT rate tile', (tester) async {
      const settings = Settings(
        taxConfig: TaxConfig(vatMode: 'EXCLUSIVE', vatRate: 10),
      );
      await tester.pumpApp(
        ReceiptTaxSection(settings: settings, onUpdate: (s) {}),
      );

      expect(find.text('10.0%'), findsOneWidget);
    });

    testWidgets('opens VAT rate dialog', (tester) async {
      const settings = Settings(
        taxConfig: TaxConfig(vatMode: 'INCLUSIVE', vatRate: 7),
      );
      await tester.pumpApp(
        ReceiptTaxSection(settings: settings, onUpdate: (s) {}),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
