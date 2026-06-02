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
  String get settingsShowShopInfo => 'Show shop info on receipt';

  @override
  String get settingsSaved => 'Settings saved';

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
  String get listView => 'List view';

  @override
  String get gridView => 'Grid view';

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
  String get settingsReceiptSize => 'Receipt Size';

  @override
  String get receiptSize80mm => '80mm (Thermal)';

  @override
  String get receiptSizeA4 => 'A4';

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
  String get backupNow => 'Backup Now';

  @override
  String get exportSuccess => 'Export successful';
}
