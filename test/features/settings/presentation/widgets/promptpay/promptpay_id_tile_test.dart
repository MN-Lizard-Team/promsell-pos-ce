import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_id_tile.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockSettingsCubit.updateField(any())).thenReturn(null);
  });

  Future<void> pumpTile(
    WidgetTester tester, {
    required Settings settings,
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => PromptpayIdTile(
          settings: settings,
          cubit: mockSettingsCubit,
          st: SettingsThemeExtension.light,
          l10n: AppLocalizations.of(context),
        ),
      ),
    );
  }

  group('PromptpayIdTile', () {
    testWidgets('renders title and masked value when promptpayId is set', (
      tester,
    ) async {
      await pumpTile(
        tester,
        settings: const Settings().copyWith(promptpayId: '0812345678'),
      );

      expect(find.text('PromptPay ID'), findsOneWidget);
      // maskSensitiveId shows last 4 digits prefixed with bullets.
      expect(find.text('••••5678'), findsOneWidget);
      expect(find.byIcon(TablerIcons.wallet), findsOneWidget);
    });

    testWidgets('renders hint when promptpayId is empty', (tester) async {
      await pumpTile(tester, settings: const Settings());

      expect(find.text('PromptPay ID'), findsOneWidget);
      expect(find.text('Phone number or Citizen ID'), findsOneWidget);
    });

    testWidgets('opens dialog on tap', (tester) async {
      await pumpTile(
        tester,
        settings: const Settings().copyWith(promptpayId: '0812345678'),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
