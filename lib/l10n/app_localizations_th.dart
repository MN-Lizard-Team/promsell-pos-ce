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
  String get noSalesYet => 'ยังไม่มีรายการขาย';

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
  String get settingsGeneral => 'ทั่วไป';

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
  String get settingsShowShopInfo => 'แสดงข้อมูลร้านในใบเสร็จ';

  @override
  String get settingsSaved => 'บันทึกการตั้งค่าแล้ว';

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
  String get listView => 'มุมมองรายการ';

  @override
  String get gridView => 'มุมมองตาราง';

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
  String get settingsReceiptSize => 'ขนาดใบเสร็จ';

  @override
  String get receiptSize80mm => '80mm (กระดาษความร้อน)';

  @override
  String get receiptSizeA4 => 'A4';

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
  String get backupNow => 'สำรองเลย';

  @override
  String get exportSuccess => 'ส่งออกสำเร็จ';
}
