import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_summary_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('GeneralSummaryCard', () {
    testWidgets('renders title and language badge', (tester) async {
      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('en'),
          themeMode: ThemeMode.light,
          accessibilityMode: false,
        ),
      );

      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byIcon(Icons.language_outlined), findsOneWidget);
    });

    testWidgets('shows ON for accessibility enabled', (tester) async {
      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('th'),
          themeMode: ThemeMode.dark,
          accessibilityMode: true,
        ),
      );

      expect(find.text('ON'), findsOneWidget);
    });

    testWidgets('shows OFF for accessibility disabled', (tester) async {
      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('en'),
          themeMode: ThemeMode.system,
          accessibilityMode: false,
        ),
      );

      expect(find.text('OFF'), findsOneWidget);
    });

    testWidgets('renders correct theme icons', (tester) async {
      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('en'),
          themeMode: ThemeMode.light,
          accessibilityMode: false,
        ),
      );
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);

      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('en'),
          themeMode: ThemeMode.dark,
          accessibilityMode: false,
        ),
      );
      expect(find.byIcon(Icons.nights_stay), findsOneWidget);

      await tester.pumpApp(
        const GeneralSummaryCard(
          locale: Locale('en'),
          themeMode: ThemeMode.system,
          accessibilityMode: false,
        ),
      );
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    });
  });
}
