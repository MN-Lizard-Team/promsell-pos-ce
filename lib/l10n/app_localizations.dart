import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In th, this message translates to:
  /// **'Promsell POS'**
  String get appTitle;

  /// No description provided for @navSale.
  ///
  /// In th, this message translates to:
  /// **'ขาย'**
  String get navSale;

  /// No description provided for @navProducts.
  ///
  /// In th, this message translates to:
  /// **'สินค้า'**
  String get navProducts;

  /// No description provided for @navHistory.
  ///
  /// In th, this message translates to:
  /// **'ประวัติ'**
  String get navHistory;

  /// No description provided for @navReport.
  ///
  /// In th, this message translates to:
  /// **'รายงาน'**
  String get navReport;

  /// No description provided for @navSettings.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่า'**
  String get navSettings;

  /// No description provided for @salePageTitle.
  ///
  /// In th, this message translates to:
  /// **'ขายสินค้า'**
  String get salePageTitle;

  /// No description provided for @clearCart.
  ///
  /// In th, this message translates to:
  /// **'ล้าง'**
  String get clearCart;

  /// No description provided for @confirmClearCart.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันล้างตะกร้าทั้งหมด?'**
  String get confirmClearCart;

  /// No description provided for @cartTitle.
  ///
  /// In th, this message translates to:
  /// **'ตะกร้า'**
  String get cartTitle;

  /// No description provided for @allCategories.
  ///
  /// In th, this message translates to:
  /// **'ทั้งหมด'**
  String get allCategories;

  /// No description provided for @saleSearchProducts.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาสินค้าที่ขาย...'**
  String get saleSearchProducts;

  /// No description provided for @quickCashExact.
  ///
  /// In th, this message translates to:
  /// **'รับพอดี'**
  String get quickCashExact;

  /// No description provided for @noProducts.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีสินค้า'**
  String get noProducts;

  /// No description provided for @saleSavedSuccess.
  ///
  /// In th, this message translates to:
  /// **'บันทึกการขายเรียบร้อย'**
  String get saleSavedSuccess;

  /// No description provided for @productAddedToCart.
  ///
  /// In th, this message translates to:
  /// **'เพิ่ม {name} แล้ว'**
  String productAddedToCart(String name);

  /// No description provided for @tapProductToAdd.
  ///
  /// In th, this message translates to:
  /// **'แตะสินค้าเพื่อเพิ่มลงตะกร้า'**
  String get tapProductToAdd;

  /// No description provided for @noMatchingProducts.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบสินค้าที่ตรงกัน'**
  String get noMatchingProducts;

  /// No description provided for @stockLimitReached.
  ///
  /// In th, this message translates to:
  /// **'ถึงจำนวนคงเหลือแล้ว'**
  String get stockLimitReached;

  /// No description provided for @cartTotal.
  ///
  /// In th, this message translates to:
  /// **'รวม'**
  String get cartTotal;

  /// No description provided for @checkout.
  ///
  /// In th, this message translates to:
  /// **'ชำระเงิน ({count})'**
  String checkout(int count);

  /// No description provided for @paymentTitle.
  ///
  /// In th, this message translates to:
  /// **'ชำระเงิน'**
  String get paymentTitle;

  /// No description provided for @totalAmount.
  ///
  /// In th, this message translates to:
  /// **'ยอดรวม'**
  String get totalAmount;

  /// No description provided for @cash.
  ///
  /// In th, this message translates to:
  /// **'เงินสด'**
  String get cash;

  /// No description provided for @transfer.
  ///
  /// In th, this message translates to:
  /// **'โอน'**
  String get transfer;

  /// No description provided for @card.
  ///
  /// In th, this message translates to:
  /// **'บัตร'**
  String get card;

  /// No description provided for @receivedAmount.
  ///
  /// In th, this message translates to:
  /// **'รับเงินมา ({currency})'**
  String receivedAmount(String currency);

  /// No description provided for @change.
  ///
  /// In th, this message translates to:
  /// **'เงินทอน'**
  String get change;

  /// No description provided for @confirmPayment.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันการชำระ'**
  String get confirmPayment;

  /// No description provided for @notePlaceholder.
  ///
  /// In th, this message translates to:
  /// **'หมายเหตุ (ไม่บังคับ)'**
  String get notePlaceholder;

  /// No description provided for @paymentReferenceOptional.
  ///
  /// In th, this message translates to:
  /// **'เลขอ้างอิงการชำระเงิน (ไม่บังคับ)'**
  String get paymentReferenceOptional;

  /// No description provided for @saleError.
  ///
  /// In th, this message translates to:
  /// **'บันทึกการขายไม่สำเร็จ'**
  String get saleError;

  /// No description provided for @insufficientCash.
  ///
  /// In th, this message translates to:
  /// **'เงินที่รับมายังไม่ครบยอด'**
  String get insufficientCash;

  /// No description provided for @productsTitle.
  ///
  /// In th, this message translates to:
  /// **'สินค้า'**
  String get productsTitle;

  /// No description provided for @searchProducts.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาสินค้า...'**
  String get searchProducts;

  /// No description provided for @noProductsYet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีสินค้า'**
  String get noProductsYet;

  /// No description provided for @errorOccurred.
  ///
  /// In th, this message translates to:
  /// **'เกิดข้อผิดพลาด'**
  String get errorOccurred;

  /// No description provided for @retry.
  ///
  /// In th, this message translates to:
  /// **'ลองอีกครั้ง'**
  String get retry;

  /// No description provided for @noCategory.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีหมวดหมู่'**
  String get noCategory;

  /// No description provided for @stockLabel.
  ///
  /// In th, this message translates to:
  /// **'คงเหลือ: {count}'**
  String stockLabel(int count);

  /// No description provided for @edit.
  ///
  /// In th, this message translates to:
  /// **'แก้ไข'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In th, this message translates to:
  /// **'ลบ'**
  String get delete;

  /// No description provided for @deleteProduct.
  ///
  /// In th, this message translates to:
  /// **'ลบสินค้า'**
  String get deleteProduct;

  /// No description provided for @confirmDeleteProduct.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันการลบ \"{name}\"?'**
  String confirmDeleteProduct(String name);

  /// No description provided for @cancel.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิก'**
  String get cancel;

  /// No description provided for @addProduct.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มสินค้า'**
  String get addProduct;

  /// No description provided for @editProductTitle.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขสินค้า'**
  String get editProductTitle;

  /// No description provided for @productNameLabel.
  ///
  /// In th, this message translates to:
  /// **'ชื่อสินค้า *'**
  String get productNameLabel;

  /// No description provided for @productNameRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณาใส่ชื่อสินค้า'**
  String get productNameRequired;

  /// No description provided for @priceLabel.
  ///
  /// In th, this message translates to:
  /// **'ราคา ({currency}) *'**
  String priceLabel(String currency);

  /// No description provided for @priceRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณาใส่ราคา'**
  String get priceRequired;

  /// No description provided for @invalidPrice.
  ///
  /// In th, this message translates to:
  /// **'ราคาไม่ถูกต้อง'**
  String get invalidPrice;

  /// No description provided for @quantityLabel.
  ///
  /// In th, this message translates to:
  /// **'จำนวน'**
  String get quantityLabel;

  /// No description provided for @quantityRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณาใส่จำนวน'**
  String get quantityRequired;

  /// No description provided for @invalidQuantity.
  ///
  /// In th, this message translates to:
  /// **'จำนวนไม่ถูกต้อง'**
  String get invalidQuantity;

  /// No description provided for @categoryLabel.
  ///
  /// In th, this message translates to:
  /// **'หมวดหมู่'**
  String get categoryLabel;

  /// No description provided for @showProduct.
  ///
  /// In th, this message translates to:
  /// **'แสดงสินค้า'**
  String get showProduct;

  /// No description provided for @save.
  ///
  /// In th, this message translates to:
  /// **'บันทึก'**
  String get save;

  /// No description provided for @productSaved.
  ///
  /// In th, this message translates to:
  /// **'บันทึกสินค้าแล้ว'**
  String get productSaved;

  /// No description provided for @stockZeroWarning.
  ///
  /// In th, this message translates to:
  /// **'สินค้าจะไม่แสดงในหน้าขายเมื่อสต็อก = 0'**
  String get stockZeroWarning;

  /// No description provided for @historyTitle.
  ///
  /// In th, this message translates to:
  /// **'ประวัติการขาย'**
  String get historyTitle;

  /// No description provided for @noSalesYet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีรายการขาย'**
  String get noSalesYet;

  /// No description provided for @noteLabel.
  ///
  /// In th, this message translates to:
  /// **'หมายเหตุ: {note}'**
  String noteLabel(String note);

  /// No description provided for @reportTitle.
  ///
  /// In th, this message translates to:
  /// **'รายงาน'**
  String get reportTitle;

  /// No description provided for @totalRevenue.
  ///
  /// In th, this message translates to:
  /// **'ยอดขายรวม'**
  String get totalRevenue;

  /// No description provided for @salesCount.
  ///
  /// In th, this message translates to:
  /// **'{count} รายการ'**
  String salesCount(int count);

  /// No description provided for @byPaymentMethod.
  ///
  /// In th, this message translates to:
  /// **'แยกตามวิธีชำระ'**
  String get byPaymentMethod;

  /// No description provided for @topProducts.
  ///
  /// In th, this message translates to:
  /// **'สินค้าขายดี (Top 5)'**
  String get topProducts;

  /// No description provided for @units.
  ///
  /// In th, this message translates to:
  /// **'{count} ชิ้น'**
  String units(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่า'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In th, this message translates to:
  /// **'ทั่วไป'**
  String get settingsGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In th, this message translates to:
  /// **'ภาษา'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In th, this message translates to:
  /// **'ธีม'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In th, this message translates to:
  /// **'สว่าง'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In th, this message translates to:
  /// **'มืด'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In th, this message translates to:
  /// **'ตามระบบ'**
  String get settingsThemeSystem;

  /// No description provided for @settingsShopInfo.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลร้าน'**
  String get settingsShopInfo;

  /// No description provided for @settingsShopName.
  ///
  /// In th, this message translates to:
  /// **'ชื่อร้าน'**
  String get settingsShopName;

  /// No description provided for @settingsAddress.
  ///
  /// In th, this message translates to:
  /// **'ที่อยู่'**
  String get settingsAddress;

  /// No description provided for @settingsPhone.
  ///
  /// In th, this message translates to:
  /// **'เบอร์โทรศัพท์'**
  String get settingsPhone;

  /// No description provided for @settingsSales.
  ///
  /// In th, this message translates to:
  /// **'การขาย'**
  String get settingsSales;

  /// No description provided for @settingsCurrency.
  ///
  /// In th, this message translates to:
  /// **'สกุลเงิน'**
  String get settingsCurrency;

  /// No description provided for @settingsDateFormat.
  ///
  /// In th, this message translates to:
  /// **'รูปแบบวันที่'**
  String get settingsDateFormat;

  /// No description provided for @settingsReceipt.
  ///
  /// In th, this message translates to:
  /// **'ใบเสร็จ'**
  String get settingsReceipt;

  /// No description provided for @settingsReceiptNote.
  ///
  /// In th, this message translates to:
  /// **'หมายเหตุท้ายใบเสร็จ'**
  String get settingsReceiptNote;

  /// No description provided for @settingsShowShopInfo.
  ///
  /// In th, this message translates to:
  /// **'แสดงข้อมูลร้านในใบเสร็จ'**
  String get settingsShowShopInfo;

  /// No description provided for @settingsSaved.
  ///
  /// In th, this message translates to:
  /// **'บันทึกการตั้งค่าแล้ว'**
  String get settingsSaved;

  /// No description provided for @langThai.
  ///
  /// In th, this message translates to:
  /// **'ภาษาไทย'**
  String get langThai;

  /// No description provided for @langEnglish.
  ///
  /// In th, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @printReceipt.
  ///
  /// In th, this message translates to:
  /// **'พิมพ์ใบเสร็จ'**
  String get printReceipt;

  /// No description provided for @shareReceipt.
  ///
  /// In th, this message translates to:
  /// **'แชร์ใบเสร็จ'**
  String get shareReceipt;

  /// No description provided for @receiptLabelReceipt.
  ///
  /// In th, this message translates to:
  /// **'ใบเสร็จ'**
  String get receiptLabelReceipt;

  /// No description provided for @receiptLabelPayment.
  ///
  /// In th, this message translates to:
  /// **'ชำระเงิน'**
  String get receiptLabelPayment;

  /// No description provided for @receiptLabelTotal.
  ///
  /// In th, this message translates to:
  /// **'รวม'**
  String get receiptLabelTotal;

  /// No description provided for @receiptLabelReceived.
  ///
  /// In th, this message translates to:
  /// **'รับเงิน'**
  String get receiptLabelReceived;

  /// No description provided for @receiptLabelChange.
  ///
  /// In th, this message translates to:
  /// **'ทอน'**
  String get receiptLabelChange;

  /// No description provided for @receiptLabelNote.
  ///
  /// In th, this message translates to:
  /// **'หมายเหตุ'**
  String get receiptLabelNote;

  /// No description provided for @receiptLabelVat.
  ///
  /// In th, this message translates to:
  /// **'ภาษีมูลค่าเพิ่ม'**
  String get receiptLabelVat;

  /// No description provided for @receiptLabelVatIncluded.
  ///
  /// In th, this message translates to:
  /// **'VAT {rate}% (รวมแล้ว)'**
  String receiptLabelVatIncluded(Object rate);

  /// No description provided for @receiptLabelSubtotal.
  ///
  /// In th, this message translates to:
  /// **'ย่อยรวม'**
  String get receiptLabelSubtotal;

  /// No description provided for @settingsAutoPrintPrompt.
  ///
  /// In th, this message translates to:
  /// **'ถามพิมพ์ใบเสร็จหลังขาย'**
  String get settingsAutoPrintPrompt;

  /// No description provided for @settingsVatRate.
  ///
  /// In th, this message translates to:
  /// **'อัตรา VAT (%)'**
  String get settingsVatRate;

  /// No description provided for @settingsVatMode.
  ///
  /// In th, this message translates to:
  /// **'โหมด VAT'**
  String get settingsVatMode;

  /// No description provided for @settingsReceiptPreviewStyle.
  ///
  /// In th, this message translates to:
  /// **'รูปแบบตัวอย่างใบเสร็จ'**
  String get settingsReceiptPreviewStyle;

  /// No description provided for @settingsShowPreSalePreview.
  ///
  /// In th, this message translates to:
  /// **'แสดงตัวอย่างใบเสร็จก่อนชำระ'**
  String get settingsShowPreSalePreview;

  /// No description provided for @settingsShowPostSalePreview.
  ///
  /// In th, this message translates to:
  /// **'แสดงตัวอย่างใบเสร็จหลังขาย'**
  String get settingsShowPostSalePreview;

  /// No description provided for @receiptPreviewStyleThermal.
  ///
  /// In th, this message translates to:
  /// **'กระดาษความร้อน'**
  String get receiptPreviewStyleThermal;

  /// No description provided for @receiptPreviewStyleCard.
  ///
  /// In th, this message translates to:
  /// **'การ์ด'**
  String get receiptPreviewStyleCard;

  /// No description provided for @receiptPreviewStyleNone.
  ///
  /// In th, this message translates to:
  /// **'ไม่แสดง'**
  String get receiptPreviewStyleNone;

  /// No description provided for @receiptPreview.
  ///
  /// In th, this message translates to:
  /// **'ตัวอย่างใบเสร็จ'**
  String get receiptPreview;

  /// No description provided for @vatModeNone.
  ///
  /// In th, this message translates to:
  /// **'ไม่มี'**
  String get vatModeNone;

  /// No description provided for @vatModeInclusive.
  ///
  /// In th, this message translates to:
  /// **'รวมแล้ว'**
  String get vatModeInclusive;

  /// No description provided for @vatModeExclusive.
  ///
  /// In th, this message translates to:
  /// **'แยกนอก'**
  String get vatModeExclusive;

  /// No description provided for @voided.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิกแล้ว'**
  String get voided;

  /// No description provided for @voidSale.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิกบิล'**
  String get voidSale;

  /// No description provided for @voidSaleConfirm.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิกบิลนี้? สต็อกจะถูกคืน'**
  String get voidSaleConfirm;

  /// No description provided for @voidReasonHint.
  ///
  /// In th, this message translates to:
  /// **'เหตุผลในการยกเลิก (ไม่บังคับ)'**
  String get voidReasonHint;

  /// No description provided for @voidSuccess.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิกบิลแล้ว'**
  String get voidSuccess;

  /// No description provided for @voidedSalesCount.
  ///
  /// In th, this message translates to:
  /// **'{count} รายการยกเลิก'**
  String voidedSalesCount(int count);

  /// No description provided for @voidedTotal.
  ///
  /// In th, this message translates to:
  /// **'ยอดที่ถูกยกเลิก'**
  String get voidedTotal;

  /// No description provided for @netRevenue.
  ///
  /// In th, this message translates to:
  /// **'ยอดขายสุทธิ'**
  String get netRevenue;

  /// No description provided for @adjustStock.
  ///
  /// In th, this message translates to:
  /// **'ปรับสต็อก'**
  String get adjustStock;

  /// No description provided for @adjustStockTitle.
  ///
  /// In th, this message translates to:
  /// **'ปรับสต็อก: {name}'**
  String adjustStockTitle(String name);

  /// No description provided for @adjustQtyLabel.
  ///
  /// In th, this message translates to:
  /// **'จำนวนที่เปลี่ยน (+/-)'**
  String get adjustQtyLabel;

  /// No description provided for @adjustReasonLabel.
  ///
  /// In th, this message translates to:
  /// **'เหตุผล *'**
  String get adjustReasonLabel;

  /// No description provided for @adjustReasonRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณาระบุเหตุผล'**
  String get adjustReasonRequired;

  /// No description provided for @adjustSuccess.
  ///
  /// In th, this message translates to:
  /// **'ปรับสต็อกแล้ว'**
  String get adjustSuccess;

  /// No description provided for @inventoryLog.
  ///
  /// In th, this message translates to:
  /// **'ประวัติสต็อก'**
  String get inventoryLog;

  /// No description provided for @noInventoryLogs.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีประวัติสต็อก'**
  String get noInventoryLogs;

  /// No description provided for @invLogTypeSale.
  ///
  /// In th, this message translates to:
  /// **'ขาย'**
  String get invLogTypeSale;

  /// No description provided for @invLogTypeVoidReversal.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิกบิล'**
  String get invLogTypeVoidReversal;

  /// No description provided for @invLogTypeStockIn.
  ///
  /// In th, this message translates to:
  /// **'รับสต็อก'**
  String get invLogTypeStockIn;

  /// No description provided for @invLogTypeStockOut.
  ///
  /// In th, this message translates to:
  /// **'ตัดสต็อก'**
  String get invLogTypeStockOut;

  /// No description provided for @productFormSectionBasicInfo.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลพื้นฐาน'**
  String get productFormSectionBasicInfo;

  /// No description provided for @productFormSectionDetails.
  ///
  /// In th, this message translates to:
  /// **'รายละเอียด'**
  String get productFormSectionDetails;

  /// No description provided for @productFormImageUrlLabel.
  ///
  /// In th, this message translates to:
  /// **'URL รูปภาพ (ไม่บังคับ)'**
  String get productFormImageUrlLabel;

  /// No description provided for @trackStock.
  ///
  /// In th, this message translates to:
  /// **'ติดตามสต็อค'**
  String get trackStock;

  /// No description provided for @trackStockHint.
  ///
  /// In th, this message translates to:
  /// **'ปิดเพื่อสินค้าประเภทบริการ (ไม่ตัดสต็อค)'**
  String get trackStockHint;

  /// No description provided for @settingsStockPolicy.
  ///
  /// In th, this message translates to:
  /// **'นโยบายสต็อค'**
  String get settingsStockPolicy;

  /// No description provided for @allowOversell.
  ///
  /// In th, this message translates to:
  /// **'อนุญาตขายเกินสต็อค'**
  String get allowOversell;

  /// No description provided for @allowOversellHint.
  ///
  /// In th, this message translates to:
  /// **'อนุญาตให้เพิ่มสินค้าเกินจำนวนคงเหลือได้'**
  String get allowOversellHint;

  /// No description provided for @lowStockThreshold.
  ///
  /// In th, this message translates to:
  /// **'เตือนสต็อคต่ำ (จำนวน)'**
  String get lowStockThreshold;

  /// No description provided for @lowStockWarning.
  ///
  /// In th, this message translates to:
  /// **'สต็อคใกล้หมด'**
  String get lowStockWarning;

  /// No description provided for @discountSectionLabel.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลด'**
  String get discountSectionLabel;

  /// No description provided for @discountDialogTitle.
  ///
  /// In th, this message translates to:
  /// **'ใส่ส่วนลด'**
  String get discountDialogTitle;

  /// No description provided for @discountTypePercent.
  ///
  /// In th, this message translates to:
  /// **'% ประเภทเปอร์เซ็นต์'**
  String get discountTypePercent;

  /// No description provided for @discountTypeAmount.
  ///
  /// In th, this message translates to:
  /// **'บาท'**
  String get discountTypeAmount;

  /// No description provided for @discountPreview.
  ///
  /// In th, this message translates to:
  /// **'หลังหัก: {amount}'**
  String discountPreview(String amount);

  /// No description provided for @discountApply.
  ///
  /// In th, this message translates to:
  /// **'ใช้ส่วนลด'**
  String get discountApply;

  /// No description provided for @discountClear.
  ///
  /// In th, this message translates to:
  /// **'ลบส่วนลด'**
  String get discountClear;

  /// No description provided for @cartDiscount.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลดทั้งบิล'**
  String get cartDiscount;

  /// No description provided for @applyCartDiscount.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มส่วนลดทั้งบิล'**
  String get applyCartDiscount;

  /// No description provided for @discountLabel.
  ///
  /// In th, this message translates to:
  /// **'-{amount}'**
  String discountLabel(String amount);

  /// No description provided for @discountValueRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณาใส่จำนวนส่วนลด'**
  String get discountValueRequired;

  /// No description provided for @discountValueInvalid.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลดไม่ถูกต้อง'**
  String get discountValueInvalid;

  /// No description provided for @preTaxTotal.
  ///
  /// In th, this message translates to:
  /// **'ยอดก่อภาษี'**
  String get preTaxTotal;

  /// No description provided for @settingsDiscountPolicy.
  ///
  /// In th, this message translates to:
  /// **'นโยบายส่วนลด'**
  String get settingsDiscountPolicy;

  /// No description provided for @enableItemDiscount.
  ///
  /// In th, this message translates to:
  /// **'เปิดใช้ส่วนลดต่อรายการ'**
  String get enableItemDiscount;

  /// No description provided for @enableCartDiscount.
  ///
  /// In th, this message translates to:
  /// **'เปิดใช้ส่วนลดต่อบิล'**
  String get enableCartDiscount;

  /// No description provided for @maxDiscountPercent.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลดสูงสุด (%)'**
  String get maxDiscountPercent;

  /// No description provided for @maxDiscountAmount.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลดสูงสุด (บาท)'**
  String get maxDiscountAmount;

  /// No description provided for @defaultDiscountType.
  ///
  /// In th, this message translates to:
  /// **'ประเภทส่วนลดเริ่มต้น'**
  String get defaultDiscountType;

  /// No description provided for @presetDiscountValues.
  ///
  /// In th, this message translates to:
  /// **'ค่าส่วนลดเร็ว (คั่นด้วย ,)'**
  String get presetDiscountValues;

  /// No description provided for @discountPresetsTitle.
  ///
  /// In th, this message translates to:
  /// **'ชุดส่วนลด'**
  String get discountPresetsTitle;

  /// No description provided for @discountPresetName.
  ///
  /// In th, this message translates to:
  /// **'ชื่อชุด'**
  String get discountPresetName;

  /// No description provided for @discountPresetType.
  ///
  /// In th, this message translates to:
  /// **'ประเภท'**
  String get discountPresetType;

  /// No description provided for @discountPresetValues.
  ///
  /// In th, this message translates to:
  /// **'ค่าส่วนลด'**
  String get discountPresetValues;

  /// No description provided for @addDiscountPreset.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มชุดส่วนลด'**
  String get addDiscountPreset;

  /// No description provided for @deleteDiscountPreset.
  ///
  /// In th, this message translates to:
  /// **'ลบชุด'**
  String get deleteDiscountPreset;

  /// No description provided for @activeDiscountPreset.
  ///
  /// In th, this message translates to:
  /// **'ใช้งานอยู่'**
  String get activeDiscountPreset;

  /// No description provided for @noDiscountPresets.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีชุดส่วนลด'**
  String get noDiscountPresets;

  /// No description provided for @addPresetValue.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มค่า'**
  String get addPresetValue;

  /// No description provided for @receiptItemDiscounts.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลดรายการ'**
  String get receiptItemDiscounts;

  /// No description provided for @receiptCartDiscount.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลดบิล'**
  String get receiptCartDiscount;

  /// No description provided for @draftsTitle.
  ///
  /// In th, this message translates to:
  /// **'บิลที่บันทึก'**
  String get draftsTitle;

  /// No description provided for @newDraft.
  ///
  /// In th, this message translates to:
  /// **'บิลใหม่'**
  String get newDraft;

  /// No description provided for @renameDraft.
  ///
  /// In th, this message translates to:
  /// **'เปลี่ยนชื่อ'**
  String get renameDraft;

  /// No description provided for @deleteDraft.
  ///
  /// In th, this message translates to:
  /// **'ลบบิล'**
  String get deleteDraft;

  /// No description provided for @deleteDraftConfirm.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันลบบิลนี้?'**
  String get deleteDraftConfirm;

  /// No description provided for @draftLimitReached.
  ///
  /// In th, this message translates to:
  /// **'บิลเต็ม  10 บิลแล้ว กรุณาลบบิลเก่าก่อน'**
  String get draftLimitReached;

  /// No description provided for @activeDraftLabel.
  ///
  /// In th, this message translates to:
  /// **'ใช้งานอยู่'**
  String get activeDraftLabel;

  /// No description provided for @draftNameHint.
  ///
  /// In th, this message translates to:
  /// **'ชื่อบิล (ไม่บังคับ)'**
  String get draftNameHint;

  /// No description provided for @switchDraft.
  ///
  /// In th, this message translates to:
  /// **'สลับไปบิลนี้'**
  String get switchDraft;

  /// No description provided for @cartCleared.
  ///
  /// In th, this message translates to:
  /// **'ล้างตะกร้าแล้ว'**
  String get cartCleared;

  /// No description provided for @undo.
  ///
  /// In th, this message translates to:
  /// **'เรียกคืน'**
  String get undo;

  /// No description provided for @itemRemoved.
  ///
  /// In th, this message translates to:
  /// **'ลบรายการแล้ว'**
  String get itemRemoved;

  /// No description provided for @removeItem.
  ///
  /// In th, this message translates to:
  /// **'ลบรายการ'**
  String get removeItem;

  /// No description provided for @listView.
  ///
  /// In th, this message translates to:
  /// **'มุมมองรายการ'**
  String get listView;

  /// No description provided for @gridView.
  ///
  /// In th, this message translates to:
  /// **'มุมมองตาราง'**
  String get gridView;

  /// No description provided for @confirmPaymentAmount.
  ///
  /// In th, this message translates to:
  /// **'ยืนยัน {currency}{amount}'**
  String confirmPaymentAmount(String currency, String amount);

  /// No description provided for @discountPreviewPercent.
  ///
  /// In th, this message translates to:
  /// **'หลังหัก: {value}%'**
  String discountPreviewPercent(String value);

  /// No description provided for @pickImageGallery.
  ///
  /// In th, this message translates to:
  /// **'เลือกจากคลังรูป'**
  String get pickImageGallery;

  /// No description provided for @pickImageCamera.
  ///
  /// In th, this message translates to:
  /// **'ถ่ายรูป'**
  String get pickImageCamera;

  /// No description provided for @removeImage.
  ///
  /// In th, this message translates to:
  /// **'ลบรูป'**
  String get removeImage;

  /// No description provided for @imagePickError.
  ///
  /// In th, this message translates to:
  /// **'ไม่สามารถเลือกรูปได้'**
  String get imagePickError;

  /// No description provided for @promptpay.
  ///
  /// In th, this message translates to:
  /// **'พร้อมเพย์'**
  String get promptpay;

  /// No description provided for @settingsPromptpayId.
  ///
  /// In th, this message translates to:
  /// **'PromptPay ID'**
  String get settingsPromptpayId;

  /// No description provided for @settingsPromptpayIdHint.
  ///
  /// In th, this message translates to:
  /// **'เบอร์โทรหรือเลขบัตรประชาชน'**
  String get settingsPromptpayIdHint;

  /// No description provided for @promptpayQrTitle.
  ///
  /// In th, this message translates to:
  /// **'สแกนจ่ายเงิน'**
  String get promptpayQrTitle;

  /// No description provided for @promptpayConfirmPayment.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันรับเงินแล้ว'**
  String get promptpayConfirmPayment;

  /// No description provided for @promptpayNotConfigured.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ได้ตั้งค่า PromptPay'**
  String get promptpayNotConfigured;

  /// No description provided for @promptpaySettingsHint.
  ///
  /// In th, this message translates to:
  /// **'ไปตั้งค่า'**
  String get promptpaySettingsHint;

  /// No description provided for @settingsReceiptSize.
  ///
  /// In th, this message translates to:
  /// **'ขนาดใบเสร็จ'**
  String get settingsReceiptSize;

  /// No description provided for @receiptSize80mm.
  ///
  /// In th, this message translates to:
  /// **'80mm (กระดาษความร้อน)'**
  String get receiptSize80mm;

  /// No description provided for @receiptSizeA4.
  ///
  /// In th, this message translates to:
  /// **'A4'**
  String get receiptSizeA4;

  /// No description provided for @settingsData.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูล'**
  String get settingsData;

  /// No description provided for @exportDatabase.
  ///
  /// In th, this message translates to:
  /// **'ส่งออกฐานข้อมูล (สำรองข้อมูลเต็มรูปแบบ)'**
  String get exportDatabase;

  /// No description provided for @exportSalesCsv.
  ///
  /// In th, this message translates to:
  /// **'ส่งออกยอดขาย (CSV)'**
  String get exportSalesCsv;

  /// No description provided for @exportProductsCsv.
  ///
  /// In th, this message translates to:
  /// **'ส่งออกสินค้า (CSV)'**
  String get exportProductsCsv;

  /// No description provided for @restoreFromBackup.
  ///
  /// In th, this message translates to:
  /// **'กู้คืนจากสำรอง...'**
  String get restoreFromBackup;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันกู้คืนข้อมูล?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลปัจจุบันจะถูกเขียนทับ ดำเนินการต่อ?'**
  String get restoreConfirmMessage;

  /// No description provided for @restoreSuccess.
  ///
  /// In th, this message translates to:
  /// **'กู้คืนข้อมูลสำเร็จ'**
  String get restoreSuccess;

  /// No description provided for @restoreError.
  ///
  /// In th, this message translates to:
  /// **'กู้คืนข้อมูลไม่สำเร็จ'**
  String get restoreError;

  /// No description provided for @backupReminderTitle.
  ///
  /// In th, this message translates to:
  /// **'แนะนำสำรองข้อมูล'**
  String get backupReminderTitle;

  /// No description provided for @backupReminderMessage.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ได้สำรองข้อมูลมากกว่า {days} วัน'**
  String backupReminderMessage(int days);

  /// No description provided for @settingsBackupReminderDays.
  ///
  /// In th, this message translates to:
  /// **'เตือนสำรองข้อมูล (วัน, 0=ปิด)'**
  String get settingsBackupReminderDays;

  /// No description provided for @backupNow.
  ///
  /// In th, this message translates to:
  /// **'สำรองเลย'**
  String get backupNow;

  /// No description provided for @exportSuccess.
  ///
  /// In th, this message translates to:
  /// **'ส่งออกสำเร็จ'**
  String get exportSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
