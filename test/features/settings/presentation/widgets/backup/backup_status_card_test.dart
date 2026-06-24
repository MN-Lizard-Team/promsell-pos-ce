import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/backup/backup_status_card.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('BackupStatusCard', () {
    Widget buildCard({String? lastBackup, int reminder = 7}) => Builder(
      builder: (context) => BackupStatusCard(
        lastBackupAt: lastBackup,
        reminderDays: reminder,
        st: SettingsThemeExtension.light,
        l10n: AppLocalizations.of(context),
      ),
    );

    testWidgets('renders with last backup', (tester) async {
      await tester.pumpApp(buildCard(lastBackup: '2026-06-01'));
      expect(find.byType(BackupStatusCard), findsOneWidget);
    });

    testWidgets('renders without last backup', (tester) async {
      await tester.pumpApp(buildCard());
      expect(find.byType(BackupStatusCard), findsOneWidget);
    });
  });
}
