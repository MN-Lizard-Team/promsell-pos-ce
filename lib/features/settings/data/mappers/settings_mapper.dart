import 'dart:convert';

import 'package:promsell_pos_ce/core/utils/app_logger.dart';
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

class SettingsMapper {
  static const _keyLocale = 'locale';
  static const _keyTheme = 'theme';
  static const _keyShopName = 'shopName';
  static const _keyAddress = 'address';
  static const _keyPhone = 'phone';
  static const _keyCurrency = 'currency';
  static const _keyDateFormat = 'dateFormat';
  static const _keyReceiptNote = 'receiptNote';
  static const _keyShowShopInfo = 'showShopInfo';
  static const _keyAutoPrintPrompt = 'autoPrintPrompt';
  static const _keyVatRate = 'vatRate';
  static const _keyVatMode = 'vatMode';
  static const _keyReceiptPreviewStyle = 'receiptPreviewStyle';
  static const _keyShowPreSalePreview = 'showPreSalePreview';
  static const _keyShowPostSalePreview = 'showPostSalePreview';
  static const _keyAllowOversell = 'allowOversell';
  static const _keyLowStockThreshold = 'lowStockThreshold';
  static const _keyEnableItemDiscount = 'enableItemDiscount';
  static const _keyEnableCartDiscount = 'enableCartDiscount';
  static const _keyMaxDiscountPercent = 'maxDiscountPercent';
  static const _keyDefaultDiscountType = 'defaultDiscountType';
  static const _keyDiscountPresets = 'discountPresets';
  static const _keyMaxDiscountAmount = 'maxDiscountAmount';
  static const _keyActiveDiscountPresetId = 'activeDiscountPresetId';
  static const _keyPromptpayId = 'promptpayId';
  static const _keyBillerId = 'billerId';
  static const _keyPromptPayTimeout = 'promptPayTimeout';
  static const _keyPromptPaySoundEnabled = 'promptPaySoundEnabled';
  static const _keyDefaultQrType = 'defaultQrType';
  static const _keyAutoConfirmAfterSlip = 'autoConfirmAfterSlip';
  static const _keyQrOverlayIcon = 'qrOverlayIcon';
  static const _keyReceiptSize = 'receiptSize';
  static const _keyBackupReminderDays = 'backupReminderDays';
  static const _keyLastBackupAt = 'lastBackupAt';
  static const _keyImageMaxWidth = 'imageMaxWidth';
  static const _keyImageQuality = 'imageQuality';
  static const _keyMaxDrafts = 'maxDrafts';
  static const _keyCartCompactMode = 'cartCompactMode';
  static const _keyUltraCompactMode = 'ultraCompactMode';
  static const _keyAccessibilityMode = 'accessibilityMode';
  static const _keyDeviceId = 'deviceId';
  static const _keyDevicePrefix = 'devicePrefix';
  static const _keyOnboardingCompleted = 'onboardingCompleted';
  static const _keyDailyCloseLock = 'dailyCloseLock';
  static const _keyLastClosedDate = 'lastClosedDate';
  static const _keyBackupEncryptionEnabled = 'backupEncryptionEnabled';

