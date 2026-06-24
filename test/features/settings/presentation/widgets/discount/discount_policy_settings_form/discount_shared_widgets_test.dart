import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount/discount_policy_settings_form/discount_shared_widgets.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('DiscountSharedWidgets', () {
    testWidgets('buildSectionTitle renders uppercase', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) =>
              DiscountSharedWidgets.buildSectionTitle(context, 'Limits'),
        ),
      );

      expect(find.text('LIMITS'), findsOneWidget);
    });

    testWidgets('buildChoiceRow renders options', (tester) async {
      var selected = 'A';
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => Builder(
            builder: (context) => DiscountSharedWidgets.buildChoiceRow(
              context: context,
              icon: Icons.percent,
              label: 'Type',
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

    testWidgets('buildSwitchTile toggles', (tester) async {
      var value = false;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => Builder(
            builder: (context) => DiscountSharedWidgets.buildSwitchTile(
              context: context,
              icon: Icons.toggle_on,
              title: 'Enable',
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('buildLimitTile renders value and opens dialog', (
      tester,
    ) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => DiscountSharedWidgets.buildLimitTile(
            context: context,
            icon: Icons.percent,
            label: 'Max',
            displayValue: '50%',
            value: 50,
            min: 0,
            max: 100,
            presets: const [10, 25, 50],
            onChanged: (v) {},
          ),
        ),
      );

      expect(find.text('Max'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      await tester.tap(find.byType(ListTile));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
