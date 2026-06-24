import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/general/general_settings_form/dialog_option_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/settings_switch_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

void main() {
  void noop() {}

  group('DialogOptionTile', () {
    testWidgets('renders selected state with check icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogOptionTile(
              icon: Icons.light_mode,
              label: 'Light',
              isSelected: true,
              st: SettingsThemeExtension.light,
              onTap: noop,
            ),
          ),
        ),
      );

      expect(find.text('Light'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders unselected state without check icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogOptionTile(
              icon: Icons.dark_mode,
              label: 'Dark',
              isSelected: false,
              st: SettingsThemeExtension.light,
              onTap: noop,
            ),
          ),
        ),
      );

      expect(find.text('Dark'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      void markTapped() => tapped = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogOptionTile(
              icon: Icons.system_update,
              label: 'System',
              isSelected: false,
              st: SettingsThemeExtension.light,
              onTap: markTapped,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('SettingsSectionCard', () {
    testWidgets('renders with title and children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSectionCard(
              title: 'General',
              children: [Text('Child 1'), Text('Child 2')],
            ),
          ),
        ),
      );

      expect(find.text('GENERAL'), findsOneWidget);
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
    });

    testWidgets('renders without title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSectionCard(children: [Text('Only child')]),
          ),
        ),
      );

      expect(find.text('Only child'), findsOneWidget);
    });
  });

  group('SettingsSwitchTile', () {
    testWidgets('renders title and switch', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSwitchTile(
              title: 'Enable feature',
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Enable feature'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('renders with subtitle and icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSwitchTile(
              title: 'Auto print',
              value: false,
              subtitle: 'Print after sale',
              icon: Icons.print,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Auto print'), findsOneWidget);
      expect(find.text('Print after sale'), findsOneWidget);
      expect(find.byIcon(Icons.print), findsOneWidget);
    });

    testWidgets('toggles value on tap', (tester) async {
      bool value = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsSwitchTile(
              title: 'Toggle',
              value: value,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();
      expect(value, isTrue);
    });
  });
}
