// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Promsell POS';

  @override
  String get navSale => 'Sale';

  @override
  String get navProducts => 'Products';

  @override
  String get navHistory => 'History';

  @override
  String get navReport => 'Report';

  @override
  String get navSettings => 'Settings';

  @override
  String get salePageTitle => 'Sale';

  @override
  String get clearCart => 'Clear';

  @override
  String get confirmClearCart => 'Clear the entire cart?';

  @override
  String get cartTitle => 'Cart';

  @override
  String get allCategories => 'All';

  @override
  String get saleSearchProducts => 'Search sale products...';

  @override
  String get quickCashExact => 'Exact cash';

  @override
  String get noProducts => 'No products';

  @override
  String get saleSavedSuccess => 'Sale saved successfully';

  @override
  String productAddedToCart(String name) {
    return '$name added';
  }

  @override
  String get tapProductToAdd => 'Tap a product to add to cart';

  @override
  String get noMatchingProducts => 'No matching products';

  @override
  String get stockLimitReached => 'Stock limit reached';

  @override
  String get cartTotal => 'Total';

  @override
  String checkout(int count) {
    return 'Checkout ($count)';
  }

  @override
  String get paymentTitle => 'Payment';

  @override
  String get totalAmount => 'Total';

  @override
  String get cash => 'Cash';

  @override
  String get transfer => 'Transfer';

  @override
  String get card => 'Card';

  @override
  String receivedAmount(String currency) {
    return 'Amount received ($currency)';
  }

  @override
  String get change => 'Change';

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String get notePlaceholder => 'Note (optional)';

  @override
  String get paymentReferenceOptional => 'Payment reference (optional)';

  @override
  String get saleError => 'Failed to save sale';

  @override
  String get insufficientCash => 'Insufficient cash received';

  @override
  String get productsTitle => 'Products';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get noCategory => 'No category';

  @override
  String stockLabel(int count) {
    return 'Stock: $count';
  }

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String confirmDeleteProduct(String name) {
    return 'Confirm delete \"$name\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProductTitle => 'Edit Product';

  @override
  String get productNameLabel => 'Product name *';

  @override
  String get productNameRequired => 'Please enter product name';

  @override
  String priceLabel(String currency) {
    return 'Price ($currency) *';
  }

  @override
  String get priceRequired => 'Please enter price';

  @override
  String get invalidPrice => 'Invalid price';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get quantityRequired => 'Please enter quantity';

  @override
  String get invalidQuantity => 'Invalid quantity';

  @override
  String get categoryLabel => 'Category';

  @override
  String get showProduct => 'Show product';

  @override
  String get save => 'Save';

  @override
  String get productSaved => 'Product saved';

  @override
  String get stockZeroWarning =>
      'Product won\'t appear in sale when stock is 0';

  @override
  String get historyTitle => 'Sale History';

  @override
  String get searchHistoryHint => 'Search receipt, payment, amount…';

  @override
  String get noSearchResults => 'No matching sales found';

  @override
  String get noSalesYet => 'No sales yet';

  @override
  String noteLabel(String note) {
    return 'Note: $note';
  }

  @override
  String get reportTitle => 'Report';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String salesCount(int count) {
    return '$count sales';
  }

  @override
  String get byPaymentMethod => 'By Payment Method';

  @override
  String get topProducts => 'Top Selling (Top 5)';

  @override
  String units(int count) {
    return '$count units';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsStoreBusiness => 'Store & Business';

  @override
  String get settingsPayments => 'Payments';

  @override
  String get settingsSystemData => 'System & Data';

  @override
  String get settingsStatusComplete => 'Complete';

  @override
  String get settingsStatusIncomplete => 'Incomplete';

  @override
  String get settingsStatusActive => 'Active';

  @override
  String get settingsStatusNotSet => 'Not set';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsAccessibilityMode => 'Large Text & High Contrast';

  @override
  String get settingsAccessibilityModeHint => 'Bigger fonts, clearer labels';

  @override
  String get generalSettingsAppearance => 'Appearance';

  @override
  String get generalSettingsLanguageRegion => 'Language & Region';

  @override
  String get generalSettingsReset => 'Reset to Defaults';

  @override
  String get generalSettingsResetConfirm =>
      'Restore language, theme, and accessibility to factory settings?';

  @override
  String get generalSettingsResetTitle => 'Reset General Settings';

  @override
  String get generalSettingsInfoDescription =>
      'Language affects all app labels and receipt text. Theme controls light/dark mode. Accessibility increases contrast and font sizes for better readability.';

  @override
  String get settingsShopInfo => 'Shop Info';

  @override
  String get settingsShopName => 'Shop Name';

  @override
  String get settingsAddress => 'Address';

  @override
  String get settingsPhone => 'Phone';

  @override
  String get settingsSales => 'Sales';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsDateFormat => 'Date Format';

  @override
  String get settingsReceipt => 'Receipt';

  @override
  String get settingsReceiptNote => 'Receipt Footer Note';

  @override
  String get settingsReceiptNoteHint => 'Thank you for your purchase';

  @override
  String get settingsShowShopInfo => 'Show shop info on receipt';

  @override
  String get settingsSectionContent => 'Content';

  @override
  String get settingsSectionPreview => 'Preview';

  @override
  String get settingsSectionTax => 'Tax';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get shopNameRequired => 'Shop name is required';

  @override
  String get shopNameTooLong => 'Shop name is too long';

  @override
  String get addressTooLong => 'Address is too long';

  @override
  String get phoneInvalid => 'Invalid phone number';

  @override
  String get shopInfoEmptyPreview => 'Your shop info will appear here';

  @override
  String get langThai => 'ภาษาไทย';

  @override
  String get langEnglish => 'English';

  @override
  String get printReceipt => 'Print Receipt';

  @override
  String get shareReceipt => 'Share Receipt';

  @override
  String get receiptLabelReceipt => 'Receipt';

  @override
  String get receiptLabelPayment => 'Payment';

  @override
  String get receiptLabelTotal => 'Total';

  @override
  String get receiptLabelReceived => 'Received';

  @override
  String get receiptLabelChange => 'Change';

  @override
  String get receiptLabelNote => 'Note';

  @override
  String get receiptLabelVat => 'VAT';

  @override
  String receiptLabelVatIncluded(Object rate) {
    return 'VAT $rate% (included)';
  }

  @override
  String get receiptLabelSubtotal => 'Subtotal';

  @override
  String get settingsAutoPrintPrompt => 'Ask to print receipt after sale';

  @override
  String get settingsVatRate => 'VAT Rate (%)';

  @override
  String get settingsVatMode => 'VAT Mode';

  @override
  String get settingsReceiptPreviewStyle => 'Receipt Preview Style';

  @override
  String get settingsShowPreSalePreview =>
      'Show receipt preview before payment';

  @override
  String get settingsShowPostSalePreview => 'Show receipt preview after sale';

  @override
  String get receiptPreviewStyleThermal => 'Thermal Paper';

  @override
  String get receiptPreviewStyleCard => 'Card';

  @override
  String get receiptPreviewStyleNone => 'None';

  @override
  String get receiptPreview => 'Receipt Preview';

  @override
  String get vatModeNone => 'None';

  @override
  String get vatModeInclusive => 'Inclusive';

  @override
  String get vatModeExclusive => 'Exclusive';

  @override
  String get voided => 'VOIDED';

  @override
  String get voidSale => 'Void Sale';

  @override
  String get voidSaleConfirm => 'Void this sale? Stock will be restored.';

  @override
  String get voidReasonHint => 'Reason for void (optional)';

  @override
  String get voidSuccess => 'Sale voided';

  @override
  String voidedSalesCount(int count) {
    return '$count voided';
  }

  @override
  String get voidedTotal => 'Voided Total';

  @override
  String get netRevenue => 'Net Revenue';

  @override
  String get adjustStock => 'Adjust Stock';

  @override
  String adjustStockTitle(String name) {
    return 'Adjust Stock: $name';
  }

  @override
  String get adjustQtyLabel => 'Quantity change (+/-)';

  @override
  String get adjustReasonLabel => 'Reason *';

  @override
  String get adjustReasonRequired => 'Please enter a reason';

  @override
  String get adjustSuccess => 'Stock adjusted';

  @override
  String get inventoryLog => 'Inventory Log';

  @override
  String get noInventoryLogs => 'No inventory logs';

  @override
  String get invLogTypeSale => 'Sale';

  @override
  String get invLogTypeVoidReversal => 'Void Reversal';

  @override
  String get invLogTypeStockIn => 'Stock In';

  @override
  String get invLogTypeStockOut => 'Stock Out';

  @override
  String get productFormSectionBasicInfo => 'Basic info';

  @override
  String get productFormSectionDetails => 'Details';

  @override
  String get productFormImageUrlLabel => 'Image URL (optional)';

  @override
  String get trackStock => 'Track stock';

  @override
  String get trackStockHint =>
      'Turn off for service items (no stock deduction)';

  @override
  String get settingsStockPolicy => 'Stock Policy';

  @override
  String get allowOversell => 'Allow overselling';

  @override
  String get allowOversellHint => 'Allow adding items beyond available stock';

  @override
  String get lowStockThreshold => 'Low stock warning (qty)';

  @override
  String get lowStockWarning => 'Low stock';

  @override
  String get discountSectionLabel => 'Discount';

  @override
  String get discountDialogTitle => 'Apply Discount';

  @override
  String get discountTypePercent => 'Percent (%)';

  @override
  String get discountTypeAmount => 'Amount (฿)';

  @override
  String discountPreview(String amount) {
    return 'After discount: $amount';
  }

  @override
  String get discountApply => 'Apply';

  @override
  String get discountClear => 'Clear discount';

  @override
  String get cartDiscount => 'Cart discount';

  @override
  String get applyCartDiscount => 'Apply cart discount';

  @override
  String discountLabel(String amount) {
    return '-$amount';
  }

  @override
  String get discountValueRequired => 'Please enter a discount value';

  @override
  String get discountValueInvalid => 'Invalid discount value';

  @override
  String get preTaxTotal => 'Pre-tax total';

  @override
  String get settingsDiscountPolicy => 'Discount Policy';

  @override
  String get enableItemDiscount => 'Enable item discount';

  @override
  String get enableCartDiscount => 'Enable cart discount';

  @override
  String get maxDiscountPercent => 'Max discount (%)';

  @override
  String get maxDiscountAmount => 'Max discount (amount)';

  @override
  String get maxAmountNoLimit => 'No limit';

  @override
  String get defaultDiscountType => 'Default discount type';

  @override
  String get presetDiscountValues => 'Preset values (comma-separated)';

  @override
  String get discountPresetsTitle => 'Discount Presets';

  @override
  String get discountPresetName => 'Preset name';

  @override
  String get discountPresetType => 'Type';

  @override
  String get discountPresetValues => 'Values';

  @override
  String get addDiscountPreset => 'Add preset';

  @override
  String get deleteDiscountPreset => 'Delete preset';

  @override
  String get activeDiscountPreset => 'Active preset';

  @override
  String get editDiscountPreset => 'Edit Preset';

  @override
  String get noDiscountPresets => 'No discount presets';

  @override
  String get addPresetValue => 'Add value';

  @override
  String get receiptItemDiscounts => 'Item Discounts';

  @override
  String get receiptCartDiscount => 'Cart Discount';

  @override
  String get draftsTitle => 'Saved Bills';

  @override
  String get newDraft => 'New bill';

  @override
  String get renameDraft => 'Rename';

  @override
  String get deleteDraft => 'Delete bill';

  @override
  String get deleteDraftConfirm => 'Delete this bill?';

  @override
  String get draftLimitReached =>
      'Maximum 10 bills reached. Please delete an old one first.';

  @override
  String get activeDraftLabel => 'Active';

  @override
  String get draftNameHint => 'Bill name (optional)';

  @override
  String get switchDraft => 'Switch to this bill';

  @override
  String get cartCleared => 'Cart cleared';

  @override
  String get undo => 'Undo';

  @override
  String get itemRemoved => 'Item removed';

  @override
  String get removeItem => 'Remove item';

  @override
  String get itemsLabel => 'items';

  @override
  String get searchCartItems => 'Search items...';

  @override
  String get searchDrafts => 'Search drafts...';

  @override
  String get untitledDraft => 'Draft';

  @override
  String get noMatchingItems => 'No matching items';

  @override
  String get noMatchingDrafts => 'No drafts match your search';

  @override
  String get groupView => 'Group view';

  @override
  String get listView => 'List view';

  @override
  String get gridView => 'Grid view';

  @override
  String get cartSizeMini => 'Mini';

  @override
  String get cartSizeHalf => 'Half';

  @override
  String get cartSizeFull => 'Full';

  @override
  String get cartCompactNormal => 'Normal density';

  @override
  String get cartCompactCompact => 'Compact density';

  @override
  String get cartCompactUltra => 'Ultra compact density';

  @override
  String get atStockLimit => 'Stock limit reached';

  @override
  String get justNow => 'Just now';

  @override
  String timeAgoMinutes(int m) {
    return '$m min ago';
  }

  @override
  String timeAgoHours(int h) {
    return '$h h ago';
  }

  @override
  String timeAgoDays(int d) {
    return '$d d ago';
  }

  @override
  String searchResultsCount(int n) {
    return '$n results';
  }

  @override
  String confirmPaymentAmount(String currency, String amount) {
    return 'Confirm $currency$amount';
  }

  @override
  String discountPreviewPercent(String value) {
    return 'After discount: $value%';
  }

  @override
  String get pickImageGallery => 'Choose from Gallery';

  @override
  String get pickImageCamera => 'Take a Photo';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get imagePickError => 'Unable to pick image';

  @override
  String get promptpay => 'PromptPay';

  @override
  String get settingsPromptpayId => 'PromptPay ID';

  @override
  String get settingsPromptpayIdHint => 'Phone number or Citizen ID';

  @override
  String get promptpayQrTitle => 'Scan to Pay';

  @override
  String get promptpayConfirmPayment => 'Confirm Payment Received';

  @override
  String get promptpayNotConfigured => 'PromptPay not configured';

  @override
  String get promptpaySettingsHint => 'Go to Settings';

  @override
  String get promptpayAccount => 'Account';

  @override
  String get promptpayScanToPay => 'Scan to Pay';

  @override
  String get promptpayQrPreview => 'Payment QR Preview';

  @override
  String get promptpayInfoDescription =>
      'Enter your PromptPay ID (phone number or citizen ID) to receive payments via QR code.';

  @override
  String get promptpayInvalidId =>
      'Please enter a valid phone number or citizen ID';

  @override
  String get settingsReceiptSize => 'Receipt Size';

  @override
  String get receiptSize80mm => '80mm (Thermal)';

  @override
  String get receiptSizeA4 => 'A4';

  @override
  String get settingsMaxDrafts => 'Max Drafts';

  @override
  String get settingsCompactCartMode => 'Compact Cart Mode';

  @override
  String get settingsUltraCompactMode => 'Ultra Compact Mode';

  @override
  String get settingsUltraCompactModeHint =>
      'Smaller items for maximum density';

  @override
  String get settingsCompactModeSubtitle =>
      'Smaller item rows, more items visible';

  @override
  String get settingsUltraModeOverrides => 'Overrides Compact mode';

  @override
  String get settingsUltraModeSubtitle => 'Minimal padding, maximum density';

  @override
  String get settingsOversellAllowed => 'Oversell allowed';

  @override
  String get settingsImages => 'Images';

  @override
  String get settingsImageMaxWidth => 'Max Width (px)';

  @override
  String get settingsImageQuality => 'Quality (%)';

  @override
  String get imageWidthSmall => 'Small';

  @override
  String get imageWidthMedium => 'Medium';

  @override
  String get imageWidthLarge => 'Large';

  @override
  String get imageWidthExtraLarge => 'Extra Large';

  @override
  String get imageWidthFullHD => 'Full HD';

  @override
  String get imageQualityDraft => 'Draft';

  @override
  String get imageQualityStandard => 'Standard';

  @override
  String get imageQualityHigh => 'High';

  @override
  String get imageQualityBest => 'Best';

  @override
  String get imageQualityOriginal => 'Original';

  @override
  String get imageExample => 'Example';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsData => 'Data';

  @override
  String get exportDatabase => 'Export Database (Full Backup)';

  @override
  String get exportSalesCsv => 'Export Sales (CSV)';

  @override
  String get exportProductsCsv => 'Export Products (CSV)';

  @override
  String get restoreFromBackup => 'Restore from Backup...';

  @override
  String get restoreConfirmTitle => 'Confirm Data Restore?';

  @override
  String get restoreConfirmMessage =>
      'Current data will be overwritten. Continue?';

  @override
  String get restoreSuccess => 'Data restored successfully';

  @override
  String get restoreError => 'Failed to restore data';

  @override
  String get backupReminderTitle => 'Backup Recommended';

  @override
  String backupReminderMessage(int days) {
    return 'No backup for more than $days days';
  }

  @override
  String get settingsBackupReminderDays => 'Backup reminder (days, 0=off)';

  @override
  String get backupWeekly => 'Weekly';

  @override
  String get backupBiweekly => 'Biweekly';

  @override
  String get backupMonthly => 'Monthly';

  @override
  String get backupBimonthly => 'Bimonthly';

  @override
  String get backupQuarterly => 'Quarterly';

  @override
  String get backupLastBackup => 'Last backup';

  @override
  String get backupToday => 'Today';

  @override
  String get backupYesterday => 'Yesterday';

  @override
  String backupDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get backupStatusSafe => 'Up to date';

  @override
  String get backupStatusWarning => 'Due soon';

  @override
  String get backupStatusOverdue => 'Overdue';

  @override
  String get backupNow => 'Backup Now';

  @override
  String get backupSuccess => 'Backup completed';

  @override
  String get backupReminderLabel => 'Backup reminder';

  @override
  String get backupFrequency => 'Frequency';

  @override
  String backupEveryNDays(int n) {
    return 'Every $n days';
  }

  @override
  String get backupOff => 'Off';

  @override
  String get backupActionTitle => 'Manual backup';

  @override
  String get backupActionSubtitle =>
      'Tap to record that you have backed up your data';

  @override
  String get backupInfoDescription =>
      'Back up regularly to protect your sales data, products, and settings.';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String bulkSelected(int count) {
    return '$count selected';
  }

  @override
  String get bulkClearDiscount => 'Clear Discount';

  @override
  String get bulkDelete => 'Delete';

  @override
  String get reorderItem => 'Drag to reorder';
}
