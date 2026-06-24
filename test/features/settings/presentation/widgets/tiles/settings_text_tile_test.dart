import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/settings_text_tile.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('SettingsTextTile', () {
    testWidgets('renders title and value', (tester) async {
      await tester.pumpApp(
        SettingsTextTile(
          title: 'Shop Name',
          value: 'My Shop',
          onChanged: (_) {},
        ),
      );

      expect(find.text('Shop Name'), findsOneWidget);
      expect(find.text('My Shop'), findsOneWidget);
    });

    testWidgets('shows tapToSet when value is empty', (tester) async {
      await tester.pumpApp(
        SettingsTextTile(title: 'Phone', value: '', onChanged: (_) {}),
      );

      expect(find.text('Tap to set'), findsOneWidget);
    });

    testWidgets('renders with icon', (tester) async {
      await tester.pumpApp(
        SettingsTextTile(
          title: 'Address',
          value: '123 St',
          icon: Icons.location_on,
          onChanged: (_) {},
        ),
      );

      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('opens edit dialog on tap', (tester) async {
      await tester.pumpApp(
        SettingsTextTile(title: 'Name', value: 'Test', onChanged: (_) {}),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('calls onChanged with new value on save', (tester) async {
      String? saved;
      await tester.pumpApp(
        SettingsTextTile(
          title: 'Name',
          value: 'Old',
          onChanged: (v) => saved = v,
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'New Value');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(saved, 'New Value');
    });
  });
}
