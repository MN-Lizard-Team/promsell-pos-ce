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
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/barcode_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/ui_config.dart';

const Object _unset = Object();

class Settings extends Equatable {
  const Settings({
    this.shopInfo = const ShopInfo(),
    this.receiptConfig = const ReceiptConfig(),
    this.taxConfig = const TaxConfig(),
    this.discountConfig = const DiscountConfig(),
    this.stockConfig = const StockConfig(),
    this.imageConfig = const ImageConfig(),
    this.paymentConfig = const PaymentConfig(),
    this.deviceConfig = const DeviceConfig(),
    this.uiConfig = const UiConfig(),
    this.dailyCloseConfig = const DailyCloseConfig(),
    this.backupConfig = const BackupConfig(),
    this.draftConfig = const DraftConfig(),
    this.barcodeConfig = const BarcodeConfig(),
    this.onboardingCompleted = false,
  });

  final ShopInfo shopInfo;
  final ReceiptConfig receiptConfig;
  final TaxConfig taxConfig;
  final DiscountConfig discountConfig;
  final StockConfig stockConfig;
  final ImageConfig imageConfig;
  final PaymentConfig paymentConfig;
  final DeviceConfig deviceConfig;
  final UiConfig uiConfig;
  final DailyCloseConfig dailyCloseConfig;
  final BackupConfig backupConfig;
  final DraftConfig draftConfig;
  final BarcodeConfig barcodeConfig;
  final bool onboardingCompleted;

  // ─── Flat convenience getters (mirror former Settings facade) ───────────

  Locale get locale => Locale(uiConfig.locale);
  ThemeMode get themeMode {
    try {
      return ThemeMode.values.byName(uiConfig.themeMode);
    } catch (_) {
      return ThemeMode.system;
    }
  }

  String get shopName => shopInfo.name;
  String get address => shopInfo.address;
  String get phone => shopInfo.phone;
  String get currency => paymentConfig.currency;
  String get dateFormat => uiConfig.dateFormat;
  String get receiptNote => receiptConfig.receiptNote;
  bool get showShopInfoOnReceipt => receiptConfig.showShopInfo;
  bool get autoPrintPrompt => receiptConfig.autoPrintPrompt;
  double get vatRate => taxConfig.vatRate;
  String get vatMode => taxConfig.vatMode;
  String get receiptPreviewStyle => receiptConfig.receiptPreviewStyle;
  bool get showPreSalePreview => receiptConfig.showPreSalePreview;
  bool get showPostSalePreview => receiptConfig.showPostSalePreview;
  bool get allowOversell => stockConfig.allowOversell;
  int get lowStockThreshold => stockConfig.lowStockThreshold;
  bool get enableItemDiscount => discountConfig.enableItemDiscount;
  bool get enableCartDiscount => discountConfig.enableCartDiscount;
  double get maxDiscountPercent => discountConfig.maxDiscountPercent;
  double get maxDiscountAmount => discountConfig.maxDiscountAmount;
  String get defaultDiscountType => discountConfig.defaultDiscountType;
  List<DiscountPreset> get discountPresets => discountConfig.discountPresets;
  String get activeDiscountPresetId => discountConfig.activeDiscountPresetId;
  DiscountPreset get activeDiscountPreset =>
      discountConfig.activeDiscountPreset;
  String get promptpayId => paymentConfig.promptpayId;
  String get billerId => paymentConfig.billerId;
  int get promptPayTimeout => paymentConfig.promptPayTimeout;
  bool get promptPaySoundEnabled => paymentConfig.promptPaySoundEnabled;
  String get defaultQrType => paymentConfig.defaultQrType;
  bool get autoConfirmAfterSlip => paymentConfig.autoConfirmAfterSlip;
  String get qrOverlayIcon => paymentConfig.qrOverlayIcon;
  String get receiptSize => receiptConfig.receiptSize;
  int get backupReminderDays => backupConfig.reminderDays;
  String? get lastBackupAt => backupConfig.lastBackupAt;
  int get imageMaxWidth => imageConfig.maxWidth;
  int get imageQuality => imageConfig.quality;
  int get maxDrafts => draftConfig.maxDrafts;
  bool get cartCompactMode => uiConfig.cartCompactMode;
  bool get ultraCompactMode => uiConfig.ultraCompactMode;
  bool get accessibilityMode => uiConfig.accessibilityMode;
  String get deviceId => deviceConfig.deviceId;
  String get devicePrefix => deviceConfig.devicePrefix;
  bool get dailyCloseLock => dailyCloseConfig.dailyCloseLock;
  String? get lastClosedDate => dailyCloseConfig.lastClosedDate;
  bool get backupEncryptionEnabled => backupConfig.encryptionEnabled;
  bool get barcodeScanEnabled => barcodeConfig.scanEnabled;
  String get barcodeAutoGeneratePrefix => barcodeConfig.autoGeneratePrefix;
  bool get barcodeBeepOnScan => barcodeConfig.beepOnScan;
  List<String> get barcodeEnabledFormats => barcodeConfig.enabledFormats;
  int get barcodeAutoOpenManualDelay => barcodeConfig.autoOpenManualDelay;
  int get barcodeLastCounter => barcodeConfig.lastCounter;
  bool get barcodeContinuousScan => barcodeConfig.continuousScan;

  // ─── Sub-entity-level copyWith ─────────────────────────────────────────────

