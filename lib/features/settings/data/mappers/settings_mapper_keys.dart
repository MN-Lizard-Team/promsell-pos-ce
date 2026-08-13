/// All canonical settings KV keys. Kept in one place because the
/// repository and database seed reference them by name.
class SettingsMapperKeys {
  SettingsMapperKeys._();

  static const keyLocale = 'locale';
  static const keyTheme = 'theme';
  static const keyShopName = 'shopName';
  static const keyAddress = 'address';
  static const keyPhone = 'phone';
  static const keyTaxId = 'taxId';
  static const keyCurrency = 'currency';
  static const keyDateFormat = 'dateFormat';
  static const keyReceiptNote = 'receiptNote';
  static const keyShowShopInfo = 'showShopInfo';
  static const keyVatRate = 'vatRate';
  static const keyVatMode = 'vatMode';
  static const keyReceiptPreviewStyle = 'receiptPreviewStyle';
  static const keyShowPreSalePreview = 'showPreSalePreview';
  static const keyShowPostSalePreview = 'showPostSalePreview';
  static const keyAllowOversell = 'allowOversell';
  static const keyLowStockThreshold = 'lowStockThreshold';
  static const keyEnableItemDiscount = 'enableItemDiscount';
  static const keyEnableCartDiscount = 'enableCartDiscount';
  static const keyMaxDiscountPercent = 'maxDiscountPercent';
  static const keyDefaultDiscountType = 'defaultDiscountType';
  static const keyDiscountPresets = 'discountPresets';
  static const keyMaxDiscountAmount = 'maxDiscountAmount';
  static const keyActiveDiscountPresetId = 'activeDiscountPresetId';
  static const keyPromptpayId = 'promptpayId';
  static const keyBillerId = 'billerId';
  static const keyPromptPayTimeout = 'promptPayTimeout';
  static const keyPromptPaySoundEnabled = 'promptPaySoundEnabled';
  static const keyDefaultQrType = 'defaultQrType';
  static const keyAutoConfirmAfterSlip = 'autoConfirmAfterSlip';
  static const keyQrOverlayIcon = 'qrOverlayIcon';
  static const keyReceiptSize = 'receiptSize';
  static const keyBackupReminderDays = 'backupReminderDays';
  static const keyLastBackupAt = 'lastBackupAt';
  static const keyImageMaxWidth = 'imageMaxWidth';
  static const keyImageQuality = 'imageQuality';
  static const keyMaxDrafts = 'maxDrafts';
  static const keyUltraCompactMode = 'ultraCompactMode';
  static const keyAccessibilityMode = 'accessibilityMode';
  static const keyDeviceId = 'deviceId';
  static const keyDevicePrefix = 'devicePrefix';
  static const keyOnboardingCompleted = 'onboardingCompleted';
  static const keyDailyCloseLock = 'dailyCloseLock';
  static const keyLastClosedDate = 'lastClosedDate';
  static const keyBackupEncryptionEnabled = 'backupEncryptionEnabled';
  static const keyBarcodeScanEnabled = 'barcodeScanEnabled';
  static const keyBarcodeBeepOnScan = 'barcodeBeepOnScan';
  static const keyBarcodeAutoGeneratePrefix = 'barcodeAutoGeneratePrefix';
  static const keyBarcodeEnabledFormats = 'barcodeEnabledFormats';
  static const keyBarcodeAutoOpenManualDelay = 'barcodeAutoOpenManualDelay';

  /// Public for partial counter writes (barcode generation).
  static const keyBarcodeLastCounter = 'barcodeLastCounter';
  static const keyBarcodeContinuousScan = 'barcodeContinuousScan';

  /// Public for partial counter writes (SKU generation).
  static const keySkuLastCounter = 'skuLastCounter';
  static const keySkuAutoGeneratePrefix = 'skuAutoGeneratePrefix';

  static const keyBusinessType = 'businessType';
  static const keyDefaultServiceChargeRate = 'defaultServiceChargeRate';

  // Legacy seed keys (pre-canonical camelCase) — dual-read only.
  static const legacyShopName = 'shop_name';
  static const legacyReceiptNote = 'receipt_footer';
  static const legacyVatRate = 'vat_rate';
  static const legacyVatMode = 'vat_mode';
  static const legacyCurrency = 'currency_symbol';
}
