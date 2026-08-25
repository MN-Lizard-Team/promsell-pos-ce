import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/backup_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_root_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_attention_banner.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/settings_category_tile.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;

  void stubSettings(Settings settings) {
    when(() => mockSettingsCubit.state).thenReturn(
      SettingsState(status: SettingsStatus.loaded, settings: settings),
    );
  }

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    stubSettings(const Settings());
    when(() => mockSettingsCubit.update(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(const Settings());
  });

  group('SettingsPage Clean Index', () {
    testWidgets('shows loading state while settings are loading', (
      tester,
    ) async {
      when(
        () => mockSettingsCubit.state,
      ).thenReturn(const SettingsState(status: SettingsStatus.loading));

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SettingsCategoryTile), findsNothing);
    });

    testWidgets('shows retry action when settings fail to load', (
      tester,
    ) async {
      when(
        () => mockSettingsCubit.state,
      ).thenReturn(const SettingsState(status: SettingsStatus.failure));
      when(() => mockSettingsCubit.load()).thenAnswer((_) async {});

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(SettingsCategoryTile), findsNothing);

      await tester.tap(find.text('Retry'));
      verify(() => mockSettingsCubit.load()).called(1);
    });

    testWidgets('renders settings list without hero dashboard', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(SettingsCategoryTile), findsWidgets);
      expect(find.byType(SettingsSectionCard), findsWidgets);
      expect(find.byIcon(Icons.settings), findsNothing);
    });

    testWidgets('shows category tiles for core destinations', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsCategoryTile), findsAtLeastNWidgets(10));
      // General, Store, Discounts, Payments, Day close, Backup & data, About
      expect(find.byType(SettingsSectionCard), findsAtLeastNWidgets(7));
      expect(find.textContaining('General'), findsWidgets);
      expect(find.textContaining('Backup'), findsWidgets);
      expect(find.textContaining('Day close'), findsOneWidget);
      expect(find.textContaining('Backup & data'), findsOneWidget);
    });

    testWidgets('keeps AppBar title and persistent search field', (
      tester,
    ) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
      // Title stays (does not swap to search-only AppBar)
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows attention banner when backup overdue', (tester) async {
      stubSettings(
        const Settings(
          shopInfo: ShopInfo(name: 'Shop', phone: '081'),
          paymentConfig: PaymentConfig(promptpayId: '0812345678'),
          backupConfig: BackupConfig(reminderDays: 7),
        ),
      );

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsAttentionBanner), findsOneWidget);
      expect(find.text('Backup Recommended'), findsOneWidget);
    });

    testWidgets('hides attention when healthy', (tester) async {
      stubSettings(
        Settings(
          shopInfo: const ShopInfo(name: 'Shop', phone: '081'),
          paymentConfig: const PaymentConfig(promptpayId: '0812345678'),
          backupConfig: BackupConfig(
            reminderDays: 7,
            lastBackupAt: DateTime.now().toIso8601String(),
          ),
        ),
      );

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Backup Recommended'), findsNothing);
      expect(find.text('Finish shop profile'), findsNothing);
      expect(find.textContaining('setup items'), findsNothing);
    });

    testWidgets('shows shop attention when incomplete', (tester) async {
      stubSettings(
        Settings(
          shopInfo: const ShopInfo(name: 'OnlyName'),
          paymentConfig: const PaymentConfig(promptpayId: '0812345678'),
          backupConfig: BackupConfig(
            reminderDays: 7,
            lastBackupAt: DateTime.now().toIso8601String(),
          ),
        ),
      );

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Finish shop profile'), findsOneWidget);
    });

    testWidgets('does not show permanent readiness checklist', (tester) async {
      stubSettings(
        Settings(
          shopInfo: const ShopInfo(name: 'Shop', phone: '081'),
          paymentConfig: const PaymentConfig(promptpayId: '0812345678'),
          backupConfig: BackupConfig(
            reminderDays: 7,
            lastBackupAt: DateTime.now().toIso8601String(),
          ),
        ),
      );

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('READINESS'), findsNothing);
    });
  });
}
