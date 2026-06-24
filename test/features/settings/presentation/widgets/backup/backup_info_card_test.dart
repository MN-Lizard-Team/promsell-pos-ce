import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/backup/backup_info_card.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('BackupInfoCard', () {
    testWidgets('renders info card', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) {
            return BackupInfoCard(
              st:
                  Theme.of(context).extension<SettingsThemeExtension>() ??
                  SettingsThemeExtension.light,
              l10n: AppLocalizations.of(context),
            );
          },
        ),
      );

      expect(find.byType(BackupInfoCard), findsOneWidget);
    });
  });
}
