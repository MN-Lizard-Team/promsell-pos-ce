import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_list_page.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/about_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page.dart';
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
      ThemeMode.light => Icons.wb_sunny,
      ThemeMode.dark => Icons.nights_stay,
      ThemeMode.system => Icons.brightness_auto,
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

  static List<SettingsTileData> generalTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SettingsTileData(
        icon: Icons.settings_outlined,
        title: l10n.settingsGeneral,
        accent: st.softAccent,
        subtitle: '${localeLabel(context, s)} · ${themeLabel(context, s)}',
        statusChip: SettingsStatusChip(
          label: s.locale.languageCode.toUpperCase(),
          color: st.softAccent,
          st: st,
        ),
        page: const GeneralSettingsPage(),
      ),
      SettingsTileData(
        icon: Icons.image_outlined,
        title: l10n.settingsImages,
        accent: st.softAccent,
        subtitle: '${s.imageMaxWidth}px · ${s.imageQuality}%',
        statusChip: SettingsStatusChip(
          label: '${s.imageMaxWidth}px',
          color: st.softAccent,
          st: st,
        ),
        page: const ImageSettingsPage(),
      ),
      SettingsTileData(
        icon: Icons.qr_code_scanner_outlined,
        title: l10n.barcodeSettings,
        accent: st.softAccent,
        statusChip: SettingsStatusChip(
          label: s.barcodeScanEnabled
              ? l10n.settingsStatusActive
              : l10n.settingsStatusNotSet,
          color: s.barcodeScanEnabled ? AppColors.success : st.mutedText,
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
    final shopComplete = s.shopName.isNotEmpty && s.phone.isNotEmpty;
    return [
      SettingsTileData(
        icon: Icons.store_outlined,
        title: l10n.settingsShopInfo,
        accent: st.softAccent,
        subtitle: s.shopName.isNotEmpty ? s.shopName : null,
        statusChip: SettingsStatusChip(
          label: shopComplete
              ? l10n.settingsStatusComplete
              : l10n.settingsStatusIncomplete,
          color: shopComplete ? AppColors.success : AppColors.warning,
          st: st,
        ),
        page: const ShopInfoSettingsPage(),
      ),
      SettingsTileData(
        icon: Icons.point_of_sale_outlined,
        title: l10n.settingsSales,
        accent: st.softAccent,
        statusChip: SettingsStatusChip(
          label: s.currency,
          color: st.softAccent,
          st: st,
        ),
        page: const SalesSettingsPage(),
      ),
      SettingsTileData(
        icon: Icons.receipt_long_outlined,
        title: l10n.settingsReceipt,
        accent: st.softAccent,
        statusChip: SettingsStatusChip(
          label: s.receiptSize,
          color: st.softAccent,
          st: st,
        ),
        page: const ReceiptSettingsPage(),
      ),
      SettingsTileData(
        icon: Icons.inventory_2_outlined,
        title: l10n.settingsStockPolicy,
        accent: st.softAccent,
        statusChip: SettingsStatusChip(
          label: s.allowOversell ? 'ON' : '${s.lowStockThreshold}',
          color: s.allowOversell ? AppColors.error : st.softAccent,
          st: st,
        ),
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
        icon: Icons.local_offer_outlined,
        title: l10n.settingsDiscountPolicy,
        accent: st.softAccent,
        subtitle:
            '${s.discountPresets.length} ${l10n.discountPresetsTitle.toLowerCase()}',
        statusChip: SettingsStatusChip(
          label: s.activeDiscountPreset.name,
          color: st.softAccent,
          st: st,
        ),
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
        icon: Icons.qr_code_2_outlined,
        title: l10n.promptpay,
        accent: st.softAccent,
        subtitle: s.promptpayId.isNotEmpty ? s.promptpayId : null,
        statusChip: SettingsStatusChip(
          label: s.promptpayId.isNotEmpty
              ? l10n.settingsStatusActive
              : l10n.settingsStatusNotSet,
          color: s.promptpayId.isNotEmpty ? AppColors.success : st.mutedText,
          st: st,
        ),
        page: const PromptpaySettingsPage(),
      ),
    ];
  }

  static List<SettingsTileData> systemTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final backup = backupStatus(context, s);
    return [
      SettingsTileData(
        icon: Icons.lock_clock_outlined,
        title: l10n.settingsDailyCloseTitle,
        accent: st.softAccent,
        subtitle: l10n.settingsDailyCloseSubtitle,
        statusChip: SettingsStatusChip(
          label: l10n.closeDay,
          color: st.softAccent,
          st: st,
        ),
        page: const DailyCloseListPage(),
      ),
      SettingsTileData(
        icon: Icons.backup_outlined,
        title: l10n.settingsBackup,
        accent: st.softAccent,
        subtitle: s.backupReminderDays == 0
            ? l10n.backupOff
            : l10n.backupEveryNDays(s.backupReminderDays),
        statusChip: SettingsStatusChip(
          label: backup.label,
          color: backup.color,
          st: st,
        ),
        page: const BackupSettingsPage(),
      ),
      SettingsTileData(
        icon: Icons.storage_outlined,
        title: l10n.settingsDbHealthTitle,
        accent: st.softAccent,
        subtitle: l10n.settingsDbHealthSubtitle,
        statusChip: SettingsStatusChip(
          label: l10n.dbHealthTitle,
          color: st.softAccent,
          st: st,
        ),
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
        icon: Icons.info_outline,
        title: l10n.aboutApp,
        accent: st.softAccent,
        subtitle: l10n.agplShort,
        page: const AboutPage(),
      ),
    ];
  }

  static List<SettingsSectionData> allSections(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SettingsSectionData(
        title: l10n.settingsGeneral,
        tiles: generalTiles(context, s, st, l10n),
      ),
      SettingsSectionData(
        title: l10n.settingsStoreSales,
        tiles: storeTiles(context, s, st, l10n),
      ),
      SettingsSectionData(
        title: l10n.settingsDiscounts,
        tiles: discountTiles(context, s, st, l10n),
      ),
      SettingsSectionData(
        title: l10n.settingsPayments,
        tiles: paymentTiles(context, s, st, l10n),
      ),
      SettingsSectionData(
        title: l10n.settingsSystemData,
        tiles: systemTiles(context, s, st, l10n),
      ),
      SettingsSectionData(
        title: l10n.settingsAbout,
        tiles: aboutTiles(context, s, st, l10n),
      ),
    ];
  }
}
