import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/general_appearance_tiles.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('GeneralAppearanceTiles', () {
    testWidgets('renders theme, compact cart, accessibility tiles', (
      tester,
    ) async {
      await tester.pumpApp(
        GeneralAppearanceTiles(settings: const Settings(), onUpdate: (s) {}),
      );

      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('toggles compact cart mode', (tester) async {
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
    });

    testWidgets('opens theme dialog', (tester) async {
      await tester.pumpApp(
        GeneralAppearanceTiles(settings: const Settings(), onUpdate: (s) {}),
      );

      await tester.tap(find.byType(ListTile).first);
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
