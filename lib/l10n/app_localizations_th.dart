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
  String get navHome => 'หน้าหลัก';

  @override
  String get navSale => 'ขายสินค้า';

  @override
  String get navProducts => 'สินค้า';

  @override
  String get navHistory => 'ประวัติการขาย';

  @override
  String get navReport => 'สรุปยอด';

  @override
  String get navSettings => 'ตั้งค่า';

  @override
  String get salePageTitle => 'ขายสินค้า';

  @override
  String get salePageSubtitle => 'เพิ่มสินค้าและทำรายการขาย';

  @override
  String get saleBillNoteTitle => 'หมายเหตุบิล';

  @override
  String get dragToResizeCart => 'ลากเพื่อปรับขนาดตะกร้า';

  @override
  String get exitCompactMode => 'ออกจากโหมดกะทัดรัด';

  @override
  String get exitCompactModeConfirm => 'สลับเป็นมุมมองตะกร้าปกติ?';

  @override
  String autoConfirmingIn(int secs) {
    return 'ยืนยันอัตโนมัติใน $secs...';
  }

  @override
  String get clearCart => 'ล้าง';

  @override
  String get confirmClearCart => 'ยืนยันล้างตะกร้าทั้งหมด?';

  @override
  String get cartTitle => 'บิล';

  @override
  String get cartEmpty => 'ตะกร้าว่าง';

  @override
  String get backToSale => 'กลับไปขายสินค้า';

  @override
  String get checkoutButton => 'ชำระเงิน';

  @override
  String get addItems => 'เพิ่มสินค้า';

  @override
  String itemRemoved(String name) {
    return 'ลบ $name แล้ว';
  }

  @override
  String get undo => 'ยกเลิก';

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
  String get saleSuccessTitle => 'ชำระเงินสำเร็จ';

  @override
  String saleSuccessSubtitle(String number) {
    return 'ใบเสร็จ #$number';
  }

  @override
  String get changeDue => 'เงินทอน';

  @override
  String get nextSale => 'ขายบิลถัดไป';

  @override
  String productAddedToCart(String name) {
    return 'เพิ่ม $name แล้ว';
  }

  @override
  String get tapProductToAdd => 'แตะสินค้าเพื่อเพิ่มในบิลนี้';

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
  String get totalAmount => 'ยอดชำระ';

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
  String get saleTimeout => 'หมดเวลารอการชำระเงิน กรุณาลองอีกครั้ง';

  @override
  String get insufficientCash => 'เงินที่รับมายังไม่ครบยอด';

  @override
  String get remainingAmount => 'ยอดขาด';

  @override
  String get productsTitle => 'สินค้า';

  @override
  String get searchProducts => 'ค้นหาสินค้า บาร์โค้ด และ อื่นๆ...';

  @override
  String get searchProductsHint => 'แตะเพื่อค้นหาสินค้า บาร์โค้ด และอื่นๆ...';

  @override
  String get tapToSearch => 'แตะเพื่อค้นหา';

  @override
  String get searchActive => 'กำลังค้นหา';

  @override
  String get recentSearches => 'ค้นหาล่าสุด';

  @override
  String get noProductsYet => 'ยังไม่มีสินค้า';

  @override
  String get noProductsYetHint =>
      'เพิ่มสินค้าชิ้นแรกของคุณหรือนำเข้าจาก CSV เพื่อเริ่มต้น';

  @override
  String get errorOccurred => 'เกิดข้อผิดพลาด';

  @override
  String get receiptPrintFailed =>
      'การพิมพ์ล้มเหลว กรุณาตรวจสอบเครื่องพิมพ์แล้วลองอีกครั้ง';

  @override
  String get receiptShareFailed => 'ไม่สามารถแชร์ใบเสร็จได้ กรุณาลองอีกครั้ง';

  @override
  String get receiptPdfFailed => 'ไม่สามารถสร้าง PDF ใบเสร็จได้';

  @override
  String get receiptPrintSuccess => 'พิมพ์ใบเสร็จสำเร็จ';

  @override
  String get receiptShareSuccess => 'แชร์ใบเสร็จสำเร็จ';

  @override
  String get receiptTaxInvoice => 'ใบกำกับภาษี';

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get noCategory => 'ไม่มีหมวดหมู่';

  @override
  String stockLabel(int count) {
    return 'คงเหลือ: $count';
  }

  @override
  String stockRemaining(int count) {
    return 'เหลือ: $count';
  }

  @override
  String get itemNoteLabel => 'หมายเหตุสินค้า';

  @override
  String get itemNoteHint => 'เพิ่มหมายเหตุสำหรับสินค้านี้';

  @override
  String get duplicateItem => 'คัดลอกรายการแล้ว';

  @override
  String get duplicateItemAction => 'คัดลอกรายการ';

  @override
  String get clear => 'ล้าง';

  @override
  String get edit => 'แก้ไข';

  @override
  String get delete => 'ลบ';

  @override
  String get activate => 'เปิดใช้งาน';

  @override
  String get deactivate => 'ปิดการใช้งาน';

  @override
  String get deleteProduct => 'ลบสินค้า';

  @override
  String confirmDeleteProduct(String name) {
    return 'ยืนยันการลบ \"$name\"?';
  }

  @override
  String productDeactivateConfirm(String name) {
    return 'ปิดการใช้งาน \"$name\"? สินค้านี้จะถูกซ่อนจากหน้าขาย';
  }

  @override
  String productActivateConfirm(String name) {
    return 'เปิดใช้งาน \"$name\"? สินค้านี้จะแสดงบนหน้าขาย';
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
  String get productNameHint => 'เช่น อเมริกาโน้เย็น แกรนด์';

  @override
  String get productNameRequired => 'กรุณาใส่ชื่อสินค้า';

  @override
  String get productNameTooLong => 'ชื่อสินค้ายาวเกินไป (สูงสุด 100 ตัวอักษร)';

  @override
  String get quickEditStockSet => 'ตั้งค่าใหม่';

  @override
  String get quickEditStockAdjust => 'เพิ่ม/ลด';

  @override
  String get quickEditNameHint => 'ใส่ชื่อสินค้าใหม่';

  @override
  String get quickEditPriceHint => 'ใส่ราคาขายใหม่';

  @override
  String get quickEditStockSetHint =>
      'แตะ + / - หรือตัวเลขเพื่อแก้ไข กดค้างปุ่มเพื่อปรับเร็ว';

  @override
  String get quickEditStockAdjustHint =>
      'ใส่จำนวนที่ต้องการเพิ่มหรือลดจากสต็อกปัจจุบัน';

  @override
  String get stockStepperLongPressHint => 'กดค้างเพื่อเพิ่ม/ลดแบบต่อเนื่อง';

  @override
  String get stockStepperTapNumberHint => 'แตะตัวเลขเพื่อกรอกโดยตรง';

  @override
  String get quickEditNameSaved => 'อัปเดตชื่อแล้ว';

  @override
  String get quickEditNameCancelled => 'ไม่ได้เปลี่ยนแปลงชื่อ';

  @override
  String get quickEditNameInvalid => 'ชื่อไม่ถูกต้อง';

  @override
  String get quickEditPriceSaved => 'อัปเดตราคาแล้ว';

  @override
  String get quickEditPriceCancelled => 'ไม่ได้เปลี่ยนแปลงราคา';

  @override
  String get quickEditPriceInvalid => 'ราคาไม่ถูกต้อง';

  @override
  String priceLabel(String currency) {
    return 'ราคา ($currency) *';
  }

  @override
  String get priceRequired => 'กรุณาใส่ราคา';

  @override
  String get invalidPrice => 'ราคาไม่ถูกต้อง';

  @override
  String get priceMustBePositive => 'ราคาต้องมากกว่า 0';

  @override
  String get quantityLabel => 'จำนวน';

  @override
  String get quantityRequired => 'กรุณาใส่จำนวน';

  @override
  String get invalidQuantity => 'จำนวนไม่ถูกต้อง';

  @override
  String get invalidBarcode => 'บาร์โค้ดต้องเป็นตัวอักษรและตัวเลขเท่านั้น';

  @override
  String get invalidBarcodeFormat =>
      'บาร์โค้ดต้องมีแค่ตัวอักษรและตัวเลข (ห้ามมีช่องว่าง ขีดกลาง หรืออักขระพิเศษ)';

  @override
  String get categoryLabel => 'หมวดหมู่';

  @override
  String get categoryHelper => 'ไม่บังคับ — ช่วยจัดหมวดหมู่สินค้าใน POS';

  @override
  String get showProduct => 'แสดงสินค้า';

  @override
  String get productVisibility => 'การมองเห็นสินค้า';

  @override
  String get save => 'บันทึก';

  @override
  String get productSaved => 'บันทึกสินค้าแล้ว';

  @override
  String get productActivated => 'เปิดใช้งานสินค้าแล้ว';

  @override
  String get productDeactivated => 'ปิดการใช้งานสินค้าแล้ว';

  @override
  String get productDeleted => 'ลบสินค้าแล้ว';

  @override
  String productDeletedWithName(String name) {
    return 'ลบ $name แล้ว';
  }

  @override
  String get productDeletedShort => 'ลบสินค้าแล้ว';

  @override
  String get stockUpdated => 'อัปเดตสต็อกแล้ว';

  @override
  String get stockUpdateCancelled => 'ไม่ได้เปลี่ยนแปลงสต็อก';

  @override
  String get stockUpdateInvalid => 'ค่าสต็อกไม่ถูกต้อง';

  @override
  String get stockUpdateError => 'อัปเดตสต็อกไม่สำเร็จ';

  @override
  String get productUpdateError => 'อัปเดตสินค้าไม่สำเร็จ';

  @override
  String get productAddError => 'เพิ่มสินค้าไม่สำเร็จ';

  @override
  String get productDeleteError => 'ลบสินค้าไม่สำเร็จ';

  @override
  String get stockZeroWarning => 'สินค้าจะไม่แสดงในหน้าขายเมื่อสต็อก = 0';

  @override
  String get historyTitle => 'ประวัติการขาย';

  @override
  String get searchHistoryHint => 'ค้นหาเลขใบเสร็จ วิธีชำระ ยอดรวม…';

  @override
  String get searchSales => 'ค้นหายอดขาย';

  @override
  String get noSearchResults => 'ไม่พบรายการขาย';

  @override
  String get noSalesYet => 'ยังไม่มีรายการขาย';

  @override
  String get noSalesInRange => 'ไม่มีรายการขายในช่วงวันที่ที่เลือก';

  @override
  String get changeDateRange => 'เปลี่ยนช่วงวันที่';

  @override
  String searchResultsCount(int n) {
    return '$n รายการ';
  }

  @override
  String get noResultsInDateRange =>
      'ไม่พบในช่วงวันที่นี้ ลองเปลี่ยนช่วงวันที่';

  @override
  String searchingInRange(Object range) {
    return 'ค้นหาในช่วง: $range';
  }

  @override
  String get tapToExpandHint => 'แตะเพื่อดูรายละเอียดเพิ่มเติม';

  @override
  String get noDailyClosesYet => 'ยังไม่มีการปิดรับ';

  @override
  String noteLabel(String note) {
    return 'หมายเหตุ: $note';
  }

  @override
  String get reportTitle => 'สรุปยอดขาย';

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
  String get settingsTaxId => 'เลขประจำตัวผู้เสียภาษี';

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
  String get taxIdInvalid => 'เลขประจำตัวผู้เสียภาษีต้องมี 13 หลัก';

  @override
  String get taxIdChecksumInvalid =>
      'เลขประจำตัวผู้เสียภาษีไม่ถูกต้อง กรุณาตรวจสอบเลข 13 หลักอีกครั้ง';

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
  String get reprintReceipt => 'พิมพ์ใบเสร็จอีกครั้ง';

  @override
  String get shareReceiptCopy => 'แชร์สำเนา';

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
  String get viewReceipt => 'ดูใบเสร็จ';

  @override
  String get hideReceipt => 'ซ่อนใบเสร็จ';

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
  String get voidReason => 'เหตุผลที่ยกเลิก';

  @override
  String get voidReasonHint => 'ระบุเหตุผลที่ยกเลิก';

  @override
  String get voidReasonRequired => 'กรุณาระบุเหตุผลที่ยกเลิก';

  @override
  String voidedAtLabel(String datetime) {
    return 'ยกเลิกเมื่อ $datetime';
  }

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
  String get invLogReasonProductStockEdited => 'แก้ไขสต็อกสินค้า';

  @override
  String invLogSaleRef(String ref) {
    return 'บิล · $ref';
  }

  @override
  String productHistoryShowingLatest(int count) {
    return 'แสดง $count รายการล่าสุด';
  }

  @override
  String get productHistoryViewAll => 'ดูประวัติทั้งหมด';

  @override
  String get productFormSectionBasicInfo => 'ข้อมูลพื้นฐาน';

  @override
  String get tabInfo => 'สินค้า';

  @override
  String get tabPrice => 'ราคา';

  @override
  String get tabStock => 'สต็อก';

  @override
  String get tabCodes => 'รหัส';

  @override
  String get productFormSectionDetails => 'รายละเอียด';

  @override
  String get productFormImageUrlLabel => 'URL รูปภาพ (ไม่บังคับ)';

  @override
  String get trackStock => 'ติดตามสต็อก';

  @override
  String get trackStockHint => 'ปิดเพื่อสินค้าประเภทบริการ (ไม่ตัดสต็อค)';

  @override
  String get trackStockDisableConfirm =>
      'การปิดการติดตามสต็อกจะแช่แข็งค่าสต็อกปัจจุบัน คุณสามารถเปิดใหม่ได้ในภายหลังเพื่อติดตามต่อ';

  @override
  String get stockTrackingDisabled =>
      'การติดตามสต็อกปิดอยู่ เปิดเพื่อจัดการจำนวนสต็อก';

  @override
  String get stockNotTracked => 'ไม่ติดตามสต็อก';

  @override
  String get settingsStockPolicy => 'นโยบายสต็อค';

  @override
  String get allowOversell => 'อนุญาตขายเกินสต็อค';

  @override
  String get allowOversellHint => 'อนุญาตให้เพิ่มสินค้าเกินจำนวนคงเหลือได้';

  @override
  String get stockBlocked => 'บล็อค';

  @override
  String get lowStockThreshold => 'เตือนสต็อคต่ำ (จำนวน)';

  @override
  String get lowStockWarning => 'สต็อคใกล้หมด';

  @override
  String get inStock => 'มีสินค้า';

  @override
  String get codesCardTitle => 'SKU & บาร์โค้ด';

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
  String get cartDiscount => 'ส่วนลดท้ายบิล';

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
  String get draftsTitle => 'บิลเปิด';

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
  String get openBillsSectionSelling => 'กำลังขาย';

  @override
  String get openBillsSectionParked => 'พักไว้';

  @override
  String get draftNameHint => 'ชื่อบิล (ไม่บังคับ)';

  @override
  String get switchDraft => 'สลับไปบิลนี้';

  @override
  String get cartCleared => 'ล้างตะกร้าแล้ว';

  @override
  String get removeItem => 'ลบรายการ';

  @override
  String get itemsLabel => 'รายการ';

  @override
  String get searchCartItems => 'ค้นหาสินค้าในตะกร้า...';

  @override
  String get searchDrafts => 'ค้นหาบิล...';

  @override
  String get untitledDraft => 'บิลไม่มีชื่อ';

  @override
  String get noMatchingItems => 'ไม่พบสินค้าที่ตรงกัน';

  @override
  String get noMatchingDrafts => 'ไม่พบบิลที่ตรงกัน';

  @override
  String get noSavedBills => 'ยังไม่มีบิลเปิด';

  @override
  String get noSavedBillsHint => 'พักบิลจากหน้าขายเพื่อเปิดที่นี่';

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
  String get totalDiscountLabel => 'ส่วนลดทั้งหมด';

  @override
  String get settingsReceiptSize => 'ขนาดใบเสร็จ';

  @override
  String get receiptSize58mm => '58mm (กระดาษความร้อน)';

  @override
  String get receiptSize80mm => '80mm (กระดาษความร้อน)';

  @override
  String get receiptSizeA4 => 'A4';

  @override
  String get receiptSize58mmDesc => 'กระทัดรัด — เครื่องพิมพ์พกพาขนาดเล็ก';

  @override
  String get receiptSize80mmDesc => 'มาตรฐาน — เครื่องพิมพ์ความร้อนทั่วไป';

  @override
  String get receiptSizeA4Desc => 'เอกสาร — สำหรับส่งอีเมล/ส่งออก PDF';

  @override
  String get settingsMaxDrafts => 'บิลสูงสุด';

  @override
  String get settingsCompactCartMode => 'ตะกร้าแบบ Delivery';

  @override
  String get settingsUltraCompactMode => 'โหมดกะทัดรัดมาก';

  @override
  String get settingsUltraCompactModeHint =>
      'รายการเล็กลงเพื่อความหนาแน่นสูงสุด';

  @override
  String get settingsCompactModeSubtitle =>
      'แถบล่างแบบแอปส่งอาหาร; ปิด = พาเนลตะกร้าแบบเดิม';

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
  String get settingsSetupReadiness => 'ความพร้อมร้าน';

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
      'ส่งออกสำรองข้อมูลเป็นประจำ (แนะนำเข้ารหัส PIN อย่างน้อย 6 ตัว) กู้คืนบนเครื่องเดิมได้เมื่อยังมีคีย์เข้ารหัส ห้ามใช้ข้ามเครื่องหลังถอนแอป';

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
  String get basePrice => 'ราคาหลัก';

  @override
  String get optionsLabel => 'ตัวเลือก';

  @override
  String get dbHealthTitle => 'สุขภาพฐานข้อมูล';

  @override
  String get dbHealthFileSize => 'ขนาดไฟล์ฐานข้อมูล';

  @override
  String get dbHealthLarge => 'ใหญ่';

  @override
  String get dbHealthOk => 'ปกติ';

  @override
  String get dbHealthLow => 'ต่ำ';

  @override
  String get dbHealthFreeStorage => 'พื้นที่ว่าง';

  @override
  String get dbHealthUnknown => 'ไม่ทราบ';

  @override
  String get dbHealthMigrationStatus => 'สถานะการอัปเกรดฐานข้อมูลล่าสุด';

  @override
  String get dbHealthMigrationNone => 'ไม่มีประวัติ';

  @override
  String get dbHealthMigrationRunning =>
      'กำลังทำงาน — อาจถูกขัดจังหวะจากการปิดแอปผิดปกติ';

  @override
  String get dbHealthMigrationSucceeded => 'สำเร็จ';

  @override
  String get dbHealthMigrationFailed =>
      'ล้มเหลว — โปรดสำรองข้อมูลก่อนเปิดแอปอีกครั้ง';

  @override
  String get dbHealthLowStorageTitle => 'พื้นที่จัดเก็บเหลือน้อย';

  @override
  String dbHealthLowStorageMessage(String space) {
    return 'เหลือพื้นที่เพียง $space โปรดเคลียร์พื้นที่จัดเก็บก่อนทำการบำรุงรักษาฐานข้อมูลหรืออัปเดตแอป';
  }

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
  String get onboardingShopInfoTitle => 'ข้อมูลร้าน';

  @override
  String get onboardingShopInfoSubtitle => 'ข้อมูลนี้จะแสดงบนใบเสร็จของร้าน';

  @override
  String get onboardingRequiredLabel => 'จำเป็น';

  @override
  String get onboardingOptionalLabel => 'ไม่บังคับ';

  @override
  String get onboardingReceiptPreviewTitle => 'ตัวอย่างหัวใบเสร็จ';

  @override
  String get onboardingReceiptPreviewEmpty => 'ชื่อร้านจะแสดงตรงนี้';

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
  String get onboardingSkipSetup => 'ข้ามการตั้งค่า';

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
  String get onboardingDone => 'เสร็จสิ้น';

  @override
  String get onboardingBack => 'ย้อนกลับ';

  @override
  String get onboardingNext => 'ถัดไป';

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
  String get onboardingTrustOffline => 'ใช้งานได้แม้ไม่มีอินเทอร์เน็ต';

  @override
  String get onboardingTrustLocal => 'ข้อมูลอยู่บนอุปกรณ์นี้';

  @override
  String get onboardingTrustEncrypted => 'พื้นที่จัดเก็บเข้ารหัส';

  @override
  String onboardingStepOf(int step, int total) {
    return 'ขั้นตอนที่ $step จาก $total';
  }

  @override
  String get onboardingVatNoneHelp => 'ไม่มีการเพิ่ม VAT ในการขาย';

  @override
  String get onboardingVatInclusiveHelp => 'ราคาที่แสดงรวม VAT แล้ว';

  @override
  String get onboardingVatExclusiveHelp => 'ระบบจะบวก VAT เพิ่มจากราคาที่แสดง';

  @override
  String get onboardingInvalidVatRate =>
      'กรอกอัตรา VAT เป็นตัวเลขระหว่าง 0 ถึง 100';

  @override
  String get onboardingPromptPaySecurity =>
      'ไม่บังคับ ข้อมูลจะเก็บไว้บนอุปกรณ์นี้และใช้สร้าง QR รับเงิน';

  @override
  String get onboardingCurrencyBaht => '฿ บาท';

  @override
  String get onboardingCurrencyUsd => '\$ ดอลลาร์';

  @override
  String get onboardingCurrencyEur => '€ ยูโร';

  @override
  String get onboardingCurrencyJpy => '¥ เยน';

  @override
  String get onboardingSetupComplete => 'ตั้งค่าเรียบร้อย';

  @override
  String get onboardingSecurityProtected => 'ปกป้องด้วย PIN ร้าน';

  @override
  String get onboardingSecurityNotProtected => 'ยังไม่ได้ตั้ง PIN ร้าน';

  @override
  String get onboardingFirstSaleHint => 'ขั้นตอนถัดไป: เริ่มขายรายการแรกของคุณ';

  @override
  String get onboardingSummaryStore => 'ร้านค้า';

  @override
  String get onboardingSummaryCurrency => 'สกุลเงิน';

  @override
  String get onboardingSummaryTax => 'ภาษี';

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
  String get taxIdHint => 'เลขประจำตัวผู้เสียภาษี 13 หลัก (เช่น 1234567890123)';

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
  String get deleteCategory => 'ลบหมวดหมู่';

  @override
  String confirmDeleteCategory(String name) {
    return 'คุณแน่ใจหรือว่าจะลบ \"$name\"?';
  }

  @override
  String bulkDeleteConfirm(int count) {
    return 'ลบ $count หมวดหมู่?';
  }

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
  String get noSearchResultsHint => 'ลองใช้คำค้นหาอื่นหรือตรวจสอบการสะกด';

  @override
  String get clearFilters => 'ล้างตัวกรอง';

  @override
  String get selected => 'เลือกแล้ว';

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
  String get tapToZoom => 'แตะเพื่อขยาย';

  @override
  String get imageError => 'ไม่สามารถโหลดรูปได้';

  @override
  String get productImageSemantics => 'รูปภาพสินค้า';

  @override
  String get noProductImageSemantics => 'ไม่มีรูปภาพสินค้า';

  @override
  String get na => 'ไม่ระบุ';

  @override
  String get skuLabel => 'SKU';

  @override
  String get barcodeLabel => 'บาร์โค้ด';

  @override
  String get barcodeHint => 'เช่น 8850012345678';

  @override
  String costLabel(String currency) {
    return 'ต้นทุน ($currency)';
  }

  @override
  String get costHelper => 'ใช้คำนวณกำไรขั้นต้น (ไม่บังคับ)';

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
  String get unsavedChangesTitle => 'ยังไม่ได้บันทึก';

  @override
  String get restore => 'กู้คืน';

  @override
  String get scanBarcode => 'สแกนบาร์โค้ด';

  @override
  String get barcodeScannerHint => 'จัดบาร์โค้ดให้อยู่ในกรอบ';

  @override
  String get barcodeNotFound => 'ไม่พบสินค้าที่มีบาร์โค้ดนี้';

  @override
  String get duplicateBarcode => 'บาร์โค้ดนี้มีอยู่แล้ว';

  @override
  String get enterManually => 'ป้อนด้วยตนเอง';

  @override
  String get enterBarcodeManually => 'ป้อนบาร์โค้ดด้วยตนเอง';

  @override
  String get cameraPermissionDenied =>
      'ต้องอนุญาตใช้กล้องเพื่อสแกนบาร์โค้ด กรุณาเปิดสิทธิ์การเข้าถึงกล้องในการตั้งค่า';

  @override
  String get openSettings => 'เปิดการตั้งค่า';

  @override
  String get scanSuccess => 'สแกนสำเร็จ';

  @override
  String get scanFromGallery => 'สแกนจากรูป';

  @override
  String get barcodeNotFoundInImage => 'ไม่พบบาร์โค้ดในรูป';

  @override
  String get barcodeMustBeAlphanumeric =>
      'บาร์โค้ดต้องเป็นตัวอักษรและตัวเลขเท่านั้น';

  @override
  String get scanningImage => 'กำลังสแกนรูป...';

  @override
  String get continuousScan => 'สแกนต่อเนื่อง';

  @override
  String get continuousScanHint => 'สแกนต่อเนื่องโดยไม่ปิดหน้าจอสแกน';

  @override
  String get focusCamera => 'โฟกัส';

  @override
  String productFound(String name) {
    return 'เพิ่ม $name แล้ว';
  }

  @override
  String get productNotFoundShort => 'ไม่พบสินค้า';

  @override
  String scanCount(int count) {
    return 'สแกนแล้ว $count ชิ้น';
  }

  @override
  String get done => 'เสร็จ';

  @override
  String get torchOn => 'เปิดไฟฉาย';

  @override
  String get torchOff => 'ปิดไฟฉาย';

  @override
  String get submit => 'ยืนยัน';

  @override
  String get generateBarcode => 'สร้างบาร์โค้ด';

  @override
  String get barcodeGenerated => 'สร้างบาร์โค้ดแล้ว';

  @override
  String get barcodeGenerationError => 'สร้างบาร์โค้ดไม่สำเร็จ';

  @override
  String get generateSku => 'สร้าง SKU';

  @override
  String get skuGenerated => 'สร้าง SKU แล้ว';

  @override
  String get skuGenerationError => 'สร้าง SKU ไม่สำเร็จ';

  @override
  String get batchGenerateBarcodes => 'สร้างบาร์โค้ดให้สินค้าที่ยังไม่มี';

  @override
  String get batchGenerateBarcodesHint =>
      'สร้างบาร์โค้ดให้สินค้าทุกชิ้นที่ยังไม่มีบาร์โค้ด';

  @override
  String get batchGenerateConfirmTitle => 'สร้างบาร์โค้ด';

  @override
  String batchGenerateConfirmBody(Object count) {
    return 'สร้างบาร์โค้ด EAN-13 ให้สินค้า $count ชิ้นที่ยังไม่มีบาร์โค้ด?';
  }

  @override
  String batchGenerateSuccess(Object count) {
    return 'สร้างบาร์โค้ดให้สินค้า $count ชิ้นแล้ว';
  }

  @override
  String get batchGenerateNone => 'สินค้าทุกชิ้นมีบาร์โค้ดแล้ว';

  @override
  String get batchGenerateFailed => 'สร้างบาร์โค้ดไม่สำเร็จ';

  @override
  String productsWithoutBarcode(Object count) {
    return 'มีสินค้า $count ชิ้นที่ยังไม่มีบาร์โค้ด';
  }

  @override
  String get barcodeSettings => 'ตั้งค่าบาร์โค้ด';

  @override
  String get enableBarcodeScan => 'เปิดใช้งานสแกนบาร์โค้ด';

  @override
  String get enableBarcodeScanHint => 'แสดงปุ่มสแกนกล้องในหน้าขาย';

  @override
  String get playBeepOnScan => 'สั่นเตือนเมื่อสแกนสำเร็จ';

  @override
  String get playBeepOnScanHint =>
      'สั่นเตือนด้วยการสั่นสะเทือนเมื่อสแกนบาร์โค้ดสำเร็จ';

  @override
  String get barcodePrefix => 'คำนำหน้าสร้างอัตโนมัติ';

  @override
  String get barcodePrefixHint =>
      'เช่น 200, 201 (ตัวเลข 1-3 หลัก สำหรับ EAN-13)';

  @override
  String get barcodePrefixError => 'ต้องเป็นตัวเลข 1-3 หลักเท่านั้น';

  @override
  String get barcodeFormats => 'รูปแบบบาร์โค้ดที่สแกน';

  @override
  String get barcodeFormatsHint => 'เลือกรูปแบบที่ต้องการสแกน (ลดการสแกนผิด)';

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
  String get selectAll => 'เลือกทั้งหมด';

  @override
  String get deselectAll => 'ยกเลิกเลือกทั้งหมด';

  @override
  String get barcodeAutoOpenManual => 'เปิดป้อนด้วยตนเองอัตโนมัติ';

  @override
  String get barcodeAutoOpenManualHint =>
      'เปิดช่องป้อนบาร์โค้ดด้วยตนเองถ้าสแกนไม่สำเร็จภายในเวลาที่กำหนด';

  @override
  String get disabled => 'ปิดใช้งาน';

  @override
  String get secondsSuffix => ' วิ';

  @override
  String get barcodeHelpTitle => 'วิธีใช้บาร์โค้ด';

  @override
  String get barcodeHelpWhatIsTitle => 'บาร์โค้ดคืออะไร?';

  @override
  String get barcodeHelpWhatIsBody =>
      'บาร์โค้ดคือรหัสที่อ่านได้ด้วยเครื่อง (มักเป็นเส้นหรือตัวเลข) ที่พิมพ์บนบรรจุภัณฑ์สินค้า คุณสามารถสแกนด้วยกล้องเพื่อเพิ่มสินค้าใส่ตะกร้าได้อย่างรวดเร็ว';

  @override
  String get barcodeHelpHowToScanTitle => 'วิธีสแกน';

  @override
  String get barcodeHelpHowToScanBody =>
      'จัดกล้องให้ตรงกับบาร์โค้ดบนสินค้า ตรวจสอบให้มีแสงสว่างเพียงพอและถือโทรศัพท์ให้นิ่ง ถ้าสแกนไม่สำเร็จ ให้แตะ ป้อนด้วยตนเอง แล้วพิมพ์ตัวเลขบาร์โค้ด';

  @override
  String get barcodeHelpNoBarcodeTitle => 'สินค้าไม่มีบาร์โค้ด?';

  @override
  String get barcodeHelpNoBarcodeBody =>
      'ถ้าสินค้าไม่มีบาร์โค้ด คุณสามารถสร้างบาร์โค้ดอัตโนมัติได้ในหน้าข้อมูลสินค้า (แท็บขั้นสูง) เพื่อให้สามารถสแกนได้ในภายหลังที่หน้าขาย';

  @override
  String get barcodeHelper =>
      'สแกนหรือพิมพ์บาร์โค้ดบนบรรจุภัณฑ์สินค้า ถ้าไม่มี ให้แตะ สร้างบาร์โค้ด';

  @override
  String get skuHelper =>
      'รหัสสินค้าภายใน (ไม่บังคับ) ตัวอย่าง: SKU00001 หรือ SHIRT-RED-L ถ้าไม่มี ให้แตะ สร้าง SKU';

  @override
  String get imagePicked => 'เพิ่มรูปภาพแล้ว';

  @override
  String get imagePickFailed => 'ไม่สามารถเพิ่มรูปภาพได้ โปรดลองอีกครั้ง';

  @override
  String get storagePermissionDenied =>
      'ต้องอนุญาตเข้าถึงคลังรูปเพื่อเลือกรูป กรุณาเปิดสิทธิ์การเข้าถึงในการตั้งค่า';

  @override
  String get removeImageConfirm => 'ต้องการลบรูปภาพนี้?';

  @override
  String get imageHelper => 'แตะเพื่อเปลี่ยนรูป กดค้างเพื่อดูตัวอย่าง';

  @override
  String get tapToAddImage => 'แตะเพื่อเพิ่มรูปภาพ';

  @override
  String get imageNotFound => 'รูปภาพที่บันทึกไว้ถูกลบแล้ว โปรดเลือกใหม่';

  @override
  String get clearImageCache => 'ล้างแคชรูปภาพ';

  @override
  String get clearImageCacheConfirm =>
      'จะลบรูปภาพสินค้าที่ไม่ได้ใช้งานเพื่อเพิ่มพื้นที่จัดเก็บ ต้องการดำเนินการต่อ?';

  @override
  String get imageCacheCleared => 'ล้างแคชรูปภาพแล้ว';

  @override
  String get basic => 'พื้นฐาน';

  @override
  String get advanced => 'ขั้นสูง';

  @override
  String get settingsStoreSales => 'ร้านค้าและการขาย';

  @override
  String get settingsDiscounts => 'ส่วนลด';

  @override
  String get settingsAbout => 'เกี่ยวกับ';

  @override
  String get aboutApp => 'เกี่ยวกับแอป';

  @override
  String get appVersion => 'เวอร์ชัน';

  @override
  String get appBuild => 'บิลด์';

  @override
  String get appDescription => 'แอป POS ออฟไลน์สำหรับร้านค้าเล็กๆ';

  @override
  String get builtWith => 'สร้างด้วย';

  @override
  String get techStackFlutter => 'Flutter';

  @override
  String get techStackDrift => 'Drift SQLite';

  @override
  String get privacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get openSourceLicense => 'ลิขสิทธิ์โอเพนซอร์ส';

  @override
  String get crashLogs => 'บันทึกข้อผิดพลาด';

  @override
  String get exportCrashLogs => 'ส่งออกบันทึกข้อผิดพลาด';

  @override
  String get clearCrashLogs => 'ล้างบันทึกข้อผิดพลาด';

  @override
  String get clearCrashLogsConfirm =>
      'ต้องการล้างบันทึกข้อผิดพลาดทั้งหมดใช่หรือไม่?';

  @override
  String get crashLogSize => 'ขนาดไฟล์';

  @override
  String get crashLogEmpty => 'ไม่มีบันทึกข้อผิดพลาด';

  @override
  String get contactUs => 'ติดต่อ';

  @override
  String get agplLicense =>
      'สัญญาอนุญาต GNU Affero General Public License v3.0';

  @override
  String get agplShort => 'AGPL-3.0';

  @override
  String get copyrightNotice => '© 2026 Promsell POS CE · AGPL-3.0';

  @override
  String get dataCollection => 'การเก็บข้อมูล';

  @override
  String get dataCollectionBody =>
      'Promsell ไม่เก็บและไม่ส่งข้อมูลส่วนบุคคลไปยังเซิร์ฟเวอร์ของผู้พัฒนา ข้อมูลการขาย สต็อก การตั้งค่า และข้อมูลร้าน/ลูกค้าที่คุณกรอก (ถ้ามี) จัดเก็บบนเครื่องนี้เท่านั้น (SQLite/SQLCipher) จะไม่ออกจากเครื่อง เว้นแต่คุณส่งออกหรือแชร์เอง';

  @override
  String get customerDataTitle => 'ข้อมูลลูกค้า';

  @override
  String get customerDataBody =>
      'หากใช้ฟีเจอร์ลูกค้า ชื่อ เบอร์โทร และอีเมลจะเก็บบนเครื่องนี้เท่านั้น ลบรายชื่อได้ตลอดเวลา และไม่ส่งไปเซิร์ฟเวอร์ของผู้พัฒนา';

  @override
  String get thirdPartyServices => 'บริการภายนอก';

  @override
  String get thirdPartyServicesBody =>
      'เราไม่ใช้บริการวิเคราะห์ข้อมูล โฆษณา หรือคลาวด์ แอปทำงานแบบออฟไลน์ทั้งหมด';

  @override
  String get dataStorage => 'การจัดเก็บข้อมูล';

  @override
  String get dataStorageBody =>
      'ข้อมูลของคุณอยู่ในเครื่อง ส่งออกหรือลบได้ผ่านสำรอง/กู้คืน การกู้คืนในแอปใช้ได้เฉพาะเครื่องเดิมขณะที่คีย์ SQLCipher ยังอยู่ ไม่รองรับข้ามเครื่องหรือหลังถอนการติดตั้ง/ล้างคีย์ รูปสินค้าใช้แคช LRU 50MB ในเครื่อง';

  @override
  String get backupEncryptionBody =>
      'การส่งออกฐานข้อมูลใช้ AES-256-GCM ด้วยคีย์จาก PIN (PBKDF2 อย่างน้อย 6 ตัวอักษร) ค่าเริ่มต้นเปิดเข้ารหัสสำหรับติดตั้งใหม่ PIN ไม่ถูกเก็บหรือส่งออก หากลืม PIN จะกู้ไฟล์สำรองนั้นไม่ได้ ฐานข้อมูลจริงถูกปกป้องด้วย SQLCipher แยกต่างหาก';

  @override
  String get permissionsTitle => 'สิทธิ์การเข้าถึง';

  @override
  String get permissionsCamera =>
      'กล้อง: ใช้สำหรับถ่ายรูปสินค้าและสแกนบาร์โค้ด ไม่มีการส่งรูปภาพหรือข้อมูลสแกนออกจากเครื่อง';

  @override
  String get permissionsStorage =>
      'คลังข้อมูล: ใช้สำหรับบันทึกข้อมูลสำรองและใบเสร็จเท่านั้น';

  @override
  String get permissionsInternet =>
      'อินเทอร์เน็ต: ไม่บังคับ ใช้สำหรับโหลดรูปภาพสินค้าจาก URL เท่านั้น เมื่อแชร์รูปภาพสินค้า URL จะถูกส่งไปยังชีตแชร์ของระบบ (ในเครื่องเท่านั้น ไม่ส่งไปเซิร์ฟเวอร์ของเรา)';

  @override
  String get crashLoggingTitle => 'การบันทึกข้อผิดพลาด';

  @override
  String get crashLoggingBody =>
      'หากแอปผิดพลาด ระบบจะบันทึกข้อความผิดพลาด สแตกเทรซ และเวลาที่เกิดเหตุลงในเครื่องของคุณ ข้อมูลที่อ่อนไหว (หมายเลขโทรศัพท์ PromptPay ID เลขบัตรประชาชน) จะถูกล้างโดยอัตโนมัติก่อนจัดเก็บ บันทึกข้อผิดพลาดไม่ถูกส่งออกจากเครื่อง คุณสามารถดู ส่งออก และล้างบันทึกได้ใน การตั้งค่า → เกี่ยวกับ → บันทึกข้อผิดพลาด';

  @override
  String get contactTitle => 'ติดต่อ';

  @override
  String get contactBody => 'สอบถามเพิ่มเติม: mnlizard.official@gmail.com';

  @override
  String get productPreviewSystemInfo => 'ข้อมูลระบบ';

  @override
  String get sellingPrice => 'ราคาขาย';

  @override
  String get priceHint => 'เช่น 45.00';

  @override
  String get profit => 'กำไร';

  @override
  String get dateCreated => 'วันที่สร้าง';

  @override
  String get dateUpdated => 'วันที่อัปเดต';

  @override
  String get barcodeViewFull => 'ดู';

  @override
  String get barcodeSave => 'บันทึก';

  @override
  String get barcodePrint => 'พิมพ์';

  @override
  String get productPreviewMargin => 'กำไรขั้นต้น';

  @override
  String get productPreviewStockValue => 'มูลค่าสต็อก';

  @override
  String get productPreviewStockValueSale => 'มูลค่าขายทั้งหมด';

  @override
  String get productPreviewPotentialProfit => 'กำไรหากขายหมด';

  @override
  String get productPreviewTotalSold => 'ยอดขายรวม';

  @override
  String get productPreviewTotalIn => 'รับเข้ารวม';

  @override
  String get productPreviewTotalOut => 'ปรับลดรวม';

  @override
  String get productPreviewLastUpdate => 'อัปเดตสต็อกล่าสุด';

  @override
  String get productPreviewRecentMoves => 'การเคลื่อนไหวล่าสุด';

  @override
  String get productPreviewMarkup => 'เพิ่มราคาจากต้นทุน';

  @override
  String get productPreviewRoi => 'ผลตอบแทนต่อต้นทุน';

  @override
  String get productPreviewTotalRevenue => 'ราคารวมสต็อกทั้งหมด';

  @override
  String get productPreviewTotalProfit => 'กำไรรวมจากสต็อก';

  @override
  String get productPreviewStatus => 'สถานะ';

  @override
  String get productPreviewActive => 'เปิดใช้งาน';

  @override
  String get productPreviewCost => 'ต้นทุน';

  @override
  String get productPreviewBarcodeLabel => 'ป้ายบาร์โค้ด';

  @override
  String get productPreviewProductId => 'รหัสสินค้า';

  @override
  String get ok => 'ตกลง';

  @override
  String get close => 'ปิด';

  @override
  String get invalidValue => 'ค่าไม่ถูกต้อง';

  @override
  String discountPresetAdded(String label) {
    return 'เพิ่ม $label';
  }

  @override
  String discountPresetRemoved(String label) {
    return 'ลบ $label';
  }

  @override
  String get unsupportedFormat => 'รูปแบบไม่รองรับ';

  @override
  String get barcodeSavedSuccess => 'บันทึกบาร์โค้ดสำเร็จ';

  @override
  String get barcodePrintedSuccess => 'พิมพ์บาร์โค้ดสำเร็จ';

  @override
  String get barcodeViewError => 'ไม่สามารถดูบาร์โค้ดได้';

  @override
  String get barcodeSaveError => 'ไม่สามารถบันทึกบาร์โค้ดได้';

  @override
  String get barcodePrintError => 'ไม่สามารถพิมพ์บาร์โค้ดได้';

  @override
  String get inventoryValue => 'มูลค่าคงคลัง';

  @override
  String get currencyBaht => 'บาท';

  @override
  String get currencyDollar => 'ดอลลาร์';

  @override
  String get currencyEuro => 'ยูโร';

  @override
  String get currencyYen => 'เยน';

  @override
  String get stockOnHand => 'คงเหลือ';

  @override
  String get piecesLabel => 'ชิ้น';

  @override
  String get totalProducts => 'สินค้าทั้งหมด';

  @override
  String get todayRevenue => 'ยอดขายวันนี้';

  @override
  String get todaySalesCount => 'บิด';

  @override
  String get cartItems => 'ชิ้น';

  @override
  String get sortDefault => 'ค่าเริ่มต้น';

  @override
  String get sortNameAsc => 'ชื่อ A-Z';

  @override
  String get sortPriceLowHigh => 'ราคา: ต่ำ-สูง';

  @override
  String get sortPriceHighLow => 'ราคา: สูง-ต่ำ';

  @override
  String get sortStockLowHigh => 'สต็อก: น้อย-มาก';

  @override
  String get filterCategory => 'หมวดหมู่';

  @override
  String get filterSort => 'เรียง';

  @override
  String get filterStock => 'สต็อก';

  @override
  String get filterAll => 'ทั้งหมด';

  @override
  String get filterMore => 'กรอง';

  @override
  String get productRowMenuQty => 'กำหนดจำนวน';

  @override
  String get productRowMenuAdd => 'เพิ่มลงตะกร้า';

  @override
  String get productRowMenu => 'เมนูสินค้า';

  @override
  String get cartBottomLabel => 'ตะกร้า';

  @override
  String get saleCategoryTabsLabel => 'หมวดหมู่';

  @override
  String get filterPageTitle => 'กรองสินค้า';

  @override
  String get filterReset => 'ล้าง';

  @override
  String get filterShowResults => 'ดูผลลัพธ์';

  @override
  String filterShowResultsCount(int count) {
    return 'ดูผลลัพธ์ ($count)';
  }

  @override
  String get filterDone => 'เสร็จ';

  @override
  String filterRemainingCount(int count) {
    return 'เหลือ $count รายการ';
  }

  @override
  String get filterPriceCustom => 'กำหนดเอง';

  @override
  String get filterPriceRange => 'ราคา';

  @override
  String get filterPriceMin => 'ต่ำสุด';

  @override
  String get filterPriceMax => 'สูงสุด';

  @override
  String get filterCategoryChipHint => 'หมวดใช้แถบด้านบน';

  @override
  String get filterPriceOrderHint => 'ต่ำสุดต้อง ≤ สูงสุด';

  @override
  String filterPriceQuickUnder50(String currency) {
    return '≤ ${currency}50';
  }

  @override
  String filterPriceQuick51to100(String currency) {
    return '${currency}51–100';
  }

  @override
  String filterPriceQuick101to200(String currency) {
    return '${currency}101–200';
  }

  @override
  String filterPriceQuickOver200(String currency) {
    return '≥ ${currency}201';
  }

  @override
  String get sortChipDefault => 'ปกติ';

  @override
  String get sortChipName => 'ชื่อ';

  @override
  String get sortChipPriceAsc => 'ราคา ↑';

  @override
  String get sortChipPriceDesc => 'ราคา ↓';

  @override
  String get sortChipStock => 'สต็อก';

  @override
  String filterActiveCount(int count) {
    return 'ใช้งาน $count';
  }

  @override
  String get businessType => 'ประเภทธุรกิจ';

  @override
  String get businessTypeRetail => 'ค้าปลีก';

  @override
  String get businessTypeRestaurant => 'ร้านอาหาร';

  @override
  String get businessTypeSubtitle => 'สลับระหว่างโหมดค้าปลีกและร้านอาหาร';

  @override
  String get serviceChargeRate => 'อัตราค่าบริการ (%)';

  @override
  String get serviceChargeRateSubtitle =>
      'อัตราค่าบริการเริ่มต้นสำหรับคำสั่งอาหาร';

  @override
  String get orderType => 'ประเภทคำสั่ง';

  @override
  String get orderTypeDineIn => 'ทานที่ร้าน';

  @override
  String get orderTypeTakeaway => 'สั่งกลับบ้าน';

  @override
  String get orderTypeDelivery => 'จัดส่ง';

  @override
  String get orderChannel => 'ช่องทางสั่งซื้อ';

  @override
  String get orderChannelWalkIn => 'เดินเข้าร้าน';

  @override
  String get orderChannelPhone => 'โทรศัพท์';

  @override
  String get orderChannelOnline => 'ออนไลน์';

  @override
  String get externalOrderRef => 'เลขอ้างอิงการสั่งซื้อ';

  @override
  String get externalOrderRefHint =>
      'หมายเลขคำสั่งซื้อจากแพลตฟอร์มจัดส่ง (ไม่บังคับ)';

  @override
  String get serviceCharge => 'ค่าบริการ';

  @override
  String get averageTransactionValue => 'ยอดเฉลี่ยต่อบิล';

  @override
  String get grossRevenue => 'ยอดขายรวมก่อนหัก void';

  @override
  String get promotionDiscount => 'ส่วนลดโปรโมชั่น';

  @override
  String get orderTypeBreakdown => 'ประเภทคำสั่งซื้อ';

  @override
  String get orderChannelBreakdown => 'ช่องทางการสั่งซื้อ';

  @override
  String get peakHours => 'ช่วงเวลาขายดี';

  @override
  String get uniqueCustomers => 'ลูกค้าไม่ซ้ำ';

  @override
  String get repeatCustomers => 'ลูกค้าซื้อซ้ำ';

  @override
  String get promotionOrders => 'บิลที่ใช้โปรโมชั่น';

  @override
  String get voidReasons => 'เหตุผลที่ยกเลิก';

  @override
  String get profitability => 'ความคุ้มทุน';

  @override
  String get grossProfit => 'กำไรขั้นต้น';

  @override
  String get profitMargin => 'อัตรากำไร';

  @override
  String get totalCost => 'ต้นทุนรวม';

  @override
  String get costCoverage => 'ความครอบคลุมต้นทุน';

  @override
  String costCoverageIncomplete(Object total, Object withCost) {
    return 'ข้อมูลต้นทุนไม่ครบ ($withCost/$total รายการ)';
  }

  @override
  String get costCoverageUnavailable => 'ยังไม่มีข้อมูลต้นทุน';

  @override
  String get insights => 'ภาพรวม';

  @override
  String get orderBreakdown => 'การกระจายคำสั่งซื้อ';

  @override
  String get tableNumber => 'โต๊ะ';

  @override
  String get selectTable => 'เลือกโต๊ะ';

  @override
  String get noTable => 'ยังไม่ได้กำหนดโต๊ะ';

  @override
  String get restaurantSettings => 'ตั้งค่าร้านอาหาร';

  @override
  String get tableManagement => 'จัดการโต๊ะ';

  @override
  String get tableManagementSubtitle => 'จัดการโต๊ะและโซนในร้าน';

  @override
  String get addTable => 'เพิ่มโต๊ะ';

  @override
  String get editTable => 'แก้ไขโต๊ะ';

  @override
  String get deleteTable => 'ลบโต๊ะ';

  @override
  String get tableName => 'ชื่อโต๊ะ';

  @override
  String get tableNameHint => 'เช่น โต๊ะ 1, T-01';

  @override
  String get tableZone => 'โซน';

  @override
  String get tableZoneHint => 'เช่น ในร้าน, นอกร้าน, ระเบียง';

  @override
  String get tableSeats => 'จำนวนที่นั่ง';

  @override
  String get tableSeatsHint => 'จำนวนที่นั่งของโต๊ะ';

  @override
  String get tableStatusAvailable => 'ว่าง';

  @override
  String get tableStatusOccupied => 'ไม่ว่าง';

  @override
  String get tableStatusReserved => 'จองแล้ว';

  @override
  String get noTablesYet => 'ยังไม่มีโต๊ะ เพิ่มโต๊ะแรกของคุณ';

  @override
  String get confirmDeleteTable => 'ลบโต๊ะนี้?';

  @override
  String get selectTableForDineIn => 'เลือกโต๊ะสำหรับคำสั่งนี้';

  @override
  String get noTablesAvailable =>
      'ยังไม่ได้ตั้งค่าโต๊ะ เพิ่มโต๊ะในเมนูจัดการโต๊ะ';

  @override
  String get optionGroups => 'กลุ่มตัวเลือก';

  @override
  String get optionGroupsSubtitle =>
      'เพิ่มตัวเลือกเช่น ขนาด, ท็อปปิ้ง, ระดับความเผ็ด';

  @override
  String get addOptionGroup => 'เพิ่มกลุ่มตัวเลือก';

  @override
  String get editOptionGroup => 'แก้ไขกลุ่มตัวเลือก';

  @override
  String get optionGroupName => 'ชื่อกลุ่ม';

  @override
  String get optionGroupNameRequired => 'กรุณากรอกชื่อกลุ่ม';

  @override
  String get optionGroupNameHint => 'เช่น ขนาด, ท็อปปิ้ง, ระดับความเผ็ด';

  @override
  String get optionSelectionType => 'ประเภทการเลือก';

  @override
  String get optionSelectionSingle => 'เลือกได้อย่างเดียว';

  @override
  String get optionSelectionMultiple => 'เลือกได้หลายอย่าง';

  @override
  String get optionRequired => 'บังคับเลือก';

  @override
  String get optionOptional => 'ไม่บังคับ';

  @override
  String get addOption => 'เพิ่มตัวเลือก';

  @override
  String get editOption => 'แก้ไขตัวเลือก';

  @override
  String get optionName => 'ชื่อตัวเลือก';

  @override
  String get optionNameHint => 'เช่น เล็ก, ช็อตเพิ่ม, ไม่ใส่น้ำแข็ง';

  @override
  String get optionPriceDelta => 'ราคาเพิ่มเติม';

  @override
  String get optionPriceDeltaHint => 'ราคาเพิ่มเติม (สามารถเป็น 0)';

  @override
  String get optionPriceDeltaHelper =>
      'เพิ่มจากราคาหลัก เช่น 5.00 จะเพิ่ม 5.00 ให้ราคาสินค้า';

  @override
  String get optionNameTooLong => 'ชื่อตัวเลือกต้องไม่เกิน 100 ตัวอักษร';

  @override
  String get optionPriceInvalid => 'ราคาต้องเป็นตัวเลขที่ถูกต้อง';

  @override
  String get optionPriceTooManyDecimals => 'ราคาต้องมีไม่เกิน 2 ตำแหน่งทศนิยม';

  @override
  String get optionPriceTooLarge => 'การปรับราคาใหญ่เกินไป (สูงสุด 999999.99)';

  @override
  String get deleteOptionGroup => 'ลบกลุ่มตัวเลือก';

  @override
  String get confirmDeleteOptionGroup =>
      'ลบกลุ่มตัวเลือกนี้และตัวเลือกทั้งหมดในกลุ่ม?';

  @override
  String get deleteOption => 'ลบตัวเลือก';

  @override
  String get confirmDeleteOption => 'ลบตัวเลือกนี้?';

  @override
  String get noOptionGroups => 'ยังไม่มีกลุ่มตัวเลือก';

  @override
  String get selectOptions => 'เลือกตัวเลือก';

  @override
  String optionsFor(String product) {
    return 'ตัวเลือกสำหรับ $product';
  }

  @override
  String optionRequiredMessage(String group) {
    return 'กรุณาเลือกตัวเลือกสำหรับ $group';
  }

  @override
  String get customersTitle => 'ลูกค้า';

  @override
  String get customerSaved => 'บันทึกลูกค้าแล้ว';

  @override
  String get addCustomer => 'เพิ่มลูกค้า';

  @override
  String get editCustomerTitle => 'แก้ไขลูกค้า';

  @override
  String get customerNameLabel => 'ชื่อ';

  @override
  String get customerNameRequired => 'กรุณากรอกชื่อ';

  @override
  String get customerPhoneLabel => 'เบอร์โทร';

  @override
  String get customerEmailLabel => 'อีเมล';

  @override
  String get customerNoteLabel => 'บันทึก';

  @override
  String get customerNoteHint => 'เพิ่มบันทึกเกี่ยวกับลูกค้ารายนี้...';

  @override
  String get customerInfoSection => 'ข้อมูลลูกค้า';

  @override
  String get customerNotesSection => 'บันทึก';

  @override
  String get customerStatisticsSection => 'สถิติ';

  @override
  String get customerTotalVisits => 'จำนวนการเข้าซื้อ';

  @override
  String get customerTotalSpent => 'ยอดใช้จ่ายรวม';

  @override
  String get deleteCustomerTitle => 'ลบลูกค้า';

  @override
  String deleteCustomerConfirm(String name) {
    return 'คุณแน่ใจหรือว่าจะลบ \"$name\"?';
  }

  @override
  String get searchCustomers => 'ค้นหาลูกค้า...';

  @override
  String get noCustomersYet => 'ยังไม่มีลูกค้า';

  @override
  String get noCustomersFound => 'ไม่พบลูกค้า';

  @override
  String get addFirstCustomer => 'เพิ่มลูกค้าคนแรกของคุณเพื่อติดตามการซื้อ';

  @override
  String customerVisits(int count) {
    return 'เข้าซื้อ $count ครั้ง';
  }

  @override
  String get selectCustomer => 'เลือกลูกค้า';

  @override
  String get clearCustomer => 'ล้างลูกค้า';

  @override
  String get noCustomer => 'ไม่มีลูกค้า';

  @override
  String get receiptLabelCustomer => 'ลูกค้า';

  @override
  String get selectPromotion => 'เลือกโปรโมชัน';

  @override
  String get clearPromotion => 'ล้างโปรโมชัน';

  @override
  String get noActivePromotions => 'ไม่มีโปรโมชันที่ใช้งานอยู่';

  @override
  String get promotionNotFound => 'ไม่พบโปรโมชันหรือหมดอายุแล้ว';

  @override
  String get receiptLabelPromotion => 'โปรโมชัน';

  @override
  String get receiptLabelPromotionDiscount => 'ส่วนลดโปร';

  @override
  String get customerNotFound => 'ไม่พบลูกค้าหรือถูกลบแล้ว';

  @override
  String get insufficientStock => 'สต็อกไม่เพียงพอ';

  @override
  String get productNotFound => 'ไม่พบสินค้า';

  @override
  String get productInactive => 'สินค้าไม่ได้เปิดใช้งาน';

  @override
  String get saleNotFound => 'ไม่พบรายการขาย';

  @override
  String get saleAlreadyVoided => 'รายการนี้ถูกยกเลิกแล้ว';

  @override
  String get notFound => 'ไม่พบข้อมูล';

  @override
  String get validationError => 'ข้อมูลไม่ถูกต้อง';

  @override
  String get databaseError => 'ข้อผิดพลาดฐานข้อมูล';

  @override
  String get backupFailed => 'สำรองข้อมูลล้มเหลว';

  @override
  String get backupShareSubject => 'ไฟล์สำรอง Promsell POS';

  @override
  String get backupPinTitle => 'PIN เข้ารหัสสำรองข้อมูล';

  @override
  String get backupPinHint => 'กรอก PIN เพื่อเข้ารหัสไฟล์สำรอง';

  @override
  String get backupPinRequired => 'ต้องใส่ PIN เมื่อเปิดการเข้ารหัส';

  @override
  String get backupPinTooShort => 'PIN ต้องมีอย่างน้อย 6 ตัวอักษร';

  @override
  String get backupPinConfirmHint => 'ยืนยัน PIN';

  @override
  String get backupPinMismatch => 'PIN ไม่ตรงกัน';

  @override
  String get backupEncryptionOffTitle => 'ปิดการเข้ารหัสสำรองข้อมูล?';

  @override
  String get backupEncryptionOffConfirm =>
      'ไฟล์สำรองที่ไม่ได้เข้ารหัสเสี่ยงถูกคัดลอกได้ง่ายขึ้นหากมีคนได้ไฟล์ คุณเปิดการเข้ารหัสใหม่ได้ภายหลัง';

  @override
  String customerSpentLabel(String amount) {
    return 'ใช้ไป $amount';
  }

  @override
  String get tryDifferentSearch => 'ลองคำค้นหาอื่น';

  @override
  String get promotionsTitle => 'โปรโมชัน';

  @override
  String get promotionSaved => 'บันทึกโปรโมชันแล้ว';

  @override
  String get addPromotion => 'เพิ่มโปรโมชัน';

  @override
  String get editPromotionTitle => 'แก้ไขโปรโมชัน';

  @override
  String get promotionNameLabel => 'ชื่อโปรโมชัน';

  @override
  String get promotionNameRequired => 'กรุณากรอกชื่อ';

  @override
  String get promotionValueLabel => 'ส่วนลด (%)';

  @override
  String get promotionAmountLabel => 'มูลค่าส่วนลด';

  @override
  String get promotionValueRequired => 'กรุณากรอกค่า';

  @override
  String get promotionValueInvalid => 'กรุณากรอกค่าที่ถูกต้อง';

  @override
  String get promotionPercentMax => 'เปอร์เซ็นต์ต้องไม่เกิน 100';

  @override
  String get promotionMinPurchaseLabel => 'ยอดซื้อขั้นต่ำ';

  @override
  String get promotionMinPurchaseHint => '0 = ไม่มีขั้นต่ำ';

  @override
  String get promotionDetailsSection => 'รายละเอียดโปรโมชัน';

  @override
  String get promotionScheduleSection => 'กำหนดเวลา';

  @override
  String get promotionStatusSection => 'สถานะ';

  @override
  String get promotionStartDate => 'วันเริ่มต้น';

  @override
  String get promotionEndDate => 'วันสิ้นสุด';

  @override
  String get promotionNoEndDate => 'ไม่มีวันสิ้นสุด';

  @override
  String get promotionActive => 'ใช้งานอยู่';

  @override
  String get promotionInactive => 'ปิดใช้งาน';

  @override
  String get promotionActiveDesc => 'โปรโมชันนี้กำลังใช้งานอยู่';

  @override
  String get promotionInactiveDesc => 'โปรโมชันนี้ถูกปิดใช้งาน';

  @override
  String get promotionPercentage => 'เปอร์เซ็นต์';

  @override
  String get promotionFixedAmount => 'จำนวนเงินคงที่';

  @override
  String get deletePromotionTitle => 'ลบโปรโมชัน';

  @override
  String deletePromotionConfirm(String name) {
    return 'คุณแน่ใจหรือว่าจะลบ \"$name\"?';
  }

  @override
  String get searchPromotions => 'ค้นหาโปรโมชัน...';

  @override
  String get noPromotionsYet => 'ยังไม่มีโปรโมชัน';

  @override
  String get noPromotionsFound => 'ไม่พบโปรโมชัน';

  @override
  String get addFirstPromotion => 'สร้างโปรโมชันแรกของคุณเพื่อให้ส่วนลด';

  @override
  String promotionPercentOff(String value) {
    return 'ลด $value%';
  }

  @override
  String promotionAmountOff(String value) {
    return 'ลด $value';
  }

  @override
  String promotionMinPurchase(String amount) {
    return 'ซื้อขั้นต่ำ: $amount';
  }

  @override
  String homeGreeting(String shopName) {
    return 'สวัสดี, $shopName';
  }

  @override
  String get homeSubtitle => 'เริ่มต้นวันให้ยอดปัง!';

  @override
  String get homeTodayRevenue => 'ยอดขายวันนี้';

  @override
  String get homeVsYesterday => 'เทียบกับเมื่อวาน';

  @override
  String get homeRevenue => 'รายรับ';

  @override
  String get homeCost => 'ต้นทุน';

  @override
  String get homeProfit => 'กำไร';

  @override
  String get homeMainMenu => 'เมนูหลัก';

  @override
  String get homeHistory => 'ประวัติ';

  @override
  String get homeCloseDay => 'ปิดยอดวัน';

  @override
  String get homePromotionBannerCta => 'สร้างเลย';

  @override
  String get homeCreatePromotion => 'สร้างโปรโมชั่น';

  @override
  String get importProducts => 'นำเข้าสินค้า';

  @override
  String get productTabAll => 'ทั้งหมด';

  @override
  String get productTabCategory => 'หมวดหมู่';

  @override
  String get productTabStock => 'คลังสินค้า';

  @override
  String get productMenuEdit => 'แก้ไข';

  @override
  String get productMenuPreview => 'ดูตัวอย่าง';

  @override
  String get importFromCsv => 'นำเข้าจาก CSV';

  @override
  String get selectCsvFile => 'เลือกไฟล์ CSV';

  @override
  String get csvImportPreview => 'ตัวอย่างข้อมูลที่จะนำเข้า';

  @override
  String get confirmImport => 'ยืนยันนำเข้า';

  @override
  String importSuccess(int count) {
    return 'นำเข้าสินค้า $count รายการแล้ว';
  }

  @override
  String get importError => 'นำเข้าสินค้าไม่สำเร็จ';

  @override
  String get csvImportError => 'อ่านไฟล์ CSV ไม่สำเร็จ';

  @override
  String get csvNoData => 'ไม่พบข้อมูลในไฟล์ CSV';

  @override
  String get csvInvalidFormat => 'รูปแบบไฟล์ไม่ถูกต้อง';

  @override
  String get csvInvalidEncoding =>
      'ไฟล์ไม่ใช่ UTF-8 ที่ถูกต้อง กรุณาบันทึก CSV เป็น UTF-8 แล้วลองอีกครั้ง';

  @override
  String csvFileTooLarge(int maxMb) {
    return 'ไฟล์ใหญ่เกินไป (สูงสุด $maxMb MB)';
  }

  @override
  String csvTooManyRows(int maxRows) {
    return 'มีแถวมากเกินไป (สูงสุด $maxRows แถว)';
  }

  @override
  String csvRowErrorsSkipped(int count) {
    return 'จะข้าม $count แถวที่มีข้อผิดพลาด';
  }

  @override
  String csvImportPartialSuccess(int imported, int errors) {
    return 'นำเข้า $imported รายการ; ล้มเหลว $errors แถว';
  }

  @override
  String csvImportCategoriesCreated(int count) {
    return 'สร้างหมวดหมู่ $count รายการ';
  }

  @override
  String get csvDownloadTemplate => 'ดาวน์โหลดเทมเพลต';

  @override
  String get csvColumnLegend =>
      'จำเป็น: ชื่อ, ราคา. ไม่บังคับ: รหัสสินค้า, บาร์โค้ด, ต้นทุน, สต็อก, หมวดหมู่, ติดตามสต็อก';

  @override
  String get csvImporting => 'กำลังนำเข้า…';

  @override
  String csvRowLabel(int row, String message) {
    return 'แถว $row: $message';
  }

  @override
  String get csvTemplateShared => 'เทมเพลตพร้อมแชร์แล้ว';

  @override
  String get csvParseErrorsTitle => 'แถวที่จะถูกข้าม';

  @override
  String get csvPostImportErrorsTitle => 'แถวที่นำเข้าไม่สำเร็จ';

  @override
  String get homePromotionBannerSubtitle => 'เพิ่มยอดขายได้ง่ายๆ';

  @override
  String get homeNoActivePromotion => 'ไม่มีโปรโมชันที่ใช้งานอยู่';

  @override
  String get homePromotionOff => 'ลด';

  @override
  String homeFromBills(int count) {
    return 'จาก $count บิล';
  }

  @override
  String get productDetailTitle => 'รายละเอียดสินค้า';

  @override
  String get productTabInfo => 'ข้อมูลสินค้า';

  @override
  String get productTabHistory => 'ประวัติ';

  @override
  String get productDescriptionLabel => 'รายละเอียด';

  @override
  String get productDescriptionEmpty => 'ไม่มีรายละเอียด';

  @override
  String get productUnitLabel => 'หน่วยนับ';

  @override
  String get productUnitDefault => 'ชิ้น';

  @override
  String get productTabPointOfSale => 'ขายหน้าร้าน';

  @override
  String get productTabPriceStock => 'ราคาและสต็อก';

  @override
  String get productTabCodesMore => 'รหัสและเพิ่มเติม';

  @override
  String get productRecommended => 'สินค้าแนะนำ';

  @override
  String get productUnitOther => 'อื่น ๆ';

  @override
  String get productCustomUnit => 'ระบุหน่วยนับ';

  @override
  String get productTaxLabel => 'ภาษี';

  @override
  String get productWeightLabel => 'น้ำหนัก';

  @override
  String get productSizeLabel => 'ขนาดสินค้า';

  @override
  String get productBrandLabel => 'แบรนด์';

  @override
  String get productSupplierLabel => 'ผู้จัดจำหน่าย';

  @override
  String get copyBarcode => 'คัดลอกบาร์โค้ด';

  @override
  String get printBarcode => 'พิมพ์บาร์โค้ด';

  @override
  String get productAdjustStock => 'ปรับสต็อก';

  @override
  String get productNoHistory => 'ไม่มีประวัติการเคลื่อนไหวสต็อก';

  @override
  String get normalProduct => 'สินค้าปกติ';

  @override
  String get readyToSell => 'พร้อมขาย';

  @override
  String get retailPrice => 'ราคาขายปลีก';

  @override
  String get averageCost => 'ต้นทุนเฉลี่ย';

  @override
  String get averageProfit => 'กำไรต่อชิ้น';

  @override
  String get remainingStock => 'สต็อกคงเหลือ';

  @override
  String get moveProduct => 'ย้ายสินค้า';

  @override
  String get editProduct => 'แก้ไขสินค้า';

  @override
  String pieces(int count) {
    return '$count ชิ้น';
  }

  @override
  String resourceNotFound(String resource) {
    return 'ไม่พบ$resource';
  }

  @override
  String resourceNotFoundWithId(String resource, String id) {
    return 'ไม่พบ$resource (ID: $id)';
  }

  @override
  String get businessRuleViolation => 'ละเมิดกฎทางธุรกิจ';

  @override
  String get networkError => 'ข้อผิดพลาดเครือข่าย';

  @override
  String networkErrorDefault(int code) {
    return 'ข้อผิดพลาดเครือข่าย (สถานะ: $code)';
  }

  @override
  String get fileSystemError => 'ข้อผิดพลาดระบบไฟล์';

  @override
  String get permissionDenied => 'ไม่ได้รับอนุญาต';

  @override
  String permissionDeniedMessage(String permission) {
    return 'กรุณาอนุญาตการเข้าถึง$permission';
  }

  @override
  String get unexpectedError => 'เกิดข้อผิดพลาดที่ไม่คาดคิด';

  @override
  String get invalidDiscount => 'ส่วนลดไม่ถูกต้อง';

  @override
  String get negativePriceNotAllowed => 'ไม่อนุญาตให้ใส่ราคาติดลบ';

  @override
  String get homeLoadError => 'โหลดข้อมูลไม่สำเร็จ';

  @override
  String get productFormSectionGeneral => 'ข้อมูลทั่วไป';

  @override
  String get productFormSectionPricing => 'ราคา & ต้นทุน';

  @override
  String get productFormSectionStock => 'สต็อก & หน่วยนับ';

  @override
  String get productFormSectionSettings => 'การตั้งค่า';

  @override
  String get productFormSectionExtra => 'ข้อมูลเพิ่มเติม';

  @override
  String get notSpecified => 'ไม่ระบุ';

  @override
  String get saveProduct => 'บันทึกสินค้า';

  @override
  String get discardChanges => 'ไม่บันทึก';

  @override
  String get unsavedChangesMessageCreate =>
      'ออกโดยไม่บันทึกสินค้า? ร่างจะถูกเก็บไว้ให้กู้คืนครั้งถัดไป หรือเลือกทิ้งร่าง';

  @override
  String get unsavedChangesMessageEdit =>
      'มีการแก้ไขที่ยังไม่บันทึก ต้องการออกโดยไม่บันทึกหรือไม่?';

  @override
  String get costExceedsPriceWarning => 'ต้นทุนสูงกว่าราคาขาย — กำไรติดลบ';

  @override
  String get priceStockEstimateTitle => 'ถ้าขายหมดสต็อก';

  @override
  String get priceStockEstimateRevenue => 'รายได้โดยประมาณ';

  @override
  String get priceStockEstimateProfit => 'กำไรโดยประมาณ';

  @override
  String get editStockAdjustHint =>
      'แก้จำนวนผ่านปุ่มปรับสต็อก เพื่อให้มีประวัติการเคลื่อนไหว';

  @override
  String lowStockThresholdHint(int n) {
    return 'เตือนสต็อกต่ำที่ $n';
  }

  @override
  String get stockInventoryValueTitle => 'มูลค่าคลัง';

  @override
  String get adjustModeAdd => 'เพิ่ม';

  @override
  String get adjustModeRemove => 'ลด';

  @override
  String get adjustQtyAmountLabel => 'จำนวน';

  @override
  String adjustCurrentStock(String qty, String unit) {
    return 'สต็อกปัจจุบัน: $qty $unit';
  }

  @override
  String adjustPreviewResult(String from, String to, String unit) {
    return '$from → $to $unit';
  }

  @override
  String get adjustWouldGoNegative => 'สต็อกไม่พอสำหรับจำนวนที่ลด';

  @override
  String get adjustReasonRestock => 'รับเข้า / เติมสต็อก';

  @override
  String get adjustReasonDamaged => 'ชำรุด / เสียหาย';

  @override
  String get adjustReasonLost => 'สูญหาย';

  @override
  String get adjustReasonCountCorrection => 'แก้จากนับสต็อก';

  @override
  String get adjustReasonReturn => 'รับคืนจากลูกค้า';

  @override
  String get adjustReasonOther => 'อื่นๆ';

  @override
  String get adjustReasonOtherHint => 'ระบุเหตุผล';

  @override
  String get editLowStockThreshold => 'แก้เกณฑ์เตือน';

  @override
  String get lowStockThresholdSaved => 'อัปเดตเกณฑ์เตือนสต็อกต่ำแล้ว';

  @override
  String get createProductFromBarcode => 'สร้างสินค้า';

  @override
  String get scanAgainToAdd => 'บันทึกแล้ว — สแกนอีกครั้งเพื่อใส่ตะกร้า';

  @override
  String get productCreatedAddedToCart => 'สร้างสินค้าและใส่ตะกร้าแล้ว';

  @override
  String get barcodeReplaceTitle => 'แทนที่บาร์โค้ด?';

  @override
  String barcodeReplaceMessage(String code) {
    return 'รหัสปัจจุบัน: $code — รหัสใหม่จะแทนที่ของเดิม';
  }

  @override
  String get skuReplaceTitle => 'แทนที่ SKU?';

  @override
  String skuReplaceMessage(String code) {
    return 'รหัสปัจจุบัน: $code — รหัสใหม่จะแทนที่ของเดิม';
  }

  @override
  String get barcodePreviewEmpty => 'พรีวิวจะแสดงเมื่อพิมพ์หรือสร้างบาร์โค้ด';

  @override
  String get scanModeContinuous => 'ต่อเนื่อง';

  @override
  String get scanModeSingle => 'ครั้งเดียว';

  @override
  String get searchMatchName => 'ชื่อ';

  @override
  String get searchMatchSku => 'SKU';

  @override
  String get searchMatchBarcode => 'บาร์โค้ด';

  @override
  String searchResultCount(int count) {
    return 'พบ $count รายการ';
  }

  @override
  String get searchFiltersIgnoredHint =>
      'แสดงทุกรายการที่ตรงคำค้น (ไม่ใช้ตัวกรองรายการ)';

  @override
  String searchShowingCount(int shown, int total) {
    return 'แสดง $shown จาก $total';
  }

  @override
  String barcodeAmbiguousCount(int count) {
    return 'มีสินค้า $count รายการใช้บาร์โค้ดนี้';
  }

  @override
  String get cartBillDetails => 'รายละเอียดบิล';

  @override
  String get cartHoldBill => 'บิลที่บันทึก';

  @override
  String cartItemCount(int count) {
    return '$count รายการ';
  }

  @override
  String cartActiveBill(String name) {
    return 'บิล: $name';
  }

  @override
  String get heroNoBarcode => 'ไม่มีบาร์โค้ด';

  @override
  String get setSellingPrice => 'ตั้งราคาขาย';

  @override
  String get showProductHint => 'เปิดแล้วแสดงในรายการสินค้าและหน้าขาย';

  @override
  String get productRecommendedHint => 'ไฮไลต์บนหน้าขายและมีป้ายในรายการสินค้า';

  @override
  String get productBrandHint => 'แบรนด์หรือผู้ผลิต (ไม่บังคับ)';

  @override
  String get productDescriptionHint =>
      'หมายเหตุสำหรับพนักงาน (ไม่แสดงบนหน้าขาย)';

  @override
  String get productFormSectionVisibility => 'การแสดงผล';

  @override
  String get productSettingsOutcomeVisible => 'แสดงบนขาย';

  @override
  String get productSettingsOutcomeHidden => 'ซ่อนจากขาย';

  @override
  String get productSettingsOutcomeRecommended => 'แนะนำ';

  @override
  String get productSettingsOutcomeNotRecommended => 'ไม่แนะนำ';

  @override
  String get productRecommendedNeedsVisible =>
      'สินค้าแนะนำควรเปิดแสดง — เปิดแสดงสินค้า หรือปิดแนะนำ';

  @override
  String get saleRecommendedFilter => 'แนะนำ';

  @override
  String get saleRecommendedFilterAll => 'ทั้งหมด';

  @override
  String get productSupplierHint => 'แหล่งที่ซื้อสินค้า (ไม่บังคับ)';

  @override
  String get productOptionsSummaryTitle => 'ตัวเลือกเพิ่ม';

  @override
  String productOptionGroupSummary(String name, String detail, int count) {
    return '$name · $detail · $count ตัวเลือก';
  }

  @override
  String get productFormCostEmptyHint => 'ใส่ต้นทุนเพื่อดูกำไรและมาร์กอัป';

  @override
  String get productFormMarkupFromCost => 'ตั้งราคาจากต้นทุน';

  @override
  String productFormPriceChanged(String from, String to) {
    return '$from → $to';
  }

  @override
  String get clearFieldTitle => 'ล้างข้อความ?';

  @override
  String get clearFieldConfirm => 'จะลบข้อความในช่องนี้ แน่ใจหรือไม่?';

  @override
  String get deleteProductConfirmTitle => 'ลบสินค้านี้ออกจากรายการ?';

  @override
  String get removeCartLineTitle => 'ลบรายการนี้ออกจากบิล?';

  @override
  String removeCartLineQty(int count) {
    return 'จำนวน $count ชิ้น';
  }

  @override
  String get removeCartLineConfirm => 'ลบรายการ';

  @override
  String get datePresetToday => 'วันนี้';

  @override
  String get datePresetYesterday => 'เมื่อวาน';

  @override
  String get datePresetLast7Days => '7 วัน';

  @override
  String get datePresetThisMonth => 'เดือนนี้';

  @override
  String get datePresetCustom => 'กำหนดเอง';

  @override
  String get dateFilterSheetTitle => 'เลือกช่วงวันที่';

  @override
  String get dateFilterSheetSubtitle =>
      'เลือกหมวดหมู่ที่กำหนดไว้ หรือกำหนดช่วงวันที่เอง';

  @override
  String get dateFilterCategoryTile => 'หมวดหมู่';

  @override
  String get dateFilterCategoryDesc => 'วันนี้ • เมื่อวาน • 7 วัน • เดือนนี้';

  @override
  String get dateFilterCustomTile => 'กำหนดเอง';

  @override
  String get dateFilterCustomDesc => 'เลือกวันเริ่มต้นและวันสิ้นสุดเอง';

  @override
  String get dateFilterCustomPick => 'เลือกช่วงวันที่';

  @override
  String get dateFilterCustomChange => 'เปลี่ยนช่วงวันที่';

  @override
  String get dateFilterCustomApply => 'ใช้ช่วงนี้';

  @override
  String get dateFilterCustomCurrent => 'ช่วงที่เลือก';

  @override
  String get dateFilterPickYear => 'เลือกปี';

  @override
  String get dateFilterPickMonth => 'เลือกเดือน';

  @override
  String get dateFilterSelectYear => 'เลือกปีนี้';

  @override
  String get dateFilterSelectMonth => 'เลือกเดือนนี้';

  @override
  String get dateFilterThisYear => 'ปีนี้';

  @override
  String get dateFilterLastYear => 'ปีก่อน';

  @override
  String get dateFilterThisMonth => 'เดือนนี้';

  @override
  String get dateFilterUseToday => 'ตั้งเป็นวันนี้';

  @override
  String get dateFilterTipTitle => 'เกร็ดความรู้';

  @override
  String get dateFilterTipBody =>
      'หมวดหมู่เหมาะกับดูสรุปรายวัน/รายสัปดาห์ ส่วนกำหนดเองเหมาะกับการเปรียบเทียบช่วงเวลาแบบยืดหยุ่น';

  @override
  String get reportAverage => 'เฉลี่ย';

  @override
  String get reportRecent => 'ล่าสุด';

  @override
  String paymentMethodShare(String percent) {
    return '$percent%';
  }

  @override
  String get closeDayToday => 'ปิดยอดวันนี้';

  @override
  String get dailyCloseSummaryTitle => 'สรุป';

  @override
  String get dailyCloseSalesCountLabel => 'จำนวนบิล';

  @override
  String get dailyCloseVoidedCountLabel => 'จำนวนยกเลิก';

  @override
  String get dailyCloseGrossRevenue => 'ยอดรวมก่อนหักยกเลิก';

  @override
  String get dailyCloseVoidedAmount => 'ยอดยกเลิก';

  @override
  String get dailyCloseByPayment => 'แยกตามวิธีชำระ';

  @override
  String get dailyCloseVatCollected => 'ภาษีมูลค่าเพิ่ม';

  @override
  String get dailyCloseDiscountsGiven => 'ส่วนลดที่ให้';

  @override
  String get dailyCloseCashReconciliation => 'กระทบยอดเงินสด';

  @override
  String get dailyCloseOpeningCash => 'เงินสดเปิดลิ้นชัก';

  @override
  String get dailyCloseExpectedCash => 'เงินสดที่ควรมี';

  @override
  String get dailyCloseCountedCash => 'เงินสดที่นับได้';

  @override
  String get dailyCloseOverShort => 'เกิน / ขาด';

  @override
  String get dailyCloseNoteOptional => 'หมายเหตุ (ถ้ามี)';

  @override
  String get dailyCloseStatusOpen => 'เปิดอยู่';

  @override
  String get dailyCloseStatusClosed => 'ปิดแล้ว';

  @override
  String get dailyCloseStatusClosedBadge => 'ปิดแล้ว';

  @override
  String get dailyCloseStatusOpenBadge => 'เปิด';

  @override
  String get noCategoriesFound => 'ไม่พบหมวดหมู่ที่ตรงกับการค้นหา';

  @override
  String get categorySaved => 'บันทึกหมวดหมู่แล้ว';

  @override
  String get categoryDeleted => 'ลบหมวดหมู่แล้ว';

  @override
  String categoriesDeleted(int count) {
    return 'ลบ $count หมวดหมู่แล้ว';
  }

  @override
  String get categoryReorderHint => 'ลากเพื่อจัดลำดับหมวดหมู่ที่แสดงบนหน้าขาย';

  @override
  String deleteCategoryProductsImpact(int count) {
    return 'สินค้า $count รายการจะถูกย้ายไปหมวดหมู่ที่เลือก (หรือไม่มีหมวดหมู่)';
  }

  @override
  String get categoryNameTooLong => 'ชื่อต้องไม่เกิน 100 ตัวอักษร';

  @override
  String get goToSale => 'ไปหน้าขาย';

  @override
  String closeDayForDate(String date) {
    return 'ปิดยอดวันที่ $date';
  }

  @override
  String get reportNoSalesInPeriod => 'ไม่มียอดขายในช่วงนี้';

  @override
  String get reportEmptyDesc =>
      'ลองเปลี่ยนช่วงวันที่ หรือเริ่มขายสินค้าเพื่อดูสรุปยอดที่นี่';

  @override
  String get reportErrorDesc =>
      'ไม่สามารถโหลดข้อมูลได้ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get reportLoadingDesc => 'กำลังเรียกข้อมูลยอดขาย...';

  @override
  String get currentBill => 'บิลปัจจุบัน';

  @override
  String currentBillWithCount(int count) {
    return 'บิล ($count)';
  }

  @override
  String saleBillAt(int count) {
    return 'บิลที่ $count';
  }

  @override
  String productCountAt(int count) {
    return 'สินค้า $count รายการ';
  }

  @override
  String get viewBill => 'บิล';

  @override
  String viewBillWithCount(int count) {
    return 'บิล ($count)';
  }

  @override
  String get draftNotFound => 'ไม่พบบิลเปิด';

  @override
  String maxDraftsReached(int count) {
    return 'บิลเปิดครบจำนวนสูงสุด ($count)';
  }

  @override
  String get addToCart => 'เพิ่มลงตะกร้า';

  @override
  String get holdCurrentBill => 'พักบิลนี้';

  @override
  String get newBill => 'บิลใหม่';

  @override
  String get billHeld => 'บันทึกบิลแล้ว';

  @override
  String get newBillConfirm => 'บันทึกบิลปัจจุบันแล้วเริ่มบิลว่างใหม่?';

  @override
  String get newBillStarted => 'เริ่มบิลใหม่แล้ว';

  @override
  String get voidBlockedDayClosed => 'ปิดยอดแล้ว เปิดวันก่อนเพื่อยกเลิกบิลนี้';

  @override
  String get billParked => 'พักบิลแล้ว — พร้อมลูกค้าถัดไป';

  @override
  String get receiptThankYouDefault => 'ขอบคุณครับ/ค่ะ!';

  @override
  String get receiptNotTaxInvoice => 'ใบเสร็จการขาย — ไม่ใช่ใบกำกับภาษี';

  @override
  String get receiptTaxId => 'เลขประจำตัวผู้เสียภาษี';

  @override
  String get receiptReprint => 'พิมพ์ซ้ำ';

  @override
  String get receiptShareVoidBlocked =>
      'ไม่สามารถแชร์บิลที่ยกเลิกเป็นใบเสร็จปกติได้ — พิมพ์จะมีเครื่องหมายยกเลิก';

  @override
  String get parkBill => 'พักบิล';

  @override
  String get parkBillConfirmTitle => 'พักบิลนี้?';

  @override
  String get parkBillConfirmMessage =>
      'บันทึกตะกร้านี้ แล้วเริ่มบิลว่างให้ลูกค้าถัดไป — เปิดบิลที่พักได้จากรายการบิลเปิด';

  @override
  String get parkBillNameTitle => 'ตั้งชื่อบิล (ไม่บังคับ)';

  @override
  String currentBillNamed(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get amountDue => 'ยอดชำระ';

  @override
  String payAmount(String amount) {
    return 'ชำระ $amount';
  }

  @override
  String get parkAndNext => 'พักแล้วคิวถัดไป';

  @override
  String openBillsCount(int count) {
    return 'บิลเปิด ($count)';
  }

  @override
  String billItemsMissing(int count) {
    return 'ไม่พบ $count รายการ (สินค้าอาจถูกลบ)';
  }

  @override
  String get splitTenderTitle => 'แบ่งชำระ (เงินสด + อื่น)';

  @override
  String get splitTenderSubtitle => 'จ่ายบางส่วนเงินสด ที่เหลือโอน/QR/บัตร';

  @override
  String get splitCashAmount => 'จำนวนเงินสด';

  @override
  String get paymentMismatch => 'ยอดชำระไม่ตรงกับยอดบิล';

  @override
  String get paymentMixed => 'แบ่งชำระ';

  @override
  String get promptPayShareTitle => 'ส่วน PromptPay';

  @override
  String get promptPayShareHint => 'สแกนเฉพาะส่วน PromptPay (ไม่ใช่ยอดบิลเต็ม)';

  @override
  String get promptPayFullBillTitle => 'ชำระด้วย PromptPay';

  @override
  String settingsAttentionItemsCount(int count) {
    return 'มี $count รายการที่ควรตั้งค่า';
  }

  @override
  String get settingsAttentionShopTitle => 'ตั้งค่าข้อมูลร้านให้ครบ';

  @override
  String get settingsAttentionShopBody =>
      'ใส่ชื่อร้านและเบอร์โทรเพื่อใบเสร็จที่ถูกต้อง';

  @override
  String get settingsAttentionPromptpayTitle => 'ตั้งค่าพร้อมเพย์';

  @override
  String get settingsAttentionPromptpayBody =>
      'เพิ่มเลขพร้อมเพย์เพื่อแสดง QR ตอนชำระเงิน';

  @override
  String get settingsAttentionReview => 'ดูรายการ';

  @override
  String get settingsDayClose => 'ปิดวัน';

  @override
  String get settingsBackupData => 'สำรองและข้อมูล';

  @override
  String settingsPreview(String section) {
    return 'ตัวอย่าง$section';
  }

  @override
  String get settingsModeLabel => 'โหมด';

  @override
  String get settingsCatalogMode => 'แคตตาล็อก';

  @override
  String get shopNamePlaceholder => 'ชื่อร้านของคุณ';

  @override
  String get shopAddressPlaceholder => 'ยังไม่ได้ตั้งที่อยู่';

  @override
  String get shopPhonePlaceholder => 'ยังไม่ได้ตั้งเบอร์โทร';

  @override
  String get settingsDetails => 'รายละเอียด';

  @override
  String get settingsPolicy => 'นโยบาย';

  @override
  String get settingsOn => 'เปิด';

  @override
  String get settingsOff => 'ปิด';

  @override
  String get cartPaymentInProgress =>
      'กำลังชำระเงิน — ล็อกตะกร้าจนกว่าจะเสร็จหรือยกเลิก';

  @override
  String get backupRestoreTitle => 'กู้คืนสำรอง (เครื่องนี้เท่านั้น)';

  @override
  String get backupRestoreConfirmTitle => 'กู้คืนสำรองข้อมูล?';

  @override
  String get backupRestoreConfirmMessage =>
      'จะแทนที่ฐานข้อมูลปัจจุบันบนเครื่องนี้ ระบบจะเก็บสำเนาก่อนกู้คืน หลังกู้คืนให้ปิดแอปแล้วเปิดใหม่ ใช้ได้เฉพาะเครื่องเดิม (คีย์ SQLCipher ต้องยังอยู่)';

  @override
  String get backupRestoreSuccess =>
      'กู้คืนสำเร็จ กรุณาปิดแอปให้สนิทแล้วเปิดใหม่';

  @override
  String get backupRestorePlainUnsupported =>
      'ไม่รองรับไฟล์ SQLite แบบไม่เข้ารหัส ใช้ไฟล์ที่ส่งออกจากแอปนี้';

  @override
  String get backupRestoreInvalid => 'ไฟล์สำรองไม่ถูกต้อง';

  @override
  String get backupRestoreSourceMissing => 'ไม่พบไฟล์สำรอง';

  @override
  String get backupConfirmExportTitle => 'ยืนยันการส่งออกสำรอง';

  @override
  String get backupConfirmRestoreTitle => 'ยืนยันการกู้คืนสำรอง';

  @override
  String get appLockTitle => 'ล็อก PIN ร้าน';

  @override
  String get appLockSubtitle =>
      'ป้องกันยกเลิกบิล สำรอง ปรับสต็อก นำเข้า CSV และแก้ PromptPay';

  @override
  String get appLockSectionTitle => 'การกระทำที่เสี่ยง';

  @override
  String get appLockRequirePin => 'ต้องใช้ PIN ร้าน';

  @override
  String appLockRequirePinHint(int minutes) {
    return 'เมื่อเปิด ระบบจะขอ PIN ก่อนยกเลิกบิล ส่งออก/กู้คืนสำรอง ปรับสต็อก นำเข้า CSV และแก้ PromptPay (ผ่อนผัน $minutes นาที)';
  }

  @override
  String get appLockCreatePin => 'สร้าง PIN ร้าน';

  @override
  String get appLockEnterPin => 'กรอก PIN ร้าน';

  @override
  String get appLockConfirmPin => 'ยืนยัน PIN';

  @override
  String get appLockPinLabel => 'PIN';

  @override
  String get appLockUnlock => 'ปลดล็อก';

  @override
  String get appLockEnabled => 'เปิดใช้ PIN ร้านแล้ว';

  @override
  String get appLockDisabled => 'ปิด PIN ร้านแล้ว';

  @override
  String get appLockEnableFailed => 'เปิดใช้ PIN ไม่สำเร็จ';

  @override
  String get appLockDisableNeedsPin => 'ต้องใช้ PIN เพื่อปิด';

  @override
  String appLockPinTooShort(int min) {
    return 'PIN ต้องมีอย่างน้อย $min หลัก';
  }

  @override
  String get appLockPinTooTrivial =>
      'PIN ง่ายเกินไป — กรุณาตั้ง PIN ที่ยากต่อการเดา';

  @override
  String get appLockIncorrectPin => 'PIN ไม่ถูกต้อง';

  @override
  String get appLockActionRequired => 'ต้องใช้ PIN ร้าน';

  @override
  String get appLockConfirmVoid => 'ยืนยันยกเลิกบิลด้วย PIN ร้าน';

  @override
  String get appLockConfirmPromptPay => 'ยืนยันการเปลี่ยน PromptPay';

  @override
  String get appLockConfirmStock => 'ยืนยันปรับสต็อกด้วย PIN ร้าน';

  @override
  String get appLockConfirmCsv => 'ยืนยันนำเข้า CSV ด้วย PIN ร้าน';

  @override
  String get appLockPinsMismatch => 'PIN ไม่ตรงกัน';

  @override
  String appLockLockedOut(int seconds) {
    return 'พยายามผิดหลายครั้ง ลองใหม่ใน $seconds วินาที';
  }

  @override
  String get appLockEnterCurrentPin => 'กรอก PIN เดิม';

  @override
  String get appLockChangePin => 'เปลี่ยน PIN';

  @override
  String get appLockChangePinHint => 'ต้องใส่ PIN เดิมก่อน แล้วตั้ง PIN ใหม่';

  @override
  String get appLockPinChanged => 'เปลี่ยน PIN แล้ว';

  @override
  String get appLockPinStatus => 'สถานะ PIN';

  @override
  String appLockPinSetDate(String date) {
    return 'ตั้งล่าสุด: $date';
  }

  @override
  String get appLockPinSetUnknown => 'ไม่ทราบวันที่ตั้ง';

  @override
  String get appLockSessionGraceTitle => 'เวลาผ่อนผัน session';

  @override
  String get appLockSessionGraceHint =>
      'หลังปลดล็อก PIN ระบบจะไม่ขอ PIN ซ้ำภายในระยะเวลานี้ — เลือก 0 เพื่อถามทุกครั้ง (single-action)';

  @override
  String get appLockGraceSingleAction => 'ถามทุกครั้ง (single-action)';

  @override
  String get appLockSessionGraceChanged => 'เปลี่ยนเวลาผ่อนผันแล้ว';

  @override
  String get appLockLockoutPolicyTitle => 'นโยบายล็อกชั่วคราว';

  @override
  String get appLockLockoutPolicyHint =>
      'หลังพยายามผิดครบจำนวนที่กำหนด ระบบจะล็อกชั่วคราวและทวีคูณเวลาในแต่ละครั้งถัดไป';

  @override
  String get appLockMaxFailedAttempts => 'จำนวนพยายามผิดสูงสุด';

  @override
  String appLockMaxFailedAttemptsValue(int n) {
    return 'ล็อกหลังผิด $n ครั้ง';
  }

  @override
  String get appLockBaseLockout => 'เวลาล็อกเริ่มต้น';

  @override
  String appLockBaseLockoutValue(String duration) {
    return 'เริ่มต้น $duration (ทวีคูณสูงสุด 16 เท่า)';
  }

  @override
  String get appLockLockoutPolicyChanged => 'เปลี่ยนนโยบายล็อกแล้ว';

  @override
  String get appLockErasePin => 'ลบ PIN ทิ้ง';

  @override
  String get appLockErasePinTitle => 'ลบ PIN ที่เก็บไว้?';

  @override
  String get appLockErasePinConfirm =>
      'การกระทำนี้จะลบ PIN ที่เก็บไว้ถาวร — หากต้องการเปิดใช้ล็อกอีกครั้งจะต้องตั้ง PIN ใหม่ ไม่สามารถยกเลิกได้';

  @override
  String get appLockErasePinHint =>
      'ลบ PIN ที่เก็บไว้ถาวร — การเปิดใช้ใหม่ต้องตั้ง PIN ใหม่';

  @override
  String get appLockPinErased => 'ลบ PIN แล้ว';

  @override
  String get appLockDisableConfirmTitle => 'ปิดใช้ PIN ร้าน?';

  @override
  String get appLockDisableConfirmBody =>
      'หากปิด PIN ร้าน ทุกคนที่เข้าถึงเครื่องนี้จะสามารถยกเลิกบิล ส่งออก/กู้คืนสำรอง ปรับสต็อก นำเข้า CSV และแก้ PromptPay ได้โดยไม่ต้องยืนยัน PIN ยังเก็บไว้ จึงเปิดใช้ใหม่ได้ภายหลังโดยไม่ต้องตั้งใหม่';

  @override
  String get appLockConfirmDisable => 'ปิด ฉันเข้าใจ';

  @override
  String get onboardingStorePinTitle => 'ตั้งรหัส PIN ร้าน';

  @override
  String onboardingStorePinBody(int min) {
    return 'จำเป็นสำหรับยกเลิกบิล สำรอง ปรับสต็อก นำเข้า CSV และแก้ PromptPay (อย่างน้อย $min หลัก) เก็บไว้เอง — ไม่มีระบบกู้ PIN';
  }

  @override
  String get onboardingSkipPin => 'ข้าม';

  @override
  String get onboardingSkipPinConfirmTitle => 'ข้ามการตั้ง PIN?';

  @override
  String get onboardingSkipPinConfirmBody =>
      'หากไม่ตั้ง PIN ร้าน ทุกคนที่เข้าถึงเครื่องนี้จะสามารถยกเลิกบิล ส่งออก/กู้คืนสำรอง ปรับสต็อก นำเข้า CSV และแก้ PromptPay ได้โดยไม่ต้องยืนยัน คุณสามารถเปิด PIN ได้ภายหลังใน การตั้งค่า → ล็อก PIN ร้าน';

  @override
  String get onboardingSetupPinInstead => 'ตั้ง PIN แทน';

  @override
  String get onboardingConfirmSkipPin => 'ข้าม ฉันเข้าใจ';

  @override
  String get onboardingPinSkippedHint =>
      'ยังไม่ตั้ง PIN — เปิดได้ภายหลังใน การตั้งค่า → ล็อก PIN ร้าน';

  @override
  String get exportPdf => 'ส่งออก PDF';

  @override
  String get exportCsv => 'ส่งออก CSV';

  @override
  String get exportReport => 'ส่งออกรายงาน';

  @override
  String get exportNoData => 'ไม่มีข้อมูลให้ส่งออก';

  @override
  String get exportFailed => 'ส่งออกไม่สำเร็จ';

  @override
  String get revenueTrend => 'แนวโน้มยอดขาย';

  @override
  String get dailyRevenue => 'ยอดขายรายวัน';

  @override
  String get periodComparison => 'เทียบกับช่วงก่อนหน้า';

  @override
  String periodChangePositive(String percent) {
    return '+$percent%';
  }

  @override
  String periodChangeNegative(String percent) {
    return '$percent%';
  }

  @override
  String get periodChangeZero => 'ไม่เปลี่ยนแปลง';

  @override
  String get previousPeriod => 'ช่วงก่อนหน้า';

  @override
  String get chartNoData => 'ไม่มีข้อมูลสำหรับกราฟ';

  @override
  String get dateRangeSeparator => ' – ';

  @override
  String get percentagePointsUnit => 'จุด';

  @override
  String get reportSectionLabel => 'ส่วนรายงาน';

  @override
  String get recoveryKitSectionTitle => 'ชุดกู้คืนข้อมูล';

  @override
  String get recoveryKitSectionDesc =>
      'กู้คีย์เข้ารหัสเมื่อเปลี่ยนเครื่องหรือคีย์หาย เก็บไฟล์ .promkey และรหัสลับไว้แยกกันในที่ปลอดภัย';

  @override
  String get recoveryKitExportAction => 'ส่งออกชุดกู้คืน';

  @override
  String get recoveryKitImportAction => 'นำเข้าชุดกู้คืน';

  @override
  String get recoveryKitShareSubject => 'ชุดกู้คืน Promsell POS';

  @override
  String get recoveryKitExportSecretTitle => 'ตั้งรหัสลับสำหรับชุดกู้คืน';

  @override
  String get recoveryKitImportSecretTitle => 'กรอกรหัสลับของชุดกู้คืน';

  @override
  String get recoveryKitSecretLabel => 'รหัสลับ';

  @override
  String get recoveryKitSecretHelper =>
      'อย่างน้อย 8 ตัวอักษร ใช้รหัสนี้เพื่อนำเข้าชุดกู้คืนในภายหลัง';

  @override
  String get recoveryKitSecretRequired => 'กรุณากรอกรหัสลับ';

  @override
  String get recoveryKitSecretTooShort => 'รหัสลับต้องมีอย่างน้อย 8 ตัวอักษร';

  @override
  String get recoveryKitExportConfirmTitle =>
      'ทุกคนที่มีทั้งไฟล์นี้และรหัสลับจะถอดรหัสข้อมูลของคุณได้';

  @override
  String get recoveryKitExportConfirmMessage =>
      'เก็บไฟล์ .promkey และรหัสลับไว้แยกกันในที่ปลอดภัย หากผู้ไม่หวังดีได้ทั้งสองอย่าง จะอ่านข้อมูลการขายและฐานข้อมูลทั้งหมดได้';

  @override
  String get recoveryKitExportSuccess =>
      'ส่งออกชุดกู้คืนแล้ว เก็บไฟล์และรหัสลับไว้ให้ปลอดภัย';

  @override
  String get recoveryKitImportReplaceTitle =>
      'เครื่องนี้มีคีย์เข้ารหัสอยู่แล้ว';

  @override
  String get recoveryKitImportReplaceMessage =>
      'การนำเข้าจะแทนที่คีย์เดิม ข้อมูลที่บันทึกด้วยคีย์เดิมจะต้องใช้คีย์เดิมจึงจะเปิดได้อีกครั้ง ดำเนินการต่อหรือไม่?';

  @override
  String get recoveryKitImportSuccess =>
      'นำเข้าชุดกู้คืนสำเร็จ ข้อมูลสำรองเก่ายังต้องใช้คีย์เดิมที่สร้างไฟล์นั้นไว้';

  @override
  String get recoveryKitErrorWrongSecret => 'รหัสลับไม่ถูกต้อง';

  @override
  String get recoveryKitErrorCorrupt => 'ไฟล์ชุดกู้คืนไม่ถูกต้อง';

  @override
  String get recoveryKitErrorVersionUnsupported =>
      'แอปไม่รองรับชุดกู้คืนเวอร์ชันนี้ กรุณาอัปเดตแอปแล้วลองอีกครั้ง';

  @override
  String get recoveryKitErrorFileNotFound => 'ไม่พบไฟล์ชุดกู้คืน';

  @override
  String get recoveryKitErrorNoKey => 'ไม่พบคีย์เข้ารหัสสำหรับส่งออก';

  @override
  String get recoveryKitErrorKeyUnavailable =>
      'เข้าถึงคีย์เข้ารหัสของเครื่องนี้ไม่ได้ หากมีชุดกู้คืน ให้กดนำเข้าชุดกู้คืนด้านบน แล้วปิดและเปิดแอปใหม่';
}
