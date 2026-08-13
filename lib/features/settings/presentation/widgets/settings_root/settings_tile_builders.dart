import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_list_page.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/pages/table_management_page.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/about_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/app_lock_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/barcode_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/db_health_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/discount_policy_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/general_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/image_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/promptpay_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/receipt_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/sales_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/shop_info_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/stock_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_tile_data.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_status_chip.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class SettingsTileBuilders {
  SettingsTileBuilders._();

  /// Mask phone / citizen-style IDs for list display (show last 4).
  static String maskSensitiveId(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 4) return '••••';
    return '••••${digits.substring(digits.length - 4)}';
  }

  static String localeLabel(BuildContext context, Settings s) {
    final l10n = context.l10n;
    switch (s.locale.languageCode) {
      case 'th':
        return l10n.langThai;
      case 'en':
        return l10n.langEnglish;
      default:
        return s.locale.languageCode;
    }
  }

  static String themeLabel(BuildContext context, Settings s) {
    final l10n = context.l10n;
    switch (s.themeMode) {
      case ThemeMode.light:
        return l10n.settingsThemeLight;
      case ThemeMode.dark:
        return l10n.settingsThemeDark;
      default:
        return l10n.settingsThemeSystem;
    }
  }

  static IconData themeIcon(Settings s) {
    return switch (s.themeMode) {
      ThemeMode.light => TablerIcons.sun,
      ThemeMode.dark => TablerIcons.moon,
      ThemeMode.system => TablerIcons.brightnessAuto,
    };
  }

  static Color themeColor(Settings s) {
    return switch (s.themeMode) {
      ThemeMode.light => AppColors.warning,
      ThemeMode.dark => AppColors.info,
      ThemeMode.system => AppColors.primary,
    };
  }

  static ({String label, Color color}) backupStatus(
    BuildContext context,
    Settings s,
  ) {
    final l10n = context.l10n;
    if (s.backupReminderDays == 0) {
      return (label: l10n.backupOff, color: context.settingsTheme.mutedText);
    }
    if (s.lastBackupAt == null) {
      return (label: l10n.backupStatusOverdue, color: AppColors.error);
    }
    final last = DateTime.tryParse(s.lastBackupAt!);
    if (last == null) {
      return (label: l10n.backupStatusOverdue, color: AppColors.error);
    }
    final days = DateTime.now().difference(last).inDays;
    if (days <= s.backupReminderDays) {
      return (label: l10n.backupStatusSafe, color: AppColors.success);
    }
    if (days <= s.backupReminderDays * 2) {
      return (label: l10n.backupStatusWarning, color: AppColors.warning);
    }
    return (label: l10n.backupStatusOverdue, color: AppColors.error);
  }

  /// Risk chips only: overdue / warning. Safe and Off → null (subtitle carries info).
  static Widget? backupRiskChip(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
  ) {
    if (s.backupReminderDays == 0) return null;
    final backup = backupStatus(context, s);
    final l10n = context.l10n;
    final isRisk =
        backup.label == l10n.backupStatusOverdue ||
        backup.label == l10n.backupStatusWarning;
    if (!isRisk) return null;
    return SettingsStatusChip(label: backup.label, color: backup.color, st: st);
  }

  static List<SettingsTileData> generalTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SettingsTileData(
        icon: TablerIcons.settings,
        title: l10n.settingsGeneral,
        accent: st.softAccent,
        subtitle: '${localeLabel(context, s)} · ${themeLabel(context, s)}',
        page: const GeneralSettingsPage(),
      ),
      SettingsTileData(
        icon: TablerIcons.photo,
        title: l10n.settingsImages,
        accent: st.softAccent,
        subtitle: '${s.imageMaxWidth}px · ${s.imageQuality}%',
        page: const ImageSettingsPage(),
      ),
      SettingsTileData(
        icon: TablerIcons.scan,
        title: l10n.barcodeSettings,
        accent: st.softAccent,
        statusChip: s.barcodeScanEnabled
            ? null
            : SettingsStatusChip(
                label: l10n.settingsStatusNotSet,
                color: st.mutedText,
                st: st,
              ),
        page: const BarcodeSettingsPage(),
      ),
    ];
  }

  static List<SettingsTileData> storeTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final shopComplete = s.shopInfo.isComplete;
    return [
      SettingsTileData(
        icon: TablerIcons.buildingStore,
        title: l10n.settingsShopInfo,
        accent: st.softAccent,
        subtitle: s.shopName.isNotEmpty ? s.shopName : null,
        statusChip: shopComplete
            ? null
            : SettingsStatusChip(
                label: l10n.settingsStatusIncomplete,
                color: AppColors.warning,
                st: st,
              ),
        page: const ShopInfoSettingsPage(),
      ),
      SettingsTileData(
        icon: TablerIcons.deviceMobile,
        title: l10n.settingsSales,
        accent: st.softAccent,
        subtitle: '${s.currency} · ${s.vatMode}',
        searchKeywords: const [
          'vat',
          'tax',
          'ภาษี',
          'vat rate',
          'service charge',
          'currency',
        ],
        page: const SalesSettingsPage(),
      ),
      SettingsTileData(
        icon: TablerIcons.receipt2,
        title: l10n.settingsReceipt,
        accent: st.softAccent,
        subtitle: s.receiptSize,
        searchKeywords: const [
          'receipt',
          'preview',
          'ใบเสร็จ',
          'thermal',
          'a4',
          '80mm',
          'paper',
        ],
        page: const ReceiptSettingsPage(),
      ),
      SettingsTileData(
        icon: TablerIcons.box,
        title: l10n.settingsStockPolicy,
        accent: st.softAccent,
        subtitle: '${s.lowStockThreshold}',
        statusChip: s.allowOversell
            ? SettingsStatusChip(
                label: l10n.settingsOn,
                color: AppColors.error,
                st: st,
              )
            : null,
        page: const StockSettingsPage(),
      ),
    ];
  }

  static List<SettingsTileData> discountTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SettingsTileData(
        icon: TablerIcons.tag,
        title: l10n.settingsDiscountPolicy,
        accent: st.softAccent,
        subtitle:
            '${s.discountPresets.length} ${l10n.discountPresetsTitle.toLowerCase()}',
        page: const DiscountPolicySettingsPage(),
      ),
    ];
  }

  static List<SettingsTileData> paymentTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SettingsTileData(
        icon: TablerIcons.qrcode,
        title: l10n.promptpay,
        accent: st.softAccent,
        subtitle: s.promptpayId.isNotEmpty
            ? maskSensitiveId(s.promptpayId)
            : null,
        statusChip: s.promptpayId.isNotEmpty
            ? null
            : SettingsStatusChip(
                label: l10n.settingsStatusNotSet,
                color: st.mutedText,
                st: st,
              ),
        page: const PromptpaySettingsPage(),
      ),
    ];
  }

  /// End-of-day ops (not mixed into backup/DB).
  static List<SettingsTileData> dayCloseTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SettingsTileData(
        icon: TablerIcons.lock,
        title: l10n.settingsDailyCloseTitle,
        accent: st.softAccent,
        subtitle: l10n.settingsDailyCloseSubtitle,
        page: const DailyCloseListPage(),
      ),
    ];
  }

  static List<SettingsTileData> backupDataTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SettingsTileData(
        icon: TablerIcons.databaseExport,
        title: l10n.settingsBackup,
        accent: st.softAccent,
        subtitle: s.backupReminderDays == 0
            ? l10n.backupOff
            : l10n.backupEveryNDays(s.backupReminderDays),
        statusChip: backupRiskChip(context, s, st),
        page: const BackupSettingsPage(),
      ),
      SettingsTileData(
        icon: TablerIcons.pin,
        title: l10n.appLockTitle,
        accent: st.softAccent,
        subtitle: l10n.appLockSubtitle,
        page: const AppLockSettingsPage(),
      ),
      SettingsTileData(
        icon: TablerIcons.database,
        title: l10n.settingsDbHealthTitle,
        accent: st.softAccent,
        subtitle: l10n.settingsDbHealthSubtitle,
        page: const DbHealthPage(),
      ),
    ];
  }

  static List<SettingsTileData> aboutTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SettingsTileData(
        icon: TablerIcons.infoCircle,
        title: l10n.aboutApp,
        accent: st.softAccent,
        subtitle: l10n.agplShort,
        page: const AboutPage(),
      ),
    ];
  }

  static List<SettingsTileData> restaurantTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SettingsTileData(
        icon: TablerIcons.toolsKitchen2,
        title: l10n.tableManagement,
        accent: st.softAccent,
        subtitle: l10n.tableManagementSubtitle,
        page: const TableManagementPage(),
      ),
    ];
  }

  /// Clean Index IA:
  /// General → Store & Sales → Restaurant? → Discounts → Payments
  /// → Day close → Backup & data → About
  static List<SettingsSectionData> allSections(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final sections = <SettingsSectionData>[
      SettingsSectionData(
        title: l10n.settingsGeneral,
        tiles: generalTiles(context, s, st, l10n),
      ),
      SettingsSectionData(
        title: l10n.settingsStoreSales,
        tiles: storeTiles(context, s, st, l10n),
      ),
    ];
    if (s.isRestaurantMode) {
      sections.add(
        SettingsSectionData(
          title: l10n.restaurantSettings,
          tiles: restaurantTiles(context, s, st, l10n),
        ),
      );
    }
    sections.addAll([
      SettingsSectionData(
        title: l10n.settingsDiscounts,
        tiles: discountTiles(context, s, st, l10n),
      ),
      SettingsSectionData(
        title: l10n.settingsPayments,
        tiles: paymentTiles(context, s, st, l10n),
      ),
      SettingsSectionData(
        title: l10n.settingsDayClose,
        tiles: dayCloseTiles(context, s, st, l10n),
      ),
      SettingsSectionData(
        title: l10n.settingsBackupData,
        tiles: backupDataTiles(context, s, st, l10n),
      ),
      SettingsSectionData(
        title: l10n.settingsAbout,
        tiles: aboutTiles(context, s, st, l10n),
      ),
    ]);
    return sections;
  }
}
