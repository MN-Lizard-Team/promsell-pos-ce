import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/general_appearance_tiles.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('GeneralAppearanceTiles', () {
    testWidgets('renders theme tile only (a11y toggle deferred)', (
      tester,
    ) async {
      await tester.pumpApp(
        GeneralAppearanceTiles(settings: const Settings(), onUpdate: (s) {}),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(Switch), findsNothing);
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