  Settings copyWithEntities({
    ShopInfo? shopInfo,
    ReceiptConfig? receiptConfig,
    TaxConfig? taxConfig,
    DiscountConfig? discountConfig,
    StockConfig? stockConfig,
    ImageConfig? imageConfig,
    PaymentConfig? paymentConfig,
    DeviceConfig? deviceConfig,
    UiConfig? uiConfig,
    DailyCloseConfig? dailyCloseConfig,
    BackupConfig? backupConfig,
    DraftConfig? draftConfig,
    BarcodeConfig? barcodeConfig,
    bool? onboardingCompleted,
  }) {
    return Settings(
      shopInfo: shopInfo ?? this.shopInfo,
      receiptConfig: receiptConfig ?? this.receiptConfig,
      taxConfig: taxConfig ?? this.taxConfig,
      discountConfig: discountConfig ?? this.discountConfig,
      stockConfig: stockConfig ?? this.stockConfig,
      imageConfig: imageConfig ?? this.imageConfig,
      paymentConfig: paymentConfig ?? this.paymentConfig,
      deviceConfig: deviceConfig ?? this.deviceConfig,
      uiConfig: uiConfig ?? this.uiConfig,
      dailyCloseConfig: dailyCloseConfig ?? this.dailyCloseConfig,
      backupConfig: backupConfig ?? this.backupConfig,
      draftConfig: draftConfig ?? this.draftConfig,
      barcodeConfig: barcodeConfig ?? this.barcodeConfig,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  // ─── Flat copyWith (mirror former Settings.copyWith) ────────────────────

  Settings copyWith({
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
    String? billerId,
    int? promptPayTimeout,
    bool? promptPaySoundEnabled,
    String? defaultQrType,
    bool? autoConfirmAfterSlip,
    String? qrOverlayIcon,
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
    bool? barcodeScanEnabled,
    String? barcodeAutoGeneratePrefix,
    bool? barcodeBeepOnScan,
    List<String>? barcodeEnabledFormats,
    int? barcodeAutoOpenManualDelay,
    int? barcodeLastCounter,
    bool? barcodeContinuousScan,
  }) {
    return copyWithEntities(
      shopInfo: shopInfo.copyWith(
        name: shopName,
        address: address,
        phone: phone,
      ),
      receiptConfig: receiptConfig.copyWith(
        receiptSize: receiptSize,
        receiptPreviewStyle: receiptPreviewStyle,
        receiptNote: receiptNote,
        showShopInfo: showShopInfoOnReceipt,
        autoPrintPrompt: autoPrintPrompt,
        showPreSalePreview: showPreSalePreview,
        showPostSalePreview: showPostSalePreview,
      ),
      taxConfig: taxConfig.copyWith(vatRate: vatRate, vatMode: vatMode),
      discountConfig: discountConfig.copyWith(
        enableItemDiscount: enableItemDiscount,
        enableCartDiscount: enableCartDiscount,
        maxDiscountPercent: maxDiscountPercent,
        maxDiscountAmount: maxDiscountAmount,
        defaultDiscountType: defaultDiscountType,
        discountPresets: discountPresets,
        activeDiscountPresetId: activeDiscountPresetId,
      ),
      stockConfig: stockConfig.copyWith(
        allowOversell: allowOversell,
        lowStockThreshold: lowStockThreshold,
      ),
      imageConfig: imageConfig.copyWith(
        maxWidth: imageMaxWidth,
        quality: imageQuality,
      ),
      paymentConfig: paymentConfig.copyWith(
        currency: currency,
        promptpayId: promptpayId,
        billerId: billerId,
        promptPayTimeout: promptPayTimeout,
        promptPaySoundEnabled: promptPaySoundEnabled,
        defaultQrType: defaultQrType,
        autoConfirmAfterSlip: autoConfirmAfterSlip,
        qrOverlayIcon: qrOverlayIcon,
      ),
      deviceConfig: deviceConfig.copyWith(
        deviceId: deviceId,
        devicePrefix: devicePrefix,
      ),
      uiConfig: uiConfig.copyWith(
        locale: locale?.languageCode,
        themeMode: themeMode?.name,
        dateFormat: dateFormat,
        cartCompactMode: cartCompactMode,
        ultraCompactMode: ultraCompactMode,
        accessibilityMode: accessibilityMode,
      ),
      dailyCloseConfig: dailyCloseConfig.copyWith(
        dailyCloseLock: dailyCloseLock,
        lastClosedDate: identical(lastClosedDate, _unset)
            ? null
            : lastClosedDate as String?,
      ),
      backupConfig: backupConfig.copyWith(
        reminderDays: backupReminderDays,
        lastBackupAt: identical(lastBackupAt, _unset)
            ? null
            : lastBackupAt as String?,
        encryptionEnabled: backupEncryptionEnabled,
      ),
      draftConfig: draftConfig.copyWith(maxDrafts: maxDrafts),
      barcodeConfig: barcodeConfig.copyWith(
        scanEnabled: barcodeScanEnabled,
        autoGeneratePrefix: barcodeAutoGeneratePrefix,
        beepOnScan: barcodeBeepOnScan,
        enabledFormats: barcodeEnabledFormats,
        autoOpenManualDelay: barcodeAutoOpenManualDelay,
        lastCounter: barcodeLastCounter,
        continuousScan: barcodeContinuousScan,
      ),
      onboardingCompleted: onboardingCompleted,
    );
  }

  @override
  List<Object?> get props => [
    shopInfo,
    receiptConfig,
    taxConfig,
    discountConfig,
    stockConfig,
    imageConfig,
    paymentConfig,
    deviceConfig,
    uiConfig,
    dailyCloseConfig,
    backupConfig,
    draftConfig,
    barcodeConfig,
    onboardingCompleted,
  ];
}
