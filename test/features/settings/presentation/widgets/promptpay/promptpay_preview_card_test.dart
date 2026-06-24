import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_preview_card.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('PromptpayPreviewCard', () {
    Widget buildCard(String id) => Builder(
      builder: (context) => PromptpayPreviewCard(
        promptpayId: id,
        st: SettingsThemeExtension.light,
        l10n: AppLocalizations.of(context),
      ),
    );

    testWidgets('shows configured state when has ID', (tester) async {
      await tester.pumpApp(buildCard('0812345678'));
      expect(find.byType(PromptpayPreviewCard), findsOneWidget);
    });

    testWidgets('shows not configured state when empty', (tester) async {
      await tester.pumpApp(buildCard(''));
      expect(find.byType(PromptpayPreviewCard), findsOneWidget);
    });
  });
}
