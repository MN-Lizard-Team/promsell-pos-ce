import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/backup_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/promptpay_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/shop_info_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_attention_banner.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('SettingsAttentionIssue.resolve', () {
    test('empty when healthy', () {
      final issues = SettingsAttentionIssue.resolve(
        Settings(
          shopInfo: const ShopInfo(name: 'Shop', phone: '081'),
          paymentConfig: const PaymentConfig(promptpayId: '0812345678'),
          backupConfig: BackupConfig(
            reminderDays: 7,
            lastBackupAt: DateTime.now().toIso8601String(),
          ),
        ),
        l10n,
      );
      expect(issues, isEmpty);
    });

    test('priority backup > shop > promptpay', () {
      final issues = SettingsAttentionIssue.resolve(
        const Settings(
          shopInfo: ShopInfo(name: ''),
          backupConfig: BackupConfig(reminderDays: 7),
        ),
        l10n,
      );
      expect(issues.length, 3);
      expect(issues.first.kind, SettingsAttentionKind.backupOverdue);
      expect(issues[1].kind, SettingsAttentionKind.shopIncomplete);
      expect(issues[2].kind, SettingsAttentionKind.promptpayEmpty);
      expect(issues.first.page, isA<BackupSettingsPage>());
    });

    test('shop incomplete when name only', () {
      final issues = SettingsAttentionIssue.resolve(
        Settings(
          shopInfo: const ShopInfo(name: 'OnlyName'),
          paymentConfig: const PaymentConfig(promptpayId: '0812345678'),
          backupConfig: BackupConfig(
            reminderDays: 7,
            lastBackupAt: DateTime.now().toIso8601String(),
          ),
        ),
        l10n,
      );
      expect(issues.length, 1);
      expect(issues.single.kind, SettingsAttentionKind.shopIncomplete);
      expect(issues.single.page, isA<ShopInfoSettingsPage>());
    });

    test('promptpay only when empty', () {
      final issues = SettingsAttentionIssue.resolve(
        const Settings(
          shopInfo: ShopInfo(name: 'Shop', phone: '081'),
          backupConfig: BackupConfig(reminderDays: 0),
        ),
        l10n,
      );
      expect(issues.length, 1);
      expect(issues.single.kind, SettingsAttentionKind.promptpayEmpty);
      expect(issues.single.page, isA<PromptpaySettingsPage>());
    });
  });

  group('SettingsAttentionBanner', () {
    testWidgets('hides when healthy', (tester) async {
      final settings = Settings(
        shopInfo: const ShopInfo(name: 'Shop', phone: '081'),
        paymentConfig: const PaymentConfig(promptpayId: '0812345678'),
        backupConfig: BackupConfig(
          reminderDays: 7,
          lastBackupAt: DateTime.now().toIso8601String(),
        ),
      );

      await tester.pumpApp(
        SettingsAttentionBanner(settings: settings, onOpen: (_) {}),
      );

      expect(find.text('Backup Recommended'), findsNothing);
      expect(find.textContaining('setup items'), findsNothing);
      expect(find.text('Finish shop profile'), findsNothing);
    });

    testWidgets('shows backup copy when only overdue', (tester) async {
      final settings = const Settings(
        shopInfo: ShopInfo(name: 'Shop', phone: '081'),
        paymentConfig: PaymentConfig(promptpayId: '0812345678'),
        backupConfig: BackupConfig(reminderDays: 7),
      );

      await tester.pumpApp(
        SettingsAttentionBanner(settings: settings, onOpen: (_) {}),
      );

      expect(find.text('Backup Recommended'), findsOneWidget);
    });

    testWidgets('shows multi-issue summary and opens primary page', (
      tester,
    ) async {
      Widget? opened;
      final settings = const Settings(
        shopInfo: ShopInfo(name: ''),
        backupConfig: BackupConfig(reminderDays: 7),
      );

      await tester.pumpApp(
        SettingsAttentionBanner(
          settings: settings,
          onOpen: (page) => opened = page,
        ),
      );

      expect(find.textContaining('setup items need attention'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);

      await tester.tap(find.textContaining('setup items need attention'));
      expect(opened, isA<BackupSettingsPage>());
    });

    testWidgets('shop-only opens shop page', (tester) async {
      Widget? opened;
      final settings = Settings(
        shopInfo: const ShopInfo(name: 'X'),
        paymentConfig: const PaymentConfig(promptpayId: '0812345678'),
        backupConfig: BackupConfig(
          reminderDays: 7,
          lastBackupAt: DateTime.now().toIso8601String(),
        ),
      );

      await tester.pumpApp(
        SettingsAttentionBanner(
          settings: settings,
          onOpen: (page) => opened = page,
        ),
      );

      await tester.tap(find.text('Finish shop profile'));
      expect(opened, isA<ShopInfoSettingsPage>());
    });
  });
}
