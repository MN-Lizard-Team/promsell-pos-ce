import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/backup_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/app_lock_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/shop_info_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_root_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_search_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_header.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/settings_action_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  final sl = GetIt.instance;
  late MockSettingsCubit mockSettingsCubit;
  late MockAppLockService mockLock;

  void stubSettings(Settings settings) {
    when(() => mockSettingsCubit.state).thenReturn(
      SettingsState(status: SettingsStatus.loaded, settings: settings),
    );
  }

  /// Registers a store PIN mock so the readiness checklist treats the PIN
  /// as configured (4/4-capable). Tests that need it call this.
  void registerConfiguredPin() {
    when(() => mockLock.isEnabled()).thenAnswer((_) async => true);
    when(() => mockLock.hasPin()).thenAnswer((_) async => true);
    if (!sl.isRegistered<AppLockService>()) {
      sl.registerSingleton<AppLockService>(mockLock);
    }
  }

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    mockLock = MockAppLockService();
    stubSettings(const Settings());
    when(() => mockSettingsCubit.update(any())).thenAnswer((_) async {});
    if (sl.isRegistered<AppLockService>()) {
      sl.unregister<AppLockService>();
    }
  });

  tearDown(() {
    if (sl.isRegistered<AppLockService>()) {
      sl.unregister<AppLockService>();
    }
  });

  setUpAll(() {
    registerFallbackValue(const Settings());
  });

  group('SettingsPage Command Dashboard', () {
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
      expect(find.byType(SettingsActionCard), findsNothing);
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
      expect(find.byType(SettingsActionCard), findsNothing);

      await tester.tap(find.text('Retry'));
      verify(() => mockSettingsCubit.load()).called(1);
    });

    testWidgets('renders hero dashboard with action card grid', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(ListView), findsWidgets);
      expect(find.byType(SettingsActionCard), findsWidgets);
      expect(find.byType(SettingsSectionHeader), findsWidgets);
      // Hero card shop name placeholder when empty.
      expect(find.textContaining('Shop'), findsWidgets);
    });

    testWidgets('shows action cards for core destinations', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsActionCard), findsAtLeastNWidgets(10));
      // Colored pill headers for each section.
      expect(find.byType(SettingsSectionHeader), findsAtLeastNWidgets(7));
      expect(find.textContaining('General'), findsWidgets);
      expect(find.textContaining('Backup'), findsWidgets);
      expect(find.textContaining('Day close'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Backup & data'), findsAtLeastNWidgets(1));
    });

    testWidgets('search strip opens the dedicated search page', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      // Root keeps a tappable strip (no live field) and the title AppBar.
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(AppBar), findsOneWidget);

      await tester.tap(find.textContaining('Search settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsSearchPage), findsOneWidget);
      // The search page owns the live field.
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows hero readiness ring with merchant checks', (
      tester,
    ) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      // Readiness ring shows "0/4" when nothing is configured.
      expect(find.text('0/4'), findsOneWidget);
      // Readiness dot labels are visible.
      expect(find.text('General'), findsWidgets);
    });

    testWidgets('shows attention strip when backup is overdue', (tester) async {
      stubSettings(
        const Settings(
          shopInfo: ShopInfo(name: 'Shop', phone: '081'),
          paymentConfig: PaymentConfig(promptpayId: '0812345678'),
          backupConfig: BackupConfig(reminderDays: 7),
        ),
      );
      registerConfiguredPin();

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      // Backup overdue → error-grade chip; PIN configured so it stays quiet.
      expect(find.byType(ActionChip), findsOneWidget);
    });

    testWidgets('hides attention strip when fully ready', (tester) async {
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
      registerConfiguredPin();

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(ActionChip), findsNothing);
    });

    testWidgets('lists pending readiness items in the hero status line', (
      tester,
    ) async {
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

      // 3/4 — the store PIN is still missing and shows up in the summary.
      expect(find.text('3/4'), findsOneWidget);
      expect(find.textContaining('Store PIN lock'), findsWidgets);
    });

    testWidgets('shows shop attention chip when incomplete', (tester) async {
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
      registerConfiguredPin();

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(ActionChip), findsOneWidget);
      expect(find.text('Shop Info'), findsWidgets);
    });

    testWidgets('search filters action cards by query', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      // Open the dedicated search page, then type a query that matches only
      // one section.
      await tester.tap(find.textContaining('Search settings'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'backup');
      await tester.pumpAndSettle();

      // Only backup-related action cards remain.
      expect(find.byType(SettingsActionCard), findsAtLeastNWidgets(1));
      // Hero card is not part of the search page.
      expect(find.text('0/4'), findsNothing);
    });

    testWidgets('search shows empty state when no match', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Search settings'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzz_no_match');
      await tester.pumpAndSettle();

      expect(find.byType(SettingsActionCard), findsNothing);
      expect(find.byIcon(TablerIcons.searchOff), findsOneWidget);
    });

    testWidgets('hero card shows shop name when configured', (tester) async {
      stubSettings(
        const Settings(
          shopInfo: ShopInfo(name: 'My Test Shop', phone: '081'),
        ),
      );

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('My Test Shop'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders NavigationRail on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
    });

    testWidgets('does not render NavigationRail on phone width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(380, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsNothing);
    });
  });

  group('SettingsPage hardening', () {
    Future<void> pumpAtSize(
      WidgetTester tester,
      Size size, {
      Settings? settings,
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      if (settings != null) stubSettings(settings);
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders without overflow at 320dp with defaults', (
      tester,
    ) async {
      await pumpAtSize(tester, const Size(320, 800));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at 320dp with long Thai shop name', (
      tester,
    ) async {
      await pumpAtSize(
        tester,
        const Size(320, 800),
        settings: const Settings(
          shopInfo: ShopInfo(
            name: 'ร้านถาดทองข้าวแกงปักษ์ใต้หอมยี่ห้อเทพทิพย์',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('hero tap opens shop info page', (tester) async {
      registerConfiguredPin();
      await pumpAtSize(tester, const Size(1200, 2400));
      // The hero card is the first widget whose semantics carry the
      // readiness counter; tapping anywhere on it routes to shop info.
      await tester.tap(find.text('1/4'));
      await tester.pumpAndSettle();

      expect(find.byType(ShopInfoSettingsPage), findsOneWidget);
    });

    testWidgets('hero tap deep-links to the first pending page', (
      tester,
    ) async {
      stubSettings(
        const Settings(
          shopInfo: ShopInfo(name: 'Shop', phone: '081'),
          paymentConfig: PaymentConfig(promptpayId: '0812345678'),
        ),
      );
      registerConfiguredPin();
      await pumpAtSize(tester, const Size(1200, 2400));

      // Shop info + PromptPay + PIN done → first pending is Backup (3/4),
      // so the hero must route there instead of always to Shop Info.
      expect(find.text('3/4'), findsOneWidget);
      await tester.tap(find.text('3/4'));
      await tester.pumpAndSettle();

      expect(find.byType(BackupSettingsPage), findsOneWidget);
    });

    testWidgets('oversell ON badge uses warning tone, not error red', (
      tester,
    ) async {
      stubSettings(
        const Settings(stockConfig: StockConfig(allowOversell: true)),
      );
      await pumpAtSize(tester, const Size(1200, 2400));

      final context = tester.element(find.text('On'));
      final st = context.settingsTheme;
      final style = tester.widget<Text>(find.text('On')).style;

      expect(style?.color, st.statusWarningText);
      expect(style?.color, isNot(st.statusErrorText));
    });

    testWidgets('readiness-critical tiles render emphasized teal borders', (
      tester,
    ) async {
      await pumpAtSize(tester, const Size(1200, 2400));

      // Emphasized cards reuse the selected-product language: a 1.5px teal
      // border instead of the hairline outlineVariant one.
      final cards = tester.widgetList<Material>(
        find.byWidgetPredicate(
          (w) =>
              w is Material &&
              w.shape is RoundedRectangleBorder &&
              (w.shape as RoundedRectangleBorder).side.width == 1.5,
        ),
      );

      // Shop info, PromptPay, Backup.
      expect(cards.length, 3);
      for (final card in cards) {
        final shape = card.shape! as RoundedRectangleBorder;
        expect(
          shape.side.color,
          Theme.of(
            tester.element(find.byType(Scaffold).first),
          ).colorScheme.primary,
        );
      }
    });

    testWidgets('attention chip deep-links to backup page', (tester) async {
      stubSettings(
        const Settings(
          shopInfo: ShopInfo(name: 'Shop', phone: '081'),
          paymentConfig: PaymentConfig(promptpayId: '0812345678'),
          backupConfig: BackupConfig(reminderDays: 7),
        ),
      );
      registerConfiguredPin();
      await pumpAtSize(tester, const Size(1200, 2400));

      await tester.tap(find.byType(ActionChip).first);
      await tester.pumpAndSettle();

      expect(find.byType(BackupSettingsPage), findsOneWidget);
    });

    testWidgets('readiness count reflects configured store PIN', (
      tester,
    ) async {
      registerConfiguredPin();
      await pumpAtSize(tester, const Size(1200, 2400));

      // Default settings: only the PIN check can pass in tests.
      expect(find.text('1/4'), findsOneWidget);
      expect(find.byType(AppLockSettingsPage), findsNothing);
    });
  });
}