  Map<String, String> toMap(Settings settings) {
    return {
      _keyLocale: settings.uiConfig.locale,
      _keyTheme: settings.uiConfig.themeMode,
      _keyShopName: settings.shopInfo.name,
      _keyAddress: settings.shopInfo.address,
      _keyPhone: settings.shopInfo.phone,
      _keyCurrency: settings.paymentConfig.currency,
      _keyDateFormat: settings.uiConfig.dateFormat,
      _keyReceiptNote: settings.receiptConfig.receiptNote,
      _keyShowShopInfo: settings.receiptConfig.showShopInfo.toString(),
      _keyAutoPrintPrompt: settings.receiptConfig.autoPrintPrompt.toString(),
      _keyVatRate: settings.taxConfig.vatRate.toString(),
      _keyVatMode: settings.taxConfig.vatMode,
      _keyReceiptPreviewStyle: settings.receiptConfig.receiptPreviewStyle,
      _keyShowPreSalePreview: settings.receiptConfig.showPreSalePreview
          .toString(),
      _keyShowPostSalePreview: settings.receiptConfig.showPostSalePreview
          .toString(),
      _keyAllowOversell: settings.stockConfig.allowOversell.toString(),
      _keyLowStockThreshold: settings.stockConfig.lowStockThreshold.toString(),
      _keyEnableItemDiscount: settings.discountConfig.enableItemDiscount
          .toString(),
      _keyEnableCartDiscount: settings.discountConfig.enableCartDiscount
          .toString(),
      _keyMaxDiscountPercent: settings.discountConfig.maxDiscountPercent
          .toString(),
      _keyMaxDiscountAmount: settings.discountConfig.maxDiscountAmount
          .toString(),
      _keyDefaultDiscountType: settings.discountConfig.defaultDiscountType,
      _keyDiscountPresets: _serializeDiscountPresets(
        settings.discountConfig.discountPresets,
      ),
      _keyActiveDiscountPresetId:
          settings.discountConfig.activeDiscountPresetId,
      _keyPromptpayId: settings.paymentConfig.promptpayId,
      _keyBillerId: settings.paymentConfig.billerId,
      _keyPromptPayTimeout: settings.paymentConfig.promptPayTimeout.toString(),
      _keyPromptPaySoundEnabled: settings.paymentConfig.promptPaySoundEnabled
          .toString(),
      _keyDefaultQrType: settings.paymentConfig.defaultQrType,
      _keyAutoConfirmAfterSlip: settings.paymentConfig.autoConfirmAfterSlip
          .toString(),
      _keyQrOverlayIcon: settings.paymentConfig.qrOverlayIcon,
      _keyReceiptSize: settings.receiptConfig.receiptSize,
      _keyBackupReminderDays: settings.backupConfig.reminderDays.toString(),
      _keyLastBackupAt: settings.backupConfig.lastBackupAt ?? '',
      _keyImageMaxWidth: settings.imageConfig.maxWidth.toString(),
      _keyImageQuality: settings.imageConfig.quality.toString(),
      _keyMaxDrafts: settings.draftConfig.maxDrafts.toString(),
      _keyCartCompactMode: settings.uiConfig.cartCompactMode.toString(),
      _keyUltraCompactMode: settings.uiConfig.ultraCompactMode.toString(),
      _keyAccessibilityMode: settings.uiConfig.accessibilityMode.toString(),
      _keyDeviceId: settings.deviceConfig.deviceId,
      _keyDevicePrefix: settings.deviceConfig.devicePrefix,
      _keyOnboardingCompleted: settings.onboardingCompleted.toString(),
      _keyDailyCloseLock: settings.dailyCloseConfig.dailyCloseLock.toString(),
      _keyLastClosedDate: settings.dailyCloseConfig.lastClosedDate ?? '',
      _keyBackupEncryptionEnabled: settings.backupConfig.encryptionEnabled
          .toString(),
    };
  }

