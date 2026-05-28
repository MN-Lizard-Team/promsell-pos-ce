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
}
