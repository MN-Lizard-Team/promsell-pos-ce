import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/sales/sales_settings_form/sales_shared_widgets.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('SalesSharedWidgets', () {
    testWidgets('buildSectionTitle renders uppercase title', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) =>
              SalesSharedWidgets.buildSectionTitle(context, 'Section'),
        ),
      );

      expect(find.text('SECTION'), findsOneWidget);
    });

    testWidgets('buildChoiceRow renders options and selection', (tester) async {
      var selected = 'A';
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => Builder(
            builder: (context) => SalesSharedWidgets.buildChoiceRow(
              context: context,
              icon: Icons.sort,
              label: 'Sort',
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
      expect(find.text('Sort'), findsOneWidget);
    });

    testWidgets('buildDraftsTile renders value', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => SalesSharedWidgets.buildDraftsTile(
            context: context,
            icon: Icons.drafts_outlined,
            label: 'Drafts',
            value: 10,
            min: 1,
            max: 100,
            onChanged: (v) {},
          ),
        ),
      );

      expect(find.text('Drafts'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('buildSwitchTile renders and toggles', (tester) async {
      var value = false;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => Builder(
            builder: (context) => SalesSharedWidgets.buildSwitchTile(
              context: context,
              icon: Icons.toggle_on,
              title: 'Enable',
              subtitle: 'Subtitle',
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );

      expect(find.text('Enable'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(value, isTrue);
    });
  });
}