  Settings fromMap(Map<String, String> map) {
    return Settings(
      shopInfo: ShopInfo(
        name: map[_keyShopName] ?? '',
        address: map[_keyAddress] ?? '',
        phone: map[_keyPhone] ?? '',
      ),
      receiptConfig: ReceiptConfig(
        receiptSize: map[_keyReceiptSize] ?? '80mm',
        receiptPreviewStyle: map[_keyReceiptPreviewStyle] ?? 'thermal',
        receiptNote: map[_keyReceiptNote] ?? '',
        showShopInfo: _parseBool(map[_keyShowShopInfo], true),
        autoPrintPrompt: _parseBool(map[_keyAutoPrintPrompt], true),
        showPreSalePreview: _parseBool(map[_keyShowPreSalePreview], true),
        showPostSalePreview: _parseBool(map[_keyShowPostSalePreview], true),
      ),
      taxConfig: TaxConfig(
        vatRate: _parseDouble(map[_keyVatRate], 7.0),
        vatMode: map[_keyVatMode] ?? 'NONE',
      ),
      discountConfig: DiscountConfig(
        enableItemDiscount: _parseBool(map[_keyEnableItemDiscount], true),
        enableCartDiscount: _parseBool(map[_keyEnableCartDiscount], true),
        maxDiscountPercent: _parseDouble(map[_keyMaxDiscountPercent], 100.0),
        maxDiscountAmount: _parseDouble(map[_keyMaxDiscountAmount], 0.0),
        defaultDiscountType: map[_keyDefaultDiscountType] ?? 'PERCENT',
        discountPresets: _parseDiscountPresets(map[_keyDiscountPresets]),
        activeDiscountPresetId: map[_keyActiveDiscountPresetId] ?? 'default',
      ),
      stockConfig: StockConfig(
        allowOversell: _parseBool(map[_keyAllowOversell], false),
        lowStockThreshold: _parseInt(map[_keyLowStockThreshold], 5),
      ),
      imageConfig: ImageConfig(
        maxWidth: _parseInt(map[_keyImageMaxWidth], 800),
        quality: _parseInt(map[_keyImageQuality], 80),
      ),
      paymentConfig: PaymentConfig(
        currency: map[_keyCurrency] ?? '฿',
        promptpayId: map[_keyPromptpayId] ?? '',
        billerId: map[_keyBillerId] ?? '',
        promptPayTimeout: _parseInt(map[_keyPromptPayTimeout], 180),
        promptPaySoundEnabled: _parseBool(map[_keyPromptPaySoundEnabled], true),
        defaultQrType: map[_keyDefaultQrType] ?? 'transfer',
        autoConfirmAfterSlip: _parseBool(map[_keyAutoConfirmAfterSlip], false),
        qrOverlayIcon: map[_keyQrOverlayIcon] ?? '',
      ),
      deviceConfig: DeviceConfig(
        deviceId: map[_keyDeviceId] ?? '',
        devicePrefix: map[_keyDevicePrefix] ?? '',
      ),
      uiConfig: UiConfig(
        locale: map[_keyLocale] ?? 'th',
        themeMode: _parseThemeMode(map[_keyTheme]),
        dateFormat: map[_keyDateFormat] ?? 'dd/MM/yyyy',
        cartCompactMode: _parseBool(map[_keyCartCompactMode], false),
        ultraCompactMode: _parseBool(map[_keyUltraCompactMode], false),
        accessibilityMode: _parseBool(map[_keyAccessibilityMode], false),
      ),
      dailyCloseConfig: DailyCloseConfig(
        dailyCloseLock: _parseBool(map[_keyDailyCloseLock], false),
        lastClosedDate: _nullIfEmpty(map[_keyLastClosedDate]),
      ),
      backupConfig: BackupConfig(
        reminderDays: _parseInt(map[_keyBackupReminderDays], 7),
        lastBackupAt: _nullIfEmpty(map[_keyLastBackupAt]),
        encryptionEnabled: _parseBool(map[_keyBackupEncryptionEnabled], false),
      ),
      draftConfig: DraftConfig(maxDrafts: _parseInt(map[_keyMaxDrafts], 30)),
      onboardingCompleted: _parseBool(map[_keyOnboardingCompleted], false),
    );
  }

  static bool _parseBool(String? raw, bool fallback) {
    if (raw == null) return fallback;
    return raw == 'true' || raw == '1';
  }

  static int _parseInt(String? raw, int fallback) {
    if (raw == null) return fallback;
    return int.tryParse(raw) ?? fallback;
  }

  static String _parseThemeMode(String? raw) {
    if (raw == null || raw.isEmpty) return 'system';
    // Handle legacy integer index values (0=light, 1=dark, 2=system)
    switch (raw) {
      case '0':
        return 'light';
      case '1':
        return 'dark';
      case '2':
        return 'system';
    }
    // Already a valid name
    const valid = {'light', 'dark', 'system'};
    return valid.contains(raw) ? raw : 'system';
  }

  static double _parseDouble(String? raw, double fallback) {
    if (raw == null) return fallback;
    return double.tryParse(raw) ?? fallback;
  }

  static String? _nullIfEmpty(String? value) {
    return (value == null || value.isEmpty) ? null : value;
  }

  static String _serializeDiscountPresets(List<DiscountPreset> presets) {
    final list = presets
        .map(
          (p) => {
            'id': p.id,
            'name': p.name,
            'type': p.type,
            'values': p.values,
          },
        )
        .toList();
    return jsonEncode(list);
  }

  static List<DiscountPreset> _parseDiscountPresets(String? raw) {
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        final presets = list
            .map(
              (e) => DiscountPreset(
                id: e['id'] as String? ?? '',
                name: e['name'] as String? ?? '',
                type: e['type'] as String? ?? 'PERCENT',
                values:
                    (e['values'] as List?)
                        ?.map((v) => (v as num).toDouble())
                        .toList() ??
                    const [5.0, 10.0, 20.0, 50.0],
              ),
            )
            .where((p) => p.id.isNotEmpty)
            .toList();
        if (presets.isNotEmpty) return presets;
      } catch (e, stack) {
        AppLogger.warning(
          'SettingsMapper: discount presets parse failed',
          error: e,
          stack: stack,
        );
      }
    }
    return const [
      DiscountPreset(
        id: 'default',
        name: 'Default',
        type: 'PERCENT',
        values: [5.0, 10.0, 20.0, 50.0],
      ),
    ];
  }
}
