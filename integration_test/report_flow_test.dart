import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/main_dev.dart' as app;

import 'robot_pattern/report_robot.dart';

/// Device E2E for the Report page.
///
/// Uses localized nav labels instead of raw icon glyphs (the bottom-nav icon
/// set is `tabler_icons_plus`, not Material's `Icons.bar_chart`). Runs on the
/// Android emulator only.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Report Page Flow', () {
    testWidgets('open report page and verify tabs work', (tester) async {
      app.main();
      await tester.pump(const Duration(milliseconds: 800));

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      // Open the Report shell tab via its localized label.
      await tester.tap(find.text(l10n.navReport).first);
      await tester.pump(const Duration(milliseconds: 800));

      // Report title is stable (no longer flips with sub-tab).
      expect(find.text(l10n.reportTitle), findsWidgets);

      final robot = ReportRobot(tester);

      // Sub-tab switches use localized labels too.
      await robot.switchToHistory(label: l10n.navHistory);
      await tester.pump(const Duration(milliseconds: 800));

      await robot.switchToReport(label: l10n.navReport);
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets('select date preset updates the view', (tester) async {
      app.main();
      await tester.pump(const Duration(milliseconds: 800));

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.tap(find.text(l10n.navReport).first);
      await tester.pump(const Duration(milliseconds: 800));

      // Select "Last 7 days" preset.
      final robot = ReportRobot(tester);
      await robot.selectPreset(l10n.datePresetLast7Days);

      // Verify the page is still showing (no crash).
      expect(find.byType(Card), findsWidgets);
    });
  });
}
