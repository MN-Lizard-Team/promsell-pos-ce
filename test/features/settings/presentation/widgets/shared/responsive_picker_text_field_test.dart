import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/responsive_settings_picker.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_text_field.dart';

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

  group('SettingsTextField', () {
    testWidgets('renders with label and icon', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTextField(
              controller: controller,
              label: 'Name',
              icon: Icons.person,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      controller.dispose();
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      final controller = TextEditingController();
      String? changed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsTextField(
              controller: controller,
              label: 'Name',
              icon: Icons.person,
              onChanged: (v) => changed = v,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test');
      expect(changed, 'test');
      controller.dispose();
    });
  });
}
