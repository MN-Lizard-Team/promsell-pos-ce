// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Promsell POS';

  @override
  String get appTagline => 'ร้านค้าอัจฉริยะ';

  @override
  String get loading => 'กำลังโหลด...';

  @override
  String get navSale => 'ขาย';

  @override
  String get navProducts => 'สินค้า';

  @override
  String get navHistory => 'ประวัติ';

  @override
  String get navReport => 'รายงาน';

  @override
  String get navSettings => 'ตั้งค่า';

  @override
  String get salePageTitle => 'ขายสินค้า';

  @override
  String get clearCart => 'ล้าง';

  @override
  String get confirmClearCart => 'ยืนยันล้างตะกร้าทั้งหมด?';

  @override
  String get cartTitle => 'ตะกร้า';

  @override
  String get allCategories => 'ทั้งหมด';

  @override
  String get saleSearchProducts => 'ค้นหาสินค้าที่ขาย...';

  @override
  String get quickCashExact => 'รับพอดี';

  @override
  String get noProducts => 'ไม่มีสินค้า';

  @override
  String get saleSavedSuccess => 'บันทึกการขายเรียบร้อย';

  @override
  String productAddedToCart(String name) {
    return 'เพิ่ม $name แล้ว';
  }

  @override
  String get tapProductToAdd => 'แตะสินค้าเพื่อเพิ่มลงตะกร้า';

  @override
  String get noMatchingProducts => 'ไม่พบสินค้าที่ตรงกัน';

  @override
  String get stockLimitReached => 'ถึงจำนวนคงเหลือแล้ว';

  @override
  String get cartTotal => 'รวม';

  @override
  String checkout(int count) {
    return 'ชำระเงิน ($count)';
  }

  @override
  String get paymentTitle => 'ชำระเงิน';

  @override
  String get totalAmount => 'ยอดรวม';

  @override
  String get cash => 'เงินสด';

  @override
  String get transfer => 'โอน';

  @override
  String get card => 'บัตร';

  @override
  String receivedAmount(String currency) {
    return 'รับเงินมา ($currency)';
  }

  @override
  String get change => 'เงินทอน';

  @override
  String get confirmPayment => 'ยืนยันการชำระ';

  @override
  String get notePlaceholder => 'หมายเหตุ (ไม่บังคับ)';

  @override
  String get paymentReferenceOptional => 'เลขอ้างอิงการชำระเงิน (ไม่บังคับ)';

  @override
  String get saleError => 'บันทึกการขายไม่สำเร็จ';

  @override
  String get insufficientCash => 'เงินที่รับมายังไม่ครบยอด';

  @override
  String get productsTitle => 'สินค้า';

  @override
  String get searchProducts => 'ค้นหาสินค้า...';

  @override
  String get noProductsYet => 'ยังไม่มีสินค้า';

  @override
  String get errorOccurred => 'เกิดข้อผิดพลาด';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get noCategory => 'ไม่มีหมวดหมู่';

  @override
  String stockLabel(int count) {
    return 'คงเหลือ: $count';
  }

  @override
  String get edit => 'แก้ไข';

  @override
  String get delete => 'ลบ';

  @override
  String get deleteProduct => 'ลบสินค้า';

  @override
  String confirmDeleteProduct(String name) {
    return 'ยืนยันการลบ \"$name\"?';
  }

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get addProduct => 'เพิ่มสินค้า';

  @override
  String get editProductTitle => 'แก้ไขสินค้า';

  @override
  String get productNameLabel => 'ชื่อสินค้า *';

  @override
  String get productNameRequired => 'กรุณาใส่ชื่อสินค้า';

  @override
  String priceLabel(String currency) {
    return 'ราคา ($currency) *';
  }

  @override
  String get priceRequired => 'กรุณาใส่ราคา';

  @override
  String get invalidPrice => 'ราคาไม่ถูกต้อง';

  @override
  String get quantityLabel => 'จำนวน';

  @override
  String get quantityRequired => 'กรุณาใส่จำนวน';

  @override
  String get invalidQuantity => 'จำนวนไม่ถูกต้อง';

  @override
  String get categoryLabel => 'หมวดหมู่';

  @override
  String get showProduct => 'แสดงสินค้า';

  @override
  String get save => 'บันทึก';

  @override
  String get productSaved => 'บันทึกสินค้าแล้ว';

  @override
  String get stockZeroWarning => 'สินค้าจะไม่แสดงในหน้าขายเมื่อสต็อก = 0';

  @override
  String get historyTitle => 'ประวัติการขาย';

  @override
  String get searchHistoryHint => 'ค้นหาเลขใบเสร็จ วิธีชำระ ยอดรวม…';

  @override
  String get noSearchResults => 'ไม่พบรายการขายที่ตรงกัน';

  @override
  String get noSalesYet => 'ยังไม่มีรายการขาย';

  @override
  String get noDailyClosesYet => 'ยังไม่มีการปิดรับ';

  @override
  String noteLabel(String note) {
    return 'หมายเหตุ: $note';
  }

  @override
  String get reportTitle => 'รายงาน';

  @override
  String get totalRevenue => 'ยอดขายรวม';

  @override
  String salesCount(int count) {
    return '$count รายการ';
  }

  @override
  String get byPaymentMethod => 'แยกตามวิธีชำระ';

  @override
  String get topProducts => 'สินค้าขายดี (Top 5)';

  @override
  String units(int count) {
    return '$count ชิ้น';
  }

  @override
  String get settingsTitle => 'ตั้งค่า';

  @override
  String get searchSettings => 'ค้นหาการตั้งค่า...';

  @override
  String get pressBackAgainToExit => 'กดย้อนกลับอีกครั้งเพื่อออก';

  @override
  String get settingsGeneral => 'ทั่วไป';

  @override
  String get settingsStoreBusiness => 'ร้านค้าและธุรกิจ';

  @override
  String get settingsPayments => 'การชำระเงิน';

  @override
  String get settingsSystemData => 'ระบบและข้อมูล';

  @override
  String get settingsStatusComplete => 'สมบูรณ์';

  @override
  String get settingsStatusIncomplete => 'ยังไม่สมบูรณ์';

  @override
  String get settingsStatusActive => 'ใช้งานอยู่';

  @override
  String get settingsStatusNotSet => 'ยังไม่ตั้งค่า';

  @override
  String get settingsLanguage => 'ภาษา';

  @override
  String get settingsTheme => 'ธีม';

  @override
  String get settingsThemeLight => 'สว่าง';

  @override
  String get settingsThemeDark => 'มืด';

  @override
  String get settingsThemeSystem => 'ตามระบบ';

  @override
  String get settingsAccessibilityMode => 'ตัวอักษรใหญ่และคอนทราสต์สูง';

  @override
  String get settingsAccessibilityModeHint => 'ตัวอักษรใหญ่ขึ้น อ่านง่ายขึ้น';

  @override
  String get generalSettingsAppearance => 'รูปแบบ';

  @override
  String get generalSettingsLanguageRegion => 'ภาษาและภูมิภาค';

  @override
  String get generalSettingsReset => 'คืนค่าเริ่มต้น';

  @override
  String get generalSettingsResetConfirm =>
      'คืนค่าภาษา ธีม และการช่วยเหลือการเข้าถึงกลับเป็นค่าเริ่มต้น?';

  @override
  String get generalSettingsResetTitle => 'คืนค่าการตั้งค่าทั่วไป';

  @override
  String get generalSettingsInfoDescription =>
      'ภาษามีผลต่อป้ายและข้อความใบเสร็จทั้งหมด ธีมควบคุมโหมดสว่าง/มืด การช่วยเหลือการเข้าถึงเพิ่มความคมชัดและขนาดตัวอักษรให้เห็นชัดเจนขึ้น';

  @override
  String get settingsShopInfo => 'ข้อมูลร้าน';

  @override
  String get settingsShopName => 'ชื่อร้าน';

  @override
  String get settingsAddress => 'ที่อยู่';

  @override
  String get settingsPhone => 'เบอร์โทรศัพท์';

  @override
  String get settingsSales => 'การขาย';

  @override
  String get settingsCurrency => 'สกุลเงิน';

  @override
  String get settingsDateFormat => 'รูปแบบวันที่';

  @override
  String get settingsReceipt => 'ใบเสร็จ';

  @override
  String get settingsReceiptNote => 'หมายเหตุท้ายใบเสร็จ';

  @override
  String get settingsReceiptNoteHint => 'ขอบคุณที่อุดหนุน';

  @override
  String get settingsShowShopInfo => 'แสดงข้อมูลร้านในใบเสร็จ';

  @override
  String get settingsSectionContent => 'เนื้อหา';

  @override
  String get settingsSectionPreview => 'ตัวอย่าง';

  @override
  String get settingsSectionTax => 'ภาษี';

  @override
  String get settingsSaved => 'บันทึกการตั้งค่าแล้ว';

  @override
  String get shopNameRequired => 'กรุณากรอกชื่อร้าน';

  @override
  String get shopNameTooLong => 'ชื่อร้านยาวเกินไป';

  @override
  String get addressTooLong => 'ที่อยู่ยาวเกินไป';

  @override
  String get phoneInvalid => 'เบอร์โทรศัพท์ไม่ถูกต้อง';

  @override
  String get shopInfoEmptyPreview => 'ข้อมูลร้านจะปรากฏที่นี่';

  @override
  String get langThai => 'ภาษาไทย';

  @override
  String get langEnglish => 'English';

  @override
  String get printReceipt => 'พิมพ์ใบเสร็จ';

  @override
  String get shareReceipt => 'แชร์ใบเสร็จ';

  @override
  String get receiptLabelReceipt => 'ใบเสร็จ';

  @override
  String get receiptLabelPayment => 'ชำระเงิน';

  @override
  String get receiptLabelTotal => 'รวม';

  @override
  String get receiptLabelReceived => 'รับเงิน';

  @override
  String get receiptLabelChange => 'ทอน';

  @override
  String get receiptLabelNote => 'หมายเหตุ';

  @override
  String get receiptLabelVat => 'ภาษีมูลค่าเพิ่ม';

  @override
  String receiptLabelVatIncluded(Object rate) {
    return 'VAT $rate% (รวมแล้ว)';
  }

  @override
  String get receiptLabelSubtotal => 'ย่อยรวม';

  @override
  String get settingsAutoPrintPrompt => 'ถามพิมพ์ใบเสร็จหลังขาย';

  @override
  String get settingsVatRate => 'อัตรา VAT (%)';

  @override
  String get settingsVatMode => 'โหมด VAT';

  @override
  String get settingsReceiptPreviewStyle => 'รูปแบบตัวอย่างใบเสร็จ';

  @override
  String get settingsShowPreSalePreview => 'แสดงตัวอย่างใบเสร็จก่อนชำระ';

  @override
  String get settingsShowPostSalePreview => 'แสดงตัวอย่างใบเสร็จหลังขาย';

  @override
  String get receiptPreviewStyleThermal => 'กระดาษความร้อน';

  @override
  String get receiptPreviewStyleCard => 'การ์ด';

  @override
  String get receiptPreviewStyleNone => 'ไม่แสดง';

  @override
  String get receiptPreview => 'ตัวอย่างใบเสร็จ';

  @override
  String get vatModeNone => 'ไม่มี';

  @override
  String get vatModeInclusive => 'รวมแล้ว';

  @override
  String get vatModeExclusive => 'แยกนอก';

  @override
  String get voided => 'ยกเลิกแล้ว';

  @override
  String get voidSale => 'ยกเลิกบิล';

  @override
  String get voidSaleConfirm => 'ยกเลิกบิลนี้? สต็อกจะถูกคืน';

  @override
  String get voidReasonHint => 'เหตุผลในการยกเลิก (ไม่บังคับ)';

  @override
  String get voidSuccess => 'ยกเลิกบิลแล้ว';

  @override
  String voidedSalesCount(int count) {
    return '$count รายการยกเลิก';
  }

  @override
  String get voidedTotal => 'ยอดที่ถูกยกเลิก';

  @override
  String get netRevenue => 'ยอดขายสุทธิ';

  @override
  String get adjustStock => 'ปรับสต็อก';

  @override
  String adjustStockTitle(String name) {
    return 'ปรับสต็อก: $name';
  }

  @override
  String get adjustQtyLabel => 'จำนวนที่เปลี่ยน (+/-)';

  @override
  String get adjustReasonLabel => 'เหตุผล *';

  @override
  String get adjustReasonRequired => 'กรุณาระบุเหตุผล';

  @override
  String get adjustSuccess => 'ปรับสต็อกแล้ว';

  @override
  String get inventoryLog => 'ประวัติสต็อก';

  @override
  String get noInventoryLogs => 'ยังไม่มีประวัติสต็อก';

  @override
  String get invLogTypeSale => 'ขาย';

  @override
  String get invLogTypeVoidReversal => 'ยกเลิกบิล';

  @override
  String get invLogTypeStockIn => 'รับสต็อก';

  @override
  String get invLogTypeStockOut => 'ตัดสต็อก';

  @override
  String get productFormSectionBasicInfo => 'ข้อมูลพื้นฐาน';

  @override
  String get tabInfo => 'ข้อมูล';

  @override
  String get tabPrice => 'ราคา';

  @override
  String get tabStock => 'สต็อก';

  @override
  String get productFormSectionDetails => 'รายละเอียด';

  @override
  String get productFormImageUrlLabel => 'URL รูปภาพ (ไม่บังคับ)';

  @override
  String get trackStock => 'ติดตามสต็อค';

  @override
  String get trackStockHint => 'ปิดเพื่อสินค้าประเภทบริการ (ไม่ตัดสต็อค)';

  @override
  String get settingsStockPolicy => 'นโยบายสต็อค';

  @override
  String get allowOversell => 'อนุญาตขายเกินสต็อค';

  @override
  String get allowOversellHint => 'อนุญาตให้เพิ่มสินค้าเกินจำนวนคงเหลือได้';

  @override
  String get lowStockThreshold => 'เตือนสต็อคต่ำ (จำนวน)';

  @override
  String get lowStockWarning => 'สต็อคใกล้หมด';

  @override
  String get discountSectionLabel => 'ส่วนลด';

  @override
  String get discountDialogTitle => 'ใส่ส่วนลด';

  @override
  String get discountTypePercent => '% ประเภทเปอร์เซ็นต์';

  @override
  String get discountTypeAmount => 'บาท';

  @override
  String discountPreview(String amount) {
    return 'หลังหัก: $amount';
  }

  @override
  String get discountApply => 'ใช้ส่วนลด';

  @override
  String get discountClear => 'ลบส่วนลด';

  @override
  String get cartDiscount => 'ส่วนลดทั้งบิล';

  @override
  String get applyCartDiscount => 'เพิ่มส่วนลดทั้งบิล';

  @override
  String discountLabel(String amount) {
    return '-$amount';
  }

  @override
  String get discountValueRequired => 'กรุณาใส่จำนวนส่วนลด';

  @override
  String get discountValueInvalid => 'ส่วนลดไม่ถูกต้อง';

  @override
  String get preTaxTotal => 'ยอดก่อภาษี';

  @override
  String get settingsDiscountPolicy => 'นโยบายส่วนลด';

  @override
  String get enableItemDiscount => 'เปิดใช้ส่วนลดต่อรายการ';

  @override
  String get enableCartDiscount => 'เปิดใช้ส่วนลดต่อบิล';

  @override
  String get maxDiscountPercent => 'ส่วนลดสูงสุด (%)';

  @override
  String get maxDiscountAmount => 'ส่วนลดสูงสุด (บาท)';

  @override
  String get maxAmountNoLimit => 'ไม่จำกัด';

  @override
  String get defaultDiscountType => 'ประเภทส่วนลดเริ่มต้น';

  @override
  String get presetDiscountValues => 'ค่าส่วนลดเร็ว (คั่นด้วย ,)';

  @override
  String get discountPresetsTitle => 'ชุดส่วนลด';

  @override
  String get discountPresetName => 'ชื่อชุด';

  @override
  String get discountPresetType => 'ประเภท';

  @override
  String get discountPresetValues => 'ค่าส่วนลด';

  @override
  String get addDiscountPreset => 'เพิ่มชุดส่วนลด';

  @override
  String get deleteDiscountPreset => 'ลบชุด';

  @override
  String get activeDiscountPreset => 'ใช้งานอยู่';

  @override
  String get editDiscountPreset => 'แก้ไขชุดส่วนลด';

  @override
  String get noDiscountPresets => 'ยังไม่มีชุดส่วนลด';

  @override
  String get addPresetValue => 'เพิ่มค่า';

  @override
  String get receiptItemDiscounts => 'ส่วนลดรายการ';

  @override
  String get receiptCartDiscount => 'ส่วนลดบิล';

  @override
  String get draftsTitle => 'บิลที่บันทึก';

  @override
  String get newDraft => 'บิลใหม่';

  @override
  String get renameDraft => 'เปลี่ยนชื่อ';

  @override
  String get deleteDraft => 'ลบบิล';

  @override
  String get deleteDraftConfirm => 'ยืนยันลบบิลนี้?';

  @override
  String get draftLimitReached => 'บิลเต็ม  10 บิลแล้ว กรุณาลบบิลเก่าก่อน';

  @override
  String get activeDraftLabel => 'ใช้งานอยู่';

  @override
  String get draftNameHint => 'ชื่อบิล (ไม่บังคับ)';

  @override
  String get switchDraft => 'สลับไปบิลนี้';

  @override
  String get cartCleared => 'ล้างตะกร้าแล้ว';

  @override
  String get undo => 'เรียกคืน';

  @override
  String get itemRemoved => 'ลบรายการแล้ว';

  @override
  String get removeItem => 'ลบรายการ';

  @override
  String get itemsLabel => 'รายการ';

  @override
  String get searchCartItems => 'ค้นหาสินค้าในตะกร้า...';

  @override
  String get searchDrafts => 'ค้นหาบิล...';

  @override
  String get untitledDraft => 'บิลใหม่';

  @override
  String get noMatchingItems => 'ไม่พบสินค้าที่ตรงกัน';

  @override
  String get noMatchingDrafts => 'ไม่พบบิลที่ตรงกัน';

  @override
  String get groupView => 'มุมมองแบบกลุ่ม';

  @override
  String get listView => 'มุมมองรายการ';

  @override
  String get gridView => 'มุมมองตาราง';

  @override
  String get cartSizeMini => 'เล็ก';

  @override
  String get cartSizeHalf => 'ปกติ';

  @override
  String get cartSizeFull => 'เต็ม';

  @override
  String get cartCompactNormal => 'ขนาดปกติ';

  @override
  String get cartCompactCompact => 'กะทัดรัด';

  @override
  String get cartCompactUltra => 'กะทัดรัดมาก';

  @override
  String get atStockLimit => 'สินค้าหมดสต็อก';

  @override
  String get justNow => 'เมื่อสักครู่';

  @override
  String timeAgoMinutes(int m) {
    return '$m นาทีที่แล้ว';
  }

  @override
  String timeAgoHours(int h) {
    return '$h ชั่วโมงที่แล้ว';
  }

  @override
  String timeAgoDays(int d) {
    return '$d วันที่แล้ว';
  }

  @override
  String searchResultsCount(int n) {
    return '$n รายการ';
  }

  @override
  String confirmPaymentAmount(String currency, String amount) {
    return 'ยืนยัน $currency$amount';
  }

  @override
  String discountPreviewPercent(String value) {
    return 'หลังหัก: $value%';
  }

  @override
  String get pickImageGallery => 'เลือกจากคลังรูป';

  @override
  String get pickImageCamera => 'ถ่ายรูป';

  @override
  String get removeImage => 'ลบรูป';

  @override
  String get imagePickError => 'ไม่สามารถเลือกรูปได้';

  @override
  String get promptpay => 'พร้อมเพย์';

  @override
  String get settingsPromptpayId => 'PromptPay ID';

  @override
  String get settingsPromptpayIdHint => 'เบอร์โทรหรือเลขบัตรประชาชน';

  @override
  String get promptpayQrTitle => 'สแกนจ่ายเงิน';

  @override
  String get promptpayConfirmPayment => 'ยืนยันรับเงินแล้ว';

  @override
  String get promptpayNotConfigured => 'ยังไม่ได้ตั้งค่า PromptPay';

  @override
  String get promptpaySettingsHint => 'ไปตั้งค่า';

  @override
  String get promptpayAccount => 'บัญชี';

  @override
  String get promptpayScanToPay => 'สแกนจ่ายเงิน';

  @override
  String get promptpayQrPreview => 'ตัวอย่าง QR รับเงิน';

  @override
  String get promptpayInfoDescription =>
      'ป้อน PromptPay ID (เบอร์โทรหรือเลขบัตรประชาชน) เพื่อรับเงินผ่าน QR Code';

  @override
  String get promptpayInvalidId =>
      'กรุณากรอกเบอร์โทรหรือเลขบัตรประชาชนที่ถูกต้อง';

  @override
  String get promptpayWaitingForPayment => 'รอลูกค้าชำระเงิน...';

  @override
  String get promptpayPaymentTimeout => 'หมดเวลาชำระเงิน ยกเลิกการขาย';

  @override
  String get promptpayExtendTime => 'ขยายเวลา +1 นาที';

  @override
  String get promptpayCancelPayment => 'ยกเลิกการชำระ';

  @override
  String get promptpayTransactionReference => 'เลขอ้างอิง (ถ้ามี)';

  @override
  String get promptpayQrSaved => 'บันทึก QR ลงแกลเลอรีแล้ว';

  @override
  String get promptpayQrShared => 'แชร์ QR แล้ว';

  @override
  String get promptpaySaveQr => 'บันทึก QR';

  @override
  String get promptpayShareQr => 'แชร์ QR';

  @override
  String get promptpaySoundEnabled => 'เสียงตอนยืนยัน';

  @override
  String get promptpayTimeoutSetting => 'เวลานับถอยหลัง (นาที)';

  @override
  String get minutes => 'นาที';

  @override
  String get slipScanTitle => 'สแกนสลิปธนาคาร';

  @override
  String get slipScanHint => 'จัด QR code บนสลิปให้อยู่ในกรอบ';

  @override
  String get slipScanSuccess => 'ตรวจสอบสลิปสำเร็จ';

  @override
  String get slipScanInvalid => 'สลิปไม่ถูกต้อง';

  @override
  String get slipErrorEmpty => 'ไม่พบข้อมูลใน QR code';

  @override
  String get slipErrorNotASlip =>
      'นี่คือ QR ชำระเงิน ไม่ใช่สลิปธนาคาร กรุณาสแกน QR บนสลิปโอนเงิน';

  @override
  String get slipErrorUnreadable => 'อ่านสลิปไม่ได้ กรุณาลองใหม่';

  @override
  String get promptpayInvalidQr => 'QR code ไม่ถูกต้อง';

  @override
  String get settingsBillerId => 'รหัสผู้เรียกเก็บเงิน';

  @override
  String get settingsBillerIdHint =>
      'เลขประจำตัวผู้เสียภาษีสำหรับ QR ใบแจ้งหนี้';

  @override
  String get settingsDefaultQrType => 'QR เริ่มต้น';

  @override
  String get settingsDefaultQrTypeTransfer => 'โอนเงิน';

  @override
  String get settingsDefaultQrTypeBill => 'จ่ายบิล';

  @override
  String get settingsAutoConfirmAfterSlip => 'ยืนยันอัตโนมัติหลังสแกนสลิป';

  @override
  String get settingsAutoConfirmAfterSlipHint =>
      'ยืนยันการชำระเงินอัตโนมัติ 2 วินาทีหลังตรวจสอบสลิปสำเร็จ';

  @override
  String get settingsQrOverlayIcon => 'ไอคอน QR';

  @override
  String get cart => 'ตะกร้า';

  @override
  String get moreItems => 'รายการอื่น';

  @override
  String get total => 'รวม';

  @override
  String get waitingForPayment => 'รอการชำระเงิน...';

  @override
  String get copyPromptpayId => 'คัดลอกแล้ว';

  @override
  String get paymentVerified => 'ชำระเงินยืนยันแล้ว';

  @override
  String get showMore => 'แสดงเพิ่ม';

  @override
  String get showLess => 'แสดงน้อยลง';

  @override
  String itemsCount(Object count) {
    return '$count รายการ';
  }

  @override
  String get settingsReceiptSize => 'ขนาดใบเสร็จ';

  @override
  String get receiptSize80mm => '80mm (กระดาษความร้อน)';

  @override
  String get receiptSizeA4 => 'A4';

  @override
  String get settingsMaxDrafts => 'บิลสูงสุด';

  @override
  String get settingsCompactCartMode => 'โหมดตะกร้ากะทัดรัด';

  @override
  String get settingsUltraCompactMode => 'โหมดกะทัดรัดมาก';

  @override
  String get settingsUltraCompactModeHint =>
      'รายการเล็กลงเพื่อความหนาแน่นสูงสุด';

  @override
  String get settingsCompactModeSubtitle => 'แถวสินค้าเล็กลง มองเห็นได้มากขึ้น';

  @override
  String get settingsUltraModeOverrides => 'แทนที่โหมดกะทัดรัด';

  @override
  String get settingsUltraModeSubtitle => 'ระยะห่างน้อยที่สุด แสดงได้มากที่สุด';

  @override
  String get settingsOversellAllowed => 'อนุญาตขายเกิน';

  @override
  String get settingsImages => 'รูปภาพ';

  @override
  String get settingsImageMaxWidth => 'ความกว้างสูงสุด (px)';

  @override
  String get settingsImageQuality => 'คุณภาพ (%)';

  @override
  String get imageWidthSmall => 'เล็ก';

  @override
  String get imageWidthMedium => 'กลาง';

  @override
  String get imageWidthLarge => 'ใหญ่';

  @override
  String get imageWidthExtraLarge => 'ใหญ่พิเศษ';

  @override
  String get imageWidthFullHD => 'เต็มจอ';

  @override
  String get imageQualityDraft => 'ร่าง';

  @override
  String get imageQualityStandard => 'มาตรฐาน';

  @override
  String get imageQualityHigh => 'สูง';

  @override
  String get imageQualityBest => 'ดีที่สุด';

  @override
  String get imageQualityOriginal => 'ต้นฉบับ';

  @override
  String get imageExample => 'ตัวอย่าง';

  @override
  String get settingsBackup => 'สำรองข้อมูล';

  @override
  String get settingsData => 'ข้อมูล';

  @override
  String get exportDatabase => 'ส่งออกฐานข้อมูล (สำรองข้อมูลเต็มรูปแบบ)';

  @override
  String get exportSalesCsv => 'ส่งออกยอดขาย (CSV)';

  @override
  String get exportProductsCsv => 'ส่งออกสินค้า (CSV)';

  @override
  String get restoreFromBackup => 'กู้คืนจากสำรอง...';

  @override
  String get restoreConfirmTitle => 'ยืนยันกู้คืนข้อมูล?';

  @override
  String get restoreConfirmMessage =>
      'ข้อมูลปัจจุบันจะถูกเขียนทับ ดำเนินการต่อ?';

  @override
  String get restoreSuccess => 'กู้คืนข้อมูลสำเร็จ';

  @override
  String get restoreError => 'กู้คืนข้อมูลไม่สำเร็จ';

  @override
  String get backupReminderTitle => 'แนะนำสำรองข้อมูล';

  @override
  String backupReminderMessage(int days) {
    return 'ยังไม่ได้สำรองข้อมูลมากกว่า $days วัน';
  }

  @override
  String get settingsBackupReminderDays => 'เตือนสำรองข้อมูล (วัน, 0=ปิด)';

  @override
  String get backupWeekly => 'รายสัปดาห์';

  @override
  String get backupBiweekly => '2 สัปดาห์';

  @override
  String get backupMonthly => 'รายเดือน';

  @override
  String get backupBimonthly => '2 เดือน';

  @override
  String get backupQuarterly => '3 เดือน';

  @override
  String get backupLastBackup => 'สำรองล่าสุด';

  @override
  String get backupToday => 'วันนี้';

  @override
  String get backupYesterday => 'เมื่อวาน';

  @override
  String backupDaysAgo(int days) {
    return '$days วันที่แล้ว';
  }

  @override
  String get backupStatusSafe => 'ปลอดภัย';

  @override
  String get backupStatusWarning => 'ใกล้ครบกำหนด';

  @override
  String get backupStatusOverdue => 'ล่าช้า';

  @override
  String get backupNow => 'สำรองเลย';

  @override
  String get backupSuccess => 'สำรองข้อมูลสำเร็จ';

  @override
  String get backupReminderLabel => 'เตือนสำรองข้อมูล';

  @override
  String get backupFrequency => 'ความถี่';

  @override
  String backupEveryNDays(int n) {
    return 'ทุก $n วัน';
  }

  @override
  String get backupOff => 'ปิด';

  @override
  String get backupActionTitle => 'สำรองข้อมูลด้วยตนเอง';

  @override
  String get backupActionSubtitle => 'แตะเพื่อบันทึกว่าคุณได้สำรองข้อมูลแล้ว';

  @override
  String get backupEncryptionTitle => 'การเข้ารหัสสำรองข้อมูล';

  @override
  String get backupEncryptionLabel => 'เข้ารหัสไฟล์สำรอง';

  @override
  String get backupEncryptionDesc =>
      'ปกป้องไฟล์สำรองด้วยการเข้ารหัส AES-256-GCM (ต้องใส่ PIN)';

  @override
  String get backupInfoDescription =>
      'สำรองข้อมูลเป็นประจำเพื่อป้องกันข้อมูลการขาย สินค้า และการตั้งค่าของคุณ';

  @override
  String get exportSuccess => 'ส่งออกสำเร็จ';

  @override
  String bulkSelected(int count) {
    return 'เลือกแล้ว $count รายการ';
  }

  @override
  String get bulkClearDiscount => 'ล้างส่วนลด';

  @override
  String get bulkDelete => 'ลบรายการ';

  @override
  String get reorderItem => 'ลากเพื่อจัดเรียง';

  @override
  String get dailyCloseTitle => 'ปิดยอดประจำวัน';

  @override
  String get dailyCloseHistoryTitle => 'ประวัติปิดยอด';

  @override
  String get closeToday => 'ปิดยอดวันนี้';

  @override
  String get closeDay => 'ปิดยอด';

  @override
  String get reopenDay => 'เปิดยอดใหม่';

  @override
  String get closeDayConfirmTitle => 'ปิดยอด?';

  @override
  String get closeDayConfirmMessage =>
      'การดำเนินการนี้จะล็อกวันและบันทึกการตรวจสอบยอด';

  @override
  String get reopenDayConfirmTitle => 'เปิดยอดใหม่?';

  @override
  String get reopenDayConfirmMessage =>
      'การดำเนินการนี้จะปลดล็อกวัน การขายจะถูกนับเข้ายอดใหม่';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get dbHealthTitle => 'สุขภาพฐานข้อมูล';

  @override
  String get dbHealthFileSize => 'ขนาดไฟล์ฐานข้อมูล';

  @override
  String get dbHealthLarge => 'ใหญ่';

  @override
  String get dbHealthOk => 'ปกติ';

  @override
  String get dbHealthLargeTitle => 'ฐานข้อมูลมีขนาดใหญ่';

  @override
  String get dbHealthLargeMessage =>
      'ฐานข้อมูลของคุณมีขนาดเกิน 50 MB พิจารณาสำรองข้อมูลและเก็บข้อมูลเก่า';

  @override
  String get dbHealthRowCounts => 'จำนวนแถว';

  @override
  String get dbHealthVacuum => 'บีบอัดฐานข้อมูล';

  @override
  String get dbHealthVacuumDescription =>
      'บีบอัดจะสร้างไฟล์ฐานข้อมูลใหม่เพื่อคืนพื้นที่ว่างและลดการแตกกระจาย';

  @override
  String get onboardingWelcome => 'ยินดีต้อนรับ';

  @override
  String get onboardingShopInfoTitle => 'ข้อมูลร้าน';

  @override
  String get onboardingShopNameLabel => 'ชื่อร้าน';

  @override
  String get onboardingShopNameHint => 'ร้านค้าของฉัน';

  @override
  String get onboardingAddressLabel => 'ที่อยู่';

  @override
  String get onboardingAddressHint => '123 ถนนหลัก';

  @override
  String get onboardingPhoneLabel => 'เบอร์โทรศัพท์';

  @override
  String get onboardingPhoneHint => '0812345678';

  @override
  String get onboardingPromptPayTitle => 'พร้อมเพย์';

  @override
  String get onboardingPromptPaySubtitle =>
      'ป้อนรหัสพร้อมเพย์เพื่อรับชำระผ่าน QR';

  @override
  String get onboardingPromptPayIdLabel => 'รหัสพร้อมเพย์';

  @override
  String get onboardingPromptPayIdHint =>
      'เบอร์โทร (10 หลัก) หรือบัตรประชาชน (13 หลัก)';

  @override
  String get onboardingVatRateLabel => 'อัตรา VAT %';

  @override
  String get onboardingSkip => 'ข้ามไปก่อน';

  @override
  String get onboardingSkipSetup => 'ข้ามการตั้งค่า';

  @override
  String get onboardingWelcomeTitle => 'ยินดีต้อนรับสู่ Promsell POS';

  @override
  String get onboardingWelcomeSubtitle =>
      'ระบบ POS มือถือออฟไลน์\nมาตั้งค่าร้านค้าของคุณในไม่กี่ขั้นตอน';

  @override
  String get onboardingLocaleCurrencyTitle => 'ภาษาและสกุลเงิน';

  @override
  String get onboardingAllSet => 'พร้อมแล้ว!';

  @override
  String get onboardingReadyToSell => 'ร้านค้าของคุณถูกตั้งค่าและพร้อมขายแล้ว';

  @override
  String get onboardingShopInfo => 'ข้อมูลร้าน';

  @override
  String get onboardingLocaleCurrency => 'ภาษาและสกุลเงิน';

  @override
  String get onboardingTaxSetup => 'ตั้งค่าภาษี';

  @override
  String get onboardingPromptPay => 'พร้อมเพย์';

  @override
  String get onboardingDone => 'เสร็จสิ้น';

  @override
  String get onboardingBack => 'ย้อนกลับ';

  @override
  String get onboardingNext => 'ถัดไป';

  @override
  String get onboardingGetStarted => 'เริ่มต้นใช้งาน';

  @override
  String get onboardingStartSelling => 'เริ่มขาย';

  @override
  String get onboardingLanguage => 'ภาษา';

  @override
  String get onboardingThai => 'ไทย';

  @override
  String get onboardingEnglish => 'อังกฤษ';

  @override
  String get onboardingCurrency => 'สกุลเงิน';

  @override
  String get onboardingDateFormat => 'รูปแบบวันที่';

  @override
  String get onboardingVatMode => 'โหมด VAT (ไม่บังคับ)';

  @override
  String get onboardingNone => 'ไม่มี';

  @override
  String get onboardingInclusive => 'รวมในราคา';

  @override
  String get onboardingExclusive => 'แยกจากราคา';

  @override
  String dailyCloseLoadError(String message) {
    return 'ข้อผิดพลาด: $message';
  }

  @override
  String dailyCloseSales(int count) {
    return 'ยอดขาย: $count';
  }

  @override
  String dailyCloseVoids(int count) {
    return 'ยกเลิก: $count';
  }

  @override
  String get settingsDailyCloseTitle => 'ปิดยอดประจำวัน';

  @override
  String get settingsDailyCloseSubtitle => 'การตรวจสอบยอดประจำวัน';

  @override
  String get settingsDbHealthTitle => 'สุขภาพฐานข้อมูล';

  @override
  String get settingsDbHealthSubtitle => 'ขนาด จำนวนแถว บีบอัด';

  @override
  String get settingsDailyCloseLockTitle => 'บล็อกการขายหลังปิดยอด';

  @override
  String get settingsDailyCloseLockSubtitle =>
      'เมื่อเปิดใช้งาน การขายใหม่จะถูกบล็อกหากวันนี้ปิดยอดแล้ว';

  @override
  String get dbHealthVacuumSuccess => 'บีบอัดฐานข้อมูลสำเร็จ';

  @override
  String dbHealthVacuumFailed(String error) {
    return 'บีบอัดล้มเหลว: $error';
  }

  @override
  String dbHealthError(String message) {
    return 'ข้อผิดพลาด: $message';
  }

  @override
  String get dayClosedMessage => 'วันนี้ปิดยอดแล้ว กรุณาเปิดยอดใหม่เพื่อขายต่อ';

  @override
  String get tapToSet => 'แตะเพื่อตั้งค่า';

  @override
  String get shopNameHint => 'ชื่อร้านค้า';

  @override
  String get addressHint => 'ที่อยู่ร้านค้า';

  @override
  String get phoneHint => '081-234-5678';

  @override
  String get categoryManagementTitle => 'จัดการหมวดหมู่';

  @override
  String get noCategoriesYet => 'ยังไม่มีหมวดหมู่';

  @override
  String get uncategorized => 'ไม่มีหมวดหมู่';

  @override
  String get searchCategories => 'ค้นหาหมวดหมู่...';

  @override
  String get addCategory => 'เพิ่มหมวดหมู่';

  @override
  String get editCategory => 'แก้ไขหมวดหมู่';

  @override
  String get deleteCategoryConfirm => 'ยืนยันการลบหมวดหมู่?';

  @override
  String get categoryName => 'ชื่อหมวดหมู่';

  @override
  String get categoryNameRequired => 'กรุณาใส่ชื่อหมวดหมู่';

  @override
  String get categoryNameExists => 'ชื่อหมวดหมู่นี้มีอยู่แล้ว';

  @override
  String get categoryInUse => 'ไม่สามารถลบหมวดหมู่ที่มีสินค้าได้';

  @override
  String get chooseCategory => 'เลือกหมวดหมู่';

  @override
  String get manageCategories => 'จัดการหมวดหมู่';

  @override
  String get sortOrder => 'ลำดับ';

  @override
  String get sortOrderRequired => 'กรุณาใส่ลำดับ';

  @override
  String get categoryColor => 'สี';

  @override
  String get categoryIcon => 'ไอคอน';

  @override
  String get invalidNumber => 'ตัวเลขไม่ถูกต้อง';

  @override
  String get addProductTitle => 'เพิ่มสินค้า';

  @override
  String get noCategorySelected => 'ยังไม่เลือกหมวดหมู่';

  @override
  String get noProductsInCategory => 'ไม่มีสินค้าในหมวดหมู่นี้';

  @override
  String get clearFilters => 'ล้างตัวกรอง';

  @override
  String get startTypingToSearch => 'เริ่มพิมพ์เพื่อค้นหา';

  @override
  String get searchByNameSkuBarcode => 'ค้นหาด้วยชื่อ, SKU, หรือบาร์โค้ด';

  @override
  String get tryDifferentKeyword => 'ลองคำค้นหาอื่น';

  @override
  String get clearSearch => 'ล้างการค้นหา';

  @override
  String get inactive => 'ไม่ใช้งาน';

  @override
  String get na => 'ไม่ระบุ';

  @override
  String get skuLabel => 'SKU';

  @override
  String get barcodeLabel => 'บาร์โค้ด';

  @override
  String get outOfStockShort => 'หมด';

  @override
  String get productsCount => 'สินค้า';

  @override
  String get lowStock => 'เหลือน้อย';

  @override
  String get outOfStock => 'หมดสต็อก';

  @override
  String get saveDraft => 'บันทึกร่าง';

  @override
  String get discardDraft => 'ทิ้งร่าง';

  @override
  String get restoreDraft => 'กู้คืนร่าง?';

  @override
  String get draftSaved => 'บันทึกร่างแล้ว';

  @override
  String get unsavedChangesMessage => 'มีการเปลี่ยนแปลงที่ยังไม่บันทึก';

  @override
  String get restore => 'กู้คืน';
}
