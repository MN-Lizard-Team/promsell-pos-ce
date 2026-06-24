import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form/receipt_shared_widgets.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('ReceiptSharedWidgets', () {
    testWidgets('buildSectionTitle renders uppercase', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) =>
              ReceiptSharedWidgets.buildSectionTitle(context, 'Tax'),
        ),
      );

      expect(find.text('TAX'), findsOneWidget);
    });

    testWidgets('buildChoiceRow renders options and selection', (tester) async {
      var selected = 'A';
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => Builder(
            builder: (context) => ReceiptSharedWidgets.buildChoiceRow(
              context: context,
              icon: Icons.sort,
              label: 'Mode',
              options: const ['A', 'B'],
              selected: selected,
              onSelected: (v) => setState(() => selected = v),
              labelBuilder: (v) => 'Option $v',
            ),
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
    });

    testWidgets('buildSwitchTile renders and toggles', (tester) async {
      var value = false;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => Builder(
            builder: (context) => ReceiptSharedWidgets.buildSwitchTile(
              context: context,
              icon: Icons.print_outlined,
              title: 'Print',
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );

      expect(find.text('Print'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(value, isTrue);
    });
  });
}
