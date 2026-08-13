import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_summary_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('GeneralSummaryCard', () {
    testWidgets('renders title and language badge', (tester) async {
      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('en'),
          themeMode: ThemeMode.light,
        ),
      );

      expect(find.byIcon(TablerIcons.settings), findsOneWidget);
      expect(find.byIcon(TablerIcons.language), findsOneWidget);
    });

    testWidgets('does not show accessibility ON/OFF badges', (tester) async {
      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('th'),
          themeMode: ThemeMode.dark,
        ),
      );

      expect(find.text('ON'), findsNothing);
      expect(find.text('OFF'), findsNothing);
    });

    testWidgets('renders correct theme icons', (tester) async {
      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('en'),
          themeMode: ThemeMode.light,
        ),
      );
      expect(find.byIcon(TablerIcons.sun), findsOneWidget);

      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('en'),
          themeMode: ThemeMode.dark,
        ),
      );
      expect(find.byIcon(TablerIcons.moon), findsOneWidget);

      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('en'),
          themeMode: ThemeMode.system,
        ),
      );
      expect(find.byIcon(TablerIcons.brightnessAuto), findsOneWidget);
    });
  });
}
