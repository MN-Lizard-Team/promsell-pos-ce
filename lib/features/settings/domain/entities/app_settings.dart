import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/backup_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/daily_close_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/device_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/draft_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/image_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/receipt_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/ui_config.dart';

const Object _unset = Object();

@Deprecated(
  'Use Settings with typed group entities instead. '
  'AppSettings is a temporary facade for migration.',
)
class AppSettings extends Equatable {
  const AppSettings._(this._settings);

  factory AppSettings({
    Locale locale = const Locale('th'),
    ThemeMode themeMode = ThemeMode.system,
    String shopName = '',
    String address = '',
    String phone = '',
    String currency = '฿',
    String dateFormat = 'dd/MM/yyyy',
    String receiptNote = '',
    bool showShopInfoOnReceipt = true,
    bool autoPrintPrompt = true,
    double vatRate = 7.0,
    String vatMode = 'NONE',
    String receiptPreviewStyle = 'thermal',
    bool showPreSalePreview = true,
    bool showPostSalePreview = true,
    bool allowOversell = false,
    int lowStockThreshold = 5,
    bool enableItemDiscount = true,
    bool enableCartDiscount = true,
    double maxDiscountPercent = 100.0,
    double maxDiscountAmount = 0.0,
    String defaultDiscountType = 'PERCENT',
    List<DiscountPreset> discountPresets = const [
      DiscountPreset(
        id: 'default',
        name: 'Default',
        type: 'PERCENT',
        values: [5.0, 10.0, 20.0, 50.0],
      ),
    ],
    String activeDiscountPresetId = 'default',
    String promptpayId = '',
    String receiptSize = '80mm',
    int backupReminderDays = 7,
    String? lastBackupAt,
    int imageMaxWidth = 800,
    int imageQuality = 80,
    int maxDrafts = 30,
    bool cartCompactMode = false,
    bool ultraCompactMode = false,
    bool accessibilityMode = false,
    String deviceId = '',
    String devicePrefix = '',
    bool onboardingCompleted = false,
    bool dailyCloseLock = false,
    String? lastClosedDate,
    bool backupEncryptionEnabled = false,
  }) {
    return AppSettings._(
      Settings(
        shopInfo: ShopInfo(name: shopName, address: address, phone: phone),
        receiptConfig: ReceiptConfig(
          receiptSize: receiptSize,
          receiptPreviewStyle: receiptPreviewStyle,
          receiptNote: receiptNote,
          showShopInfo: showShopInfoOnReceipt,
          autoPrintPrompt: autoPrintPrompt,
          showPreSalePreview: showPreSalePreview,
          showPostSalePreview: showPostSalePreview,
        ),
        taxConfig: TaxConfig(vatRate: vatRate, vatMode: vatMode),
        discountConfig: DiscountConfig(
          enableItemDiscount: enableItemDiscount,
          enableCartDiscount: enableCartDiscount,
          maxDiscountPercent: maxDiscountPercent,
          maxDiscountAmount: maxDiscountAmount,
          defaultDiscountType: defaultDiscountType,
          discountPresets: discountPresets,
          activeDiscountPresetId: activeDiscountPresetId,
        ),
        stockConfig: StockConfig(
          allowOversell: allowOversell,
          lowStockThreshold: lowStockThreshold,
        ),
        imageConfig: ImageConfig(
          maxWidth: imageMaxWidth,
          quality: imageQuality,
        ),
        paymentConfig: PaymentConfig(
          currency: currency,
          promptpayId: promptpayId,
        ),
        deviceConfig: DeviceConfig(
          deviceId: deviceId,
          devicePrefix: devicePrefix,
        ),
        uiConfig: UiConfig(
          locale: locale.languageCode,
          themeMode: themeMode.name,
          dateFormat: dateFormat,
          cartCompactMode: cartCompactMode,
          ultraCompactMode: ultraCompactMode,
          accessibilityMode: accessibilityMode,
        ),
        dailyCloseConfig: DailyCloseConfig(
          dailyCloseLock: dailyCloseLock,
          lastClosedDate: lastClosedDate,
        ),
        backupConfig: BackupConfig(
          reminderDays: backupReminderDays,
          lastBackupAt: lastBackupAt,
          encryptionEnabled: backupEncryptionEnabled,
        ),
        draftConfig: DraftConfig(maxDrafts: maxDrafts),
        onboardingCompleted: onboardingCompleted,
      ),
    );
  }

