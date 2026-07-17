import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/backup_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/barcode_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_tile_builders.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_tile_data.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;
  const st = SettingsThemeExtension.light;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  SettingsTileData? tileNamed(List<SettingsTileData> tiles, String title) {
    for (final t in tiles) {
      if (t.title == title) return t;
    }
    return null;
  }

  Widget buildHost(Widget Function(BuildContext context) builder) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: builder),
    );
  }

  group('SettingsTileBuilders chip policy', () {
    testWidgets('shop chip only when incomplete (name+phone)', (tester) async {
      await tester.pumpWidget(
        buildHost((context) {
          final incomplete = SettingsTileBuilders.storeTiles(
            context,
            const Settings(shopInfo: ShopInfo(name: 'OnlyName')),
            st,
            l10n,
          );
          final shop = tileNamed(incomplete, l10n.settingsShopInfo)!;
          expect(shop.statusChip, isNotNull);

          final complete = SettingsTileBuilders.storeTiles(
            context,
            const Settings(
              shopInfo: ShopInfo(name: 'Shop', phone: '0812345678'),
            ),
            st,
            l10n,
          );
          expect(
            tileNamed(complete, l10n.settingsShopInfo)!.statusChip,
            isNull,
          );
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('promptpay chip only when empty', (tester) async {
      await tester.pumpWidget(
        buildHost((context) {
          final empty = SettingsTileBuilders.paymentTiles(
            context,
            const Settings(),
            st,
            l10n,
          );
          expect(tileNamed(empty, l10n.promptpay)!.statusChip, isNotNull);

          final set = SettingsTileBuilders.paymentTiles(
            context,
            const Settings(
              paymentConfig: PaymentConfig(promptpayId: '0812345678'),
            ),
            st,
            l10n,
          );
          expect(tileNamed(set, l10n.promptpay)!.statusChip, isNull);
          expect(
            tileNamed(set, l10n.promptpay)!.subtitle,
            SettingsTileBuilders.maskSensitiveId('0812345678'),
          );
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('backup chip only on overdue/warning', (tester) async {
      await tester.pumpWidget(
        buildHost((context) {
          final overdue = SettingsTileBuilders.backupDataTiles(
            context,
            const Settings(backupConfig: BackupConfig(reminderDays: 7)),
            st,
            l10n,
          );
          expect(
            tileNamed(overdue, l10n.settingsBackup)!.statusChip,
            isNotNull,
          );

          final recent = SettingsTileBuilders.backupDataTiles(
            context,
            Settings(
              backupConfig: BackupConfig(
                reminderDays: 7,
                lastBackupAt: DateTime.now().toIso8601String(),
              ),
            ),
            st,
            l10n,
          );
          expect(tileNamed(recent, l10n.settingsBackup)!.statusChip, isNull);

          final off = SettingsTileBuilders.backupDataTiles(
            context,
            const Settings(backupConfig: BackupConfig(reminderDays: 0)),
            st,
            l10n,
          );
          expect(tileNamed(off, l10n.settingsBackup)!.statusChip, isNull);
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('decorative chips removed from general/sales/daily/db', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildHost((context) {
          final general = SettingsTileBuilders.generalTiles(
            context,
            const Settings(),
            st,
            l10n,
          );
          expect(tileNamed(general, l10n.settingsGeneral)!.statusChip, isNull);
          expect(tileNamed(general, l10n.settingsImages)!.statusChip, isNull);
          expect(tileNamed(general, l10n.barcodeSettings)!.statusChip, isNull);

          final disabledBarcode = SettingsTileBuilders.generalTiles(
            context,
            const Settings(barcodeConfig: BarcodeConfig(scanEnabled: false)),
            st,
            l10n,
          );
          expect(
            tileNamed(disabledBarcode, l10n.barcodeSettings)!.statusChip,
            isNotNull,
          );

          final store = SettingsTileBuilders.storeTiles(
            context,
            const Settings(
              shopInfo: ShopInfo(name: 'S', phone: '1'),
            ),
            st,
            l10n,
          );
          expect(tileNamed(store, l10n.settingsSales)!.statusChip, isNull);
          expect(tileNamed(store, l10n.settingsReceipt)!.subtitle, isNotNull);
          expect(tileNamed(store, l10n.settingsReceipt)!.statusChip, isNull);

          final dayClose = SettingsTileBuilders.dayCloseTiles(
            context,
            const Settings(),
            st,
            l10n,
          );
          expect(
            tileNamed(dayClose, l10n.settingsDailyCloseTitle)!.statusChip,
            isNull,
          );

          final backupData = SettingsTileBuilders.backupDataTiles(
            context,
            Settings(
              backupConfig: BackupConfig(
                reminderDays: 7,
                lastBackupAt: DateTime.now().toIso8601String(),
              ),
            ),
            st,
            l10n,
          );
          expect(
            tileNamed(backupData, l10n.settingsDbHealthTitle)!.statusChip,
            isNull,
          );
          return const SizedBox.shrink();
        }),
      );
    });

    testWidgets('stock chip only when oversell on', (tester) async {
      await tester.pumpWidget(
        buildHost((context) {
          final off = SettingsTileBuilders.storeTiles(
            context,
            const Settings(),
            st,
            l10n,
          );
          expect(tileNamed(off, l10n.settingsStockPolicy)!.statusChip, isNull);

          final on = SettingsTileBuilders.storeTiles(
            context,
            const Settings(stockConfig: StockConfig(allowOversell: true)),
            st,
            l10n,
          );
          expect(
            tileNamed(on, l10n.settingsStockPolicy)!.statusChip,
            isNotNull,
          );
          return const SizedBox.shrink();
        }),
      );
    });
  });

  group('SettingsTileBuilders IA', () {
    testWidgets('day close separate from backup & data', (tester) async {
      await tester.pumpWidget(
        buildHost((context) {
          final sections = SettingsTileBuilders.allSections(
            context,
            const Settings(),
            st,
            l10n,
          );
          final titles = sections.map((s) => s.title).toList();
          expect(titles, contains(l10n.settingsDayClose));
          expect(titles, contains(l10n.settingsBackupData));
          expect(titles, isNot(contains(l10n.settingsSystemData)));

          final dayIdx = titles.indexOf(l10n.settingsDayClose);
          final backupIdx = titles.indexOf(l10n.settingsBackupData);
          final aboutIdx = titles.indexOf(l10n.settingsAbout);
          expect(dayIdx, lessThan(backupIdx));
          expect(backupIdx, lessThan(aboutIdx));

          final daySec = sections.firstWhere(
            (s) => s.title == l10n.settingsDayClose,
          );
          expect(daySec.tiles.length, 1);
          expect(daySec.tiles.single.title, l10n.settingsDailyCloseTitle);

          final backupSec = sections.firstWhere(
            (s) => s.title == l10n.settingsBackupData,
          );
          expect(
            backupSec.tiles.map((t) => t.title),
            containsAll([l10n.settingsBackup, l10n.settingsDbHealthTitle]),
          );
          return const SizedBox.shrink();
        }),
      );
    });
  });
}
