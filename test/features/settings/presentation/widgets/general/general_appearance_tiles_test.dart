import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/general_appearance_tiles.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('GeneralAppearanceTiles', () {
    testWidgets('renders theme, compact cart, and accessibility tiles', (
      tester,
    ) async {
      await tester.pumpApp(
        GeneralAppearanceTiles(settings: const Settings(), onUpdate: (_) {}),
      );

      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      expect(find.byIcon(Icons.accessibility_new_outlined), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('opens theme dialog on tap', (tester) async {
      await tester.pumpApp(
        GeneralAppearanceTiles(settings: const Settings(), onUpdate: (_) {}),
      );

      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
      expect(find.byIcon(Icons.nights_stay), findsOneWidget);
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    });

    testWidgets('calls onUpdate when compact cart toggled', (tester) async {
      Settings? updated;
      await tester.pumpApp(
        GeneralAppearanceTiles(
          settings: const Settings(),
          onUpdate: (s) => updated = s,
        ),
      );

      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      expect(updated, isNotNull);
      expect(updated!.cartCompactMode, isFalse);
    });

    testWidgets('calls onUpdate when accessibility toggled', (tester) async {
      Settings? updated;
      await tester.pumpApp(
        GeneralAppearanceTiles(
          settings: const Settings(),
          onUpdate: (s) => updated = s,
        ),
      );

      await tester.tap(find.byType(Switch).last);
      await tester.pump();
      expect(updated, isNotNull);
      expect(updated!.accessibilityMode, isTrue);
    });

    testWidgets('selecting theme mode calls onUpdate', (tester) async {
      Settings? updated;
      await tester.pumpApp(
        GeneralAppearanceTiles(
          settings: const Settings(),
          onUpdate: (s) => updated = s,
        ),
      );

      await tester.tap(find.byIcon(Icons.dark_mode_outlined));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.nights_stay));
      await tester.pump();

      expect(updated, isNotNull);
      expect(updated!.themeMode, ThemeMode.dark);
    });
  });
}