  final Settings _settings;

  Settings toSettings() => _settings;

  factory AppSettings.fromSettings(Settings settings) =>
      AppSettings._(settings);

  Locale get locale => Locale(_settings.uiConfig.locale);
  ThemeMode get themeMode {
    try {
      return ThemeMode.values.byName(_settings.uiConfig.themeMode);
    } catch (_) {
      return ThemeMode.system;
    }
  }

  String get shopName => _settings.shopInfo.name;
  String get address => _settings.shopInfo.address;
  String get phone => _settings.shopInfo.phone;
  String get currency => _settings.paymentConfig.currency;
  String get dateFormat => _settings.uiConfig.dateFormat;
  String get receiptNote => _settings.receiptConfig.receiptNote;
  bool get showShopInfoOnReceipt => _settings.receiptConfig.showShopInfo;
  bool get autoPrintPrompt => _settings.receiptConfig.autoPrintPrompt;
  double get vatRate => _settings.taxConfig.vatRate;
  String get vatMode => _settings.taxConfig.vatMode;
  String get receiptPreviewStyle => _settings.receiptConfig.receiptPreviewStyle;
  bool get showPreSalePreview => _settings.receiptConfig.showPreSalePreview;
  bool get showPostSalePreview => _settings.receiptConfig.showPostSalePreview;
  bool get allowOversell => _settings.stockConfig.allowOversell;
  int get lowStockThreshold => _settings.stockConfig.lowStockThreshold;
  bool get enableItemDiscount => _settings.discountConfig.enableItemDiscount;
  bool get enableCartDiscount => _settings.discountConfig.enableCartDiscount;
  double get maxDiscountPercent => _settings.discountConfig.maxDiscountPercent;
  double get maxDiscountAmount => _settings.discountConfig.maxDiscountAmount;
  String get defaultDiscountType =>
      _settings.discountConfig.defaultDiscountType;
  List<DiscountPreset> get discountPresets =>
      _settings.discountConfig.discountPresets;
  String get activeDiscountPresetId =>
      _settings.discountConfig.activeDiscountPresetId;
  DiscountPreset get activeDiscountPreset =>
      _settings.discountConfig.activeDiscountPreset;
  String get promptpayId => _settings.paymentConfig.promptpayId;
  String get receiptSize => _settings.receiptConfig.receiptSize;
  int get backupReminderDays => _settings.backupConfig.reminderDays;
  String? get lastBackupAt => _settings.backupConfig.lastBackupAt;
  int get imageMaxWidth => _settings.imageConfig.maxWidth;
  int get imageQuality => _settings.imageConfig.quality;
  int get maxDrafts => _settings.draftConfig.maxDrafts;
  bool get cartCompactMode => _settings.uiConfig.cartCompactMode;
  bool get ultraCompactMode => _settings.uiConfig.ultraCompactMode;
  bool get accessibilityMode => _settings.uiConfig.accessibilityMode;
  String get deviceId => _settings.deviceConfig.deviceId;
  String get devicePrefix => _settings.deviceConfig.devicePrefix;
  bool get onboardingCompleted => _settings.onboardingCompleted;
  bool get dailyCloseLock => _settings.dailyCloseConfig.dailyCloseLock;
  String? get lastClosedDate => _settings.dailyCloseConfig.lastClosedDate;
  bool get backupEncryptionEnabled => _settings.backupConfig.encryptionEnabled;

