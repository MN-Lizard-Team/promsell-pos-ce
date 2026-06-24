import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/general_language_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/general_reset_tile.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('GeneralLanguageTile', () {
    testWidgets('renders language label', (tester) async {
      await tester.pumpApp(
        GeneralLanguageTile(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.byIcon(Icons.language_outlined), findsOneWidget);
    });

    testWidgets('opens language dialog on tap', (tester) async {
      await tester.pumpApp(
        GeneralLanguageTile(settings: const Settings(), onUpdate: (_) {}),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('GeneralResetTile', () {
    testWidgets('renders reset tile with icon', (tester) async {
      await tester.pumpApp(
        GeneralResetTile(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.byIcon(Icons.restore), findsOneWidget);
    });

    testWidgets('opens reset confirmation dialog on tap', (tester) async {
      await tester.pumpApp(
        GeneralResetTile(settings: const Settings(), onUpdate: (_) {}),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('calls onUpdate with reset values on confirm', (tester) async {
      Settings? updated;
      await tester.pumpApp(
        GeneralResetTile(
          settings: const Settings(),
          onUpdate: (s) => updated = s,
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(updated, isNotNull);
      expect(updated!.themeMode, ThemeMode.system);
      expect(updated!.accessibilityMode, isFalse);
    });
  });
}
