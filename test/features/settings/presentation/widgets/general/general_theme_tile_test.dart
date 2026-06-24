import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/general_theme_tile.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('GeneralThemeTile', () {
    testWidgets('renders theme tile with icon', (tester) async {
      await tester.pumpApp(
        GeneralThemeTile(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    });

    testWidgets('opens theme dialog on tap', (tester) async {
      await tester.pumpApp(
        GeneralThemeTile(settings: const Settings(), onUpdate: (_) {}),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
      expect(find.byIcon(Icons.nights_stay), findsOneWidget);
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    });

    testWidgets('calls onUpdate with selected theme', (tester) async {
      Settings? updated;
      await tester.pumpApp(
        GeneralThemeTile(
          settings: const Settings(),
          onUpdate: (s) => updated = s,
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.wb_sunny));
      await tester.pump();

      expect(updated, isNotNull);
      expect(updated!.themeMode, ThemeMode.light);
    });
  });
}
