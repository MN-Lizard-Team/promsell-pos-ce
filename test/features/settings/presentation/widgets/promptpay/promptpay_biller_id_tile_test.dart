import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay/promptpay_biller_id_tile.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

class MockAppLockService extends Mock implements AppLockService {}

void main() {
  late MockSettingsCubit mockSettingsCubit;
  late MockAppLockService mockAppLockService;

  setUp(() async {
    await GetIt.I.reset();
    mockSettingsCubit = MockSettingsCubit();
    mockAppLockService = MockAppLockService();

    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockSettingsCubit.updateField(any())).thenReturn(null);
    // Lock disabled so ensureAppUnlocked returns true without prompting.
    when(() => mockAppLockService.isEnabled()).thenAnswer((_) async => false);

    GetIt.I.registerSingleton<AppLockService>(mockAppLockService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpTile(
    WidgetTester tester, {
    required Settings settings,
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => PromptpayBillerIdTile(
          settings: settings,
          cubit: mockSettingsCubit,
          st: SettingsThemeExtension.light,
          l10n: AppLocalizations.of(context),
        ),
      ),
    );
  }

  group('PromptpayBillerIdTile', () {
    testWidgets('renders title and masked biller ID when set', (tester) async {
      await pumpTile(
        tester,
        settings: const Settings().copyWith(billerId: '1234567890121'),
      );

      expect(find.text('Biller ID'), findsOneWidget);
      // maskSensitiveId shows last 4 digits prefixed with bullets.
      expect(find.text('••••0121'), findsOneWidget);
      expect(find.byIcon(TablerIcons.receipt2), findsOneWidget);
    });

    testWidgets('renders hint when biller ID is empty', (tester) async {
      await pumpTile(tester, settings: const Settings());

      expect(find.text('Biller ID'), findsOneWidget);
      expect(find.text('Tax ID for Bill Payment QR'), findsOneWidget);
    });

    testWidgets('opens dialog on tap', (tester) async {
      await pumpTile(
        tester,
        settings: const Settings().copyWith(billerId: '1234567890121'),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('dialog validator rejects 12-digit input', (tester) async {
      await pumpTile(tester, settings: const Settings());

      await tester.tap(find.byType(ListTile));
      await tester.pump();
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), '123456789012');
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Must be 13 or 15 digits'), findsOneWidget);
      verifyNever(() => mockSettingsCubit.updateField(any()));
    });

    testWidgets('dialog validator rejects bad checksum', (tester) async {
      // 13 digits but wrong check digit (should be 1, used 2).
      await pumpTile(tester, settings: const Settings());

      await tester.tap(find.byType(ListTile));
      await tester.pump();
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), '1234567890122');
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Invalid checksum — please verify the ID'),
        findsOneWidget,
      );
      verifyNever(() => mockSettingsCubit.updateField(any()));
    });

    testWidgets('dialog validator accepts valid 13-digit ID', (tester) async {
      // 1234567890121 has a valid NISO 7064 Mod 11,10 checksum.
      await pumpTile(tester, settings: const Settings());

      await tester.tap(find.byType(ListTile));
      await tester.pump();
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), '1234567890121');
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pumpAndSettle();

      verify(() => mockSettingsCubit.updateField(any())).called(1);
    });
  });
}