  AppSettings copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    String? shopName,
    String? address,
    String? phone,
    String? currency,
    String? dateFormat,
    String? receiptNote,
    bool? showShopInfoOnReceipt,
    bool? autoPrintPrompt,
    double? vatRate,
    String? vatMode,
    String? receiptPreviewStyle,
    bool? showPreSalePreview,
    bool? showPostSalePreview,
    bool? allowOversell,
    int? lowStockThreshold,
    bool? enableItemDiscount,
    bool? enableCartDiscount,
    double? maxDiscountPercent,
    double? maxDiscountAmount,
    String? defaultDiscountType,
    List<DiscountPreset>? discountPresets,
    String? activeDiscountPresetId,
    String? promptpayId,
    String? receiptSize,
    int? backupReminderDays,
    Object? lastBackupAt = _unset,
    int? imageMaxWidth,
    int? imageQuality,
    int? maxDrafts,
    bool? cartCompactMode,
    bool? ultraCompactMode,
    bool? accessibilityMode,
    String? deviceId,
    String? devicePrefix,
    bool? onboardingCompleted,
    bool? dailyCloseLock,
    Object? lastClosedDate = _unset,
    bool? backupEncryptionEnabled,
  }) {
    return AppSettings._(
      _settings.copyWith(
        shopInfo: _settings.shopInfo.copyWith(
          name: shopName,
          address: address,
          phone: phone,
        ),
        receiptConfig: _settings.receiptConfig.copyWith(
          receiptSize: receiptPreviewStyle != null ? null : receiptSize,
          receiptPreviewStyle: receiptPreviewStyle,
          receiptNote: receiptNote,
          showShopInfo: showShopInfoOnReceipt,
          autoPrintPrompt: autoPrintPrompt,
          showPreSalePreview: showPreSalePreview,
          showPostSalePreview: showPostSalePreview,
        ),
        taxConfig: _settings.taxConfig.copyWith(
          vatRate: vatRate,
          vatMode: vatMode,
        ),
        discountConfig: _settings.discountConfig.copyWith(
          enableItemDiscount: enableItemDiscount,
          enableCartDiscount: enableCartDiscount,
          maxDiscountPercent: maxDiscountPercent,
          maxDiscountAmount: maxDiscountAmount,
          defaultDiscountType: defaultDiscountType,
          discountPresets: discountPresets,
          activeDiscountPresetId: activeDiscountPresetId,
        ),
        stockConfig: _settings.stockConfig.copyWith(
          allowOversell: allowOversell,
          lowStockThreshold: lowStockThreshold,
        ),
        imageConfig: _settings.imageConfig.copyWith(
          maxWidth: imageMaxWidth,
          quality: imageQuality,
        ),
        paymentConfig: _settings.paymentConfig.copyWith(
          currency: currency,
          promptpayId: promptpayId,
        ),
        deviceConfig: _settings.deviceConfig.copyWith(
          deviceId: deviceId,
          devicePrefix: devicePrefix,
        ),
        uiConfig: _settings.uiConfig.copyWith(
          locale: locale?.languageCode,
          themeMode: themeMode?.name,
          dateFormat: dateFormat,
          cartCompactMode: cartCompactMode,
          ultraCompactMode: ultraCompactMode,
          accessibilityMode: accessibilityMode,
        ),
        dailyCloseConfig: _settings.dailyCloseConfig.copyWith(
          dailyCloseLock: dailyCloseLock,
          lastClosedDate: identical(lastClosedDate, _unset)
              ? null
              : lastClosedDate as String?,
        ),
        backupConfig: _settings.backupConfig.copyWith(
          reminderDays: backupReminderDays,
          lastBackupAt: identical(lastBackupAt, _unset)
              ? null
              : lastBackupAt as String?,
          encryptionEnabled: backupEncryptionEnabled,
        ),
        draftConfig: _settings.draftConfig.copyWith(maxDrafts: maxDrafts),
        onboardingCompleted: onboardingCompleted,
      ),
    );
  }

  @override
  List<Object?> get props => [_settings];
}
