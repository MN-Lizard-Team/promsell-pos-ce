import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/responsive_settings_picker.dart';

void main() {
  group('ResponsiveSettingsPicker', () {
    testWidgets('renders ListTile on wide screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: ResponsiveSettingsPicker(
                icon: Icons.settings,
                title: 'Setting',
                child: Text('Picker'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Setting'), findsOneWidget);
    });

    testWidgets('renders Column on narrow screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: ResponsiveSettingsPicker(
                icon: Icons.settings,
                title: 'Setting',
                child: Text('Picker'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListTile), findsNothing);
      expect(find.text('Setting'), findsOneWidget);
    });
  });
}
