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
  String get appTagline => 'Smart Retail';

  @override
  String get loading => 'Loading...';

  @override
  String get navHome => 'Home';

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
  String get salePageSubtitle => 'Add products and complete the sale';

  @override
  String get saleBillNoteTitle => 'Bill note';

  @override
  String get dragToResizeCart => 'Drag to resize cart';

  @override
  String get exitCompactMode => 'Exit Compact Mode';

  @override
  String get exitCompactModeConfirm => 'Switch to normal cart view?';

  @override
  String autoConfirmingIn(int secs) {
    return 'Auto-confirming in $secs...';
  }

  @override
  String get clearCart => 'Clear';

  @override
  String get confirmClearCart => 'Clear the entire cart?';

  @override
  String get cartTitle => 'Bill';

  @override
  String get cartEmpty => 'Cart is empty';

  @override
  String get backToSale => 'Back to Sale';

  @override
  String get checkoutButton => 'Pay';

  @override
  String get addItems => 'Add Items';

  @override
  String itemRemoved(String name) {
    return '$name removed';
  }

  @override
  String get undo => 'Undo';

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
  String get tapProductToAdd => 'Tap a product to add to this bill';

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
  String get totalAmount => 'Amount due';

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
  String get saleTimeout => 'Payment timed out, please try again';

  @override
  String get insufficientCash => 'Insufficient cash received';

  @override
  String get remainingAmount => 'Remaining';

  @override
  String get productsTitle => 'Products';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get recentSearches => 'Recent searches';

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
  String stockRemaining(int count) {
    return 'Left: $count';
  }

  @override
  String get itemNoteLabel => 'Item note';

  @override
  String get itemNoteHint => 'Add a note for this item';

  @override
  String get duplicateItem => 'Item duplicated';

  @override
  String get duplicateItemAction => 'Duplicate';

  @override
  String get clear => 'Clear';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String confirmDeleteProduct(String name) {
    return 'Confirm delete \"$name\"?';
  }

  @override
  String productDeactivateConfirm(String name) {
    return 'Deactivate \"$name\"? This product will be hidden from the sales screen.';
  }

  @override
  String productActivateConfirm(String name) {
    return 'Activate \"$name\"? This product will be visible on the sales screen.';
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
  String get productNameTooLong =>
      'Product name is too long (max 100 characters)';

  @override
  String get quickEditStockSet => 'Set';

  @override
  String get quickEditStockAdjust => 'Adjust';

  @override
  String get quickEditNameHint => 'Enter the new product name';

  @override
  String get quickEditPriceHint => 'Enter the new selling price';

  @override
  String get quickEditStockSetHint =>
      'Tap + / - or the number to edit. Long-press buttons for fast adjust.';

  @override
  String get quickEditStockAdjustHint =>
      'Enter the amount to add or subtract from current stock';

  @override
  String get stockStepperLongPressHint => 'Long-press to continuously adjust';

  @override
  String get stockStepperTapNumberHint => 'Tap number to enter directly';

  @override
  String get quickEditNameSaved => 'Name updated';

  @override
  String get quickEditNameCancelled => 'Name not changed';

  @override
  String get quickEditNameInvalid => 'Invalid name';

  @override
  String get quickEditPriceSaved => 'Price updated';

  @override
  String get quickEditPriceCancelled => 'Price not changed';

  @override
  String get quickEditPriceInvalid => 'Invalid price';

  @override
  String priceLabel(String currency) {
    return 'Price ($currency) *';
  }

  @override
  String get priceRequired => 'Please enter price';

  @override
  String get invalidPrice => 'Invalid price';

  @override
  String get priceMustBePositive => 'Price must be greater than 0';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get quantityRequired => 'Please enter quantity';

  @override
  String get invalidQuantity => 'Invalid quantity';

  @override
  String get invalidBarcode =>
      'Barcode must be alphanumeric (letters and numbers only)';

  @override
  String get categoryLabel => 'Category';

  @override
  String get showProduct => 'Show product';

  @override
  String get productVisibility => 'Product visibility';

  @override
  String get save => 'Save';

  @override
  String get productSaved => 'Product saved';

  @override
  String get productActivated => 'Product activated';

  @override
  String get productDeactivated => 'Product deactivated';

  @override
  String get productDeleted => 'Product deleted';

  @override
  String get stockUpdated => 'Stock updated';

  @override
  String get stockUpdateCancelled => 'Stock not changed';

  @override
  String get stockUpdateInvalid => 'Invalid stock value';

  @override
  String get stockUpdateError => 'Failed to update stock';

  @override
  String get productUpdateError => 'Failed to update product';

  @override
  String get productAddError => 'Failed to add product';

  @override
  String get productDeleteError => 'Failed to delete product';

  @override
  String get stockZeroWarning =>
      'Product won\'t appear in sale when stock is 0';

  @override
  String get historyTitle => 'Sale History';

  @override
  String get searchHistoryHint => 'Search receipt, payment, amount…';

  @override
  String get noSearchResults => 'No settings found';

  @override
  String get noSalesYet => 'No sales yet';

  @override
  String get noDailyClosesYet => 'No daily closes yet';

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
  String get searchSettings => 'Search settings...';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

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
  String get voidReason => 'Void reason';

  @override
  String get voidReasonHint => 'Enter reason for void';

  @override
  String get voidReasonRequired => 'Please enter a void reason';

  @override
  String voidedAtLabel(String datetime) {
    return 'Voided at $datetime';
  }

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
  String get invLogReasonProductStockEdited => 'Product stock edited';

  @override
  String invLogSaleRef(String ref) {
    return 'Sale · $ref';
  }

  @override
  String productHistoryShowingLatest(int count) {
    return 'Showing latest $count movements';
  }

  @override
  String get productHistoryViewAll => 'View full history';

  @override
  String get productFormSectionBasicInfo => 'Basic info';

  @override
  String get tabInfo => 'Info';

  @override
  String get tabPrice => 'Price';

  @override
  String get tabStock => 'Stock';

  @override
  String get tabCodes => 'Codes';

  @override
  String get productFormSectionDetails => 'Details';

  @override
  String get productFormImageUrlLabel => 'Image URL (optional)';

  @override
  String get trackStock => 'Track Stock';

  @override
  String get trackStockHint =>
      'Turn off for service items (no stock deduction)';

  @override
  String get trackStockDisableConfirm =>
      'Disabling stock tracking will freeze the current stock value. You can re-enable it later to resume tracking.';

  @override
  String get stockTrackingDisabled =>
      'Stock tracking is disabled. Enable to manage stock quantity.';

  @override
  String get stockNotTracked => 'Not tracking stock';

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
  String get inStock => 'In stock';

  @override
  String get codesCardTitle => 'SKU & Barcode';

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
  String get draftsTitle => 'Open bills';

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
  String get removeItem => 'Remove item';

  @override
  String get itemsLabel => 'items';

  @override
  String get searchCartItems => 'Search items...';

  @override
  String get searchDrafts => 'Search bills...';

  @override
  String get untitledDraft => 'Bill';

  @override
  String get noMatchingItems => 'No matching items';

  @override
  String get noMatchingDrafts => 'No drafts match your search';

  @override
  String get noSavedBills => 'No saved bills yet';

  @override
  String get noSavedBillsHint =>
      'Park a bill from the sale screen to save it here';

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
  String get promptpayWaitingForPayment => 'Waiting for customer to pay...';

  @override
  String get promptpayPaymentTimeout => 'Payment timed out. Sale cancelled.';

  @override
  String get promptpayExtendTime => 'Extend +1 min';

  @override
  String get promptpayCancelPayment => 'Cancel Payment';

  @override
  String get promptpayTransactionReference =>
      'Transaction Reference (optional)';

  @override
  String get promptpayQrSaved => 'QR saved to gallery';

  @override
  String get promptpayQrShared => 'QR shared';

  @override
  String get promptpaySaveQr => 'Save QR';

  @override
  String get promptpayShareQr => 'Share QR';

  @override
  String get promptpaySoundEnabled => 'Sound on confirmation';

  @override
  String get promptpayTimeoutSetting => 'Payment timeout (minutes)';

  @override
  String get minutes => 'minutes';

  @override
  String get slipScanTitle => 'Scan Bank Slip';

  @override
  String get slipScanHint => 'Align the QR code on the slip within the frame';

  @override
  String get slipScanSuccess => 'Slip verified';

  @override
  String get slipScanInvalid => 'Invalid slip QR';

  @override
  String get slipErrorEmpty => 'Empty QR code detected';

  @override
  String get slipErrorNotASlip =>
      'This is a payment QR, not a bank slip. Please scan the QR on the bank transfer slip.';

  @override
  String get slipErrorUnreadable => 'Unable to read slip QR. Please try again.';

  @override
  String get promptpayInvalidQr => 'Invalid QR code';

  @override
  String get settingsBillerId => 'Biller ID';

  @override
  String get settingsBillerIdHint => 'Tax ID for Bill Payment QR';

  @override
  String get settingsDefaultQrType => 'Default QR Type';

  @override
  String get settingsDefaultQrTypeTransfer => 'Transfer';

  @override
  String get settingsDefaultQrTypeBill => 'Bill Payment';

  @override
  String get settingsAutoConfirmAfterSlip => 'Auto-confirm after slip scan';

  @override
  String get settingsAutoConfirmAfterSlipHint =>
      'Automatically confirm payment 2 seconds after successful slip verification';

  @override
  String get settingsQrOverlayIcon => 'QR Icon';

  @override
  String get cart => 'Cart';

  @override
  String get moreItems => 'more items';

  @override
  String get total => 'Total';

  @override
  String get waitingForPayment => 'Waiting for payment...';

  @override
  String get copyPromptpayId => 'Copied to clipboard';

  @override
  String get paymentVerified => 'Payment verified';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String itemsCount(Object count) {
    return '$count items';
  }

  @override
  String get totalDiscountLabel => 'Total discount';

  @override
  String get settingsReceiptSize => 'Receipt Size';

  @override
  String get receiptSize80mm => '80mm (Thermal)';

  @override
  String get receiptSizeA4 => 'A4';

  @override
  String get settingsMaxDrafts => 'Max Drafts';

  @override
  String get settingsCompactCartMode => 'Delivery-style Cart';

  @override
  String get settingsUltraCompactMode => 'Ultra Compact Mode';

  @override
  String get settingsUltraCompactModeHint =>
      'Smaller items for maximum density';

  @override
  String get settingsCompactModeSubtitle =>
      'Bottom bar cart like delivery apps; off = classic panel';

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
  String get settingsSetupReadiness => 'Store readiness';

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
  String get backupEncryptionTitle => 'Backup Encryption (Optional)';

  @override
  String get backupEncryptionLabel => 'Encrypt backups';

  @override
  String get backupEncryptionDesc =>
      'Protect backup files with AES-256-GCM encryption (PIN required)';

  @override
  String get backupInfoDescription =>
      'Export backups regularly (encryption recommended, PIN at least 6 characters). In-app restore is same-device only while the SQLCipher key remains. Cross-device restore and key recovery are not available.';

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

  @override
  String get dailyCloseTitle => 'Daily Close';

  @override
  String get dailyCloseHistoryTitle => 'Daily Close History';

  @override
  String get closeToday => 'Close Today';

  @override
  String get closeDay => 'Close Day';

  @override
  String get reopenDay => 'Reopen Day';

  @override
  String get closeDayConfirmTitle => 'Close Day?';

  @override
  String get closeDayConfirmMessage =>
      'This will lock the day and save the reconciliation.';

  @override
  String get reopenDayConfirmTitle => 'Reopen Day?';

  @override
  String get reopenDayConfirmMessage =>
      'This will unlock the day. Sales will count toward a new close.';

  @override
  String get confirm => 'Confirm';

  @override
  String get dbHealthTitle => 'Database Health';

  @override
  String get dbHealthFileSize => 'Database file size';

  @override
  String get dbHealthLarge => 'LARGE';

  @override
  String get dbHealthOk => 'OK';

  @override
  String get dbHealthLargeTitle => 'Large database';

  @override
  String get dbHealthLargeMessage =>
      'Your database is over 50 MB. Consider backing up and archiving old data.';

  @override
  String get dbHealthRowCounts => 'Row counts';

  @override
  String get dbHealthVacuum => 'Vacuum Database';

  @override
  String get dbHealthVacuumDescription =>
      'Vacuum rebuilds the database file to reclaim unused space and reduce fragmentation.';

  @override
  String get onboardingWelcome => 'Welcome';

  @override
  String get onboardingShopInfoTitle => 'Shop Info';

  @override
  String get onboardingShopNameLabel => 'Shop name';

  @override
  String get onboardingShopNameHint => 'My Shop';

  @override
  String get onboardingAddressLabel => 'Address';

  @override
  String get onboardingAddressHint => '123 Main Street';

  @override
  String get onboardingPhoneLabel => 'Phone';

  @override
  String get onboardingPhoneHint => '0812345678';

  @override
  String get onboardingPromptPayTitle => 'PromptPay';

  @override
  String get onboardingPromptPaySubtitle =>
      'Enter your PromptPay ID to accept QR payments.';

  @override
  String get onboardingPromptPayIdLabel => 'PromptPay ID';

  @override
  String get onboardingPromptPayIdHint =>
      'Phone (10 digits) or Citizen ID (13 digits)';

  @override
  String get onboardingVatRateLabel => 'VAT rate %';

  @override
  String get onboardingSkip => 'Skip for now';

  @override
  String get onboardingSkipSetup => 'Skip Setup';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Promsell POS';

  @override
  String get onboardingWelcomeSubtitle =>
      'Your offline-first mobile point of sale.\nLet\'s set up your shop in a few steps.';

  @override
  String get onboardingLocaleCurrencyTitle => 'Locale & Currency';

  @override
  String get onboardingAllSet => 'All set!';

  @override
  String get onboardingReadyToSell =>
      'Your shop is configured and ready to sell.';

  @override
  String get onboardingShopInfo => 'Shop Info';

  @override
  String get onboardingLocaleCurrency => 'Locale & Currency';

  @override
  String get onboardingTaxSetup => 'Tax Setup';

  @override
  String get onboardingPromptPay => 'PromptPay';

  @override
  String get onboardingDone => 'Done';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingStartSelling => 'Start Selling';

  @override
  String get onboardingLanguage => 'Language';

  @override
  String get onboardingThai => 'Thai';

  @override
  String get onboardingEnglish => 'English';

  @override
  String get onboardingCurrency => 'Currency';

  @override
  String get onboardingDateFormat => 'Date format';

  @override
  String get onboardingVatMode => 'VAT mode (optional)';

  @override
  String get onboardingNone => 'None';

  @override
  String get onboardingInclusive => 'Inclusive';

  @override
  String get onboardingExclusive => 'Exclusive';

  @override
  String dailyCloseLoadError(String message) {
    return 'Error: $message';
  }

  @override
  String dailyCloseSales(int count) {
    return 'Sales: $count';
  }

  @override
  String dailyCloseVoids(int count) {
    return 'Voids: $count';
  }

  @override
  String get settingsDailyCloseTitle => 'Daily Close';

  @override
  String get settingsDailyCloseSubtitle => 'End of day reconciliation';

  @override
  String get settingsDbHealthTitle => 'Database Health';

  @override
  String get settingsDbHealthSubtitle => 'Size, row counts, vacuum';

  @override
  String get settingsDailyCloseLockTitle => 'Block sales after day close';

  @override
  String get settingsDailyCloseLockSubtitle =>
      'When enabled, new sales are blocked if the current day has been closed.';

  @override
  String get dbHealthVacuumSuccess => 'Database vacuumed successfully';

  @override
  String dbHealthVacuumFailed(String error) {
    return 'Vacuum failed: $error';
  }

  @override
  String dbHealthError(String message) {
    return 'Error: $message';
  }

  @override
  String get dayClosedMessage => 'Day closed. Reopen to continue.';

  @override
  String get tapToSet => 'Tap to set';

  @override
  String get shopNameHint => 'Enter shop name';

  @override
  String get addressHint => 'Enter address';

  @override
  String get phoneHint => '081-234-5678';

  @override
  String get categoryManagementTitle => 'Manage Categories';

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get searchCategories => 'Search categories...';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategoryConfirm => 'Confirm delete category?';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String confirmDeleteCategory(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String bulkDeleteConfirm(int count) {
    return 'Delete $count categories?';
  }

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameRequired => 'Please enter category name';

  @override
  String get categoryNameExists => 'Category name already exists';

  @override
  String get categoryInUse => 'Cannot delete category that has products';

  @override
  String get chooseCategory => 'Choose Category';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get sortOrder => 'Sort order';

  @override
  String get sortOrderRequired => 'Please enter sort order';

  @override
  String get categoryColor => 'Color';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get addProductTitle => 'Add Product';

  @override
  String get noCategorySelected => 'No category selected';

  @override
  String get noProductsInCategory => 'No products in this category';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get startTypingToSearch => 'Start typing to search';

  @override
  String get searchByNameSkuBarcode => 'Search by name, SKU, or barcode';

  @override
  String get tryDifferentKeyword => 'Try a different keyword';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get inactive => 'Inactive';

  @override
  String get tapToZoom => 'Tap to zoom';

  @override
  String get imageError => 'Image error';

  @override
  String get productImageSemantics => 'Product image';

  @override
  String get noProductImageSemantics => 'No product image';

  @override
  String get na => 'N/A';

  @override
  String get skuLabel => 'SKU';

  @override
  String get barcodeLabel => 'Barcode';

  @override
  String costLabel(String currency) {
    return 'Cost ($currency)';
  }

  @override
  String get costHelper => 'Used to calculate gross profit (optional)';

  @override
  String get outOfStockShort => 'Out';

  @override
  String get productsCount => 'Products';

  @override
  String get lowStock => 'Low stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get discardDraft => 'Discard Draft';

  @override
  String get restoreDraft => 'Restore draft?';

  @override
  String get draftSaved => 'Draft saved';

  @override
  String get unsavedChangesMessage => 'You have unsaved changes';

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get restore => 'Restore';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get barcodeScannerHint => 'Align barcode within the frame';

  @override
  String get barcodeNotFound => 'No product found with this barcode';

  @override
  String get duplicateBarcode => 'This barcode already exists';

  @override
  String get enterManually => 'Enter Manually';

  @override
  String get enterBarcodeManually => 'Enter barcode manually';

  @override
  String get cameraPermissionDenied =>
      'Camera permission is required to scan barcodes. Please grant camera access in settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get scanSuccess => 'Scan successful';

  @override
  String get scanFromGallery => 'Scan from image';

  @override
  String get barcodeNotFoundInImage => 'No barcode found in image';

  @override
  String get barcodeMustBeAlphanumeric =>
      'Barcode must be alphanumeric (letters and numbers only)';

  @override
  String get scanningImage => 'Scanning image...';

  @override
  String get continuousScan => 'Continuous scan';

  @override
  String get continuousScanHint => 'Keep scanning without closing the scanner';

  @override
  String get focusCamera => 'Focus';

  @override
  String productFound(String name) {
    return '$name added';
  }

  @override
  String get productNotFoundShort => 'Product not found';

  @override
  String scanCount(int count) {
    return '$count scanned';
  }

  @override
  String get done => 'Done';

  @override
  String get torchOn => 'Turn on flashlight';

  @override
  String get torchOff => 'Turn off flashlight';

  @override
  String get submit => 'Submit';

  @override
  String get generateBarcode => 'Generate Barcode';

  @override
  String get barcodeGenerated => 'Barcode generated';

  @override
  String get barcodeGenerationError => 'Failed to generate barcode';

  @override
  String get batchGenerateBarcodes => 'Generate Missing Barcodes';

  @override
  String get batchGenerateBarcodesHint =>
      'Generate barcodes for all products without one';

  @override
  String get batchGenerateConfirmTitle => 'Generate Barcodes';

  @override
  String batchGenerateConfirmBody(Object count) {
    return 'Generate EAN-13 barcodes for $count product(s) without barcodes?';
  }

  @override
  String batchGenerateSuccess(Object count) {
    return 'Generated barcodes for $count product(s)';
  }

  @override
  String get batchGenerateNone => 'All products already have barcodes';

  @override
  String get batchGenerateFailed => 'Failed to generate barcodes';

  @override
  String productsWithoutBarcode(Object count) {
    return '$count product(s) without barcode';
  }

  @override
  String get barcodeSettings => 'Barcode Settings';

  @override
  String get enableBarcodeScan => 'Enable barcode scan in sale';

  @override
  String get enableBarcodeScanHint =>
      'Show camera scan button on the sale page';

  @override
  String get playBeepOnScan => 'Vibrate on scan';

  @override
  String get playBeepOnScanHint =>
      'Haptic vibration feedback when barcode is scanned successfully';

  @override
  String get barcodePrefix => 'Auto-generate prefix';

  @override
  String get barcodePrefixHint => 'e.g. 200, 201 (1-3 digit number for EAN-13)';

  @override
  String get barcodePrefixError => 'Must be 1-3 numeric digits only';

  @override
  String get barcodeFormats => 'Scan formats';

  @override
  String get barcodeFormatsHint =>
      'Select which barcode formats to scan (reduces false positives)';

  @override
  String get barcodeFormatEan13 => 'EAN-13';

  @override
  String get barcodeFormatEan8 => 'EAN-8';

  @override
  String get barcodeFormatUpcA => 'UPC-A';

  @override
  String get barcodeFormatUpcE => 'UPC-E';

  @override
  String get barcodeFormatCode128 => 'Code 128';

  @override
  String get barcodeFormatCode39 => 'Code 39';

  @override
  String get barcodeFormatItf => 'ITF';

  @override
  String get barcodeFormatQrCode => 'QR Code';

  @override
  String get barcodeFormatDataMatrix => 'Data Matrix';

  @override
  String get barcodeFormatPdf417 => 'PDF417';

  @override
  String get barcodeFormatAztec => 'Aztec';

  @override
  String get barcodeFormatCodabar => 'Codabar';

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get barcodeAutoOpenManual => 'Auto-open manual entry';

  @override
  String get barcodeAutoOpenManualHint =>
      'Open manual barcode entry if scan fails within the set time';

  @override
  String get disabled => 'Disabled';

  @override
  String get secondsSuffix => 's';

  @override
  String get barcodeHelpTitle => 'How to use barcodes';

  @override
  String get barcodeHelpWhatIsTitle => 'What is a barcode?';

  @override
  String get barcodeHelpWhatIsBody =>
      'A barcode is a machine-readable code (usually lines or numbers) printed on product packaging. You can scan it with the camera to quickly add products to the cart.';

  @override
  String get barcodeHelpHowToScanTitle => 'How to scan';

  @override
  String get barcodeHelpHowToScanBody =>
      'Point the camera at the barcode on the product. Make sure there is good lighting and hold the phone steady. If scanning fails, tap Enter Manually and type the barcode number.';

  @override
  String get barcodeHelpNoBarcodeTitle => 'Product has no barcode?';

  @override
  String get barcodeHelpNoBarcodeBody =>
      'If the product doesn\'t have a barcode, you can generate one automatically in the product form (Advanced tab). This lets you scan it later at the checkout.';

  @override
  String get barcodeHelper =>
      'Scan or type the barcode on the product packaging. If none, tap Generate Barcode.';

  @override
  String get skuHelper =>
      'Internal product code (optional). Example: SHIRT-RED-L';

  @override
  String get imagePicked => 'Image added';

  @override
  String get imagePickFailed => 'Could not add image. Please try again.';

  @override
  String get storagePermissionDenied =>
      'Storage permission is required to pick images. Please grant storage access in settings.';

  @override
  String get removeImageConfirm => 'Remove this image?';

  @override
  String get imageHelper => 'Tap to change, long-press to preview';

  @override
  String get tapToAddImage => 'Tap to add image';

  @override
  String get imageNotFound => 'Saved image was removed. Please pick again.';

  @override
  String get clearImageCache => 'Clear image cache';

  @override
  String get clearImageCacheConfirm =>
      'This will delete all unused product images to free up storage. Continue?';

  @override
  String get imageCacheCleared => 'Image cache cleared';

  @override
  String get basic => 'Basic';

  @override
  String get advanced => 'Advanced';

  @override
  String get settingsStoreSales => 'Store & Sales';

  @override
  String get settingsDiscounts => 'Discounts';

  @override
  String get settingsAbout => 'About';

  @override
  String get aboutApp => 'About App';

  @override
  String get appVersion => 'Version';

  @override
  String get appBuild => 'Build';

  @override
  String get appDescription => 'Offline-first mobile POS for small businesses';

  @override
  String get builtWith => 'Built with';

  @override
  String get techStackFlutter => 'Flutter';

  @override
  String get techStackDrift => 'Drift SQLite';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get openSourceLicense => 'Open Source License';

  @override
  String get crashLogs => 'Crash Logs';

  @override
  String get exportCrashLogs => 'Export Crash Logs';

  @override
  String get clearCrashLogs => 'Clear Crash Logs';

  @override
  String get clearCrashLogsConfirm => 'Do you want to clear all crash logs?';

  @override
  String get crashLogSize => 'File size';

  @override
  String get crashLogEmpty => 'No crash logs';

  @override
  String get contactUs => 'Contact';

  @override
  String get agplLicense => 'GNU Affero General Public License v3.0';

  @override
  String get agplShort => 'AGPL-3.0';

  @override
  String get copyrightNotice => '© 2026 Promsell POS CE · AGPL-3.0';

  @override
  String get dataCollection => 'Data Collection';

  @override
  String get dataCollectionBody =>
      'Promsell does not collect any personal data. All sales, inventory, and settings are stored locally on your device using SQLite. No data is transmitted to our servers.';

  @override
  String get thirdPartyServices => 'Third-Party Services';

  @override
  String get thirdPartyServicesBody =>
      'We do not use analytics, advertising, or cloud services. The app works entirely offline.';

  @override
  String get dataStorage => 'Data Storage';

  @override
  String get dataStorageBody =>
      'Your data remains on your device. You can export or delete it at any time via the Backup/Restore feature. Product images are stored locally in the app\'s private directory and are subject to automatic LRU cache eviction (50MB limit) to prevent excessive disk usage.';

  @override
  String get backupEncryptionBody =>
      'Promsell offers optional AES-256-GCM encryption for database backups. If enabled, backups are encrypted with a key derived from a user-supplied PIN via PBKDF2. The PIN is never stored on the device or transmitted anywhere. Forgetting the PIN makes the backup unrecoverable — we cannot reset or recover it.';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionsCamera =>
      'Camera: Used for taking product photos and scanning product barcodes. No photos or scans are transmitted off-device.';

  @override
  String get permissionsStorage =>
      'Storage: Used only for saving backups and receipts.';

  @override
  String get permissionsInternet =>
      'Internet: Optional, used only for loading product images if URLs are provided. When sharing product images, URLs are sent to the platform\'s native share sheet (local device only, not to our servers).';

  @override
  String get crashLoggingTitle => 'Crash Logging';

  @override
  String get crashLoggingBody =>
      'If the app crashes, a local crash log entry is written to your device containing the error message, stack trace, and timestamp. Sensitive data (phone numbers, PromptPay IDs, citizen IDs) is automatically sanitized before storage. Crash logs are never transmitted off-device. You can view, export, and clear crash logs in Settings → About → Crash Logs.';

  @override
  String get contactTitle => 'Contact';

  @override
  String get contactBody => 'For questions: mnlizard.official@gmail.com';

  @override
  String get productPreviewSystemInfo => 'System Info';

  @override
  String get sellingPrice => 'Selling Price';

  @override
  String get profit => 'Profit';

  @override
  String get dateCreated => 'Created';

  @override
  String get dateUpdated => 'Updated';

  @override
  String get barcodeViewFull => 'View';

  @override
  String get barcodeSave => 'Save';

  @override
  String get barcodePrint => 'Print';

  @override
  String get productPreviewMargin => 'Margin';

  @override
  String get productPreviewStockValue => 'Stock Value';

  @override
  String get productPreviewStockValueSale => 'Total Sale Value';

  @override
  String get productPreviewPotentialProfit => 'Potential Profit';

  @override
  String get productPreviewTotalSold => 'Total Sold';

  @override
  String get productPreviewTotalIn => 'Total Restocked';

  @override
  String get productPreviewTotalOut => 'Total Adjusted Out';

  @override
  String get productPreviewLastUpdate => 'Last Stock Update';

  @override
  String get productPreviewRecentMoves => 'Recent Movements';

  @override
  String get productPreviewMarkup => 'Markup from Cost';

  @override
  String get productPreviewRoi => 'Return on Cost';

  @override
  String get productPreviewTotalRevenue => 'Total Stock Revenue';

  @override
  String get productPreviewTotalProfit => 'Total Stock Profit';

  @override
  String get productPreviewStatus => 'Status';

  @override
  String get productPreviewActive => 'Active';

  @override
  String get productPreviewCost => 'Cost';

  @override
  String get productPreviewBarcodeLabel => 'Barcode Label';

  @override
  String get productPreviewProductId => 'Product ID';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get invalidValue => 'Invalid value';

  @override
  String discountPresetAdded(String label) {
    return 'Added $label';
  }

  @override
  String discountPresetRemoved(String label) {
    return 'Removed $label';
  }

  @override
  String get unsupportedFormat => 'Unsupported format';

  @override
  String get barcodeSavedSuccess => 'Barcode saved successfully';

  @override
  String get barcodePrintedSuccess => 'Barcode printed successfully';

  @override
  String get barcodeViewError => 'Failed to view barcode';

  @override
  String get barcodeSaveError => 'Failed to save barcode';

  @override
  String get barcodePrintError => 'Failed to print barcode';

  @override
  String get inventoryValue => 'Inventory value';

  @override
  String get currencyBaht => 'Baht';

  @override
  String get currencyDollar => 'Dollar';

  @override
  String get currencyEuro => 'Euro';

  @override
  String get currencyYen => 'Yen';

  @override
  String get stockOnHand => 'On hand';

  @override
  String get piecesLabel => 'pcs';

  @override
  String get totalProducts => 'Total products';

  @override
  String get todayRevenue => 'Today\'s Revenue';

  @override
  String get todaySalesCount => 'Sales';

  @override
  String get cartItems => 'Items';

  @override
  String get sortDefault => 'Default';

  @override
  String get sortNameAsc => 'Name A-Z';

  @override
  String get sortPriceLowHigh => 'Price: Low to High';

  @override
  String get sortPriceHighLow => 'Price: High to Low';

  @override
  String get sortStockLowHigh => 'Stock: Low to High';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterSort => 'Sort';

  @override
  String get filterStock => 'Stock';

  @override
  String get filterAll => 'All';

  @override
  String get filterMore => 'Filter';

  @override
  String get filterPageTitle => 'Filter Products';

  @override
  String get filterReset => 'Reset';

  @override
  String get filterShowResults => 'Show Results';

  @override
  String filterShowResultsCount(int count) {
    return 'Show Results ($count)';
  }

  @override
  String get filterPriceRange => 'Price Range';

  @override
  String get filterPriceMin => 'Min';

  @override
  String get filterPriceMax => 'Max';

  @override
  String filterActiveCount(int count) {
    return '$count active';
  }

  @override
  String get businessType => 'Business Type';

  @override
  String get businessTypeRetail => 'Retail';

  @override
  String get businessTypeRestaurant => 'Restaurant';

  @override
  String get businessTypeSubtitle =>
      'Switch between retail and restaurant mode';

  @override
  String get serviceChargeRate => 'Service Charge Rate (%)';

  @override
  String get serviceChargeRateSubtitle =>
      'Default service charge percentage for restaurant orders';

  @override
  String get orderType => 'Order Type';

  @override
  String get orderTypeDineIn => 'Dine In';

  @override
  String get orderTypeTakeaway => 'Takeaway';

  @override
  String get orderTypeDelivery => 'Delivery';

  @override
  String get orderChannel => 'Order Channel';

  @override
  String get orderChannelWalkIn => 'Walk-in';

  @override
  String get orderChannelPhone => 'Phone';

  @override
  String get orderChannelOnline => 'Online';

  @override
  String get externalOrderRef => 'External Order Ref';

  @override
  String get externalOrderRefHint =>
      'Delivery platform order number (optional)';

  @override
  String get serviceCharge => 'Service Charge';

  @override
  String get tableNumber => 'Table';

  @override
  String get selectTable => 'Select Table';

  @override
  String get noTable => 'No table assigned';

  @override
  String get restaurantSettings => 'Restaurant Settings';

  @override
  String get tableManagement => 'Table Management';

  @override
  String get tableManagementSubtitle => 'Manage restaurant tables and zones';

  @override
  String get addTable => 'Add Table';

  @override
  String get editTable => 'Edit Table';

  @override
  String get deleteTable => 'Delete Table';

  @override
  String get tableName => 'Table Name';

  @override
  String get tableNameHint => 'e.g., Table 1, T-01';

  @override
  String get tableZone => 'Zone';

  @override
  String get tableZoneHint => 'e.g., Indoor, Outdoor, Terrace';

  @override
  String get tableSeats => 'Seats';

  @override
  String get tableSeatsHint => 'Number of seats';

  @override
  String get tableStatusAvailable => 'Available';

  @override
  String get tableStatusOccupied => 'Occupied';

  @override
  String get tableStatusReserved => 'Reserved';

  @override
  String get noTablesYet => 'No tables yet. Add your first table.';

  @override
  String get confirmDeleteTable => 'Delete this table?';

  @override
  String get selectTableForDineIn => 'Select a table for this order';

  @override
  String get noTablesAvailable =>
      'No tables configured. Add tables in Table Management.';

  @override
  String get optionGroups => 'Option Groups';

  @override
  String get optionGroupsSubtitle =>
      'Add modifiers like size, add-ons, or spice level';

  @override
  String get addOptionGroup => 'Add Option Group';

  @override
  String get editOptionGroup => 'Edit Option Group';

  @override
  String get optionGroupName => 'Group Name';

  @override
  String get optionGroupNameHint => 'e.g., Size, Add-ons, Spice Level';

  @override
  String get optionSelectionType => 'Selection Type';

  @override
  String get optionSelectionSingle => 'Single Choice';

  @override
  String get optionSelectionMultiple => 'Multiple Choice';

  @override
  String get optionRequired => 'Required';

  @override
  String get optionOptional => 'Optional';

  @override
  String get addOption => 'Add Option';

  @override
  String get editOption => 'Edit Option';

  @override
  String get optionName => 'Option Name';

  @override
  String get optionNameHint => 'e.g., Small, Extra Shot, No Ice';

  @override
  String get optionPriceDelta => 'Price Adjustment';

  @override
  String get optionPriceDeltaHint => 'Additional cost (can be 0)';

  @override
  String get deleteOptionGroup => 'Delete Option Group';

  @override
  String get confirmDeleteOptionGroup =>
      'Delete this option group and all its options?';

  @override
  String get deleteOption => 'Delete Option';

  @override
  String get confirmDeleteOption => 'Delete this option?';

  @override
  String get noOptionGroups => 'No option groups yet.';

  @override
  String get selectOptions => 'Select Options';

  @override
  String optionsFor(String product) {
    return 'Options for $product';
  }

  @override
  String optionRequiredMessage(String group) {
    return 'Please select an option for $group';
  }

  @override
  String get customersTitle => 'Customers';

  @override
  String get customerSaved => 'Customer saved';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get editCustomerTitle => 'Edit Customer';

  @override
  String get customerNameLabel => 'Name';

  @override
  String get customerNameRequired => 'Name is required';

  @override
  String get customerPhoneLabel => 'Phone';

  @override
  String get customerEmailLabel => 'Email';

  @override
  String get customerNoteLabel => 'Notes';

  @override
  String get customerNoteHint => 'Add a note about this customer...';

  @override
  String get customerInfoSection => 'Customer Information';

  @override
  String get customerNotesSection => 'Notes';

  @override
  String get customerStatisticsSection => 'Statistics';

  @override
  String get customerTotalVisits => 'Total Visits';

  @override
  String get customerTotalSpent => 'Total Spent';

  @override
  String get deleteCustomerTitle => 'Delete Customer';

  @override
  String deleteCustomerConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get searchCustomers => 'Search customers...';

  @override
  String get noCustomersYet => 'No customers yet';

  @override
  String get noCustomersFound => 'No customers found';

  @override
  String get addFirstCustomer =>
      'Add your first customer to track their purchases';

  @override
  String customerVisits(int count) {
    return '$count visits';
  }

  @override
  String get selectCustomer => 'Select customer';

  @override
  String get clearCustomer => 'Clear customer';

  @override
  String get noCustomer => 'No customer';

  @override
  String get receiptLabelCustomer => 'Customer';

  @override
  String get selectPromotion => 'Select promotion';

  @override
  String get clearPromotion => 'Clear promotion';

  @override
  String get noActivePromotions => 'No active promotions';

  @override
  String get promotionNotFound => 'Promotion not found or inactive';

  @override
  String get receiptLabelPromotion => 'Promotion';

  @override
  String get receiptLabelPromotionDiscount => 'Promo discount';

  @override
  String get customerNotFound => 'Customer not found or deleted';

  @override
  String get insufficientStock => 'Insufficient stock available';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get productInactive => 'Product is inactive';

  @override
  String get saleNotFound => 'Sale not found';

  @override
  String get saleAlreadyVoided => 'Sale already voided';

  @override
  String get notFound => 'Not Found';

  @override
  String get validationError => 'Validation Error';

  @override
  String get databaseError => 'Database Error';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get backupShareSubject => 'Promsell POS backup';

  @override
  String get backupPinTitle => 'Backup encryption PIN';

  @override
  String get backupPinHint => 'Enter PIN to encrypt backup';

  @override
  String get backupPinRequired => 'PIN is required when encryption is on';

  @override
  String get backupPinTooShort => 'PIN must be at least 6 characters';

  @override
  String get backupPinConfirmHint => 'Confirm PIN';

  @override
  String get backupPinMismatch => 'PINs do not match';

  @override
  String get backupEncryptionOffTitle => 'Turn off backup encryption?';

  @override
  String get backupEncryptionOffConfirm =>
      'Backups shared without encryption are easier to copy if the file is taken. You can turn encryption back on later.';

  @override
  String customerSpentLabel(String amount) {
    return 'Spent $amount';
  }

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get promotionsTitle => 'Promotions';

  @override
  String get promotionSaved => 'Promotion saved';

  @override
  String get addPromotion => 'Add Promotion';

  @override
  String get editPromotionTitle => 'Edit Promotion';

  @override
  String get promotionNameLabel => 'Promotion Name';

  @override
  String get promotionNameRequired => 'Name is required';

  @override
  String get promotionValueLabel => 'Discount (%)';

  @override
  String get promotionAmountLabel => 'Discount Amount';

  @override
  String get promotionValueRequired => 'Value is required';

  @override
  String get promotionValueInvalid => 'Enter a valid value';

  @override
  String get promotionPercentMax => 'Percentage cannot exceed 100';

  @override
  String get promotionMinPurchaseLabel => 'Minimum Purchase Amount';

  @override
  String get promotionMinPurchaseHint => '0 = no minimum';

  @override
  String get promotionDetailsSection => 'Promotion Details';

  @override
  String get promotionScheduleSection => 'Schedule';

  @override
  String get promotionStatusSection => 'Status';

  @override
  String get promotionStartDate => 'Start Date';

  @override
  String get promotionEndDate => 'End Date';

  @override
  String get promotionNoEndDate => 'No end date';

  @override
  String get promotionActive => 'Active';

  @override
  String get promotionInactive => 'Inactive';

  @override
  String get promotionActiveDesc => 'This promotion is currently active';

  @override
  String get promotionInactiveDesc => 'This promotion is disabled';

  @override
  String get promotionPercentage => 'Percentage';

  @override
  String get promotionFixedAmount => 'Fixed Amount';

  @override
  String get deletePromotionTitle => 'Delete Promotion';

  @override
  String deletePromotionConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get searchPromotions => 'Search promotions...';

  @override
  String get noPromotionsYet => 'No promotions yet';

  @override
  String get noPromotionsFound => 'No promotions found';

  @override
  String get addFirstPromotion =>
      'Create your first promotion to offer discounts';

  @override
  String promotionPercentOff(String value) {
    return '$value% off';
  }

  @override
  String promotionAmountOff(String value) {
    return '$value off';
  }

  @override
  String promotionMinPurchase(String amount) {
    return 'Min. purchase: $amount';
  }

  @override
  String homeGreeting(String shopName) {
    return 'Hello, $shopName';
  }

  @override
  String get homeSubtitle => 'Let\'s make today a great sales day!';

  @override
  String get homeTodayRevenue => 'Today\'s Revenue';

  @override
  String get homeVsYesterday => 'vs yesterday';

  @override
  String get homeRevenue => 'Revenue';

  @override
  String get homeCost => 'Cost';

  @override
  String get homeProfit => 'Profit';

  @override
  String get homeMainMenu => 'Main Menu';

  @override
  String get homeHistory => 'History';

  @override
  String get homeCloseDay => 'Close Day';

  @override
  String get homePromotionBannerCta => 'Create Now';

  @override
  String get homeCreatePromotion => 'Create Promotion';

  @override
  String get importProducts => 'Import Products';

  @override
  String get productTabAll => 'All';

  @override
  String get productTabCategory => 'Category';

  @override
  String get productTabStock => 'Stock';

  @override
  String get productMenuEdit => 'Edit';

  @override
  String get productMenuPreview => 'Preview';

  @override
  String get importFromCsv => 'Import from CSV';

  @override
  String get selectCsvFile => 'Select CSV File';

  @override
  String get csvImportPreview => 'Preview data to import';

  @override
  String get confirmImport => 'Confirm Import';

  @override
  String importSuccess(int count) {
    return 'Imported $count products';
  }

  @override
  String get importError => 'Failed to import products';

  @override
  String get csvImportError => 'Failed to read CSV file';

  @override
  String get csvNoData => 'No data found in CSV file';

  @override
  String get csvInvalidFormat => 'Invalid file format';

  @override
  String csvFileTooLarge(int maxMb) {
    return 'File is too large (max $maxMb MB)';
  }

  @override
  String csvTooManyRows(int maxRows) {
    return 'Too many rows (max $maxRows)';
  }

  @override
  String csvRowErrorsSkipped(int count) {
    return '$count row error(s) will be skipped';
  }

  @override
  String csvImportPartialSuccess(int imported, int errors) {
    return 'Imported $imported; $errors row(s) failed';
  }

  @override
  String csvImportCategoriesCreated(int count) {
    return '$count categories created';
  }

  @override
  String get csvDownloadTemplate => 'Download template';

  @override
  String get csvColumnLegend =>
      'Required: name, price. Optional: sku, barcode, cost, stock, category, track_stock';

  @override
  String get csvImporting => 'Importing…';

  @override
  String csvRowLabel(int row, String message) {
    return 'Row $row: $message';
  }

  @override
  String get csvTemplateShared => 'Template ready to share';

  @override
  String get csvParseErrorsTitle => 'Rows that will be skipped';

  @override
  String get csvPostImportErrorsTitle => 'Rows that failed to import';

  @override
  String get homePromotionBannerSubtitle => 'Easily boost your sales';

  @override
  String get homeNoActivePromotion => 'No active promotions right now';

  @override
  String get homePromotionOff => 'OFF';

  @override
  String homeFromBills(int count) {
    return 'from $count bills';
  }

  @override
  String get productDetailTitle => 'Product Details';

  @override
  String get productTabInfo => 'Product Info';

  @override
  String get productTabHistory => 'History';

  @override
  String get productDescriptionLabel => 'Description';

  @override
  String get productDescriptionEmpty => 'No description';

  @override
  String get productUnitLabel => 'Unit';

  @override
  String get productUnitDefault => 'pcs';

  @override
  String get productTabPointOfSale => 'Point of Sale';

  @override
  String get productTabPriceStock => 'Price & Stock';

  @override
  String get productTabCodesMore => 'Codes & More';

  @override
  String get productRecommended => 'Recommended product';

  @override
  String get productUnitOther => 'Other';

  @override
  String get productCustomUnit => 'Custom unit';

  @override
  String get productTaxLabel => 'Tax';

  @override
  String get productWeightLabel => 'Weight';

  @override
  String get productSizeLabel => 'Size';

  @override
  String get productBrandLabel => 'Brand';

  @override
  String get productSupplierLabel => 'Supplier';

  @override
  String get copyBarcode => 'Copy Barcode';

  @override
  String get printBarcode => 'Print Barcode';

  @override
  String get productAdjustStock => 'Adjust Stock';

  @override
  String get productNoHistory => 'No stock movement history';

  @override
  String get normalProduct => 'Normal Product';

  @override
  String get readyToSell => 'Ready to Sell';

  @override
  String get retailPrice => 'Retail Price';

  @override
  String get averageCost => 'Average Cost';

  @override
  String get averageProfit => 'Average Profit';

  @override
  String get remainingStock => 'Remaining Stock';

  @override
  String get moveProduct => 'Move Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String pieces(int count) {
    return '$count pcs';
  }

  @override
  String resourceNotFound(String resource) {
    return '$resource not found';
  }

  @override
  String resourceNotFoundWithId(String resource, String id) {
    return '$resource not found (ID: $id)';
  }

  @override
  String get businessRuleViolation => 'Business Rule Violation';

  @override
  String get networkError => 'Network Error';

  @override
  String networkErrorDefault(int code) {
    return 'Network error (status: $code)';
  }

  @override
  String get fileSystemError => 'File System Error';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String permissionDeniedMessage(String permission) {
    return 'Please grant $permission permission';
  }

  @override
  String get unexpectedError => 'Unexpected Error';

  @override
  String get invalidDiscount => 'Invalid discount value';

  @override
  String get negativePriceNotAllowed => 'Negative price is not allowed';

  @override
  String get homeLoadError => 'Failed to load data';

  @override
  String get productFormSectionGeneral => 'General';

  @override
  String get productFormSectionPricing => 'Price & cost';

  @override
  String get productFormSectionStock => 'Stock & unit';

  @override
  String get productFormSectionSettings => 'Settings';

  @override
  String get productFormSectionExtra => 'More details';

  @override
  String get profitMargin => 'Margin';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get saveProduct => 'Save product';

  @override
  String get discardChanges => 'Don\'t save';

  @override
  String get unsavedChangesMessageCreate =>
      'Leave without saving? You can restore this draft next time, or discard it.';

  @override
  String get unsavedChangesMessageEdit =>
      'You have unsaved changes. Leave without saving?';

  @override
  String get costExceedsPriceWarning =>
      'Cost is higher than selling price — negative profit';

  @override
  String get priceStockEstimateTitle => 'If all stock sells';

  @override
  String get priceStockEstimateRevenue => 'Est. revenue';

  @override
  String get priceStockEstimateProfit => 'Est. profit';

  @override
  String get editStockAdjustHint =>
      'Change quantity with Adjust stock so the change is logged.';

  @override
  String lowStockThresholdHint(int n) {
    return 'Low stock alert at $n';
  }

  @override
  String get stockInventoryValueTitle => 'Inventory value';

  @override
  String get adjustModeAdd => 'Add';

  @override
  String get adjustModeRemove => 'Remove';

  @override
  String get adjustQtyAmountLabel => 'Amount';

  @override
  String adjustCurrentStock(String qty, String unit) {
    return 'Current stock: $qty $unit';
  }

  @override
  String adjustPreviewResult(String from, String to, String unit) {
    return '$from → $to $unit';
  }

  @override
  String get adjustWouldGoNegative => 'Not enough stock for this removal';

  @override
  String get adjustReasonRestock => 'Restock';

  @override
  String get adjustReasonDamaged => 'Damaged';

  @override
  String get adjustReasonLost => 'Lost / missing';

  @override
  String get adjustReasonCountCorrection => 'Count correction';

  @override
  String get adjustReasonReturn => 'Customer return';

  @override
  String get adjustReasonOther => 'Other';

  @override
  String get adjustReasonOtherHint => 'Describe the reason';

  @override
  String get editLowStockThreshold => 'Edit threshold';

  @override
  String get lowStockThresholdSaved => 'Low stock alert updated';

  @override
  String get createProductFromBarcode => 'Create product';

  @override
  String get scanAgainToAdd => 'Product saved — scan again to add to cart';

  @override
  String get productCreatedAddedToCart => 'Product created and added to cart';

  @override
  String get barcodeReplaceTitle => 'Replace barcode?';

  @override
  String barcodeReplaceMessage(String code) {
    return 'Current code: $code. A new code will replace it.';
  }

  @override
  String get barcodePreviewEmpty =>
      'Preview appears when you enter or generate a barcode';

  @override
  String get scanModeContinuous => 'Continuous';

  @override
  String get scanModeSingle => 'Single';

  @override
  String get searchMatchName => 'Name';

  @override
  String get searchMatchSku => 'SKU';

  @override
  String get searchMatchBarcode => 'Barcode';

  @override
  String searchResultCount(int count) {
    return '$count results';
  }

  @override
  String get searchFiltersIgnoredHint =>
      'Showing all matches (list filters not applied)';

  @override
  String searchShowingCount(int shown, int total) {
    return 'Showing $shown of $total';
  }

  @override
  String barcodeAmbiguousCount(int count) {
    return '$count products share this barcode';
  }

  @override
  String get cartBillDetails => 'Bill details';

  @override
  String get cartHoldBill => 'Saved bills';

  @override
  String cartItemCount(int count) {
    return '$count items';
  }

  @override
  String cartActiveBill(String name) {
    return 'Bill: $name';
  }

  @override
  String get heroNoBarcode => 'No barcode';

  @override
  String get setSellingPrice => 'Set price';

  @override
  String get showProductHint =>
      'Visible in the product list and sale catalog when on';

  @override
  String get productRecommendedHint =>
      'Highlighted first on the sale catalog and marked in the product list';

  @override
  String get productBrandHint => 'Optional brand or manufacturer name';

  @override
  String get productDescriptionHint =>
      'Optional notes for staff (not shown on the sale catalog)';

  @override
  String get productFormSectionVisibility => 'Visibility';

  @override
  String get productSettingsOutcomeVisible => 'On sale';

  @override
  String get productSettingsOutcomeHidden => 'Hidden from sale';

  @override
  String get productSettingsOutcomeRecommended => 'Recommended';

  @override
  String get productSettingsOutcomeNotRecommended => 'Not recommended';

  @override
  String get productRecommendedNeedsVisible =>
      'Recommended products should be visible. Turn on Show product, or turn off Recommended.';

  @override
  String get saleRecommendedFilter => 'Recommended';

  @override
  String get saleRecommendedFilterAll => 'All items';

  @override
  String get productSupplierHint => 'Who you buy this product from (optional)';

  @override
  String get productOptionsSummaryTitle => 'Options';

  @override
  String productOptionGroupSummary(String name, String detail, int count) {
    return '$name · $detail · $count options';
  }

  @override
  String get productFormCostEmptyHint => 'Add cost to see profit and markup';

  @override
  String get productFormMarkupFromCost => 'Set price from cost';

  @override
  String productFormPriceChanged(String from, String to) {
    return '$from → $to';
  }

  @override
  String get clearFieldTitle => 'Clear text?';

  @override
  String get clearFieldConfirm =>
      'This will remove the text in this field. Continue?';

  @override
  String get deleteProductConfirmTitle => 'Delete this product?';

  @override
  String get removeCartLineTitle => 'Remove this item from the bill?';

  @override
  String removeCartLineQty(int count) {
    return 'Qty $count';
  }

  @override
  String get removeCartLineConfirm => 'Remove item';

  @override
  String get datePresetToday => 'Today';

  @override
  String get datePresetYesterday => 'Yesterday';

  @override
  String get datePresetLast7Days => 'Last 7 days';

  @override
  String get datePresetThisMonth => 'This month';

  @override
  String get datePresetCustom => 'Custom';

  @override
  String get reportAverage => 'Average';

  @override
  String get reportRecent => 'Recent';

  @override
  String paymentMethodShare(String percent) {
    return '$percent%';
  }

  @override
  String get closeDayToday => 'Close today';

  @override
  String get dailyCloseSummaryTitle => 'Summary';

  @override
  String get dailyCloseSalesCountLabel => 'Sales count';

  @override
  String get dailyCloseVoidedCountLabel => 'Voided count';

  @override
  String get dailyCloseGrossRevenue => 'Gross revenue';

  @override
  String get dailyCloseVoidedAmount => 'Voided amount';

  @override
  String get dailyCloseByPayment => 'By payment';

  @override
  String get dailyCloseVatCollected => 'VAT collected';

  @override
  String get dailyCloseDiscountsGiven => 'Discounts given';

  @override
  String get dailyCloseCashReconciliation => 'Cash reconciliation';

  @override
  String get dailyCloseOpeningCash => 'Opening cash';

  @override
  String get dailyCloseExpectedCash => 'Expected cash';

  @override
  String get dailyCloseCountedCash => 'Counted cash';

  @override
  String get dailyCloseOverShort => 'Over / Short';

  @override
  String get dailyCloseNoteOptional => 'Note (optional)';

  @override
  String get dailyCloseStatusOpen => 'Open';

  @override
  String get dailyCloseStatusClosed => 'Closed';

  @override
  String get dailyCloseStatusClosedBadge => 'CLOSED';

  @override
  String get dailyCloseStatusOpenBadge => 'OPEN';

  @override
  String get noCategoriesFound => 'No categories match your search';

  @override
  String get categorySaved => 'Category saved';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String categoriesDeleted(int count) {
    return '$count categories deleted';
  }

  @override
  String get categoryReorderHint =>
      'Drag to set the order shown on the POS catalog';

  @override
  String deleteCategoryProductsImpact(int count) {
    return '$count products will be moved to the selected category (or Uncategorized).';
  }

  @override
  String get categoryNameTooLong => 'Name must be at most 100 characters';

  @override
  String get goToSale => 'Go to Sale';

  @override
  String closeDayForDate(String date) {
    return 'Close day $date';
  }

  @override
  String get reportNoSalesInPeriod => 'No sales in this period';

  @override
  String get currentBill => 'Current bill';

  @override
  String currentBillWithCount(int count) {
    return 'Bill ($count)';
  }

  @override
  String get viewBill => 'Bill';

  @override
  String viewBillWithCount(int count) {
    return 'Bill ($count)';
  }

  @override
  String get draftNotFound => 'Open bill not found';

  @override
  String maxDraftsReached(int count) {
    return 'Maximum open bills ($count) reached';
  }

  @override
  String get addToCart => 'Add to cart';

  @override
  String get holdCurrentBill => 'Hold this bill';

  @override
  String get newBill => 'New bill';

  @override
  String get billHeld => 'Bill saved';

  @override
  String get newBillConfirm =>
      'Save the current bill and start a new empty bill?';

  @override
  String get newBillStarted => 'New bill started';

  @override
  String get voidBlockedDayClosed =>
      'Day is closed. Reopen the day to void this sale.';

  @override
  String get billParked => 'Bill set aside — ready for next customer.';

  @override
  String get receiptThankYouDefault => 'Thank you!';

  @override
  String get receiptNotTaxInvoice => 'Sale receipt — not a tax invoice';

  @override
  String get receiptReprint => 'REPRINT';

  @override
  String get receiptShareVoidBlocked =>
      'Cannot share a voided sale as a normal receipt. Print shows VOID.';

  @override
  String get parkBill => 'Park bill';

  @override
  String get parkBillNameTitle => 'Name this bill (optional)';

  @override
  String currentBillNamed(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get amountDue => 'Amount due';

  @override
  String payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get parkAndNext => 'Park & next';

  @override
  String openBillsCount(int count) {
    return 'Open bills ($count)';
  }

  @override
  String billItemsMissing(int count) {
    return '$count line(s) missing (product removed)';
  }

  @override
  String get splitTenderTitle => 'Split payment (cash + other)';

  @override
  String get splitTenderSubtitle =>
      'Pay part in cash and the rest with QR/transfer/card';

  @override
  String get splitCashAmount => 'Cash amount';

  @override
  String get paymentMismatch => 'Payment amounts do not match the total';

  @override
  String get paymentMixed => 'Split payment';

  @override
  String get promptPayShareTitle => 'PromptPay share';

  @override
  String get promptPayShareHint =>
      'Scan for the PromptPay portion only (not the full bill).';

  @override
  String get promptPayFullBillTitle => 'Pay with PromptPay';

  @override
  String settingsAttentionItemsCount(int count) {
    return '$count setup items need attention';
  }

  @override
  String get settingsAttentionShopTitle => 'Finish shop profile';

  @override
  String get settingsAttentionShopBody =>
      'Add your shop name and phone so receipts look correct.';

  @override
  String get settingsAttentionPromptpayTitle => 'Set up PromptPay';

  @override
  String get settingsAttentionPromptpayBody =>
      'Add a PromptPay ID to show QR at checkout.';

  @override
  String get settingsAttentionReview => 'Review';

  @override
  String get settingsDayClose => 'Day close';

  @override
  String get settingsBackupData => 'Backup & data';

  @override
  String settingsPreview(String section) {
    return '$section preview';
  }

  @override
  String get settingsModeLabel => 'Mode';

  @override
  String get settingsCatalogMode => 'Catalog';

  @override
  String get shopNamePlaceholder => 'Your shop name';

  @override
  String get shopAddressPlaceholder => 'No address set';

  @override
  String get shopPhonePlaceholder => 'No phone set';

  @override
  String get settingsDetails => 'Details';

  @override
  String get settingsPolicy => 'Policy';

  @override
  String get settingsOn => 'On';

  @override
  String get settingsOff => 'Off';

  @override
  String get cartPaymentInProgress =>
      'Payment in progress — cart is locked until you finish or cancel';

  @override
  String get backupRestoreTitle => 'Restore backup (this device)';

  @override
  String get backupRestoreConfirmTitle => 'Restore backup?';

  @override
  String get backupRestoreConfirmMessage =>
      'This replaces the current database on this device. A pre-restore copy is kept. Restart the app after restore. Same-device only (SQLCipher key must still exist).';

  @override
  String get backupRestoreSuccess =>
      'Restore complete. Please fully close and reopen the app.';

  @override
  String get backupRestorePlainUnsupported =>
      'Plain SQLite backups are not supported. Use a SQLCipher export from this app.';

  @override
  String get backupRestoreInvalid => 'Invalid backup file.';

  @override
  String get backupRestoreSourceMissing => 'Backup file not found.';

  @override
  String get backupConfirmExportTitle => 'Confirm backup export';

  @override
  String get backupConfirmRestoreTitle => 'Confirm backup restore';

  @override
  String get appLockTitle => 'Store PIN lock';

  @override
  String get appLockSubtitle => 'Protect void, backup, and PromptPay changes';

  @override
  String get appLockSectionTitle => 'Sensitive actions';

  @override
  String get appLockRequirePin => 'Require store PIN';

  @override
  String appLockRequirePinHint(int minutes) {
    return 'When enabled, void, backup export/restore, and PromptPay ID changes require PIN (session grace $minutes min).';
  }

  @override
  String get appLockCreatePin => 'Create store PIN';

  @override
  String get appLockEnterPin => 'Enter store PIN';

  @override
  String get appLockConfirmPin => 'Confirm PIN';

  @override
  String get appLockPinLabel => 'PIN';

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get appLockEnabled => 'Store PIN enabled';

  @override
  String get appLockDisabled => 'Store PIN disabled';

  @override
  String get appLockEnableFailed => 'Could not enable store PIN';

  @override
  String get appLockDisableNeedsPin => 'PIN required to disable';

  @override
  String appLockPinTooShort(int min) {
    return 'PIN must be at least $min digits';
  }

  @override
  String get appLockIncorrectPin => 'Incorrect PIN';

  @override
  String get appLockActionRequired => 'Action requires store PIN';

  @override
  String get appLockConfirmVoid => 'Confirm void with store PIN';

  @override
  String get appLockConfirmPromptPay => 'Confirm PromptPay change';

  @override
  String get appLockPinsMismatch => 'PINs do not match';
}
