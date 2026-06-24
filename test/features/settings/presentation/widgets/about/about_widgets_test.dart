import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/about/about_header_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/about/about_link_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/about/about_tech_row.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/about/version_chip.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('AboutHeaderCard', () {
    testWidgets('renders app name and version chips', (tester) async {
      await tester.pumpApp(
        const AboutHeaderCard(
          version: '1.0.0',
          buildNumber: '42',
          st: SettingsThemeExtension.light,
        ),
      );

      expect(find.text('Promsell POS CE'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });
  });

  group('AboutLinkTile', () {
    testWidgets('renders label and calls onTap', (tester) async {
      var tapped = false;
      void doNothing() => tapped = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AboutLinkTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              st: SettingsThemeExtension.light,
              onTap: doNothing,
            ),
          ),
        ),
      );

      expect(find.text('Privacy Policy'), findsOneWidget);
      await tester.tap(find.byType(ListTile));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('AboutTechRow', () {
    testWidgets('renders icon and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AboutTechRow(
              icon: Icons.flutter_dash,
              label: 'Flutter',
              st: SettingsThemeExtension.light,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.flutter_dash), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
    });
  });

  group('VersionChip', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VersionChip(
              label: 'Version',
              value: '2.1.0',
              st: SettingsThemeExtension.light,
            ),
          ),
        ),
      );

      expect(find.text('Version'), findsOneWidget);
      expect(find.text('2.1.0'), findsOneWidget);
    });
  });
}
