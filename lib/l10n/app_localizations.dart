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

  /// No description provided for @appTagline.
  ///
  /// In th, this message translates to:
  /// **'ร้านค้าอัจฉริยะ'**
  String get appTagline;

  /// No description provided for @loading.
  ///
  /// In th, this message translates to:
  /// **'กำลังโหลด...'**
  String get loading;

  /// No description provided for @navHome.
  ///
  /// In th, this message translates to:
  /// **'หน้าหลัก'**
  String get navHome;

  /// No description provided for @navSale.
  ///
  /// In th, this message translates to:
  /// **'ขายสินค้า'**
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

  /// No description provided for @salePageSubtitle.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มสินค้าและทำรายการขาย'**
  String get salePageSubtitle;

  /// No description provided for @saleBillNoteTitle.
  ///
  /// In th, this message translates to:
  /// **'หมายเหตุบิล'**
  String get saleBillNoteTitle;

  /// No description provided for @dragToResizeCart.
  ///
  /// In th, this message translates to:
  /// **'ลากเพื่อปรับขนาดตะกร้า'**
  String get dragToResizeCart;

  /// No description provided for @exitCompactMode.
  ///
  /// In th, this message translates to:
  /// **'ออกจากโหมดกะทัดรัด'**
  String get exitCompactMode;

  /// No description provided for @exitCompactModeConfirm.
  ///
  /// In th, this message translates to:
  /// **'สลับเป็นมุมมองตะกร้าปกติ?'**
  String get exitCompactModeConfirm;

  /// No description provided for @autoConfirmingIn.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันอัตโนมัติใน {secs}...'**
  String autoConfirmingIn(int secs);

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
  /// **'บิล'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In th, this message translates to:
  /// **'ตะกร้าว่าง'**
  String get cartEmpty;

  /// No description provided for @backToSale.
  ///
  /// In th, this message translates to:
  /// **'กลับไปขายสินค้า'**
  String get backToSale;

  /// No description provided for @checkoutButton.
  ///
  /// In th, this message translates to:
  /// **'ชำระเงิน'**
  String get checkoutButton;

  /// No description provided for @addItems.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มสินค้า'**
  String get addItems;

  /// No description provided for @itemRemoved.
  ///
  /// In th, this message translates to:
  /// **'ลบ {name} แล้ว'**
  String itemRemoved(String name);

  /// No description provided for @undo.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิก'**
  String get undo;

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
  /// **'แตะสินค้าเพื่อเพิ่มในบิลนี้'**
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
  /// **'ยอดชำระ'**
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

  /// No description provided for @saleTimeout.
  ///
  /// In th, this message translates to:
  /// **'หมดเวลารอการชำระเงิน กรุณาลองอีกครั้ง'**
  String get saleTimeout;

  /// No description provided for @insufficientCash.
  ///
  /// In th, this message translates to:
  /// **'เงินที่รับมายังไม่ครบยอด'**
  String get insufficientCash;

  /// No description provided for @remainingAmount.
  ///
  /// In th, this message translates to:
  /// **'ยอดขาด'**
  String get remainingAmount;

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

  /// No description provided for @recentSearches.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาล่าสุด'**
  String get recentSearches;

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

  /// No description provided for @stockRemaining.
  ///
  /// In th, this message translates to:
  /// **'เหลือ: {count}'**
  String stockRemaining(int count);

  /// No description provided for @itemNoteLabel.
  ///
  /// In th, this message translates to:
  /// **'หมายเหตุสินค้า'**
  String get itemNoteLabel;

  /// No description provided for @itemNoteHint.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มหมายเหตุสำหรับสินค้านี้'**
  String get itemNoteHint;

  /// No description provided for @duplicateItem.
  ///
  /// In th, this message translates to:
  /// **'คัดลอกรายการแล้ว'**
  String get duplicateItem;

  /// No description provided for @duplicateItemAction.
  ///
  /// In th, this message translates to:
  /// **'คัดลอกรายการ'**
  String get duplicateItemAction;

  /// No description provided for @clear.
  ///
  /// In th, this message translates to:
  /// **'ล้าง'**
  String get clear;

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

  /// No description provided for @activate.
  ///
  /// In th, this message translates to:
  /// **'เปิดใช้งาน'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In th, this message translates to:
  /// **'ปิดการใช้งาน'**
  String get deactivate;

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

  /// No description provided for @productDeactivateConfirm.
  ///
  /// In th, this message translates to:
  /// **'ปิดการใช้งาน \"{name}\"? สินค้านี้จะถูกซ่อนจากหน้าขาย'**
  String productDeactivateConfirm(String name);

  /// No description provided for @productActivateConfirm.
  ///
  /// In th, this message translates to:
  /// **'เปิดใช้งาน \"{name}\"? สินค้านี้จะแสดงบนหน้าขาย'**
  String productActivateConfirm(String name);

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

  /// No description provided for @productNameTooLong.
  ///
  /// In th, this message translates to:
  /// **'ชื่อสินค้ายาวเกินไป (สูงสุด 100 ตัวอักษร)'**
  String get productNameTooLong;

  /// No description provided for @quickEditStockSet.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่าใหม่'**
  String get quickEditStockSet;

  /// No description provided for @quickEditStockAdjust.
  ///
  /// In th, this message translates to:
  /// **'เพิ่ม/ลด'**
  String get quickEditStockAdjust;

  /// No description provided for @quickEditNameHint.
  ///
  /// In th, this message translates to:
  /// **'ใส่ชื่อสินค้าใหม่'**
  String get quickEditNameHint;

  /// No description provided for @quickEditPriceHint.
  ///
  /// In th, this message translates to:
  /// **'ใส่ราคาขายใหม่'**
  String get quickEditPriceHint;

  /// No description provided for @quickEditStockSetHint.
  ///
  /// In th, this message translates to:
  /// **'แตะ + / - หรือตัวเลขเพื่อแก้ไข กดค้างปุ่มเพื่อปรับเร็ว'**
  String get quickEditStockSetHint;

  /// No description provided for @quickEditStockAdjustHint.
  ///
  /// In th, this message translates to:
  /// **'ใส่จำนวนที่ต้องการเพิ่มหรือลดจากสต็อกปัจจุบัน'**
  String get quickEditStockAdjustHint;

  /// No description provided for @stockStepperLongPressHint.
  ///
  /// In th, this message translates to:
  /// **'กดค้างเพื่อเพิ่ม/ลดแบบต่อเนื่อง'**
  String get stockStepperLongPressHint;

  /// No description provided for @stockStepperTapNumberHint.
  ///
  /// In th, this message translates to:
  /// **'แตะตัวเลขเพื่อกรอกโดยตรง'**
  String get stockStepperTapNumberHint;

  /// No description provided for @quickEditNameSaved.
  ///
  /// In th, this message translates to:
  /// **'อัปเดตชื่อแล้ว'**
  String get quickEditNameSaved;

  /// No description provided for @quickEditNameCancelled.
  ///
  /// In th, this message translates to:
  /// **'ไม่ได้เปลี่ยนแปลงชื่อ'**
  String get quickEditNameCancelled;

  /// No description provided for @quickEditNameInvalid.
  ///
  /// In th, this message translates to:
  /// **'ชื่อไม่ถูกต้อง'**
  String get quickEditNameInvalid;

  /// No description provided for @quickEditPriceSaved.
  ///
  /// In th, this message translates to:
  /// **'อัปเดตราคาแล้ว'**
  String get quickEditPriceSaved;

  /// No description provided for @quickEditPriceCancelled.
  ///
  /// In th, this message translates to:
  /// **'ไม่ได้เปลี่ยนแปลงราคา'**
  String get quickEditPriceCancelled;

  /// No description provided for @quickEditPriceInvalid.
  ///
  /// In th, this message translates to:
  /// **'ราคาไม่ถูกต้อง'**
  String get quickEditPriceInvalid;

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

  /// No description provided for @priceMustBePositive.
  ///
  /// In th, this message translates to:
  /// **'ราคาต้องมากกว่า 0'**
  String get priceMustBePositive;

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

  /// No description provided for @invalidBarcode.
  ///
  /// In th, this message translates to:
  /// **'บาร์โค้ดต้องเป็นตัวอักษรและตัวเลขเท่านั้น'**
  String get invalidBarcode;

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

  /// No description provided for @productVisibility.
  ///
  /// In th, this message translates to:
  /// **'การมองเห็นสินค้า'**
  String get productVisibility;

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

  /// No description provided for @productActivated.
  ///
  /// In th, this message translates to:
  /// **'เปิดใช้งานสินค้าแล้ว'**
  String get productActivated;

  /// No description provided for @productDeactivated.
  ///
  /// In th, this message translates to:
  /// **'ปิดการใช้งานสินค้าแล้ว'**
  String get productDeactivated;

  /// No description provided for @productDeleted.
  ///
  /// In th, this message translates to:
  /// **'ลบสินค้าแล้ว'**
  String get productDeleted;

  /// No description provided for @stockUpdated.
  ///
  /// In th, this message translates to:
  /// **'อัปเดตสต็อกแล้ว'**
  String get stockUpdated;

  /// No description provided for @stockUpdateCancelled.
  ///
  /// In th, this message translates to:
  /// **'ไม่ได้เปลี่ยนแปลงสต็อก'**
  String get stockUpdateCancelled;

  /// No description provided for @stockUpdateInvalid.
  ///
  /// In th, this message translates to:
  /// **'ค่าสต็อกไม่ถูกต้อง'**
  String get stockUpdateInvalid;

  /// No description provided for @stockUpdateError.
  ///
  /// In th, this message translates to:
  /// **'อัปเดตสต็อกไม่สำเร็จ'**
  String get stockUpdateError;

  /// No description provided for @productUpdateError.
  ///
  /// In th, this message translates to:
  /// **'อัปเดตสินค้าไม่สำเร็จ'**
  String get productUpdateError;

  /// No description provided for @productAddError.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มสินค้าไม่สำเร็จ'**
  String get productAddError;

  /// No description provided for @productDeleteError.
  ///
  /// In th, this message translates to:
  /// **'ลบสินค้าไม่สำเร็จ'**
  String get productDeleteError;

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

  /// No description provided for @searchHistoryHint.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาเลขใบเสร็จ วิธีชำระ ยอดรวม…'**
  String get searchHistoryHint;

  /// No description provided for @noSearchResults.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบการตั้งค่า'**
  String get noSearchResults;

  /// No description provided for @noSalesYet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีรายการขาย'**
  String get noSalesYet;

  /// No description provided for @noDailyClosesYet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีการปิดรับ'**
  String get noDailyClosesYet;

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

  /// No description provided for @searchSettings.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาการตั้งค่า...'**
  String get searchSettings;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In th, this message translates to:
  /// **'กดย้อนกลับอีกครั้งเพื่อออก'**
  String get pressBackAgainToExit;

  /// No description provided for @settingsGeneral.
  ///
  /// In th, this message translates to:
  /// **'ทั่วไป'**
  String get settingsGeneral;

  /// No description provided for @settingsStoreBusiness.
  ///
  /// In th, this message translates to:
  /// **'ร้านค้าและธุรกิจ'**
  String get settingsStoreBusiness;

  /// No description provided for @settingsPayments.
  ///
  /// In th, this message translates to:
  /// **'การชำระเงิน'**
  String get settingsPayments;

  /// No description provided for @settingsSystemData.
  ///
  /// In th, this message translates to:
  /// **'ระบบและข้อมูล'**
  String get settingsSystemData;

  /// No description provided for @settingsStatusComplete.
  ///
  /// In th, this message translates to:
  /// **'สมบูรณ์'**
  String get settingsStatusComplete;

  /// No description provided for @settingsStatusIncomplete.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่สมบูรณ์'**
  String get settingsStatusIncomplete;

  /// No description provided for @settingsStatusActive.
  ///
  /// In th, this message translates to:
  /// **'ใช้งานอยู่'**
  String get settingsStatusActive;

  /// No description provided for @settingsStatusNotSet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ตั้งค่า'**
  String get settingsStatusNotSet;

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

  /// No description provided for @settingsAccessibilityMode.
  ///
  /// In th, this message translates to:
  /// **'ตัวอักษรใหญ่และคอนทราสต์สูง'**
  String get settingsAccessibilityMode;

  /// No description provided for @settingsAccessibilityModeHint.
  ///
  /// In th, this message translates to:
  /// **'ตัวอักษรใหญ่ขึ้น อ่านง่ายขึ้น'**
  String get settingsAccessibilityModeHint;

  /// No description provided for @generalSettingsAppearance.
  ///
  /// In th, this message translates to:
  /// **'รูปแบบ'**
  String get generalSettingsAppearance;

  /// No description provided for @generalSettingsLanguageRegion.
  ///
  /// In th, this message translates to:
  /// **'ภาษาและภูมิภาค'**
  String get generalSettingsLanguageRegion;

  /// No description provided for @generalSettingsReset.
  ///
  /// In th, this message translates to:
  /// **'คืนค่าเริ่มต้น'**
  String get generalSettingsReset;

  /// No description provided for @generalSettingsResetConfirm.
  ///
  /// In th, this message translates to:
  /// **'คืนค่าภาษา ธีม และการช่วยเหลือการเข้าถึงกลับเป็นค่าเริ่มต้น?'**
  String get generalSettingsResetConfirm;

  /// No description provided for @generalSettingsResetTitle.
  ///
  /// In th, this message translates to:
  /// **'คืนค่าการตั้งค่าทั่วไป'**
  String get generalSettingsResetTitle;

  /// No description provided for @generalSettingsInfoDescription.
  ///
  /// In th, this message translates to:
  /// **'ภาษามีผลต่อป้ายและข้อความใบเสร็จทั้งหมด ธีมควบคุมโหมดสว่าง/มืด การช่วยเหลือการเข้าถึงเพิ่มความคมชัดและขนาดตัวอักษรให้เห็นชัดเจนขึ้น'**
  String get generalSettingsInfoDescription;

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

  /// No description provided for @settingsReceiptNoteHint.
  ///
  /// In th, this message translates to:
  /// **'ขอบคุณที่อุดหนุน'**
  String get settingsReceiptNoteHint;

  /// No description provided for @settingsShowShopInfo.
  ///
  /// In th, this message translates to:
  /// **'แสดงข้อมูลร้านในใบเสร็จ'**
  String get settingsShowShopInfo;

  /// No description provided for @settingsSectionContent.
  ///
  /// In th, this message translates to:
  /// **'เนื้อหา'**
  String get settingsSectionContent;

  /// No description provided for @settingsSectionPreview.
  ///
  /// In th, this message translates to:
  /// **'ตัวอย่าง'**
  String get settingsSectionPreview;

  /// No description provided for @settingsSectionTax.
  ///
  /// In th, this message translates to:
  /// **'ภาษี'**
  String get settingsSectionTax;

  /// No description provided for @settingsSaved.
  ///
  /// In th, this message translates to:
  /// **'บันทึกการตั้งค่าแล้ว'**
  String get settingsSaved;

  /// No description provided for @shopNameRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณากรอกชื่อร้าน'**
  String get shopNameRequired;

  /// No description provided for @shopNameTooLong.
  ///
  /// In th, this message translates to:
  /// **'ชื่อร้านยาวเกินไป'**
  String get shopNameTooLong;

  /// No description provided for @addressTooLong.
  ///
  /// In th, this message translates to:
  /// **'ที่อยู่ยาวเกินไป'**
  String get addressTooLong;

  /// No description provided for @phoneInvalid.
  ///
  /// In th, this message translates to:
  /// **'เบอร์โทรศัพท์ไม่ถูกต้อง'**
  String get phoneInvalid;

  /// No description provided for @shopInfoEmptyPreview.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลร้านจะปรากฏที่นี่'**
  String get shopInfoEmptyPreview;

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

  /// No description provided for @voidReason.
  ///
  /// In th, this message translates to:
  /// **'เหตุผลที่ยกเลิก'**
  String get voidReason;

  /// No description provided for @voidReasonHint.
  ///
  /// In th, this message translates to:
  /// **'ระบุเหตุผลที่ยกเลิก'**
  String get voidReasonHint;

  /// No description provided for @voidReasonRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณาระบุเหตุผลที่ยกเลิก'**
  String get voidReasonRequired;

  /// No description provided for @voidedAtLabel.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิกเมื่อ {datetime}'**
  String voidedAtLabel(String datetime);

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

  /// No description provided for @invLogReasonProductStockEdited.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขสต็อกสินค้า'**
  String get invLogReasonProductStockEdited;

  /// No description provided for @invLogSaleRef.
  ///
  /// In th, this message translates to:
  /// **'บิล · {ref}'**
  String invLogSaleRef(String ref);

  /// No description provided for @productHistoryShowingLatest.
  ///
  /// In th, this message translates to:
  /// **'แสดง {count} รายการล่าสุด'**
  String productHistoryShowingLatest(int count);

  /// No description provided for @productHistoryViewAll.
  ///
  /// In th, this message translates to:
  /// **'ดูประวัติทั้งหมด'**
  String get productHistoryViewAll;

  /// No description provided for @productFormSectionBasicInfo.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลพื้นฐาน'**
  String get productFormSectionBasicInfo;

  /// No description provided for @tabInfo.
  ///
  /// In th, this message translates to:
  /// **'สินค้า'**
  String get tabInfo;

  /// No description provided for @tabPrice.
  ///
  /// In th, this message translates to:
  /// **'ราคา'**
  String get tabPrice;

  /// No description provided for @tabStock.
  ///
  /// In th, this message translates to:
  /// **'สต็อก'**
  String get tabStock;

  /// No description provided for @tabCodes.
  ///
  /// In th, this message translates to:
  /// **'รหัส'**
  String get tabCodes;

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
  /// **'ติดตามสต็อก'**
  String get trackStock;

  /// No description provided for @trackStockHint.
  ///
  /// In th, this message translates to:
  /// **'ปิดเพื่อสินค้าประเภทบริการ (ไม่ตัดสต็อค)'**
  String get trackStockHint;

  /// No description provided for @trackStockDisableConfirm.
  ///
  /// In th, this message translates to:
  /// **'การปิดการติดตามสต็อกจะแช่แข็งค่าสต็อกปัจจุบัน คุณสามารถเปิดใหม่ได้ในภายหลังเพื่อติดตามต่อ'**
  String get trackStockDisableConfirm;

  /// No description provided for @stockTrackingDisabled.
  ///
  /// In th, this message translates to:
  /// **'การติดตามสต็อกปิดอยู่ เปิดเพื่อจัดการจำนวนสต็อก'**
  String get stockTrackingDisabled;

  /// No description provided for @stockNotTracked.
  ///
  /// In th, this message translates to:
  /// **'ไม่ติดตามสต็อก'**
  String get stockNotTracked;

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

  /// No description provided for @inStock.
  ///
  /// In th, this message translates to:
  /// **'มีสินค้า'**
  String get inStock;

  /// No description provided for @codesCardTitle.
  ///
  /// In th, this message translates to:
  /// **'SKU & บาร์โค้ด'**
  String get codesCardTitle;

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

  /// No description provided for @maxAmountNoLimit.
  ///
  /// In th, this message translates to:
  /// **'ไม่จำกัด'**
  String get maxAmountNoLimit;

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

  /// No description provided for @editDiscountPreset.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขชุดส่วนลด'**
  String get editDiscountPreset;

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
  /// **'บิลเปิด'**
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

  /// No description provided for @removeItem.
  ///
  /// In th, this message translates to:
  /// **'ลบรายการ'**
  String get removeItem;

  /// No description provided for @itemsLabel.
  ///
  /// In th, this message translates to:
  /// **'รายการ'**
  String get itemsLabel;

  /// No description provided for @searchCartItems.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาสินค้าในตะกร้า...'**
  String get searchCartItems;

  /// No description provided for @searchDrafts.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาบิล...'**
  String get searchDrafts;

  /// No description provided for @untitledDraft.
  ///
  /// In th, this message translates to:
  /// **'บิล'**
  String get untitledDraft;

  /// No description provided for @noMatchingItems.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบสินค้าที่ตรงกัน'**
  String get noMatchingItems;

  /// No description provided for @noMatchingDrafts.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบบิลที่ตรงกัน'**
  String get noMatchingDrafts;

  /// No description provided for @noSavedBills.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีบิลที่บันทึก'**
  String get noSavedBills;

  /// No description provided for @noSavedBillsHint.
  ///
  /// In th, this message translates to:
  /// **'พักบิลจากหน้าขายเพื่อเก็บไว้ที่นี่'**
  String get noSavedBillsHint;

  /// No description provided for @groupView.
  ///
  /// In th, this message translates to:
  /// **'มุมมองแบบกลุ่ม'**
  String get groupView;

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

  /// No description provided for @cartSizeMini.
  ///
  /// In th, this message translates to:
  /// **'เล็ก'**
  String get cartSizeMini;

  /// No description provided for @cartSizeHalf.
  ///
  /// In th, this message translates to:
  /// **'ปกติ'**
  String get cartSizeHalf;

  /// No description provided for @cartSizeFull.
  ///
  /// In th, this message translates to:
  /// **'เต็ม'**
  String get cartSizeFull;

  /// No description provided for @cartCompactNormal.
  ///
  /// In th, this message translates to:
  /// **'ขนาดปกติ'**
  String get cartCompactNormal;

  /// No description provided for @cartCompactCompact.
  ///
  /// In th, this message translates to:
  /// **'กะทัดรัด'**
  String get cartCompactCompact;

  /// No description provided for @cartCompactUltra.
  ///
  /// In th, this message translates to:
  /// **'กะทัดรัดมาก'**
  String get cartCompactUltra;

  /// No description provided for @atStockLimit.
  ///
  /// In th, this message translates to:
  /// **'สินค้าหมดสต็อก'**
  String get atStockLimit;

  /// No description provided for @justNow.
  ///
  /// In th, this message translates to:
  /// **'เมื่อสักครู่'**
  String get justNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In th, this message translates to:
  /// **'{m} นาทีที่แล้ว'**
  String timeAgoMinutes(int m);

  /// No description provided for @timeAgoHours.
  ///
  /// In th, this message translates to:
  /// **'{h} ชั่วโมงที่แล้ว'**
  String timeAgoHours(int h);

  /// No description provided for @timeAgoDays.
  ///
  /// In th, this message translates to:
  /// **'{d} วันที่แล้ว'**
  String timeAgoDays(int d);

  /// No description provided for @searchResultsCount.
  ///
  /// In th, this message translates to:
  /// **'{n} รายการ'**
  String searchResultsCount(int n);

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

  /// No description provided for @promptpayAccount.
  ///
  /// In th, this message translates to:
  /// **'บัญชี'**
  String get promptpayAccount;

  /// No description provided for @promptpayScanToPay.
  ///
  /// In th, this message translates to:
  /// **'สแกนจ่ายเงิน'**
  String get promptpayScanToPay;

  /// No description provided for @promptpayQrPreview.
  ///
  /// In th, this message translates to:
  /// **'ตัวอย่าง QR รับเงิน'**
  String get promptpayQrPreview;

  /// No description provided for @promptpayInfoDescription.
  ///
  /// In th, this message translates to:
  /// **'ป้อน PromptPay ID (เบอร์โทรหรือเลขบัตรประชาชน) เพื่อรับเงินผ่าน QR Code'**
  String get promptpayInfoDescription;

  /// No description provided for @promptpayInvalidId.
  ///
  /// In th, this message translates to:
  /// **'กรุณากรอกเบอร์โทรหรือเลขบัตรประชาชนที่ถูกต้อง'**
  String get promptpayInvalidId;

  /// No description provided for @promptpayWaitingForPayment.
  ///
  /// In th, this message translates to:
  /// **'รอลูกค้าชำระเงิน...'**
  String get promptpayWaitingForPayment;

  /// No description provided for @promptpayPaymentTimeout.
  ///
  /// In th, this message translates to:
  /// **'หมดเวลาชำระเงิน ยกเลิกการขาย'**
  String get promptpayPaymentTimeout;

  /// No description provided for @promptpayExtendTime.
  ///
  /// In th, this message translates to:
  /// **'ขยายเวลา +1 นาที'**
  String get promptpayExtendTime;

  /// No description provided for @promptpayCancelPayment.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิกการชำระ'**
  String get promptpayCancelPayment;

  /// No description provided for @promptpayTransactionReference.
  ///
  /// In th, this message translates to:
  /// **'เลขอ้างอิง (ถ้ามี)'**
  String get promptpayTransactionReference;

  /// No description provided for @promptpayQrSaved.
  ///
  /// In th, this message translates to:
  /// **'บันทึก QR ลงแกลเลอรีแล้ว'**
  String get promptpayQrSaved;

  /// No description provided for @promptpayQrShared.
  ///
  /// In th, this message translates to:
  /// **'แชร์ QR แล้ว'**
  String get promptpayQrShared;

  /// No description provided for @promptpaySaveQr.
  ///
  /// In th, this message translates to:
  /// **'บันทึก QR'**
  String get promptpaySaveQr;

  /// No description provided for @promptpayShareQr.
  ///
  /// In th, this message translates to:
  /// **'แชร์ QR'**
  String get promptpayShareQr;

  /// No description provided for @promptpaySoundEnabled.
  ///
  /// In th, this message translates to:
  /// **'เสียงตอนยืนยัน'**
  String get promptpaySoundEnabled;

  /// No description provided for @promptpayTimeoutSetting.
  ///
  /// In th, this message translates to:
  /// **'เวลานับถอยหลัง (นาที)'**
  String get promptpayTimeoutSetting;

  /// No description provided for @minutes.
  ///
  /// In th, this message translates to:
  /// **'นาที'**
  String get minutes;

  /// No description provided for @slipScanTitle.
  ///
  /// In th, this message translates to:
  /// **'สแกนสลิปธนาคาร'**
  String get slipScanTitle;

  /// No description provided for @slipScanHint.
  ///
  /// In th, this message translates to:
  /// **'จัด QR code บนสลิปให้อยู่ในกรอบ'**
  String get slipScanHint;

  /// No description provided for @slipScanSuccess.
  ///
  /// In th, this message translates to:
  /// **'ตรวจสอบสลิปสำเร็จ'**
  String get slipScanSuccess;

  /// No description provided for @slipScanInvalid.
  ///
  /// In th, this message translates to:
  /// **'สลิปไม่ถูกต้อง'**
  String get slipScanInvalid;

  /// No description provided for @slipErrorEmpty.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบข้อมูลใน QR code'**
  String get slipErrorEmpty;

  /// No description provided for @slipErrorNotASlip.
  ///
  /// In th, this message translates to:
  /// **'นี่คือ QR ชำระเงิน ไม่ใช่สลิปธนาคาร กรุณาสแกน QR บนสลิปโอนเงิน'**
  String get slipErrorNotASlip;

  /// No description provided for @slipErrorUnreadable.
  ///
  /// In th, this message translates to:
  /// **'อ่านสลิปไม่ได้ กรุณาลองใหม่'**
  String get slipErrorUnreadable;

  /// No description provided for @promptpayInvalidQr.
  ///
  /// In th, this message translates to:
  /// **'QR code ไม่ถูกต้อง'**
  String get promptpayInvalidQr;

  /// No description provided for @settingsBillerId.
  ///
  /// In th, this message translates to:
  /// **'รหัสผู้เรียกเก็บเงิน'**
  String get settingsBillerId;

  /// No description provided for @settingsBillerIdHint.
  ///
  /// In th, this message translates to:
  /// **'เลขประจำตัวผู้เสียภาษีสำหรับ QR ใบแจ้งหนี้'**
  String get settingsBillerIdHint;

  /// No description provided for @settingsDefaultQrType.
  ///
  /// In th, this message translates to:
  /// **'QR เริ่มต้น'**
  String get settingsDefaultQrType;

  /// No description provided for @settingsDefaultQrTypeTransfer.
  ///
  /// In th, this message translates to:
  /// **'โอนเงิน'**
  String get settingsDefaultQrTypeTransfer;

  /// No description provided for @settingsDefaultQrTypeBill.
  ///
  /// In th, this message translates to:
  /// **'จ่ายบิล'**
  String get settingsDefaultQrTypeBill;

  /// No description provided for @settingsAutoConfirmAfterSlip.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันอัตโนมัติหลังสแกนสลิป'**
  String get settingsAutoConfirmAfterSlip;

  /// No description provided for @settingsAutoConfirmAfterSlipHint.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันการชำระเงินอัตโนมัติ 2 วินาทีหลังตรวจสอบสลิปสำเร็จ'**
  String get settingsAutoConfirmAfterSlipHint;

  /// No description provided for @settingsQrOverlayIcon.
  ///
  /// In th, this message translates to:
  /// **'ไอคอน QR'**
  String get settingsQrOverlayIcon;

  /// No description provided for @cart.
  ///
  /// In th, this message translates to:
  /// **'ตะกร้า'**
  String get cart;

  /// No description provided for @moreItems.
  ///
  /// In th, this message translates to:
  /// **'รายการอื่น'**
  String get moreItems;

  /// No description provided for @total.
  ///
  /// In th, this message translates to:
  /// **'รวม'**
  String get total;

  /// No description provided for @waitingForPayment.
  ///
  /// In th, this message translates to:
  /// **'รอการชำระเงิน...'**
  String get waitingForPayment;

  /// No description provided for @copyPromptpayId.
  ///
  /// In th, this message translates to:
  /// **'คัดลอกแล้ว'**
  String get copyPromptpayId;

  /// No description provided for @paymentVerified.
  ///
  /// In th, this message translates to:
  /// **'ชำระเงินยืนยันแล้ว'**
  String get paymentVerified;

  /// No description provided for @showMore.
  ///
  /// In th, this message translates to:
  /// **'แสดงเพิ่ม'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In th, this message translates to:
  /// **'แสดงน้อยลง'**
  String get showLess;

  /// No description provided for @itemsCount.
  ///
  /// In th, this message translates to:
  /// **'{count} รายการ'**
  String itemsCount(Object count);

  /// No description provided for @totalDiscountLabel.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลดทั้งหมด'**
  String get totalDiscountLabel;

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

  /// No description provided for @settingsMaxDrafts.
  ///
  /// In th, this message translates to:
  /// **'บิลสูงสุด'**
  String get settingsMaxDrafts;

  /// No description provided for @settingsCompactCartMode.
  ///
  /// In th, this message translates to:
  /// **'ตะกร้าแบบ Delivery'**
  String get settingsCompactCartMode;

  /// No description provided for @settingsUltraCompactMode.
  ///
  /// In th, this message translates to:
  /// **'โหมดกะทัดรัดมาก'**
  String get settingsUltraCompactMode;

  /// No description provided for @settingsUltraCompactModeHint.
  ///
  /// In th, this message translates to:
  /// **'รายการเล็กลงเพื่อความหนาแน่นสูงสุด'**
  String get settingsUltraCompactModeHint;

  /// No description provided for @settingsCompactModeSubtitle.
  ///
  /// In th, this message translates to:
  /// **'แถบล่างแบบแอปส่งอาหาร; ปิด = พาเนลตะกร้าแบบเดิม'**
  String get settingsCompactModeSubtitle;

  /// No description provided for @settingsUltraModeOverrides.
  ///
  /// In th, this message translates to:
  /// **'แทนที่โหมดกะทัดรัด'**
  String get settingsUltraModeOverrides;

  /// No description provided for @settingsUltraModeSubtitle.
  ///
  /// In th, this message translates to:
  /// **'ระยะห่างน้อยที่สุด แสดงได้มากที่สุด'**
  String get settingsUltraModeSubtitle;

  /// No description provided for @settingsOversellAllowed.
  ///
  /// In th, this message translates to:
  /// **'อนุญาตขายเกิน'**
  String get settingsOversellAllowed;

  /// No description provided for @settingsImages.
  ///
  /// In th, this message translates to:
  /// **'รูปภาพ'**
  String get settingsImages;

  /// No description provided for @settingsImageMaxWidth.
  ///
  /// In th, this message translates to:
  /// **'ความกว้างสูงสุด (px)'**
  String get settingsImageMaxWidth;

  /// No description provided for @settingsImageQuality.
  ///
  /// In th, this message translates to:
  /// **'คุณภาพ (%)'**
  String get settingsImageQuality;

  /// No description provided for @imageWidthSmall.
  ///
  /// In th, this message translates to:
  /// **'เล็ก'**
  String get imageWidthSmall;

  /// No description provided for @imageWidthMedium.
  ///
  /// In th, this message translates to:
  /// **'กลาง'**
  String get imageWidthMedium;

  /// No description provided for @imageWidthLarge.
  ///
  /// In th, this message translates to:
  /// **'ใหญ่'**
  String get imageWidthLarge;

  /// No description provided for @imageWidthExtraLarge.
  ///
  /// In th, this message translates to:
  /// **'ใหญ่พิเศษ'**
  String get imageWidthExtraLarge;

  /// No description provided for @imageWidthFullHD.
  ///
  /// In th, this message translates to:
  /// **'เต็มจอ'**
  String get imageWidthFullHD;

  /// No description provided for @imageQualityDraft.
  ///
  /// In th, this message translates to:
  /// **'ร่าง'**
  String get imageQualityDraft;

  /// No description provided for @imageQualityStandard.
  ///
  /// In th, this message translates to:
  /// **'มาตรฐาน'**
  String get imageQualityStandard;

  /// No description provided for @imageQualityHigh.
  ///
  /// In th, this message translates to:
  /// **'สูง'**
  String get imageQualityHigh;

  /// No description provided for @imageQualityBest.
  ///
  /// In th, this message translates to:
  /// **'ดีที่สุด'**
  String get imageQualityBest;

  /// No description provided for @imageQualityOriginal.
  ///
  /// In th, this message translates to:
  /// **'ต้นฉบับ'**
  String get imageQualityOriginal;

  /// No description provided for @imageExample.
  ///
  /// In th, this message translates to:
  /// **'ตัวอย่าง'**
  String get imageExample;

  /// No description provided for @settingsBackup.
  ///
  /// In th, this message translates to:
  /// **'สำรองข้อมูล'**
  String get settingsBackup;

  /// No description provided for @settingsSetupReadiness.
  ///
  /// In th, this message translates to:
  /// **'ความพร้อมร้าน'**
  String get settingsSetupReadiness;

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

  /// No description provided for @backupWeekly.
  ///
  /// In th, this message translates to:
  /// **'รายสัปดาห์'**
  String get backupWeekly;

  /// No description provided for @backupBiweekly.
  ///
  /// In th, this message translates to:
  /// **'2 สัปดาห์'**
  String get backupBiweekly;

  /// No description provided for @backupMonthly.
  ///
  /// In th, this message translates to:
  /// **'รายเดือน'**
  String get backupMonthly;

  /// No description provided for @backupBimonthly.
  ///
  /// In th, this message translates to:
  /// **'2 เดือน'**
  String get backupBimonthly;

  /// No description provided for @backupQuarterly.
  ///
  /// In th, this message translates to:
  /// **'3 เดือน'**
  String get backupQuarterly;

  /// No description provided for @backupLastBackup.
  ///
  /// In th, this message translates to:
  /// **'สำรองล่าสุด'**
  String get backupLastBackup;

  /// No description provided for @backupToday.
  ///
  /// In th, this message translates to:
  /// **'วันนี้'**
  String get backupToday;

  /// No description provided for @backupYesterday.
  ///
  /// In th, this message translates to:
  /// **'เมื่อวาน'**
  String get backupYesterday;

  /// No description provided for @backupDaysAgo.
  ///
  /// In th, this message translates to:
  /// **'{days} วันที่แล้ว'**
  String backupDaysAgo(int days);

  /// No description provided for @backupStatusSafe.
  ///
  /// In th, this message translates to:
  /// **'ปลอดภัย'**
  String get backupStatusSafe;

  /// No description provided for @backupStatusWarning.
  ///
  /// In th, this message translates to:
  /// **'ใกล้ครบกำหนด'**
  String get backupStatusWarning;

  /// No description provided for @backupStatusOverdue.
  ///
  /// In th, this message translates to:
  /// **'ล่าช้า'**
  String get backupStatusOverdue;

  /// No description provided for @backupNow.
  ///
  /// In th, this message translates to:
  /// **'สำรองเลย'**
  String get backupNow;

  /// No description provided for @backupSuccess.
  ///
  /// In th, this message translates to:
  /// **'สำรองข้อมูลสำเร็จ'**
  String get backupSuccess;

  /// No description provided for @backupReminderLabel.
  ///
  /// In th, this message translates to:
  /// **'เตือนสำรองข้อมูล'**
  String get backupReminderLabel;

  /// No description provided for @backupFrequency.
  ///
  /// In th, this message translates to:
  /// **'ความถี่'**
  String get backupFrequency;

  /// No description provided for @backupEveryNDays.
  ///
  /// In th, this message translates to:
  /// **'ทุก {n} วัน'**
  String backupEveryNDays(int n);

  /// No description provided for @backupOff.
  ///
  /// In th, this message translates to:
  /// **'ปิด'**
  String get backupOff;

  /// No description provided for @backupActionTitle.
  ///
  /// In th, this message translates to:
  /// **'สำรองข้อมูลด้วยตนเอง'**
  String get backupActionTitle;

  /// No description provided for @backupActionSubtitle.
  ///
  /// In th, this message translates to:
  /// **'แตะเพื่อบันทึกว่าคุณได้สำรองข้อมูลแล้ว'**
  String get backupActionSubtitle;

  /// No description provided for @backupEncryptionTitle.
  ///
  /// In th, this message translates to:
  /// **'การเข้ารหัสสำรองข้อมูล (ไม่บังคับ)'**
  String get backupEncryptionTitle;

  /// No description provided for @backupEncryptionLabel.
  ///
  /// In th, this message translates to:
  /// **'เข้ารหัสไฟล์สำรอง'**
  String get backupEncryptionLabel;

  /// No description provided for @backupEncryptionDesc.
  ///
  /// In th, this message translates to:
  /// **'ปกป้องไฟล์สำรองด้วยการเข้ารหัส AES-256-GCM (ต้องใส่ PIN)'**
  String get backupEncryptionDesc;

  /// No description provided for @backupInfoDescription.
  ///
  /// In th, this message translates to:
  /// **'ส่งออกสำรองข้อมูลเป็นประจำ (แนะนำเข้ารหัส PIN อย่างน้อย 6 ตัว) กู้คืนบนเครื่องเดิมได้เมื่อยังมีคีย์เข้ารหัส ห้ามใช้ข้ามเครื่องหลังถอนแอป'**
  String get backupInfoDescription;

  /// No description provided for @exportSuccess.
  ///
  /// In th, this message translates to:
  /// **'ส่งออกสำเร็จ'**
  String get exportSuccess;

  /// No description provided for @bulkSelected.
  ///
  /// In th, this message translates to:
  /// **'เลือกแล้ว {count} รายการ'**
  String bulkSelected(int count);

  /// No description provided for @bulkClearDiscount.
  ///
  /// In th, this message translates to:
  /// **'ล้างส่วนลด'**
  String get bulkClearDiscount;

  /// No description provided for @bulkDelete.
  ///
  /// In th, this message translates to:
  /// **'ลบรายการ'**
  String get bulkDelete;

  /// No description provided for @reorderItem.
  ///
  /// In th, this message translates to:
  /// **'ลากเพื่อจัดเรียง'**
  String get reorderItem;

  /// No description provided for @dailyCloseTitle.
  ///
  /// In th, this message translates to:
  /// **'ปิดยอดประจำวัน'**
  String get dailyCloseTitle;

  /// No description provided for @dailyCloseHistoryTitle.
  ///
  /// In th, this message translates to:
  /// **'ประวัติปิดยอด'**
  String get dailyCloseHistoryTitle;

  /// No description provided for @closeToday.
  ///
  /// In th, this message translates to:
  /// **'ปิดยอดวันนี้'**
  String get closeToday;

  /// No description provided for @closeDay.
  ///
  /// In th, this message translates to:
  /// **'ปิดยอด'**
  String get closeDay;

  /// No description provided for @reopenDay.
  ///
  /// In th, this message translates to:
  /// **'เปิดยอดใหม่'**
  String get reopenDay;

  /// No description provided for @closeDayConfirmTitle.
  ///
  /// In th, this message translates to:
  /// **'ปิดยอด?'**
  String get closeDayConfirmTitle;

  /// No description provided for @closeDayConfirmMessage.
  ///
  /// In th, this message translates to:
  /// **'การดำเนินการนี้จะล็อกวันและบันทึกการตรวจสอบยอด'**
  String get closeDayConfirmMessage;

  /// No description provided for @reopenDayConfirmTitle.
  ///
  /// In th, this message translates to:
  /// **'เปิดยอดใหม่?'**
  String get reopenDayConfirmTitle;

  /// No description provided for @reopenDayConfirmMessage.
  ///
  /// In th, this message translates to:
  /// **'การดำเนินการนี้จะปลดล็อกวัน การขายจะถูกนับเข้ายอดใหม่'**
  String get reopenDayConfirmMessage;

  /// No description provided for @confirm.
  ///
  /// In th, this message translates to:
  /// **'ยืนยัน'**
  String get confirm;

  /// No description provided for @dbHealthTitle.
  ///
  /// In th, this message translates to:
  /// **'สุขภาพฐานข้อมูล'**
  String get dbHealthTitle;

  /// No description provided for @dbHealthFileSize.
  ///
  /// In th, this message translates to:
  /// **'ขนาดไฟล์ฐานข้อมูล'**
  String get dbHealthFileSize;

  /// No description provided for @dbHealthLarge.
  ///
  /// In th, this message translates to:
  /// **'ใหญ่'**
  String get dbHealthLarge;

  /// No description provided for @dbHealthOk.
  ///
  /// In th, this message translates to:
  /// **'ปกติ'**
  String get dbHealthOk;

  /// No description provided for @dbHealthLargeTitle.
  ///
  /// In th, this message translates to:
  /// **'ฐานข้อมูลมีขนาดใหญ่'**
  String get dbHealthLargeTitle;

  /// No description provided for @dbHealthLargeMessage.
  ///
  /// In th, this message translates to:
  /// **'ฐานข้อมูลของคุณมีขนาดเกิน 50 MB พิจารณาสำรองข้อมูลและเก็บข้อมูลเก่า'**
  String get dbHealthLargeMessage;

  /// No description provided for @dbHealthRowCounts.
  ///
  /// In th, this message translates to:
  /// **'จำนวนแถว'**
  String get dbHealthRowCounts;

  /// No description provided for @dbHealthVacuum.
  ///
  /// In th, this message translates to:
  /// **'บีบอัดฐานข้อมูล'**
  String get dbHealthVacuum;

  /// No description provided for @dbHealthVacuumDescription.
  ///
  /// In th, this message translates to:
  /// **'บีบอัดจะสร้างไฟล์ฐานข้อมูลใหม่เพื่อคืนพื้นที่ว่างและลดการแตกกระจาย'**
  String get dbHealthVacuumDescription;

  /// No description provided for @onboardingWelcome.
  ///
  /// In th, this message translates to:
  /// **'ยินดีต้อนรับ'**
  String get onboardingWelcome;

  /// No description provided for @onboardingShopInfoTitle.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลร้าน'**
  String get onboardingShopInfoTitle;

  /// No description provided for @onboardingShopNameLabel.
  ///
  /// In th, this message translates to:
  /// **'ชื่อร้าน'**
  String get onboardingShopNameLabel;

  /// No description provided for @onboardingShopNameHint.
  ///
  /// In th, this message translates to:
  /// **'ร้านค้าของฉัน'**
  String get onboardingShopNameHint;

  /// No description provided for @onboardingAddressLabel.
  ///
  /// In th, this message translates to:
  /// **'ที่อยู่'**
  String get onboardingAddressLabel;

  /// No description provided for @onboardingAddressHint.
  ///
  /// In th, this message translates to:
  /// **'123 ถนนหลัก'**
  String get onboardingAddressHint;

  /// No description provided for @onboardingPhoneLabel.
  ///
  /// In th, this message translates to:
  /// **'เบอร์โทรศัพท์'**
  String get onboardingPhoneLabel;

  /// No description provided for @onboardingPhoneHint.
  ///
  /// In th, this message translates to:
  /// **'0812345678'**
  String get onboardingPhoneHint;

  /// No description provided for @onboardingPromptPayTitle.
  ///
  /// In th, this message translates to:
  /// **'พร้อมเพย์'**
  String get onboardingPromptPayTitle;

  /// No description provided for @onboardingPromptPaySubtitle.
  ///
  /// In th, this message translates to:
  /// **'ป้อนรหัสพร้อมเพย์เพื่อรับชำระผ่าน QR'**
  String get onboardingPromptPaySubtitle;

  /// No description provided for @onboardingPromptPayIdLabel.
  ///
  /// In th, this message translates to:
  /// **'รหัสพร้อมเพย์'**
  String get onboardingPromptPayIdLabel;

  /// No description provided for @onboardingPromptPayIdHint.
  ///
  /// In th, this message translates to:
  /// **'เบอร์โทร (10 หลัก) หรือบัตรประชาชน (13 หลัก)'**
  String get onboardingPromptPayIdHint;

  /// No description provided for @onboardingVatRateLabel.
  ///
  /// In th, this message translates to:
  /// **'อัตรา VAT %'**
  String get onboardingVatRateLabel;

  /// No description provided for @onboardingSkip.
  ///
  /// In th, this message translates to:
  /// **'ข้ามไปก่อน'**
  String get onboardingSkip;

  /// No description provided for @onboardingSkipSetup.
  ///
  /// In th, this message translates to:
  /// **'ข้ามการตั้งค่า'**
  String get onboardingSkipSetup;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In th, this message translates to:
  /// **'ยินดีต้อนรับสู่ Promsell POS'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In th, this message translates to:
  /// **'ระบบ POS มือถือออฟไลน์\nมาตั้งค่าร้านค้าของคุณในไม่กี่ขั้นตอน'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingLocaleCurrencyTitle.
  ///
  /// In th, this message translates to:
  /// **'ภาษาและสกุลเงิน'**
  String get onboardingLocaleCurrencyTitle;

  /// No description provided for @onboardingAllSet.
  ///
  /// In th, this message translates to:
  /// **'พร้อมแล้ว!'**
  String get onboardingAllSet;

  /// No description provided for @onboardingReadyToSell.
  ///
  /// In th, this message translates to:
  /// **'ร้านค้าของคุณถูกตั้งค่าและพร้อมขายแล้ว'**
  String get onboardingReadyToSell;

  /// No description provided for @onboardingShopInfo.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลร้าน'**
  String get onboardingShopInfo;

  /// No description provided for @onboardingLocaleCurrency.
  ///
  /// In th, this message translates to:
  /// **'ภาษาและสกุลเงิน'**
  String get onboardingLocaleCurrency;

  /// No description provided for @onboardingTaxSetup.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่าภาษี'**
  String get onboardingTaxSetup;

  /// No description provided for @onboardingPromptPay.
  ///
  /// In th, this message translates to:
  /// **'พร้อมเพย์'**
  String get onboardingPromptPay;

  /// No description provided for @onboardingDone.
  ///
  /// In th, this message translates to:
  /// **'เสร็จสิ้น'**
  String get onboardingDone;

  /// No description provided for @onboardingBack.
  ///
  /// In th, this message translates to:
  /// **'ย้อนกลับ'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In th, this message translates to:
  /// **'ถัดไป'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In th, this message translates to:
  /// **'เริ่มต้นใช้งาน'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingStartSelling.
  ///
  /// In th, this message translates to:
  /// **'เริ่มขาย'**
  String get onboardingStartSelling;

  /// No description provided for @onboardingLanguage.
  ///
  /// In th, this message translates to:
  /// **'ภาษา'**
  String get onboardingLanguage;

  /// No description provided for @onboardingThai.
  ///
  /// In th, this message translates to:
  /// **'ไทย'**
  String get onboardingThai;

  /// No description provided for @onboardingEnglish.
  ///
  /// In th, this message translates to:
  /// **'อังกฤษ'**
  String get onboardingEnglish;

  /// No description provided for @onboardingCurrency.
  ///
  /// In th, this message translates to:
  /// **'สกุลเงิน'**
  String get onboardingCurrency;

  /// No description provided for @onboardingDateFormat.
  ///
  /// In th, this message translates to:
  /// **'รูปแบบวันที่'**
  String get onboardingDateFormat;

  /// No description provided for @onboardingVatMode.
  ///
  /// In th, this message translates to:
  /// **'โหมด VAT (ไม่บังคับ)'**
  String get onboardingVatMode;

  /// No description provided for @onboardingNone.
  ///
  /// In th, this message translates to:
  /// **'ไม่มี'**
  String get onboardingNone;

  /// No description provided for @onboardingInclusive.
  ///
  /// In th, this message translates to:
  /// **'รวมในราคา'**
  String get onboardingInclusive;

  /// No description provided for @onboardingExclusive.
  ///
  /// In th, this message translates to:
  /// **'แยกจากราคา'**
  String get onboardingExclusive;

  /// No description provided for @dailyCloseLoadError.
  ///
  /// In th, this message translates to:
  /// **'ข้อผิดพลาด: {message}'**
  String dailyCloseLoadError(String message);

  /// No description provided for @dailyCloseSales.
  ///
  /// In th, this message translates to:
  /// **'ยอดขาย: {count}'**
  String dailyCloseSales(int count);

  /// No description provided for @dailyCloseVoids.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิก: {count}'**
  String dailyCloseVoids(int count);

  /// No description provided for @settingsDailyCloseTitle.
  ///
  /// In th, this message translates to:
  /// **'ปิดยอดประจำวัน'**
  String get settingsDailyCloseTitle;

  /// No description provided for @settingsDailyCloseSubtitle.
  ///
  /// In th, this message translates to:
  /// **'การตรวจสอบยอดประจำวัน'**
  String get settingsDailyCloseSubtitle;

  /// No description provided for @settingsDbHealthTitle.
  ///
  /// In th, this message translates to:
  /// **'สุขภาพฐานข้อมูล'**
  String get settingsDbHealthTitle;

  /// No description provided for @settingsDbHealthSubtitle.
  ///
  /// In th, this message translates to:
  /// **'ขนาด จำนวนแถว บีบอัด'**
  String get settingsDbHealthSubtitle;

  /// No description provided for @settingsDailyCloseLockTitle.
  ///
  /// In th, this message translates to:
  /// **'บล็อกการขายหลังปิดยอด'**
  String get settingsDailyCloseLockTitle;

  /// No description provided for @settingsDailyCloseLockSubtitle.
  ///
  /// In th, this message translates to:
  /// **'เมื่อเปิดใช้งาน การขายใหม่จะถูกบล็อกหากวันนี้ปิดยอดแล้ว'**
  String get settingsDailyCloseLockSubtitle;

  /// No description provided for @dbHealthVacuumSuccess.
  ///
  /// In th, this message translates to:
  /// **'บีบอัดฐานข้อมูลสำเร็จ'**
  String get dbHealthVacuumSuccess;

  /// No description provided for @dbHealthVacuumFailed.
  ///
  /// In th, this message translates to:
  /// **'บีบอัดล้มเหลว: {error}'**
  String dbHealthVacuumFailed(String error);

  /// No description provided for @dbHealthError.
  ///
  /// In th, this message translates to:
  /// **'ข้อผิดพลาด: {message}'**
  String dbHealthError(String message);

  /// No description provided for @dayClosedMessage.
  ///
  /// In th, this message translates to:
  /// **'วันนี้ปิดยอดแล้ว กรุณาเปิดยอดใหม่เพื่อขายต่อ'**
  String get dayClosedMessage;

  /// No description provided for @tapToSet.
  ///
  /// In th, this message translates to:
  /// **'แตะเพื่อตั้งค่า'**
  String get tapToSet;

  /// No description provided for @shopNameHint.
  ///
  /// In th, this message translates to:
  /// **'ชื่อร้านค้า'**
  String get shopNameHint;

  /// No description provided for @addressHint.
  ///
  /// In th, this message translates to:
  /// **'ที่อยู่ร้านค้า'**
  String get addressHint;

  /// No description provided for @phoneHint.
  ///
  /// In th, this message translates to:
  /// **'081-234-5678'**
  String get phoneHint;

  /// No description provided for @categoryManagementTitle.
  ///
  /// In th, this message translates to:
  /// **'จัดการหมวดหมู่'**
  String get categoryManagementTitle;

  /// No description provided for @noCategoriesYet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีหมวดหมู่'**
  String get noCategoriesYet;

  /// No description provided for @uncategorized.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีหมวดหมู่'**
  String get uncategorized;

  /// No description provided for @searchCategories.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาหมวดหมู่...'**
  String get searchCategories;

  /// No description provided for @addCategory.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มหมวดหมู่'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขหมวดหมู่'**
  String get editCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันการลบหมวดหมู่?'**
  String get deleteCategoryConfirm;

  /// No description provided for @deleteCategory.
  ///
  /// In th, this message translates to:
  /// **'ลบหมวดหมู่'**
  String get deleteCategory;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In th, this message translates to:
  /// **'คุณแน่ใจหรือว่าจะลบ \"{name}\"?'**
  String confirmDeleteCategory(String name);

  /// No description provided for @bulkDeleteConfirm.
  ///
  /// In th, this message translates to:
  /// **'ลบ {count} หมวดหมู่?'**
  String bulkDeleteConfirm(int count);

  /// No description provided for @categoryName.
  ///
  /// In th, this message translates to:
  /// **'ชื่อหมวดหมู่'**
  String get categoryName;

  /// No description provided for @categoryNameRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณาใส่ชื่อหมวดหมู่'**
  String get categoryNameRequired;

  /// No description provided for @categoryNameExists.
  ///
  /// In th, this message translates to:
  /// **'ชื่อหมวดหมู่นี้มีอยู่แล้ว'**
  String get categoryNameExists;

  /// No description provided for @categoryInUse.
  ///
  /// In th, this message translates to:
  /// **'ไม่สามารถลบหมวดหมู่ที่มีสินค้าได้'**
  String get categoryInUse;

  /// No description provided for @chooseCategory.
  ///
  /// In th, this message translates to:
  /// **'เลือกหมวดหมู่'**
  String get chooseCategory;

  /// No description provided for @manageCategories.
  ///
  /// In th, this message translates to:
  /// **'จัดการหมวดหมู่'**
  String get manageCategories;

  /// No description provided for @sortOrder.
  ///
  /// In th, this message translates to:
  /// **'ลำดับ'**
  String get sortOrder;

  /// No description provided for @sortOrderRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณาใส่ลำดับ'**
  String get sortOrderRequired;

  /// No description provided for @categoryColor.
  ///
  /// In th, this message translates to:
  /// **'สี'**
  String get categoryColor;

  /// No description provided for @categoryIcon.
  ///
  /// In th, this message translates to:
  /// **'ไอคอน'**
  String get categoryIcon;

  /// No description provided for @invalidNumber.
  ///
  /// In th, this message translates to:
  /// **'ตัวเลขไม่ถูกต้อง'**
  String get invalidNumber;

  /// No description provided for @addProductTitle.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มสินค้า'**
  String get addProductTitle;

  /// No description provided for @noCategorySelected.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่เลือกหมวดหมู่'**
  String get noCategorySelected;

  /// No description provided for @noProductsInCategory.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีสินค้าในหมวดหมู่นี้'**
  String get noProductsInCategory;

  /// No description provided for @clearFilters.
  ///
  /// In th, this message translates to:
  /// **'ล้างตัวกรอง'**
  String get clearFilters;

  /// No description provided for @startTypingToSearch.
  ///
  /// In th, this message translates to:
  /// **'เริ่มพิมพ์เพื่อค้นหา'**
  String get startTypingToSearch;

  /// No description provided for @searchByNameSkuBarcode.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาด้วยชื่อ, SKU, หรือบาร์โค้ด'**
  String get searchByNameSkuBarcode;

  /// No description provided for @tryDifferentKeyword.
  ///
  /// In th, this message translates to:
  /// **'ลองคำค้นหาอื่น'**
  String get tryDifferentKeyword;

  /// No description provided for @clearSearch.
  ///
  /// In th, this message translates to:
  /// **'ล้างการค้นหา'**
  String get clearSearch;

  /// No description provided for @inactive.
  ///
  /// In th, this message translates to:
  /// **'ไม่ใช้งาน'**
  String get inactive;

  /// No description provided for @tapToZoom.
  ///
  /// In th, this message translates to:
  /// **'แตะเพื่อขยาย'**
  String get tapToZoom;

  /// No description provided for @imageError.
  ///
  /// In th, this message translates to:
  /// **'ไม่สามารถโหลดรูปได้'**
  String get imageError;

  /// No description provided for @productImageSemantics.
  ///
  /// In th, this message translates to:
  /// **'รูปภาพสินค้า'**
  String get productImageSemantics;

  /// No description provided for @noProductImageSemantics.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีรูปภาพสินค้า'**
  String get noProductImageSemantics;

  /// No description provided for @na.
  ///
  /// In th, this message translates to:
  /// **'ไม่ระบุ'**
  String get na;

  /// No description provided for @skuLabel.
  ///
  /// In th, this message translates to:
  /// **'SKU'**
  String get skuLabel;

  /// No description provided for @barcodeLabel.
  ///
  /// In th, this message translates to:
  /// **'บาร์โค้ด'**
  String get barcodeLabel;

  /// No description provided for @costLabel.
  ///
  /// In th, this message translates to:
  /// **'ต้นทุน ({currency})'**
  String costLabel(String currency);

  /// No description provided for @costHelper.
  ///
  /// In th, this message translates to:
  /// **'ใช้คำนวณกำไรขั้นต้น (ไม่บังคับ)'**
  String get costHelper;

  /// No description provided for @outOfStockShort.
  ///
  /// In th, this message translates to:
  /// **'หมด'**
  String get outOfStockShort;

  /// No description provided for @productsCount.
  ///
  /// In th, this message translates to:
  /// **'สินค้า'**
  String get productsCount;

  /// No description provided for @lowStock.
  ///
  /// In th, this message translates to:
  /// **'เหลือน้อย'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In th, this message translates to:
  /// **'หมดสต็อก'**
  String get outOfStock;

  /// No description provided for @saveDraft.
  ///
  /// In th, this message translates to:
  /// **'บันทึกร่าง'**
  String get saveDraft;

  /// No description provided for @discardDraft.
  ///
  /// In th, this message translates to:
  /// **'ทิ้งร่าง'**
  String get discardDraft;

  /// No description provided for @restoreDraft.
  ///
  /// In th, this message translates to:
  /// **'กู้คืนร่าง?'**
  String get restoreDraft;

  /// No description provided for @draftSaved.
  ///
  /// In th, this message translates to:
  /// **'บันทึกร่างแล้ว'**
  String get draftSaved;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In th, this message translates to:
  /// **'มีการเปลี่ยนแปลงที่ยังไม่บันทึก'**
  String get unsavedChangesMessage;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ได้บันทึก'**
  String get unsavedChangesTitle;

  /// No description provided for @restore.
  ///
  /// In th, this message translates to:
  /// **'กู้คืน'**
  String get restore;

  /// No description provided for @scanBarcode.
  ///
  /// In th, this message translates to:
  /// **'สแกนบาร์โค้ด'**
  String get scanBarcode;

  /// No description provided for @barcodeScannerHint.
  ///
  /// In th, this message translates to:
  /// **'จัดบาร์โค้ดให้อยู่ในกรอบ'**
  String get barcodeScannerHint;

  /// No description provided for @barcodeNotFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบสินค้าที่มีบาร์โค้ดนี้'**
  String get barcodeNotFound;

  /// No description provided for @duplicateBarcode.
  ///
  /// In th, this message translates to:
  /// **'บาร์โค้ดนี้มีอยู่แล้ว'**
  String get duplicateBarcode;

  /// No description provided for @enterManually.
  ///
  /// In th, this message translates to:
  /// **'ป้อนด้วยตนเอง'**
  String get enterManually;

  /// No description provided for @enterBarcodeManually.
  ///
  /// In th, this message translates to:
  /// **'ป้อนบาร์โค้ดด้วยตนเอง'**
  String get enterBarcodeManually;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In th, this message translates to:
  /// **'ต้องอนุญาตใช้กล้องเพื่อสแกนบาร์โค้ด กรุณาเปิดสิทธิ์การเข้าถึงกล้องในการตั้งค่า'**
  String get cameraPermissionDenied;

  /// No description provided for @openSettings.
  ///
  /// In th, this message translates to:
  /// **'เปิดการตั้งค่า'**
  String get openSettings;

  /// No description provided for @scanSuccess.
  ///
  /// In th, this message translates to:
  /// **'สแกนสำเร็จ'**
  String get scanSuccess;

  /// No description provided for @scanFromGallery.
  ///
  /// In th, this message translates to:
  /// **'สแกนจากรูป'**
  String get scanFromGallery;

  /// No description provided for @barcodeNotFoundInImage.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบบาร์โค้ดในรูป'**
  String get barcodeNotFoundInImage;

  /// No description provided for @barcodeMustBeAlphanumeric.
  ///
  /// In th, this message translates to:
  /// **'บาร์โค้ดต้องเป็นตัวอักษรและตัวเลขเท่านั้น'**
  String get barcodeMustBeAlphanumeric;

  /// No description provided for @scanningImage.
  ///
  /// In th, this message translates to:
  /// **'กำลังสแกนรูป...'**
  String get scanningImage;

  /// No description provided for @continuousScan.
  ///
  /// In th, this message translates to:
  /// **'สแกนต่อเนื่อง'**
  String get continuousScan;

  /// No description provided for @continuousScanHint.
  ///
  /// In th, this message translates to:
  /// **'สแกนต่อเนื่องโดยไม่ปิดหน้าจอสแกน'**
  String get continuousScanHint;

  /// No description provided for @focusCamera.
  ///
  /// In th, this message translates to:
  /// **'โฟกัส'**
  String get focusCamera;

  /// No description provided for @productFound.
  ///
  /// In th, this message translates to:
  /// **'เพิ่ม {name} แล้ว'**
  String productFound(String name);

  /// No description provided for @productNotFoundShort.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบสินค้า'**
  String get productNotFoundShort;

  /// No description provided for @scanCount.
  ///
  /// In th, this message translates to:
  /// **'สแกนแล้ว {count} ชิ้น'**
  String scanCount(int count);

  /// No description provided for @done.
  ///
  /// In th, this message translates to:
  /// **'เสร็จ'**
  String get done;

  /// No description provided for @torchOn.
  ///
  /// In th, this message translates to:
  /// **'เปิดไฟฉาย'**
  String get torchOn;

  /// No description provided for @torchOff.
  ///
  /// In th, this message translates to:
  /// **'ปิดไฟฉาย'**
  String get torchOff;

  /// No description provided for @submit.
  ///
  /// In th, this message translates to:
  /// **'ยืนยัน'**
  String get submit;

  /// No description provided for @generateBarcode.
  ///
  /// In th, this message translates to:
  /// **'สร้างบาร์โค้ด'**
  String get generateBarcode;

  /// No description provided for @barcodeGenerated.
  ///
  /// In th, this message translates to:
  /// **'สร้างบาร์โค้ดแล้ว'**
  String get barcodeGenerated;

  /// No description provided for @barcodeGenerationError.
  ///
  /// In th, this message translates to:
  /// **'สร้างบาร์โค้ดไม่สำเร็จ'**
  String get barcodeGenerationError;

  /// No description provided for @batchGenerateBarcodes.
  ///
  /// In th, this message translates to:
  /// **'สร้างบาร์โค้ดให้สินค้าที่ยังไม่มี'**
  String get batchGenerateBarcodes;

  /// No description provided for @batchGenerateBarcodesHint.
  ///
  /// In th, this message translates to:
  /// **'สร้างบาร์โค้ดให้สินค้าทุกชิ้นที่ยังไม่มีบาร์โค้ด'**
  String get batchGenerateBarcodesHint;

  /// No description provided for @batchGenerateConfirmTitle.
  ///
  /// In th, this message translates to:
  /// **'สร้างบาร์โค้ด'**
  String get batchGenerateConfirmTitle;

  /// No description provided for @batchGenerateConfirmBody.
  ///
  /// In th, this message translates to:
  /// **'สร้างบาร์โค้ด EAN-13 ให้สินค้า {count} ชิ้นที่ยังไม่มีบาร์โค้ด?'**
  String batchGenerateConfirmBody(Object count);

  /// No description provided for @batchGenerateSuccess.
  ///
  /// In th, this message translates to:
  /// **'สร้างบาร์โค้ดให้สินค้า {count} ชิ้นแล้ว'**
  String batchGenerateSuccess(Object count);

  /// No description provided for @batchGenerateNone.
  ///
  /// In th, this message translates to:
  /// **'สินค้าทุกชิ้นมีบาร์โค้ดแล้ว'**
  String get batchGenerateNone;

  /// No description provided for @batchGenerateFailed.
  ///
  /// In th, this message translates to:
  /// **'สร้างบาร์โค้ดไม่สำเร็จ'**
  String get batchGenerateFailed;

  /// No description provided for @productsWithoutBarcode.
  ///
  /// In th, this message translates to:
  /// **'มีสินค้า {count} ชิ้นที่ยังไม่มีบาร์โค้ด'**
  String productsWithoutBarcode(Object count);

  /// No description provided for @barcodeSettings.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่าบาร์โค้ด'**
  String get barcodeSettings;

  /// No description provided for @enableBarcodeScan.
  ///
  /// In th, this message translates to:
  /// **'เปิดใช้งานสแกนบาร์โค้ด'**
  String get enableBarcodeScan;

  /// No description provided for @enableBarcodeScanHint.
  ///
  /// In th, this message translates to:
  /// **'แสดงปุ่มสแกนกล้องในหน้าขาย'**
  String get enableBarcodeScanHint;

  /// No description provided for @playBeepOnScan.
  ///
  /// In th, this message translates to:
  /// **'สั่นเตือนเมื่อสแกนสำเร็จ'**
  String get playBeepOnScan;

  /// No description provided for @playBeepOnScanHint.
  ///
  /// In th, this message translates to:
  /// **'สั่นเตือนด้วยการสั่นสะเทือนเมื่อสแกนบาร์โค้ดสำเร็จ'**
  String get playBeepOnScanHint;

  /// No description provided for @barcodePrefix.
  ///
  /// In th, this message translates to:
  /// **'คำนำหน้าสร้างอัตโนมัติ'**
  String get barcodePrefix;

  /// No description provided for @barcodePrefixHint.
  ///
  /// In th, this message translates to:
  /// **'เช่น 200, 201 (ตัวเลข 1-3 หลัก สำหรับ EAN-13)'**
  String get barcodePrefixHint;

  /// No description provided for @barcodePrefixError.
  ///
  /// In th, this message translates to:
  /// **'ต้องเป็นตัวเลข 1-3 หลักเท่านั้น'**
  String get barcodePrefixError;

  /// No description provided for @barcodeFormats.
  ///
  /// In th, this message translates to:
  /// **'รูปแบบบาร์โค้ดที่สแกน'**
  String get barcodeFormats;

  /// No description provided for @barcodeFormatsHint.
  ///
  /// In th, this message translates to:
  /// **'เลือกรูปแบบที่ต้องการสแกน (ลดการสแกนผิด)'**
  String get barcodeFormatsHint;

  /// No description provided for @barcodeFormatEan13.
  ///
  /// In th, this message translates to:
  /// **'EAN-13'**
  String get barcodeFormatEan13;

  /// No description provided for @barcodeFormatEan8.
  ///
  /// In th, this message translates to:
  /// **'EAN-8'**
  String get barcodeFormatEan8;

  /// No description provided for @barcodeFormatUpcA.
  ///
  /// In th, this message translates to:
  /// **'UPC-A'**
  String get barcodeFormatUpcA;

  /// No description provided for @barcodeFormatUpcE.
  ///
  /// In th, this message translates to:
  /// **'UPC-E'**
  String get barcodeFormatUpcE;

  /// No description provided for @barcodeFormatCode128.
  ///
  /// In th, this message translates to:
  /// **'Code 128'**
  String get barcodeFormatCode128;

  /// No description provided for @barcodeFormatCode39.
  ///
  /// In th, this message translates to:
  /// **'Code 39'**
  String get barcodeFormatCode39;

  /// No description provided for @barcodeFormatItf.
  ///
  /// In th, this message translates to:
  /// **'ITF'**
  String get barcodeFormatItf;

  /// No description provided for @barcodeFormatQrCode.
  ///
  /// In th, this message translates to:
  /// **'QR Code'**
  String get barcodeFormatQrCode;

  /// No description provided for @barcodeFormatDataMatrix.
  ///
  /// In th, this message translates to:
  /// **'Data Matrix'**
  String get barcodeFormatDataMatrix;

  /// No description provided for @barcodeFormatPdf417.
  ///
  /// In th, this message translates to:
  /// **'PDF417'**
  String get barcodeFormatPdf417;

  /// No description provided for @barcodeFormatAztec.
  ///
  /// In th, this message translates to:
  /// **'Aztec'**
  String get barcodeFormatAztec;

  /// No description provided for @barcodeFormatCodabar.
  ///
  /// In th, this message translates to:
  /// **'Codabar'**
  String get barcodeFormatCodabar;

  /// No description provided for @selectAll.
  ///
  /// In th, this message translates to:
  /// **'เลือกทั้งหมด'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิกเลือกทั้งหมด'**
  String get deselectAll;

  /// No description provided for @barcodeAutoOpenManual.
  ///
  /// In th, this message translates to:
  /// **'เปิดป้อนด้วยตนเองอัตโนมัติ'**
  String get barcodeAutoOpenManual;

  /// No description provided for @barcodeAutoOpenManualHint.
  ///
  /// In th, this message translates to:
  /// **'เปิดช่องป้อนบาร์โค้ดด้วยตนเองถ้าสแกนไม่สำเร็จภายในเวลาที่กำหนด'**
  String get barcodeAutoOpenManualHint;

  /// No description provided for @disabled.
  ///
  /// In th, this message translates to:
  /// **'ปิดใช้งาน'**
  String get disabled;

  /// No description provided for @secondsSuffix.
  ///
  /// In th, this message translates to:
  /// **' วิ'**
  String get secondsSuffix;

  /// No description provided for @barcodeHelpTitle.
  ///
  /// In th, this message translates to:
  /// **'วิธีใช้บาร์โค้ด'**
  String get barcodeHelpTitle;

  /// No description provided for @barcodeHelpWhatIsTitle.
  ///
  /// In th, this message translates to:
  /// **'บาร์โค้ดคืออะไร?'**
  String get barcodeHelpWhatIsTitle;

  /// No description provided for @barcodeHelpWhatIsBody.
  ///
  /// In th, this message translates to:
  /// **'บาร์โค้ดคือรหัสที่อ่านได้ด้วยเครื่อง (มักเป็นเส้นหรือตัวเลข) ที่พิมพ์บนบรรจุภัณฑ์สินค้า คุณสามารถสแกนด้วยกล้องเพื่อเพิ่มสินค้าใส่ตะกร้าได้อย่างรวดเร็ว'**
  String get barcodeHelpWhatIsBody;

  /// No description provided for @barcodeHelpHowToScanTitle.
  ///
  /// In th, this message translates to:
  /// **'วิธีสแกน'**
  String get barcodeHelpHowToScanTitle;

  /// No description provided for @barcodeHelpHowToScanBody.
  ///
  /// In th, this message translates to:
  /// **'จัดกล้องให้ตรงกับบาร์โค้ดบนสินค้า ตรวจสอบให้มีแสงสว่างเพียงพอและถือโทรศัพท์ให้นิ่ง ถ้าสแกนไม่สำเร็จ ให้แตะ ป้อนด้วยตนเอง แล้วพิมพ์ตัวเลขบาร์โค้ด'**
  String get barcodeHelpHowToScanBody;

  /// No description provided for @barcodeHelpNoBarcodeTitle.
  ///
  /// In th, this message translates to:
  /// **'สินค้าไม่มีบาร์โค้ด?'**
  String get barcodeHelpNoBarcodeTitle;

  /// No description provided for @barcodeHelpNoBarcodeBody.
  ///
  /// In th, this message translates to:
  /// **'ถ้าสินค้าไม่มีบาร์โค้ด คุณสามารถสร้างบาร์โค้ดอัตโนมัติได้ในหน้าข้อมูลสินค้า (แท็บขั้นสูง) เพื่อให้สามารถสแกนได้ในภายหลังที่หน้าขาย'**
  String get barcodeHelpNoBarcodeBody;

  /// No description provided for @barcodeHelper.
  ///
  /// In th, this message translates to:
  /// **'สแกนหรือพิมพ์บาร์โค้ดบนบรรจุภัณฑ์สินค้า ถ้าไม่มี ให้แตะ สร้างบาร์โค้ด'**
  String get barcodeHelper;

  /// No description provided for @skuHelper.
  ///
  /// In th, this message translates to:
  /// **'รหัสสินค้าภายใน (ไม่บังคับ) ตัวอย่าง: SHIRT-RED-L'**
  String get skuHelper;

  /// No description provided for @imagePicked.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มรูปภาพแล้ว'**
  String get imagePicked;

  /// No description provided for @imagePickFailed.
  ///
  /// In th, this message translates to:
  /// **'ไม่สามารถเพิ่มรูปภาพได้ โปรดลองอีกครั้ง'**
  String get imagePickFailed;

  /// No description provided for @storagePermissionDenied.
  ///
  /// In th, this message translates to:
  /// **'ต้องอนุญาตเข้าถึงคลังรูปเพื่อเลือกรูป กรุณาเปิดสิทธิ์การเข้าถึงในการตั้งค่า'**
  String get storagePermissionDenied;

  /// No description provided for @removeImageConfirm.
  ///
  /// In th, this message translates to:
  /// **'ต้องการลบรูปภาพนี้?'**
  String get removeImageConfirm;

  /// No description provided for @imageHelper.
  ///
  /// In th, this message translates to:
  /// **'แตะเพื่อเปลี่ยนรูป กดค้างเพื่อดูตัวอย่าง'**
  String get imageHelper;

  /// No description provided for @tapToAddImage.
  ///
  /// In th, this message translates to:
  /// **'แตะเพื่อเพิ่มรูปภาพ'**
  String get tapToAddImage;

  /// No description provided for @imageNotFound.
  ///
  /// In th, this message translates to:
  /// **'รูปภาพที่บันทึกไว้ถูกลบแล้ว โปรดเลือกใหม่'**
  String get imageNotFound;

  /// No description provided for @clearImageCache.
  ///
  /// In th, this message translates to:
  /// **'ล้างแคชรูปภาพ'**
  String get clearImageCache;

  /// No description provided for @clearImageCacheConfirm.
  ///
  /// In th, this message translates to:
  /// **'จะลบรูปภาพสินค้าที่ไม่ได้ใช้งานเพื่อเพิ่มพื้นที่จัดเก็บ ต้องการดำเนินการต่อ?'**
  String get clearImageCacheConfirm;

  /// No description provided for @imageCacheCleared.
  ///
  /// In th, this message translates to:
  /// **'ล้างแคชรูปภาพแล้ว'**
  String get imageCacheCleared;

  /// No description provided for @basic.
  ///
  /// In th, this message translates to:
  /// **'พื้นฐาน'**
  String get basic;

  /// No description provided for @advanced.
  ///
  /// In th, this message translates to:
  /// **'ขั้นสูง'**
  String get advanced;

  /// No description provided for @settingsStoreSales.
  ///
  /// In th, this message translates to:
  /// **'ร้านค้าและการขาย'**
  String get settingsStoreSales;

  /// No description provided for @settingsDiscounts.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลด'**
  String get settingsDiscounts;

  /// No description provided for @settingsAbout.
  ///
  /// In th, this message translates to:
  /// **'เกี่ยวกับ'**
  String get settingsAbout;

  /// No description provided for @aboutApp.
  ///
  /// In th, this message translates to:
  /// **'เกี่ยวกับแอป'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In th, this message translates to:
  /// **'เวอร์ชัน'**
  String get appVersion;

  /// No description provided for @appBuild.
  ///
  /// In th, this message translates to:
  /// **'บิลด์'**
  String get appBuild;

  /// No description provided for @appDescription.
  ///
  /// In th, this message translates to:
  /// **'แอป POS ออฟไลน์สำหรับร้านค้าเล็กๆ'**
  String get appDescription;

  /// No description provided for @builtWith.
  ///
  /// In th, this message translates to:
  /// **'สร้างด้วย'**
  String get builtWith;

  /// No description provided for @techStackFlutter.
  ///
  /// In th, this message translates to:
  /// **'Flutter'**
  String get techStackFlutter;

  /// No description provided for @techStackDrift.
  ///
  /// In th, this message translates to:
  /// **'Drift SQLite'**
  String get techStackDrift;

  /// No description provided for @privacyPolicy.
  ///
  /// In th, this message translates to:
  /// **'นโยบายความเป็นส่วนตัว'**
  String get privacyPolicy;

  /// No description provided for @openSourceLicense.
  ///
  /// In th, this message translates to:
  /// **'ลิขสิทธิ์โอเพนซอร์ส'**
  String get openSourceLicense;

  /// No description provided for @crashLogs.
  ///
  /// In th, this message translates to:
  /// **'บันทึกข้อผิดพลาด'**
  String get crashLogs;

  /// No description provided for @exportCrashLogs.
  ///
  /// In th, this message translates to:
  /// **'ส่งออกบันทึกข้อผิดพลาด'**
  String get exportCrashLogs;

  /// No description provided for @clearCrashLogs.
  ///
  /// In th, this message translates to:
  /// **'ล้างบันทึกข้อผิดพลาด'**
  String get clearCrashLogs;

  /// No description provided for @clearCrashLogsConfirm.
  ///
  /// In th, this message translates to:
  /// **'ต้องการล้างบันทึกข้อผิดพลาดทั้งหมดใช่หรือไม่?'**
  String get clearCrashLogsConfirm;

  /// No description provided for @crashLogSize.
  ///
  /// In th, this message translates to:
  /// **'ขนาดไฟล์'**
  String get crashLogSize;

  /// No description provided for @crashLogEmpty.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีบันทึกข้อผิดพลาด'**
  String get crashLogEmpty;

  /// No description provided for @contactUs.
  ///
  /// In th, this message translates to:
  /// **'ติดต่อ'**
  String get contactUs;

  /// No description provided for @agplLicense.
  ///
  /// In th, this message translates to:
  /// **'สัญญาอนุญาต GNU Affero General Public License v3.0'**
  String get agplLicense;

  /// No description provided for @agplShort.
  ///
  /// In th, this message translates to:
  /// **'AGPL-3.0'**
  String get agplShort;

  /// No description provided for @copyrightNotice.
  ///
  /// In th, this message translates to:
  /// **'© 2026 Promsell POS CE · AGPL-3.0'**
  String get copyrightNotice;

  /// No description provided for @dataCollection.
  ///
  /// In th, this message translates to:
  /// **'การเก็บข้อมูล'**
  String get dataCollection;

  /// No description provided for @dataCollectionBody.
  ///
  /// In th, this message translates to:
  /// **'Promsell ไม่เก็บข้อมูลส่วนบุคคลใดๆ ข้อมูลการขาย สินค้าคงคลัง และการตั้งค่าทั้งหมดจัดเก็บไว้ในเครื่องของคุณด้วย SQLite ไม่มีการส่งข้อมูลไปยังเซิร์ฟเวอร์ของเรา'**
  String get dataCollectionBody;

  /// No description provided for @thirdPartyServices.
  ///
  /// In th, this message translates to:
  /// **'บริการภายนอก'**
  String get thirdPartyServices;

  /// No description provided for @thirdPartyServicesBody.
  ///
  /// In th, this message translates to:
  /// **'เราไม่ใช้บริการวิเคราะห์ข้อมูล โฆษณา หรือคลาวด์ แอปทำงานแบบออฟไลน์ทั้งหมด'**
  String get thirdPartyServicesBody;

  /// No description provided for @dataStorage.
  ///
  /// In th, this message translates to:
  /// **'การจัดเก็บข้อมูล'**
  String get dataStorage;

  /// No description provided for @dataStorageBody.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลของคุณอยู่ในเครื่อง คุณสามารถส่งออกหรือลบได้ตลอดเวลาผ่านฟีเจอร์สำรอง/กู้คืน รูปภาพสินค้าจัดเก็บในไดเรกทอรีส่วนตัวของแอปและมีการล้างแคชอัตโนมัติ (จำกัด 50MB) เพื่อป้องกันการใช้พื้นที่มากเกินไป'**
  String get dataStorageBody;

  /// No description provided for @backupEncryptionBody.
  ///
  /// In th, this message translates to:
  /// **'Promsell มีการเข้ารหัส AES-256-GCM สำหรับสำรองข้อมูล หากเปิดใช้งาน ข้อมูลสำรองจะถูกเข้ารหัสด้วยคีย์ที่ได้จาก PIN ที่ผู้ใช้กำหนดผ่าน PBKDF2 PIN ไม่ถูกจัดเก็บในเครื่องหรือส่งไปยังที่ใด หากลืม PIN จะไม่สามารถกู้คืนข้อมูลสำรองได้ — เราไม่สามารถรีเซ็ตหรือกู้คืนได้'**
  String get backupEncryptionBody;

  /// No description provided for @permissionsTitle.
  ///
  /// In th, this message translates to:
  /// **'สิทธิ์การเข้าถึง'**
  String get permissionsTitle;

  /// No description provided for @permissionsCamera.
  ///
  /// In th, this message translates to:
  /// **'กล้อง: ใช้สำหรับถ่ายรูปสินค้าและสแกนบาร์โค้ด ไม่มีการส่งรูปภาพหรือข้อมูลสแกนออกจากเครื่อง'**
  String get permissionsCamera;

  /// No description provided for @permissionsStorage.
  ///
  /// In th, this message translates to:
  /// **'คลังข้อมูล: ใช้สำหรับบันทึกข้อมูลสำรองและใบเสร็จเท่านั้น'**
  String get permissionsStorage;

  /// No description provided for @permissionsInternet.
  ///
  /// In th, this message translates to:
  /// **'อินเทอร์เน็ต: ไม่บังคับ ใช้สำหรับโหลดรูปภาพสินค้าจาก URL เท่านั้น เมื่อแชร์รูปภาพสินค้า URL จะถูกส่งไปยังชีตแชร์ของระบบ (ในเครื่องเท่านั้น ไม่ส่งไปเซิร์ฟเวอร์ของเรา)'**
  String get permissionsInternet;

  /// No description provided for @crashLoggingTitle.
  ///
  /// In th, this message translates to:
  /// **'การบันทึกข้อผิดพลาด'**
  String get crashLoggingTitle;

  /// No description provided for @crashLoggingBody.
  ///
  /// In th, this message translates to:
  /// **'หากแอปผิดพลาด ระบบจะบันทึกข้อความผิดพลาด สแตกเทรซ และเวลาที่เกิดเหตุลงในเครื่องของคุณ ข้อมูลที่อ่อนไหว (หมายเลขโทรศัพท์ PromptPay ID เลขบัตรประชาชน) จะถูกล้างโดยอัตโนมัติก่อนจัดเก็บ บันทึกข้อผิดพลาดไม่ถูกส่งออกจากเครื่อง คุณสามารถดู ส่งออก และล้างบันทึกได้ใน การตั้งค่า → เกี่ยวกับ → บันทึกข้อผิดพลาด'**
  String get crashLoggingBody;

  /// No description provided for @contactTitle.
  ///
  /// In th, this message translates to:
  /// **'ติดต่อ'**
  String get contactTitle;

  /// No description provided for @contactBody.
  ///
  /// In th, this message translates to:
  /// **'สอบถามเพิ่มเติม: mnlizard.official@gmail.com'**
  String get contactBody;

  /// No description provided for @productPreviewSystemInfo.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลระบบ'**
  String get productPreviewSystemInfo;

  /// No description provided for @sellingPrice.
  ///
  /// In th, this message translates to:
  /// **'ราคาขาย'**
  String get sellingPrice;

  /// No description provided for @profit.
  ///
  /// In th, this message translates to:
  /// **'กำไร'**
  String get profit;

  /// No description provided for @dateCreated.
  ///
  /// In th, this message translates to:
  /// **'วันที่สร้าง'**
  String get dateCreated;

  /// No description provided for @dateUpdated.
  ///
  /// In th, this message translates to:
  /// **'วันที่อัปเดต'**
  String get dateUpdated;

  /// No description provided for @barcodeViewFull.
  ///
  /// In th, this message translates to:
  /// **'ดู'**
  String get barcodeViewFull;

  /// No description provided for @barcodeSave.
  ///
  /// In th, this message translates to:
  /// **'บันทึก'**
  String get barcodeSave;

  /// No description provided for @barcodePrint.
  ///
  /// In th, this message translates to:
  /// **'พิมพ์'**
  String get barcodePrint;

  /// No description provided for @productPreviewMargin.
  ///
  /// In th, this message translates to:
  /// **'กำไรขั้นต้น'**
  String get productPreviewMargin;

  /// No description provided for @productPreviewStockValue.
  ///
  /// In th, this message translates to:
  /// **'มูลค่าสต็อก'**
  String get productPreviewStockValue;

  /// No description provided for @productPreviewStockValueSale.
  ///
  /// In th, this message translates to:
  /// **'มูลค่าขายทั้งหมด'**
  String get productPreviewStockValueSale;

  /// No description provided for @productPreviewPotentialProfit.
  ///
  /// In th, this message translates to:
  /// **'กำไรหากขายหมด'**
  String get productPreviewPotentialProfit;

  /// No description provided for @productPreviewTotalSold.
  ///
  /// In th, this message translates to:
  /// **'ยอดขายรวม'**
  String get productPreviewTotalSold;

  /// No description provided for @productPreviewTotalIn.
  ///
  /// In th, this message translates to:
  /// **'รับเข้ารวม'**
  String get productPreviewTotalIn;

  /// No description provided for @productPreviewTotalOut.
  ///
  /// In th, this message translates to:
  /// **'ปรับลดรวม'**
  String get productPreviewTotalOut;

  /// No description provided for @productPreviewLastUpdate.
  ///
  /// In th, this message translates to:
  /// **'อัปเดตสต็อกล่าสุด'**
  String get productPreviewLastUpdate;

  /// No description provided for @productPreviewRecentMoves.
  ///
  /// In th, this message translates to:
  /// **'การเคลื่อนไหวล่าสุด'**
  String get productPreviewRecentMoves;

  /// No description provided for @productPreviewMarkup.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มราคาจากต้นทุน'**
  String get productPreviewMarkup;

  /// No description provided for @productPreviewRoi.
  ///
  /// In th, this message translates to:
  /// **'ผลตอบแทนต่อต้นทุน'**
  String get productPreviewRoi;

  /// No description provided for @productPreviewTotalRevenue.
  ///
  /// In th, this message translates to:
  /// **'ราคารวมสต็อกทั้งหมด'**
  String get productPreviewTotalRevenue;

  /// No description provided for @productPreviewTotalProfit.
  ///
  /// In th, this message translates to:
  /// **'กำไรรวมจากสต็อก'**
  String get productPreviewTotalProfit;

  /// No description provided for @productPreviewStatus.
  ///
  /// In th, this message translates to:
  /// **'สถานะ'**
  String get productPreviewStatus;

  /// No description provided for @productPreviewActive.
  ///
  /// In th, this message translates to:
  /// **'เปิดใช้งาน'**
  String get productPreviewActive;

  /// No description provided for @productPreviewCost.
  ///
  /// In th, this message translates to:
  /// **'ต้นทุน'**
  String get productPreviewCost;

  /// No description provided for @productPreviewBarcodeLabel.
  ///
  /// In th, this message translates to:
  /// **'ป้ายบาร์โค้ด'**
  String get productPreviewBarcodeLabel;

  /// No description provided for @productPreviewProductId.
  ///
  /// In th, this message translates to:
  /// **'รหัสสินค้า'**
  String get productPreviewProductId;

  /// No description provided for @ok.
  ///
  /// In th, this message translates to:
  /// **'ตกลง'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In th, this message translates to:
  /// **'ปิด'**
  String get close;

  /// No description provided for @invalidValue.
  ///
  /// In th, this message translates to:
  /// **'ค่าไม่ถูกต้อง'**
  String get invalidValue;

  /// No description provided for @discountPresetAdded.
  ///
  /// In th, this message translates to:
  /// **'เพิ่ม {label}'**
  String discountPresetAdded(String label);

  /// No description provided for @discountPresetRemoved.
  ///
  /// In th, this message translates to:
  /// **'ลบ {label}'**
  String discountPresetRemoved(String label);

  /// No description provided for @unsupportedFormat.
  ///
  /// In th, this message translates to:
  /// **'รูปแบบไม่รองรับ'**
  String get unsupportedFormat;

  /// No description provided for @barcodeSavedSuccess.
  ///
  /// In th, this message translates to:
  /// **'บันทึกบาร์โค้ดสำเร็จ'**
  String get barcodeSavedSuccess;

  /// No description provided for @barcodePrintedSuccess.
  ///
  /// In th, this message translates to:
  /// **'พิมพ์บาร์โค้ดสำเร็จ'**
  String get barcodePrintedSuccess;

  /// No description provided for @barcodeViewError.
  ///
  /// In th, this message translates to:
  /// **'ไม่สามารถดูบาร์โค้ดได้'**
  String get barcodeViewError;

  /// No description provided for @barcodeSaveError.
  ///
  /// In th, this message translates to:
  /// **'ไม่สามารถบันทึกบาร์โค้ดได้'**
  String get barcodeSaveError;

  /// No description provided for @barcodePrintError.
  ///
  /// In th, this message translates to:
  /// **'ไม่สามารถพิมพ์บาร์โค้ดได้'**
  String get barcodePrintError;

  /// No description provided for @inventoryValue.
  ///
  /// In th, this message translates to:
  /// **'มูลค่าคงคลัง'**
  String get inventoryValue;

  /// No description provided for @currencyBaht.
  ///
  /// In th, this message translates to:
  /// **'บาท'**
  String get currencyBaht;

  /// No description provided for @currencyDollar.
  ///
  /// In th, this message translates to:
  /// **'ดอลลาร์'**
  String get currencyDollar;

  /// No description provided for @currencyEuro.
  ///
  /// In th, this message translates to:
  /// **'ยูโร'**
  String get currencyEuro;

  /// No description provided for @currencyYen.
  ///
  /// In th, this message translates to:
  /// **'เยน'**
  String get currencyYen;

  /// No description provided for @stockOnHand.
  ///
  /// In th, this message translates to:
  /// **'คงเหลือ'**
  String get stockOnHand;

  /// No description provided for @piecesLabel.
  ///
  /// In th, this message translates to:
  /// **'ชิ้น'**
  String get piecesLabel;

  /// No description provided for @totalProducts.
  ///
  /// In th, this message translates to:
  /// **'สินค้าทั้งหมด'**
  String get totalProducts;

  /// No description provided for @todayRevenue.
  ///
  /// In th, this message translates to:
  /// **'ยอดขายวันนี้'**
  String get todayRevenue;

  /// No description provided for @todaySalesCount.
  ///
  /// In th, this message translates to:
  /// **'บิด'**
  String get todaySalesCount;

  /// No description provided for @cartItems.
  ///
  /// In th, this message translates to:
  /// **'ชิ้น'**
  String get cartItems;

  /// No description provided for @sortDefault.
  ///
  /// In th, this message translates to:
  /// **'ค่าเริ่มต้น'**
  String get sortDefault;

  /// No description provided for @sortNameAsc.
  ///
  /// In th, this message translates to:
  /// **'ชื่อ A-Z'**
  String get sortNameAsc;

  /// No description provided for @sortPriceLowHigh.
  ///
  /// In th, this message translates to:
  /// **'ราคา: ต่ำ-สูง'**
  String get sortPriceLowHigh;

  /// No description provided for @sortPriceHighLow.
  ///
  /// In th, this message translates to:
  /// **'ราคา: สูง-ต่ำ'**
  String get sortPriceHighLow;

  /// No description provided for @sortStockLowHigh.
  ///
  /// In th, this message translates to:
  /// **'สต็อก: น้อย-มาก'**
  String get sortStockLowHigh;

  /// No description provided for @filterCategory.
  ///
  /// In th, this message translates to:
  /// **'หมวดหมู่'**
  String get filterCategory;

  /// No description provided for @filterSort.
  ///
  /// In th, this message translates to:
  /// **'เรียง'**
  String get filterSort;

  /// No description provided for @filterStock.
  ///
  /// In th, this message translates to:
  /// **'สต็อก'**
  String get filterStock;

  /// No description provided for @filterAll.
  ///
  /// In th, this message translates to:
  /// **'ทั้งหมด'**
  String get filterAll;

  /// No description provided for @filterMore.
  ///
  /// In th, this message translates to:
  /// **'กรอง'**
  String get filterMore;

  /// No description provided for @filterPageTitle.
  ///
  /// In th, this message translates to:
  /// **'กรองสินค้า'**
  String get filterPageTitle;

  /// No description provided for @filterReset.
  ///
  /// In th, this message translates to:
  /// **'รีเซ็ต'**
  String get filterReset;

  /// No description provided for @filterShowResults.
  ///
  /// In th, this message translates to:
  /// **'ดูผลลัพธ์'**
  String get filterShowResults;

  /// No description provided for @filterShowResultsCount.
  ///
  /// In th, this message translates to:
  /// **'ดูผลลัพธ์ ({count})'**
  String filterShowResultsCount(int count);

  /// No description provided for @filterPriceRange.
  ///
  /// In th, this message translates to:
  /// **'ช่วงราคา'**
  String get filterPriceRange;

  /// No description provided for @filterPriceMin.
  ///
  /// In th, this message translates to:
  /// **'ต่ำสุด'**
  String get filterPriceMin;

  /// No description provided for @filterPriceMax.
  ///
  /// In th, this message translates to:
  /// **'สูงสุด'**
  String get filterPriceMax;

  /// No description provided for @filterActiveCount.
  ///
  /// In th, this message translates to:
  /// **'ใช้งาน {count}'**
  String filterActiveCount(int count);

  /// No description provided for @businessType.
  ///
  /// In th, this message translates to:
  /// **'ประเภทธุรกิจ'**
  String get businessType;

  /// No description provided for @businessTypeRetail.
  ///
  /// In th, this message translates to:
  /// **'ค้าปลีก'**
  String get businessTypeRetail;

  /// No description provided for @businessTypeRestaurant.
  ///
  /// In th, this message translates to:
  /// **'ร้านอาหาร'**
  String get businessTypeRestaurant;

  /// No description provided for @businessTypeSubtitle.
  ///
  /// In th, this message translates to:
  /// **'สลับระหว่างโหมดค้าปลีกและร้านอาหาร'**
  String get businessTypeSubtitle;

  /// No description provided for @serviceChargeRate.
  ///
  /// In th, this message translates to:
  /// **'อัตราค่าบริการ (%)'**
  String get serviceChargeRate;

  /// No description provided for @serviceChargeRateSubtitle.
  ///
  /// In th, this message translates to:
  /// **'อัตราค่าบริการเริ่มต้นสำหรับคำสั่งอาหาร'**
  String get serviceChargeRateSubtitle;

  /// No description provided for @orderType.
  ///
  /// In th, this message translates to:
  /// **'ประเภทคำสั่ง'**
  String get orderType;

  /// No description provided for @orderTypeDineIn.
  ///
  /// In th, this message translates to:
  /// **'ทานที่ร้าน'**
  String get orderTypeDineIn;

  /// No description provided for @orderTypeTakeaway.
  ///
  /// In th, this message translates to:
  /// **'สั่งกลับบ้าน'**
  String get orderTypeTakeaway;

  /// No description provided for @orderTypeDelivery.
  ///
  /// In th, this message translates to:
  /// **'จัดส่ง'**
  String get orderTypeDelivery;

  /// No description provided for @orderChannel.
  ///
  /// In th, this message translates to:
  /// **'ช่องทางสั่งซื้อ'**
  String get orderChannel;

  /// No description provided for @orderChannelWalkIn.
  ///
  /// In th, this message translates to:
  /// **'เดินเข้าร้าน'**
  String get orderChannelWalkIn;

  /// No description provided for @orderChannelPhone.
  ///
  /// In th, this message translates to:
  /// **'โทรศัพท์'**
  String get orderChannelPhone;

  /// No description provided for @orderChannelOnline.
  ///
  /// In th, this message translates to:
  /// **'ออนไลน์'**
  String get orderChannelOnline;

  /// No description provided for @externalOrderRef.
  ///
  /// In th, this message translates to:
  /// **'เลขอ้างอิงการสั่งซื้อ'**
  String get externalOrderRef;

  /// No description provided for @externalOrderRefHint.
  ///
  /// In th, this message translates to:
  /// **'หมายเลขคำสั่งซื้อจากแพลตฟอร์มจัดส่ง (ไม่บังคับ)'**
  String get externalOrderRefHint;

  /// No description provided for @serviceCharge.
  ///
  /// In th, this message translates to:
  /// **'ค่าบริการ'**
  String get serviceCharge;

  /// No description provided for @tableNumber.
  ///
  /// In th, this message translates to:
  /// **'โต๊ะ'**
  String get tableNumber;

  /// No description provided for @selectTable.
  ///
  /// In th, this message translates to:
  /// **'เลือกโต๊ะ'**
  String get selectTable;

  /// No description provided for @noTable.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ได้กำหนดโต๊ะ'**
  String get noTable;

  /// No description provided for @restaurantSettings.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่าร้านอาหาร'**
  String get restaurantSettings;

  /// No description provided for @tableManagement.
  ///
  /// In th, this message translates to:
  /// **'จัดการโต๊ะ'**
  String get tableManagement;

  /// No description provided for @tableManagementSubtitle.
  ///
  /// In th, this message translates to:
  /// **'จัดการโต๊ะและโซนในร้าน'**
  String get tableManagementSubtitle;

  /// No description provided for @addTable.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มโต๊ะ'**
  String get addTable;

  /// No description provided for @editTable.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขโต๊ะ'**
  String get editTable;

  /// No description provided for @deleteTable.
  ///
  /// In th, this message translates to:
  /// **'ลบโต๊ะ'**
  String get deleteTable;

  /// No description provided for @tableName.
  ///
  /// In th, this message translates to:
  /// **'ชื่อโต๊ะ'**
  String get tableName;

  /// No description provided for @tableNameHint.
  ///
  /// In th, this message translates to:
  /// **'เช่น โต๊ะ 1, T-01'**
  String get tableNameHint;

  /// No description provided for @tableZone.
  ///
  /// In th, this message translates to:
  /// **'โซน'**
  String get tableZone;

  /// No description provided for @tableZoneHint.
  ///
  /// In th, this message translates to:
  /// **'เช่น ในร้าน, นอกร้าน, ระเบียง'**
  String get tableZoneHint;

  /// No description provided for @tableSeats.
  ///
  /// In th, this message translates to:
  /// **'จำนวนที่นั่ง'**
  String get tableSeats;

  /// No description provided for @tableSeatsHint.
  ///
  /// In th, this message translates to:
  /// **'จำนวนที่นั่งของโต๊ะ'**
  String get tableSeatsHint;

  /// No description provided for @tableStatusAvailable.
  ///
  /// In th, this message translates to:
  /// **'ว่าง'**
  String get tableStatusAvailable;

  /// No description provided for @tableStatusOccupied.
  ///
  /// In th, this message translates to:
  /// **'ไม่ว่าง'**
  String get tableStatusOccupied;

  /// No description provided for @tableStatusReserved.
  ///
  /// In th, this message translates to:
  /// **'จองแล้ว'**
  String get tableStatusReserved;

  /// No description provided for @noTablesYet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีโต๊ะ เพิ่มโต๊ะแรกของคุณ'**
  String get noTablesYet;

  /// No description provided for @confirmDeleteTable.
  ///
  /// In th, this message translates to:
  /// **'ลบโต๊ะนี้?'**
  String get confirmDeleteTable;

  /// No description provided for @selectTableForDineIn.
  ///
  /// In th, this message translates to:
  /// **'เลือกโต๊ะสำหรับคำสั่งนี้'**
  String get selectTableForDineIn;

  /// No description provided for @noTablesAvailable.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ได้ตั้งค่าโต๊ะ เพิ่มโต๊ะในเมนูจัดการโต๊ะ'**
  String get noTablesAvailable;

  /// No description provided for @optionGroups.
  ///
  /// In th, this message translates to:
  /// **'กลุ่มตัวเลือก'**
  String get optionGroups;

  /// No description provided for @optionGroupsSubtitle.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มตัวเลือกเช่น ขนาด, ท็อปปิ้ง, ระดับความเผ็ด'**
  String get optionGroupsSubtitle;

  /// No description provided for @addOptionGroup.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มกลุ่มตัวเลือก'**
  String get addOptionGroup;

  /// No description provided for @editOptionGroup.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขกลุ่มตัวเลือก'**
  String get editOptionGroup;

  /// No description provided for @optionGroupName.
  ///
  /// In th, this message translates to:
  /// **'ชื่อกลุ่ม'**
  String get optionGroupName;

  /// No description provided for @optionGroupNameHint.
  ///
  /// In th, this message translates to:
  /// **'เช่น ขนาด, ท็อปปิ้ง, ระดับความเผ็ด'**
  String get optionGroupNameHint;

  /// No description provided for @optionSelectionType.
  ///
  /// In th, this message translates to:
  /// **'ประเภทการเลือก'**
  String get optionSelectionType;

  /// No description provided for @optionSelectionSingle.
  ///
  /// In th, this message translates to:
  /// **'เลือกได้อย่างเดียว'**
  String get optionSelectionSingle;

  /// No description provided for @optionSelectionMultiple.
  ///
  /// In th, this message translates to:
  /// **'เลือกได้หลายอย่าง'**
  String get optionSelectionMultiple;

  /// No description provided for @optionRequired.
  ///
  /// In th, this message translates to:
  /// **'บังคับเลือก'**
  String get optionRequired;

  /// No description provided for @optionOptional.
  ///
  /// In th, this message translates to:
  /// **'ไม่บังคับ'**
  String get optionOptional;

  /// No description provided for @addOption.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มตัวเลือก'**
  String get addOption;

  /// No description provided for @editOption.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขตัวเลือก'**
  String get editOption;

  /// No description provided for @optionName.
  ///
  /// In th, this message translates to:
  /// **'ชื่อตัวเลือก'**
  String get optionName;

  /// No description provided for @optionNameHint.
  ///
  /// In th, this message translates to:
  /// **'เช่น เล็ก, ช็อตเพิ่ม, ไม่ใส่น้ำแข็ง'**
  String get optionNameHint;

  /// No description provided for @optionPriceDelta.
  ///
  /// In th, this message translates to:
  /// **'ราคาเพิ่มเติม'**
  String get optionPriceDelta;

  /// No description provided for @optionPriceDeltaHint.
  ///
  /// In th, this message translates to:
  /// **'ราคาเพิ่มเติม (สามารถเป็น 0)'**
  String get optionPriceDeltaHint;

  /// No description provided for @deleteOptionGroup.
  ///
  /// In th, this message translates to:
  /// **'ลบกลุ่มตัวเลือก'**
  String get deleteOptionGroup;

  /// No description provided for @confirmDeleteOptionGroup.
  ///
  /// In th, this message translates to:
  /// **'ลบกลุ่มตัวเลือกนี้และตัวเลือกทั้งหมดในกลุ่ม?'**
  String get confirmDeleteOptionGroup;

  /// No description provided for @deleteOption.
  ///
  /// In th, this message translates to:
  /// **'ลบตัวเลือก'**
  String get deleteOption;

  /// No description provided for @confirmDeleteOption.
  ///
  /// In th, this message translates to:
  /// **'ลบตัวเลือกนี้?'**
  String get confirmDeleteOption;

  /// No description provided for @noOptionGroups.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีกลุ่มตัวเลือก'**
  String get noOptionGroups;

  /// No description provided for @selectOptions.
  ///
  /// In th, this message translates to:
  /// **'เลือกตัวเลือก'**
  String get selectOptions;

  /// No description provided for @optionsFor.
  ///
  /// In th, this message translates to:
  /// **'ตัวเลือกสำหรับ {product}'**
  String optionsFor(String product);

  /// No description provided for @optionRequiredMessage.
  ///
  /// In th, this message translates to:
  /// **'กรุณาเลือกตัวเลือกสำหรับ {group}'**
  String optionRequiredMessage(String group);

  /// No description provided for @customersTitle.
  ///
  /// In th, this message translates to:
  /// **'ลูกค้า'**
  String get customersTitle;

  /// No description provided for @customerSaved.
  ///
  /// In th, this message translates to:
  /// **'บันทึกลูกค้าแล้ว'**
  String get customerSaved;

  /// No description provided for @addCustomer.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มลูกค้า'**
  String get addCustomer;

  /// No description provided for @editCustomerTitle.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขลูกค้า'**
  String get editCustomerTitle;

  /// No description provided for @customerNameLabel.
  ///
  /// In th, this message translates to:
  /// **'ชื่อ'**
  String get customerNameLabel;

  /// No description provided for @customerNameRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณากรอกชื่อ'**
  String get customerNameRequired;

  /// No description provided for @customerPhoneLabel.
  ///
  /// In th, this message translates to:
  /// **'เบอร์โทร'**
  String get customerPhoneLabel;

  /// No description provided for @customerEmailLabel.
  ///
  /// In th, this message translates to:
  /// **'อีเมล'**
  String get customerEmailLabel;

  /// No description provided for @customerNoteLabel.
  ///
  /// In th, this message translates to:
  /// **'บันทึก'**
  String get customerNoteLabel;

  /// No description provided for @customerNoteHint.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มบันทึกเกี่ยวกับลูกค้ารายนี้...'**
  String get customerNoteHint;

  /// No description provided for @customerInfoSection.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลลูกค้า'**
  String get customerInfoSection;

  /// No description provided for @customerNotesSection.
  ///
  /// In th, this message translates to:
  /// **'บันทึก'**
  String get customerNotesSection;

  /// No description provided for @customerStatisticsSection.
  ///
  /// In th, this message translates to:
  /// **'สถิติ'**
  String get customerStatisticsSection;

  /// No description provided for @customerTotalVisits.
  ///
  /// In th, this message translates to:
  /// **'จำนวนการเข้าซื้อ'**
  String get customerTotalVisits;

  /// No description provided for @customerTotalSpent.
  ///
  /// In th, this message translates to:
  /// **'ยอดใช้จ่ายรวม'**
  String get customerTotalSpent;

  /// No description provided for @deleteCustomerTitle.
  ///
  /// In th, this message translates to:
  /// **'ลบลูกค้า'**
  String get deleteCustomerTitle;

  /// No description provided for @deleteCustomerConfirm.
  ///
  /// In th, this message translates to:
  /// **'คุณแน่ใจหรือว่าจะลบ \"{name}\"?'**
  String deleteCustomerConfirm(String name);

  /// No description provided for @searchCustomers.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาลูกค้า...'**
  String get searchCustomers;

  /// No description provided for @noCustomersYet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีลูกค้า'**
  String get noCustomersYet;

  /// No description provided for @noCustomersFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบลูกค้า'**
  String get noCustomersFound;

  /// No description provided for @addFirstCustomer.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มลูกค้าคนแรกของคุณเพื่อติดตามการซื้อ'**
  String get addFirstCustomer;

  /// No description provided for @customerVisits.
  ///
  /// In th, this message translates to:
  /// **'เข้าซื้อ {count} ครั้ง'**
  String customerVisits(int count);

  /// No description provided for @selectCustomer.
  ///
  /// In th, this message translates to:
  /// **'เลือกลูกค้า'**
  String get selectCustomer;

  /// No description provided for @clearCustomer.
  ///
  /// In th, this message translates to:
  /// **'ล้างลูกค้า'**
  String get clearCustomer;

  /// No description provided for @noCustomer.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีลูกค้า'**
  String get noCustomer;

  /// No description provided for @receiptLabelCustomer.
  ///
  /// In th, this message translates to:
  /// **'ลูกค้า'**
  String get receiptLabelCustomer;

  /// No description provided for @selectPromotion.
  ///
  /// In th, this message translates to:
  /// **'เลือกโปรโมชัน'**
  String get selectPromotion;

  /// No description provided for @clearPromotion.
  ///
  /// In th, this message translates to:
  /// **'ล้างโปรโมชัน'**
  String get clearPromotion;

  /// No description provided for @noActivePromotions.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีโปรโมชันที่ใช้งานอยู่'**
  String get noActivePromotions;

  /// No description provided for @promotionNotFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบโปรโมชันหรือหมดอายุแล้ว'**
  String get promotionNotFound;

  /// No description provided for @receiptLabelPromotion.
  ///
  /// In th, this message translates to:
  /// **'โปรโมชัน'**
  String get receiptLabelPromotion;

  /// No description provided for @receiptLabelPromotionDiscount.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลดโปร'**
  String get receiptLabelPromotionDiscount;

  /// No description provided for @customerNotFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบลูกค้าหรือถูกลบแล้ว'**
  String get customerNotFound;

  /// No description provided for @insufficientStock.
  ///
  /// In th, this message translates to:
  /// **'สต็อกไม่เพียงพอ'**
  String get insufficientStock;

  /// No description provided for @productNotFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบสินค้า'**
  String get productNotFound;

  /// No description provided for @productInactive.
  ///
  /// In th, this message translates to:
  /// **'สินค้าไม่ได้เปิดใช้งาน'**
  String get productInactive;

  /// No description provided for @saleNotFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบรายการขาย'**
  String get saleNotFound;

  /// No description provided for @saleAlreadyVoided.
  ///
  /// In th, this message translates to:
  /// **'รายการนี้ถูกยกเลิกแล้ว'**
  String get saleAlreadyVoided;

  /// No description provided for @notFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบข้อมูล'**
  String get notFound;

  /// No description provided for @validationError.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลไม่ถูกต้อง'**
  String get validationError;

  /// No description provided for @databaseError.
  ///
  /// In th, this message translates to:
  /// **'ข้อผิดพลาดฐานข้อมูล'**
  String get databaseError;

  /// No description provided for @backupFailed.
  ///
  /// In th, this message translates to:
  /// **'สำรองข้อมูลล้มเหลว'**
  String get backupFailed;

  /// No description provided for @backupShareSubject.
  ///
  /// In th, this message translates to:
  /// **'ไฟล์สำรอง Promsell POS'**
  String get backupShareSubject;

  /// No description provided for @backupPinTitle.
  ///
  /// In th, this message translates to:
  /// **'PIN เข้ารหัสสำรองข้อมูล'**
  String get backupPinTitle;

  /// No description provided for @backupPinHint.
  ///
  /// In th, this message translates to:
  /// **'กรอก PIN เพื่อเข้ารหัสไฟล์สำรอง'**
  String get backupPinHint;

  /// No description provided for @backupPinRequired.
  ///
  /// In th, this message translates to:
  /// **'ต้องใส่ PIN เมื่อเปิดการเข้ารหัส'**
  String get backupPinRequired;

  /// No description provided for @backupPinTooShort.
  ///
  /// In th, this message translates to:
  /// **'PIN ต้องมีอย่างน้อย 6 ตัวอักษร'**
  String get backupPinTooShort;

  /// No description provided for @backupPinConfirmHint.
  ///
  /// In th, this message translates to:
  /// **'ยืนยัน PIN'**
  String get backupPinConfirmHint;

  /// No description provided for @backupPinMismatch.
  ///
  /// In th, this message translates to:
  /// **'PIN ไม่ตรงกัน'**
  String get backupPinMismatch;

  /// No description provided for @backupEncryptionOffTitle.
  ///
  /// In th, this message translates to:
  /// **'ปิดการเข้ารหัสสำรองข้อมูล?'**
  String get backupEncryptionOffTitle;

  /// No description provided for @backupEncryptionOffConfirm.
  ///
  /// In th, this message translates to:
  /// **'ไฟล์สำรองที่ไม่ได้เข้ารหัสเสี่ยงถูกคัดลอกได้ง่ายขึ้นหากมีคนได้ไฟล์ คุณเปิดการเข้ารหัสใหม่ได้ภายหลัง'**
  String get backupEncryptionOffConfirm;

  /// No description provided for @customerSpentLabel.
  ///
  /// In th, this message translates to:
  /// **'ใช้ไป {amount}'**
  String customerSpentLabel(String amount);

  /// No description provided for @tryDifferentSearch.
  ///
  /// In th, this message translates to:
  /// **'ลองคำค้นหาอื่น'**
  String get tryDifferentSearch;

  /// No description provided for @promotionsTitle.
  ///
  /// In th, this message translates to:
  /// **'โปรโมชัน'**
  String get promotionsTitle;

  /// No description provided for @promotionSaved.
  ///
  /// In th, this message translates to:
  /// **'บันทึกโปรโมชันแล้ว'**
  String get promotionSaved;

  /// No description provided for @addPromotion.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มโปรโมชัน'**
  String get addPromotion;

  /// No description provided for @editPromotionTitle.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขโปรโมชัน'**
  String get editPromotionTitle;

  /// No description provided for @promotionNameLabel.
  ///
  /// In th, this message translates to:
  /// **'ชื่อโปรโมชัน'**
  String get promotionNameLabel;

  /// No description provided for @promotionNameRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณากรอกชื่อ'**
  String get promotionNameRequired;

  /// No description provided for @promotionValueLabel.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลด (%)'**
  String get promotionValueLabel;

  /// No description provided for @promotionAmountLabel.
  ///
  /// In th, this message translates to:
  /// **'มูลค่าส่วนลด'**
  String get promotionAmountLabel;

  /// No description provided for @promotionValueRequired.
  ///
  /// In th, this message translates to:
  /// **'กรุณากรอกค่า'**
  String get promotionValueRequired;

  /// No description provided for @promotionValueInvalid.
  ///
  /// In th, this message translates to:
  /// **'กรุณากรอกค่าที่ถูกต้อง'**
  String get promotionValueInvalid;

  /// No description provided for @promotionPercentMax.
  ///
  /// In th, this message translates to:
  /// **'เปอร์เซ็นต์ต้องไม่เกิน 100'**
  String get promotionPercentMax;

  /// No description provided for @promotionMinPurchaseLabel.
  ///
  /// In th, this message translates to:
  /// **'ยอดซื้อขั้นต่ำ'**
  String get promotionMinPurchaseLabel;

  /// No description provided for @promotionMinPurchaseHint.
  ///
  /// In th, this message translates to:
  /// **'0 = ไม่มีขั้นต่ำ'**
  String get promotionMinPurchaseHint;

  /// No description provided for @promotionDetailsSection.
  ///
  /// In th, this message translates to:
  /// **'รายละเอียดโปรโมชัน'**
  String get promotionDetailsSection;

  /// No description provided for @promotionScheduleSection.
  ///
  /// In th, this message translates to:
  /// **'กำหนดเวลา'**
  String get promotionScheduleSection;

  /// No description provided for @promotionStatusSection.
  ///
  /// In th, this message translates to:
  /// **'สถานะ'**
  String get promotionStatusSection;

  /// No description provided for @promotionStartDate.
  ///
  /// In th, this message translates to:
  /// **'วันเริ่มต้น'**
  String get promotionStartDate;

  /// No description provided for @promotionEndDate.
  ///
  /// In th, this message translates to:
  /// **'วันสิ้นสุด'**
  String get promotionEndDate;

  /// No description provided for @promotionNoEndDate.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีวันสิ้นสุด'**
  String get promotionNoEndDate;

  /// No description provided for @promotionActive.
  ///
  /// In th, this message translates to:
  /// **'ใช้งานอยู่'**
  String get promotionActive;

  /// No description provided for @promotionInactive.
  ///
  /// In th, this message translates to:
  /// **'ปิดใช้งาน'**
  String get promotionInactive;

  /// No description provided for @promotionActiveDesc.
  ///
  /// In th, this message translates to:
  /// **'โปรโมชันนี้กำลังใช้งานอยู่'**
  String get promotionActiveDesc;

  /// No description provided for @promotionInactiveDesc.
  ///
  /// In th, this message translates to:
  /// **'โปรโมชันนี้ถูกปิดใช้งาน'**
  String get promotionInactiveDesc;

  /// No description provided for @promotionPercentage.
  ///
  /// In th, this message translates to:
  /// **'เปอร์เซ็นต์'**
  String get promotionPercentage;

  /// No description provided for @promotionFixedAmount.
  ///
  /// In th, this message translates to:
  /// **'จำนวนเงินคงที่'**
  String get promotionFixedAmount;

  /// No description provided for @deletePromotionTitle.
  ///
  /// In th, this message translates to:
  /// **'ลบโปรโมชัน'**
  String get deletePromotionTitle;

  /// No description provided for @deletePromotionConfirm.
  ///
  /// In th, this message translates to:
  /// **'คุณแน่ใจหรือว่าจะลบ \"{name}\"?'**
  String deletePromotionConfirm(String name);

  /// No description provided for @searchPromotions.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาโปรโมชัน...'**
  String get searchPromotions;

  /// No description provided for @noPromotionsYet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีโปรโมชัน'**
  String get noPromotionsYet;

  /// No description provided for @noPromotionsFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบโปรโมชัน'**
  String get noPromotionsFound;

  /// No description provided for @addFirstPromotion.
  ///
  /// In th, this message translates to:
  /// **'สร้างโปรโมชันแรกของคุณเพื่อให้ส่วนลด'**
  String get addFirstPromotion;

  /// No description provided for @promotionPercentOff.
  ///
  /// In th, this message translates to:
  /// **'ลด {value}%'**
  String promotionPercentOff(String value);

  /// No description provided for @promotionAmountOff.
  ///
  /// In th, this message translates to:
  /// **'ลด {value}'**
  String promotionAmountOff(String value);

  /// No description provided for @promotionMinPurchase.
  ///
  /// In th, this message translates to:
  /// **'ซื้อขั้นต่ำ: {amount}'**
  String promotionMinPurchase(String amount);

  /// No description provided for @homeGreeting.
  ///
  /// In th, this message translates to:
  /// **'สวัสดี, {shopName}'**
  String homeGreeting(String shopName);

  /// No description provided for @homeSubtitle.
  ///
  /// In th, this message translates to:
  /// **'เริ่มต้นวันให้ยอดปัง!'**
  String get homeSubtitle;

  /// No description provided for @homeTodayRevenue.
  ///
  /// In th, this message translates to:
  /// **'ยอดขายวันนี้'**
  String get homeTodayRevenue;

  /// No description provided for @homeVsYesterday.
  ///
  /// In th, this message translates to:
  /// **'เทียบกับเมื่อวาน'**
  String get homeVsYesterday;

  /// No description provided for @homeRevenue.
  ///
  /// In th, this message translates to:
  /// **'รายรับ'**
  String get homeRevenue;

  /// No description provided for @homeCost.
  ///
  /// In th, this message translates to:
  /// **'ต้นทุน'**
  String get homeCost;

  /// No description provided for @homeProfit.
  ///
  /// In th, this message translates to:
  /// **'กำไร'**
  String get homeProfit;

  /// No description provided for @homeMainMenu.
  ///
  /// In th, this message translates to:
  /// **'เมนูหลัก'**
  String get homeMainMenu;

  /// No description provided for @homeHistory.
  ///
  /// In th, this message translates to:
  /// **'ประวัติ'**
  String get homeHistory;

  /// No description provided for @homeCloseDay.
  ///
  /// In th, this message translates to:
  /// **'ปิดยอดวัน'**
  String get homeCloseDay;

  /// No description provided for @homePromotionBannerCta.
  ///
  /// In th, this message translates to:
  /// **'สร้างเลย'**
  String get homePromotionBannerCta;

  /// No description provided for @homeCreatePromotion.
  ///
  /// In th, this message translates to:
  /// **'สร้างโปรโมชั่น'**
  String get homeCreatePromotion;

  /// No description provided for @importProducts.
  ///
  /// In th, this message translates to:
  /// **'นำเข้าสินค้า'**
  String get importProducts;

  /// No description provided for @productTabAll.
  ///
  /// In th, this message translates to:
  /// **'ทั้งหมด'**
  String get productTabAll;

  /// No description provided for @productTabCategory.
  ///
  /// In th, this message translates to:
  /// **'หมวดหมู่'**
  String get productTabCategory;

  /// No description provided for @productTabStock.
  ///
  /// In th, this message translates to:
  /// **'คลังสินค้า'**
  String get productTabStock;

  /// No description provided for @productMenuEdit.
  ///
  /// In th, this message translates to:
  /// **'แก้ไข'**
  String get productMenuEdit;

  /// No description provided for @productMenuPreview.
  ///
  /// In th, this message translates to:
  /// **'ดูตัวอย่าง'**
  String get productMenuPreview;

  /// No description provided for @importFromCsv.
  ///
  /// In th, this message translates to:
  /// **'นำเข้าจาก CSV'**
  String get importFromCsv;

  /// No description provided for @selectCsvFile.
  ///
  /// In th, this message translates to:
  /// **'เลือกไฟล์ CSV'**
  String get selectCsvFile;

  /// No description provided for @csvImportPreview.
  ///
  /// In th, this message translates to:
  /// **'ตัวอย่างข้อมูลที่จะนำเข้า'**
  String get csvImportPreview;

  /// No description provided for @confirmImport.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันนำเข้า'**
  String get confirmImport;

  /// No description provided for @importSuccess.
  ///
  /// In th, this message translates to:
  /// **'นำเข้าสินค้า {count} รายการแล้ว'**
  String importSuccess(int count);

  /// No description provided for @importError.
  ///
  /// In th, this message translates to:
  /// **'นำเข้าสินค้าไม่สำเร็จ'**
  String get importError;

  /// No description provided for @csvImportError.
  ///
  /// In th, this message translates to:
  /// **'อ่านไฟล์ CSV ไม่สำเร็จ'**
  String get csvImportError;

  /// No description provided for @csvNoData.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบข้อมูลในไฟล์ CSV'**
  String get csvNoData;

  /// No description provided for @csvInvalidFormat.
  ///
  /// In th, this message translates to:
  /// **'รูปแบบไฟล์ไม่ถูกต้อง'**
  String get csvInvalidFormat;

  /// No description provided for @csvFileTooLarge.
  ///
  /// In th, this message translates to:
  /// **'ไฟล์ใหญ่เกินไป (สูงสุด {maxMb} MB)'**
  String csvFileTooLarge(int maxMb);

  /// No description provided for @csvTooManyRows.
  ///
  /// In th, this message translates to:
  /// **'มีแถวมากเกินไป (สูงสุด {maxRows} แถว)'**
  String csvTooManyRows(int maxRows);

  /// No description provided for @csvRowErrorsSkipped.
  ///
  /// In th, this message translates to:
  /// **'จะข้าม {count} แถวที่มีข้อผิดพลาด'**
  String csvRowErrorsSkipped(int count);

  /// No description provided for @csvImportPartialSuccess.
  ///
  /// In th, this message translates to:
  /// **'นำเข้า {imported} รายการ; ล้มเหลว {errors} แถว'**
  String csvImportPartialSuccess(int imported, int errors);

  /// No description provided for @csvImportCategoriesCreated.
  ///
  /// In th, this message translates to:
  /// **'สร้างหมวดหมู่ {count} รายการ'**
  String csvImportCategoriesCreated(int count);

  /// No description provided for @csvDownloadTemplate.
  ///
  /// In th, this message translates to:
  /// **'ดาวน์โหลดเทมเพลต'**
  String get csvDownloadTemplate;

  /// No description provided for @csvColumnLegend.
  ///
  /// In th, this message translates to:
  /// **'จำเป็น: ชื่อ, ราคา. ไม่บังคับ: รหัสสินค้า, บาร์โค้ด, ต้นทุน, สต็อก, หมวดหมู่, ติดตามสต็อก'**
  String get csvColumnLegend;

  /// No description provided for @csvImporting.
  ///
  /// In th, this message translates to:
  /// **'กำลังนำเข้า…'**
  String get csvImporting;

  /// No description provided for @csvRowLabel.
  ///
  /// In th, this message translates to:
  /// **'แถว {row}: {message}'**
  String csvRowLabel(int row, String message);

  /// No description provided for @csvTemplateShared.
  ///
  /// In th, this message translates to:
  /// **'เทมเพลตพร้อมแชร์แล้ว'**
  String get csvTemplateShared;

  /// No description provided for @csvParseErrorsTitle.
  ///
  /// In th, this message translates to:
  /// **'แถวที่จะถูกข้าม'**
  String get csvParseErrorsTitle;

  /// No description provided for @csvPostImportErrorsTitle.
  ///
  /// In th, this message translates to:
  /// **'แถวที่นำเข้าไม่สำเร็จ'**
  String get csvPostImportErrorsTitle;

  /// No description provided for @homePromotionBannerSubtitle.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มยอดขายได้ง่ายๆ'**
  String get homePromotionBannerSubtitle;

  /// No description provided for @homeNoActivePromotion.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีโปรโมชันที่ใช้งานอยู่'**
  String get homeNoActivePromotion;

  /// No description provided for @homePromotionOff.
  ///
  /// In th, this message translates to:
  /// **'ลด'**
  String get homePromotionOff;

  /// No description provided for @homeFromBills.
  ///
  /// In th, this message translates to:
  /// **'จาก {count} บิล'**
  String homeFromBills(int count);

  /// No description provided for @productDetailTitle.
  ///
  /// In th, this message translates to:
  /// **'รายละเอียดสินค้า'**
  String get productDetailTitle;

  /// No description provided for @productTabInfo.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลสินค้า'**
  String get productTabInfo;

  /// No description provided for @productTabHistory.
  ///
  /// In th, this message translates to:
  /// **'ประวัติ'**
  String get productTabHistory;

  /// No description provided for @productDescriptionLabel.
  ///
  /// In th, this message translates to:
  /// **'รายละเอียด'**
  String get productDescriptionLabel;

  /// No description provided for @productDescriptionEmpty.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีรายละเอียด'**
  String get productDescriptionEmpty;

  /// No description provided for @productUnitLabel.
  ///
  /// In th, this message translates to:
  /// **'หน่วยนับ'**
  String get productUnitLabel;

  /// No description provided for @productUnitDefault.
  ///
  /// In th, this message translates to:
  /// **'ชิ้น'**
  String get productUnitDefault;

  /// No description provided for @productTabPointOfSale.
  ///
  /// In th, this message translates to:
  /// **'ขายหน้าร้าน'**
  String get productTabPointOfSale;

  /// No description provided for @productTabPriceStock.
  ///
  /// In th, this message translates to:
  /// **'ราคาและสต็อก'**
  String get productTabPriceStock;

  /// No description provided for @productTabCodesMore.
  ///
  /// In th, this message translates to:
  /// **'รหัสและเพิ่มเติม'**
  String get productTabCodesMore;

  /// No description provided for @productRecommended.
  ///
  /// In th, this message translates to:
  /// **'สินค้าแนะนำ'**
  String get productRecommended;

  /// No description provided for @productUnitOther.
  ///
  /// In th, this message translates to:
  /// **'อื่น ๆ'**
  String get productUnitOther;

  /// No description provided for @productCustomUnit.
  ///
  /// In th, this message translates to:
  /// **'ระบุหน่วยนับ'**
  String get productCustomUnit;

  /// No description provided for @productTaxLabel.
  ///
  /// In th, this message translates to:
  /// **'ภาษี'**
  String get productTaxLabel;

  /// No description provided for @productWeightLabel.
  ///
  /// In th, this message translates to:
  /// **'น้ำหนัก'**
  String get productWeightLabel;

  /// No description provided for @productSizeLabel.
  ///
  /// In th, this message translates to:
  /// **'ขนาดสินค้า'**
  String get productSizeLabel;

  /// No description provided for @productBrandLabel.
  ///
  /// In th, this message translates to:
  /// **'แบรนด์'**
  String get productBrandLabel;

  /// No description provided for @productSupplierLabel.
  ///
  /// In th, this message translates to:
  /// **'ผู้จัดจำหน่าย'**
  String get productSupplierLabel;

  /// No description provided for @copyBarcode.
  ///
  /// In th, this message translates to:
  /// **'คัดลอกบาร์โค้ด'**
  String get copyBarcode;

  /// No description provided for @printBarcode.
  ///
  /// In th, this message translates to:
  /// **'พิมพ์บาร์โค้ด'**
  String get printBarcode;

  /// No description provided for @productAdjustStock.
  ///
  /// In th, this message translates to:
  /// **'ปรับสต็อก'**
  String get productAdjustStock;

  /// No description provided for @productNoHistory.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีประวัติการเคลื่อนไหวสต็อก'**
  String get productNoHistory;

  /// No description provided for @normalProduct.
  ///
  /// In th, this message translates to:
  /// **'สินค้าปกติ'**
  String get normalProduct;

  /// No description provided for @readyToSell.
  ///
  /// In th, this message translates to:
  /// **'พร้อมขาย'**
  String get readyToSell;

  /// No description provided for @retailPrice.
  ///
  /// In th, this message translates to:
  /// **'ราคาขายปลีก'**
  String get retailPrice;

  /// No description provided for @averageCost.
  ///
  /// In th, this message translates to:
  /// **'ต้นทุนเฉลี่ย'**
  String get averageCost;

  /// No description provided for @averageProfit.
  ///
  /// In th, this message translates to:
  /// **'กำไรต่อชิ้น'**
  String get averageProfit;

  /// No description provided for @remainingStock.
  ///
  /// In th, this message translates to:
  /// **'สต็อกคงเหลือ'**
  String get remainingStock;

  /// No description provided for @moveProduct.
  ///
  /// In th, this message translates to:
  /// **'ย้ายสินค้า'**
  String get moveProduct;

  /// No description provided for @editProduct.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขสินค้า'**
  String get editProduct;

  /// No description provided for @pieces.
  ///
  /// In th, this message translates to:
  /// **'{count} ชิ้น'**
  String pieces(int count);

  /// No description provided for @resourceNotFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบ{resource}'**
  String resourceNotFound(String resource);

  /// No description provided for @resourceNotFoundWithId.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบ{resource} (ID: {id})'**
  String resourceNotFoundWithId(String resource, String id);

  /// No description provided for @businessRuleViolation.
  ///
  /// In th, this message translates to:
  /// **'ละเมิดกฎทางธุรกิจ'**
  String get businessRuleViolation;

  /// No description provided for @networkError.
  ///
  /// In th, this message translates to:
  /// **'ข้อผิดพลาดเครือข่าย'**
  String get networkError;

  /// No description provided for @networkErrorDefault.
  ///
  /// In th, this message translates to:
  /// **'ข้อผิดพลาดเครือข่าย (สถานะ: {code})'**
  String networkErrorDefault(int code);

  /// No description provided for @fileSystemError.
  ///
  /// In th, this message translates to:
  /// **'ข้อผิดพลาดระบบไฟล์'**
  String get fileSystemError;

  /// No description provided for @permissionDenied.
  ///
  /// In th, this message translates to:
  /// **'ไม่ได้รับอนุญาต'**
  String get permissionDenied;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In th, this message translates to:
  /// **'กรุณาอนุญาตการเข้าถึง{permission}'**
  String permissionDeniedMessage(String permission);

  /// No description provided for @unexpectedError.
  ///
  /// In th, this message translates to:
  /// **'เกิดข้อผิดพลาดที่ไม่คาดคิด'**
  String get unexpectedError;

  /// No description provided for @invalidDiscount.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลดไม่ถูกต้อง'**
  String get invalidDiscount;

  /// No description provided for @negativePriceNotAllowed.
  ///
  /// In th, this message translates to:
  /// **'ไม่อนุญาตให้ใส่ราคาติดลบ'**
  String get negativePriceNotAllowed;

  /// No description provided for @homeLoadError.
  ///
  /// In th, this message translates to:
  /// **'โหลดข้อมูลไม่สำเร็จ'**
  String get homeLoadError;

  /// No description provided for @productFormSectionGeneral.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลทั่วไป'**
  String get productFormSectionGeneral;

  /// No description provided for @productFormSectionPricing.
  ///
  /// In th, this message translates to:
  /// **'ราคา & ต้นทุน'**
  String get productFormSectionPricing;

  /// No description provided for @productFormSectionStock.
  ///
  /// In th, this message translates to:
  /// **'สต็อก & หน่วยนับ'**
  String get productFormSectionStock;

  /// No description provided for @productFormSectionSettings.
  ///
  /// In th, this message translates to:
  /// **'การตั้งค่า'**
  String get productFormSectionSettings;

  /// No description provided for @productFormSectionExtra.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลเพิ่มเติม'**
  String get productFormSectionExtra;

  /// No description provided for @profitMargin.
  ///
  /// In th, this message translates to:
  /// **'อัตรากำไร'**
  String get profitMargin;

  /// No description provided for @notSpecified.
  ///
  /// In th, this message translates to:
  /// **'ไม่ระบุ'**
  String get notSpecified;

  /// No description provided for @saveProduct.
  ///
  /// In th, this message translates to:
  /// **'บันทึกสินค้า'**
  String get saveProduct;

  /// No description provided for @discardChanges.
  ///
  /// In th, this message translates to:
  /// **'ไม่บันทึก'**
  String get discardChanges;

  /// No description provided for @unsavedChangesMessageCreate.
  ///
  /// In th, this message translates to:
  /// **'ออกโดยไม่บันทึกสินค้า? ร่างจะถูกเก็บไว้ให้กู้คืนครั้งถัดไป หรือเลือกทิ้งร่าง'**
  String get unsavedChangesMessageCreate;

  /// No description provided for @unsavedChangesMessageEdit.
  ///
  /// In th, this message translates to:
  /// **'มีการแก้ไขที่ยังไม่บันทึก ต้องการออกโดยไม่บันทึกหรือไม่?'**
  String get unsavedChangesMessageEdit;

  /// No description provided for @costExceedsPriceWarning.
  ///
  /// In th, this message translates to:
  /// **'ต้นทุนสูงกว่าราคาขาย — กำไรติดลบ'**
  String get costExceedsPriceWarning;

  /// No description provided for @priceStockEstimateTitle.
  ///
  /// In th, this message translates to:
  /// **'ถ้าขายหมดสต็อก'**
  String get priceStockEstimateTitle;

  /// No description provided for @priceStockEstimateRevenue.
  ///
  /// In th, this message translates to:
  /// **'รายได้โดยประมาณ'**
  String get priceStockEstimateRevenue;

  /// No description provided for @priceStockEstimateProfit.
  ///
  /// In th, this message translates to:
  /// **'กำไรโดยประมาณ'**
  String get priceStockEstimateProfit;

  /// No description provided for @editStockAdjustHint.
  ///
  /// In th, this message translates to:
  /// **'แก้จำนวนผ่านปุ่มปรับสต็อก เพื่อให้มีประวัติการเคลื่อนไหว'**
  String get editStockAdjustHint;

  /// No description provided for @lowStockThresholdHint.
  ///
  /// In th, this message translates to:
  /// **'เตือนสต็อกต่ำที่ {n}'**
  String lowStockThresholdHint(int n);

  /// No description provided for @stockInventoryValueTitle.
  ///
  /// In th, this message translates to:
  /// **'มูลค่าคลัง'**
  String get stockInventoryValueTitle;

  /// No description provided for @adjustModeAdd.
  ///
  /// In th, this message translates to:
  /// **'เพิ่ม'**
  String get adjustModeAdd;

  /// No description provided for @adjustModeRemove.
  ///
  /// In th, this message translates to:
  /// **'ลด'**
  String get adjustModeRemove;

  /// No description provided for @adjustQtyAmountLabel.
  ///
  /// In th, this message translates to:
  /// **'จำนวน'**
  String get adjustQtyAmountLabel;

  /// No description provided for @adjustCurrentStock.
  ///
  /// In th, this message translates to:
  /// **'สต็อกปัจจุบัน: {qty} {unit}'**
  String adjustCurrentStock(String qty, String unit);

  /// No description provided for @adjustPreviewResult.
  ///
  /// In th, this message translates to:
  /// **'{from} → {to} {unit}'**
  String adjustPreviewResult(String from, String to, String unit);

  /// No description provided for @adjustWouldGoNegative.
  ///
  /// In th, this message translates to:
  /// **'สต็อกไม่พอสำหรับจำนวนที่ลด'**
  String get adjustWouldGoNegative;

  /// No description provided for @adjustReasonRestock.
  ///
  /// In th, this message translates to:
  /// **'รับเข้า / เติมสต็อก'**
  String get adjustReasonRestock;

  /// No description provided for @adjustReasonDamaged.
  ///
  /// In th, this message translates to:
  /// **'ชำรุด / เสียหาย'**
  String get adjustReasonDamaged;

  /// No description provided for @adjustReasonLost.
  ///
  /// In th, this message translates to:
  /// **'สูญหาย'**
  String get adjustReasonLost;

  /// No description provided for @adjustReasonCountCorrection.
  ///
  /// In th, this message translates to:
  /// **'แก้จากนับสต็อก'**
  String get adjustReasonCountCorrection;

  /// No description provided for @adjustReasonReturn.
  ///
  /// In th, this message translates to:
  /// **'รับคืนจากลูกค้า'**
  String get adjustReasonReturn;

  /// No description provided for @adjustReasonOther.
  ///
  /// In th, this message translates to:
  /// **'อื่นๆ'**
  String get adjustReasonOther;

  /// No description provided for @adjustReasonOtherHint.
  ///
  /// In th, this message translates to:
  /// **'ระบุเหตุผล'**
  String get adjustReasonOtherHint;

  /// No description provided for @editLowStockThreshold.
  ///
  /// In th, this message translates to:
  /// **'แก้เกณฑ์เตือน'**
  String get editLowStockThreshold;

  /// No description provided for @lowStockThresholdSaved.
  ///
  /// In th, this message translates to:
  /// **'อัปเดตเกณฑ์เตือนสต็อกต่ำแล้ว'**
  String get lowStockThresholdSaved;

  /// No description provided for @createProductFromBarcode.
  ///
  /// In th, this message translates to:
  /// **'สร้างสินค้า'**
  String get createProductFromBarcode;

  /// No description provided for @scanAgainToAdd.
  ///
  /// In th, this message translates to:
  /// **'บันทึกแล้ว — สแกนอีกครั้งเพื่อใส่ตะกร้า'**
  String get scanAgainToAdd;

  /// No description provided for @productCreatedAddedToCart.
  ///
  /// In th, this message translates to:
  /// **'สร้างสินค้าและใส่ตะกร้าแล้ว'**
  String get productCreatedAddedToCart;

  /// No description provided for @barcodeReplaceTitle.
  ///
  /// In th, this message translates to:
  /// **'แทนที่บาร์โค้ด?'**
  String get barcodeReplaceTitle;

  /// No description provided for @barcodeReplaceMessage.
  ///
  /// In th, this message translates to:
  /// **'รหัสปัจจุบัน: {code} — รหัสใหม่จะแทนที่ของเดิม'**
  String barcodeReplaceMessage(String code);

  /// No description provided for @barcodePreviewEmpty.
  ///
  /// In th, this message translates to:
  /// **'พรีวิวจะแสดงเมื่อพิมพ์หรือสร้างบาร์โค้ด'**
  String get barcodePreviewEmpty;

  /// No description provided for @scanModeContinuous.
  ///
  /// In th, this message translates to:
  /// **'ต่อเนื่อง'**
  String get scanModeContinuous;

  /// No description provided for @scanModeSingle.
  ///
  /// In th, this message translates to:
  /// **'ครั้งเดียว'**
  String get scanModeSingle;

  /// No description provided for @searchMatchName.
  ///
  /// In th, this message translates to:
  /// **'ชื่อ'**
  String get searchMatchName;

  /// No description provided for @searchMatchSku.
  ///
  /// In th, this message translates to:
  /// **'SKU'**
  String get searchMatchSku;

  /// No description provided for @searchMatchBarcode.
  ///
  /// In th, this message translates to:
  /// **'บาร์โค้ด'**
  String get searchMatchBarcode;

  /// No description provided for @searchResultCount.
  ///
  /// In th, this message translates to:
  /// **'พบ {count} รายการ'**
  String searchResultCount(int count);

  /// No description provided for @searchFiltersIgnoredHint.
  ///
  /// In th, this message translates to:
  /// **'แสดงทุกรายการที่ตรงคำค้น (ไม่ใช้ตัวกรองรายการ)'**
  String get searchFiltersIgnoredHint;

  /// No description provided for @searchShowingCount.
  ///
  /// In th, this message translates to:
  /// **'แสดง {shown} จาก {total}'**
  String searchShowingCount(int shown, int total);

  /// No description provided for @barcodeAmbiguousCount.
  ///
  /// In th, this message translates to:
  /// **'มีสินค้า {count} รายการใช้บาร์โค้ดนี้'**
  String barcodeAmbiguousCount(int count);

  /// No description provided for @cartBillDetails.
  ///
  /// In th, this message translates to:
  /// **'รายละเอียดบิล'**
  String get cartBillDetails;

  /// No description provided for @cartHoldBill.
  ///
  /// In th, this message translates to:
  /// **'บิลที่บันทึก'**
  String get cartHoldBill;

  /// No description provided for @cartItemCount.
  ///
  /// In th, this message translates to:
  /// **'{count} รายการ'**
  String cartItemCount(int count);

  /// No description provided for @cartActiveBill.
  ///
  /// In th, this message translates to:
  /// **'บิล: {name}'**
  String cartActiveBill(String name);

  /// No description provided for @heroNoBarcode.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีบาร์โค้ด'**
  String get heroNoBarcode;

  /// No description provided for @setSellingPrice.
  ///
  /// In th, this message translates to:
  /// **'ตั้งราคาขาย'**
  String get setSellingPrice;

  /// No description provided for @showProductHint.
  ///
  /// In th, this message translates to:
  /// **'เปิดแล้วแสดงในรายการสินค้าและหน้าขาย'**
  String get showProductHint;

  /// No description provided for @productRecommendedHint.
  ///
  /// In th, this message translates to:
  /// **'ไฮไลต์บนหน้าขายและมีป้ายในรายการสินค้า'**
  String get productRecommendedHint;

  /// No description provided for @productBrandHint.
  ///
  /// In th, this message translates to:
  /// **'แบรนด์หรือผู้ผลิต (ไม่บังคับ)'**
  String get productBrandHint;

  /// No description provided for @productDescriptionHint.
  ///
  /// In th, this message translates to:
  /// **'หมายเหตุสำหรับพนักงาน (ไม่แสดงบนหน้าขาย)'**
  String get productDescriptionHint;

  /// No description provided for @productFormSectionVisibility.
  ///
  /// In th, this message translates to:
  /// **'การแสดงผล'**
  String get productFormSectionVisibility;

  /// No description provided for @productSettingsOutcomeVisible.
  ///
  /// In th, this message translates to:
  /// **'แสดงบนขาย'**
  String get productSettingsOutcomeVisible;

  /// No description provided for @productSettingsOutcomeHidden.
  ///
  /// In th, this message translates to:
  /// **'ซ่อนจากขาย'**
  String get productSettingsOutcomeHidden;

  /// No description provided for @productSettingsOutcomeRecommended.
  ///
  /// In th, this message translates to:
  /// **'แนะนำ'**
  String get productSettingsOutcomeRecommended;

  /// No description provided for @productSettingsOutcomeNotRecommended.
  ///
  /// In th, this message translates to:
  /// **'ไม่แนะนำ'**
  String get productSettingsOutcomeNotRecommended;

  /// No description provided for @productRecommendedNeedsVisible.
  ///
  /// In th, this message translates to:
  /// **'สินค้าแนะนำควรเปิดแสดง — เปิดแสดงสินค้า หรือปิดแนะนำ'**
  String get productRecommendedNeedsVisible;

  /// No description provided for @saleRecommendedFilter.
  ///
  /// In th, this message translates to:
  /// **'แนะนำ'**
  String get saleRecommendedFilter;

  /// No description provided for @saleRecommendedFilterAll.
  ///
  /// In th, this message translates to:
  /// **'ทั้งหมด'**
  String get saleRecommendedFilterAll;

  /// No description provided for @productSupplierHint.
  ///
  /// In th, this message translates to:
  /// **'แหล่งที่ซื้อสินค้า (ไม่บังคับ)'**
  String get productSupplierHint;

  /// No description provided for @productOptionsSummaryTitle.
  ///
  /// In th, this message translates to:
  /// **'ตัวเลือกเพิ่ม'**
  String get productOptionsSummaryTitle;

  /// No description provided for @productOptionGroupSummary.
  ///
  /// In th, this message translates to:
  /// **'{name} · {detail} · {count} ตัวเลือก'**
  String productOptionGroupSummary(String name, String detail, int count);

  /// No description provided for @productFormCostEmptyHint.
  ///
  /// In th, this message translates to:
  /// **'ใส่ต้นทุนเพื่อดูกำไรและมาร์กอัป'**
  String get productFormCostEmptyHint;

  /// No description provided for @productFormMarkupFromCost.
  ///
  /// In th, this message translates to:
  /// **'ตั้งราคาจากต้นทุน'**
  String get productFormMarkupFromCost;

  /// No description provided for @productFormPriceChanged.
  ///
  /// In th, this message translates to:
  /// **'{from} → {to}'**
  String productFormPriceChanged(String from, String to);

  /// No description provided for @clearFieldTitle.
  ///
  /// In th, this message translates to:
  /// **'ล้างข้อความ?'**
  String get clearFieldTitle;

  /// No description provided for @clearFieldConfirm.
  ///
  /// In th, this message translates to:
  /// **'จะลบข้อความในช่องนี้ แน่ใจหรือไม่?'**
  String get clearFieldConfirm;

  /// No description provided for @deleteProductConfirmTitle.
  ///
  /// In th, this message translates to:
  /// **'ลบสินค้านี้ออกจากรายการ?'**
  String get deleteProductConfirmTitle;

  /// No description provided for @removeCartLineTitle.
  ///
  /// In th, this message translates to:
  /// **'ลบรายการนี้ออกจากบิล?'**
  String get removeCartLineTitle;

  /// No description provided for @removeCartLineQty.
  ///
  /// In th, this message translates to:
  /// **'จำนวน {count} ชิ้น'**
  String removeCartLineQty(int count);

  /// No description provided for @removeCartLineConfirm.
  ///
  /// In th, this message translates to:
  /// **'ลบรายการ'**
  String get removeCartLineConfirm;

  /// No description provided for @datePresetToday.
  ///
  /// In th, this message translates to:
  /// **'วันนี้'**
  String get datePresetToday;

  /// No description provided for @datePresetYesterday.
  ///
  /// In th, this message translates to:
  /// **'เมื่อวาน'**
  String get datePresetYesterday;

  /// No description provided for @datePresetLast7Days.
  ///
  /// In th, this message translates to:
  /// **'7 วัน'**
  String get datePresetLast7Days;

  /// No description provided for @datePresetThisMonth.
  ///
  /// In th, this message translates to:
  /// **'เดือนนี้'**
  String get datePresetThisMonth;

  /// No description provided for @datePresetCustom.
  ///
  /// In th, this message translates to:
  /// **'กำหนดเอง'**
  String get datePresetCustom;

  /// No description provided for @reportAverage.
  ///
  /// In th, this message translates to:
  /// **'เฉลี่ย'**
  String get reportAverage;

  /// No description provided for @reportRecent.
  ///
  /// In th, this message translates to:
  /// **'ล่าสุด'**
  String get reportRecent;

  /// No description provided for @paymentMethodShare.
  ///
  /// In th, this message translates to:
  /// **'{percent}%'**
  String paymentMethodShare(String percent);

  /// No description provided for @closeDayToday.
  ///
  /// In th, this message translates to:
  /// **'ปิดยอดวันนี้'**
  String get closeDayToday;

  /// No description provided for @dailyCloseSummaryTitle.
  ///
  /// In th, this message translates to:
  /// **'สรุป'**
  String get dailyCloseSummaryTitle;

  /// No description provided for @dailyCloseSalesCountLabel.
  ///
  /// In th, this message translates to:
  /// **'จำนวนบิล'**
  String get dailyCloseSalesCountLabel;

  /// No description provided for @dailyCloseVoidedCountLabel.
  ///
  /// In th, this message translates to:
  /// **'จำนวนยกเลิก'**
  String get dailyCloseVoidedCountLabel;

  /// No description provided for @dailyCloseGrossRevenue.
  ///
  /// In th, this message translates to:
  /// **'ยอดรวมก่อนหักยกเลิก'**
  String get dailyCloseGrossRevenue;

  /// No description provided for @dailyCloseVoidedAmount.
  ///
  /// In th, this message translates to:
  /// **'ยอดยกเลิก'**
  String get dailyCloseVoidedAmount;

  /// No description provided for @dailyCloseByPayment.
  ///
  /// In th, this message translates to:
  /// **'แยกตามวิธีชำระ'**
  String get dailyCloseByPayment;

  /// No description provided for @dailyCloseVatCollected.
  ///
  /// In th, this message translates to:
  /// **'ภาษีมูลค่าเพิ่ม'**
  String get dailyCloseVatCollected;

  /// No description provided for @dailyCloseDiscountsGiven.
  ///
  /// In th, this message translates to:
  /// **'ส่วนลดที่ให้'**
  String get dailyCloseDiscountsGiven;

  /// No description provided for @dailyCloseCashReconciliation.
  ///
  /// In th, this message translates to:
  /// **'กระทบยอดเงินสด'**
  String get dailyCloseCashReconciliation;

  /// No description provided for @dailyCloseOpeningCash.
  ///
  /// In th, this message translates to:
  /// **'เงินสดเปิดลิ้นชัก'**
  String get dailyCloseOpeningCash;

  /// No description provided for @dailyCloseExpectedCash.
  ///
  /// In th, this message translates to:
  /// **'เงินสดที่ควรมี'**
  String get dailyCloseExpectedCash;

  /// No description provided for @dailyCloseCountedCash.
  ///
  /// In th, this message translates to:
  /// **'เงินสดที่นับได้'**
  String get dailyCloseCountedCash;

  /// No description provided for @dailyCloseOverShort.
  ///
  /// In th, this message translates to:
  /// **'เกิน / ขาด'**
  String get dailyCloseOverShort;

  /// No description provided for @dailyCloseNoteOptional.
  ///
  /// In th, this message translates to:
  /// **'หมายเหตุ (ถ้ามี)'**
  String get dailyCloseNoteOptional;

  /// No description provided for @dailyCloseStatusOpen.
  ///
  /// In th, this message translates to:
  /// **'เปิดอยู่'**
  String get dailyCloseStatusOpen;

  /// No description provided for @dailyCloseStatusClosed.
  ///
  /// In th, this message translates to:
  /// **'ปิดแล้ว'**
  String get dailyCloseStatusClosed;

  /// No description provided for @dailyCloseStatusClosedBadge.
  ///
  /// In th, this message translates to:
  /// **'ปิดแล้ว'**
  String get dailyCloseStatusClosedBadge;

  /// No description provided for @dailyCloseStatusOpenBadge.
  ///
  /// In th, this message translates to:
  /// **'เปิด'**
  String get dailyCloseStatusOpenBadge;

  /// No description provided for @noCategoriesFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบหมวดหมู่ที่ตรงกับการค้นหา'**
  String get noCategoriesFound;

  /// No description provided for @categorySaved.
  ///
  /// In th, this message translates to:
  /// **'บันทึกหมวดหมู่แล้ว'**
  String get categorySaved;

  /// No description provided for @categoryDeleted.
  ///
  /// In th, this message translates to:
  /// **'ลบหมวดหมู่แล้ว'**
  String get categoryDeleted;

  /// No description provided for @categoriesDeleted.
  ///
  /// In th, this message translates to:
  /// **'ลบ {count} หมวดหมู่แล้ว'**
  String categoriesDeleted(int count);

  /// No description provided for @categoryReorderHint.
  ///
  /// In th, this message translates to:
  /// **'ลากเพื่อจัดลำดับหมวดหมู่ที่แสดงบนหน้าขาย'**
  String get categoryReorderHint;

  /// No description provided for @deleteCategoryProductsImpact.
  ///
  /// In th, this message translates to:
  /// **'สินค้า {count} รายการจะถูกย้ายไปหมวดหมู่ที่เลือก (หรือไม่มีหมวดหมู่)'**
  String deleteCategoryProductsImpact(int count);

  /// No description provided for @categoryNameTooLong.
  ///
  /// In th, this message translates to:
  /// **'ชื่อต้องไม่เกิน 100 ตัวอักษร'**
  String get categoryNameTooLong;

  /// No description provided for @goToSale.
  ///
  /// In th, this message translates to:
  /// **'ไปหน้าขาย'**
  String get goToSale;

  /// No description provided for @closeDayForDate.
  ///
  /// In th, this message translates to:
  /// **'ปิดยอดวันที่ {date}'**
  String closeDayForDate(String date);

  /// No description provided for @reportNoSalesInPeriod.
  ///
  /// In th, this message translates to:
  /// **'ไม่มียอดขายในช่วงนี้'**
  String get reportNoSalesInPeriod;

  /// No description provided for @currentBill.
  ///
  /// In th, this message translates to:
  /// **'บิลปัจจุบัน'**
  String get currentBill;

  /// No description provided for @currentBillWithCount.
  ///
  /// In th, this message translates to:
  /// **'บิล ({count})'**
  String currentBillWithCount(int count);

  /// No description provided for @viewBill.
  ///
  /// In th, this message translates to:
  /// **'บิล'**
  String get viewBill;

  /// No description provided for @viewBillWithCount.
  ///
  /// In th, this message translates to:
  /// **'บิล ({count})'**
  String viewBillWithCount(int count);

  /// No description provided for @draftNotFound.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบบิลเปิด'**
  String get draftNotFound;

  /// No description provided for @maxDraftsReached.
  ///
  /// In th, this message translates to:
  /// **'บิลเปิดครบจำนวนสูงสุด ({count})'**
  String maxDraftsReached(int count);

  /// No description provided for @addToCart.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มลงตะกร้า'**
  String get addToCart;

  /// No description provided for @holdCurrentBill.
  ///
  /// In th, this message translates to:
  /// **'พักบิลนี้'**
  String get holdCurrentBill;

  /// No description provided for @newBill.
  ///
  /// In th, this message translates to:
  /// **'บิลใหม่'**
  String get newBill;

  /// No description provided for @billHeld.
  ///
  /// In th, this message translates to:
  /// **'บันทึกบิลแล้ว'**
  String get billHeld;

  /// No description provided for @newBillConfirm.
  ///
  /// In th, this message translates to:
  /// **'บันทึกบิลปัจจุบันแล้วเริ่มบิลว่างใหม่?'**
  String get newBillConfirm;

  /// No description provided for @newBillStarted.
  ///
  /// In th, this message translates to:
  /// **'เริ่มบิลใหม่แล้ว'**
  String get newBillStarted;

  /// No description provided for @voidBlockedDayClosed.
  ///
  /// In th, this message translates to:
  /// **'ปิดยอดแล้ว เปิดวันก่อนเพื่อยกเลิกบิลนี้'**
  String get voidBlockedDayClosed;

  /// No description provided for @billParked.
  ///
  /// In th, this message translates to:
  /// **'พักบิลแล้ว — พร้อมลูกค้าถัดไป'**
  String get billParked;

  /// No description provided for @receiptThankYouDefault.
  ///
  /// In th, this message translates to:
  /// **'ขอบคุณครับ/ค่ะ!'**
  String get receiptThankYouDefault;

  /// No description provided for @receiptNotTaxInvoice.
  ///
  /// In th, this message translates to:
  /// **'ใบเสร็จการขาย — ไม่ใช่ใบกำกับภาษี'**
  String get receiptNotTaxInvoice;

  /// No description provided for @receiptReprint.
  ///
  /// In th, this message translates to:
  /// **'พิมพ์ซ้ำ'**
  String get receiptReprint;

  /// No description provided for @receiptShareVoidBlocked.
  ///
  /// In th, this message translates to:
  /// **'ไม่สามารถแชร์บิลที่ยกเลิกเป็นใบเสร็จปกติได้ — พิมพ์จะมีเครื่องหมายยกเลิก'**
  String get receiptShareVoidBlocked;

  /// No description provided for @parkBill.
  ///
  /// In th, this message translates to:
  /// **'พักบิล'**
  String get parkBill;

  /// No description provided for @parkBillNameTitle.
  ///
  /// In th, this message translates to:
  /// **'ตั้งชื่อบิล (ไม่บังคับ)'**
  String get parkBillNameTitle;

  /// No description provided for @currentBillNamed.
  ///
  /// In th, this message translates to:
  /// **'{name} ({count})'**
  String currentBillNamed(String name, int count);

  /// No description provided for @amountDue.
  ///
  /// In th, this message translates to:
  /// **'ยอดชำระ'**
  String get amountDue;

  /// No description provided for @payAmount.
  ///
  /// In th, this message translates to:
  /// **'ชำระ {amount}'**
  String payAmount(String amount);

  /// No description provided for @parkAndNext.
  ///
  /// In th, this message translates to:
  /// **'พักแล้วคิวถัดไป'**
  String get parkAndNext;

  /// No description provided for @openBillsCount.
  ///
  /// In th, this message translates to:
  /// **'บิลเปิด ({count})'**
  String openBillsCount(int count);

  /// No description provided for @billItemsMissing.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบ {count} รายการ (สินค้าอาจถูกลบ)'**
  String billItemsMissing(int count);

  /// No description provided for @splitTenderTitle.
  ///
  /// In th, this message translates to:
  /// **'แบ่งชำระ (เงินสด + อื่น)'**
  String get splitTenderTitle;

  /// No description provided for @splitTenderSubtitle.
  ///
  /// In th, this message translates to:
  /// **'จ่ายบางส่วนเงินสด ที่เหลือโอน/QR/บัตร'**
  String get splitTenderSubtitle;

  /// No description provided for @splitCashAmount.
  ///
  /// In th, this message translates to:
  /// **'จำนวนเงินสด'**
  String get splitCashAmount;

  /// No description provided for @paymentMismatch.
  ///
  /// In th, this message translates to:
  /// **'ยอดชำระไม่ตรงกับยอดบิล'**
  String get paymentMismatch;

  /// No description provided for @paymentMixed.
  ///
  /// In th, this message translates to:
  /// **'แบ่งชำระ'**
  String get paymentMixed;

  /// No description provided for @promptPayShareTitle.
  ///
  /// In th, this message translates to:
  /// **'ส่วน PromptPay'**
  String get promptPayShareTitle;

  /// No description provided for @promptPayShareHint.
  ///
  /// In th, this message translates to:
  /// **'สแกนเฉพาะส่วน PromptPay (ไม่ใช่ยอดบิลเต็ม)'**
  String get promptPayShareHint;

  /// No description provided for @promptPayFullBillTitle.
  ///
  /// In th, this message translates to:
  /// **'ชำระด้วย PromptPay'**
  String get promptPayFullBillTitle;

  /// No description provided for @settingsAttentionItemsCount.
  ///
  /// In th, this message translates to:
  /// **'มี {count} รายการที่ควรตั้งค่า'**
  String settingsAttentionItemsCount(int count);

  /// No description provided for @settingsAttentionShopTitle.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่าข้อมูลร้านให้ครบ'**
  String get settingsAttentionShopTitle;

  /// No description provided for @settingsAttentionShopBody.
  ///
  /// In th, this message translates to:
  /// **'ใส่ชื่อร้านและเบอร์โทรเพื่อใบเสร็จที่ถูกต้อง'**
  String get settingsAttentionShopBody;

  /// No description provided for @settingsAttentionPromptpayTitle.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่าพร้อมเพย์'**
  String get settingsAttentionPromptpayTitle;

  /// No description provided for @settingsAttentionPromptpayBody.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มเลขพร้อมเพย์เพื่อแสดง QR ตอนชำระเงิน'**
  String get settingsAttentionPromptpayBody;

  /// No description provided for @settingsAttentionReview.
  ///
  /// In th, this message translates to:
  /// **'ดูรายการ'**
  String get settingsAttentionReview;

  /// No description provided for @settingsDayClose.
  ///
  /// In th, this message translates to:
  /// **'ปิดวัน'**
  String get settingsDayClose;

  /// No description provided for @settingsBackupData.
  ///
  /// In th, this message translates to:
  /// **'สำรองและข้อมูล'**
  String get settingsBackupData;

  /// No description provided for @settingsPreview.
  ///
  /// In th, this message translates to:
  /// **'ตัวอย่าง{section}'**
  String settingsPreview(String section);

  /// No description provided for @settingsModeLabel.
  ///
  /// In th, this message translates to:
  /// **'โหมด'**
  String get settingsModeLabel;

  /// No description provided for @settingsCatalogMode.
  ///
  /// In th, this message translates to:
  /// **'แคตตาล็อก'**
  String get settingsCatalogMode;

  /// No description provided for @shopNamePlaceholder.
  ///
  /// In th, this message translates to:
  /// **'ชื่อร้านของคุณ'**
  String get shopNamePlaceholder;

  /// No description provided for @shopAddressPlaceholder.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ได้ตั้งที่อยู่'**
  String get shopAddressPlaceholder;

  /// No description provided for @shopPhonePlaceholder.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ได้ตั้งเบอร์โทร'**
  String get shopPhonePlaceholder;

  /// No description provided for @settingsDetails.
  ///
  /// In th, this message translates to:
  /// **'รายละเอียด'**
  String get settingsDetails;

  /// No description provided for @settingsPolicy.
  ///
  /// In th, this message translates to:
  /// **'นโยบาย'**
  String get settingsPolicy;

  /// No description provided for @settingsOn.
  ///
  /// In th, this message translates to:
  /// **'เปิด'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In th, this message translates to:
  /// **'ปิด'**
  String get settingsOff;

  /// No description provided for @cartPaymentInProgress.
  ///
  /// In th, this message translates to:
  /// **'กำลังชำระเงิน — ล็อกตะกร้าจนกว่าจะเสร็จหรือยกเลิก'**
  String get cartPaymentInProgress;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In th, this message translates to:
  /// **'กู้คืนสำรอง (เครื่องนี้เท่านั้น)'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In th, this message translates to:
  /// **'กู้คืนสำรองข้อมูล?'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmMessage.
  ///
  /// In th, this message translates to:
  /// **'จะแทนที่ฐานข้อมูลปัจจุบันบนเครื่องนี้ ระบบจะเก็บสำเนาก่อนกู้คืน หลังกู้คืนให้ปิดแอปแล้วเปิดใหม่ ใช้ได้เฉพาะเครื่องเดิม (คีย์ SQLCipher ต้องยังอยู่)'**
  String get backupRestoreConfirmMessage;

  /// No description provided for @backupRestoreSuccess.
  ///
  /// In th, this message translates to:
  /// **'กู้คืนสำเร็จ กรุณาปิดแอปให้สนิทแล้วเปิดใหม่'**
  String get backupRestoreSuccess;

  /// No description provided for @backupRestorePlainUnsupported.
  ///
  /// In th, this message translates to:
  /// **'ไม่รองรับไฟล์ SQLite แบบไม่เข้ารหัส ใช้ไฟล์ที่ส่งออกจากแอปนี้'**
  String get backupRestorePlainUnsupported;

  /// No description provided for @backupRestoreInvalid.
  ///
  /// In th, this message translates to:
  /// **'ไฟล์สำรองไม่ถูกต้อง'**
  String get backupRestoreInvalid;

  /// No description provided for @backupRestoreSourceMissing.
  ///
  /// In th, this message translates to:
  /// **'ไม่พบไฟล์สำรอง'**
  String get backupRestoreSourceMissing;

  /// No description provided for @backupConfirmExportTitle.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันการส่งออกสำรอง'**
  String get backupConfirmExportTitle;

  /// No description provided for @backupConfirmRestoreTitle.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันการกู้คืนสำรอง'**
  String get backupConfirmRestoreTitle;

  /// No description provided for @appLockTitle.
  ///
  /// In th, this message translates to:
  /// **'ล็อก PIN ร้าน'**
  String get appLockTitle;

  /// No description provided for @appLockSubtitle.
  ///
  /// In th, this message translates to:
  /// **'ป้องกันการยกเลิกบิล สำรองข้อมูล และแก้ PromptPay'**
  String get appLockSubtitle;

  /// No description provided for @appLockSectionTitle.
  ///
  /// In th, this message translates to:
  /// **'การกระทำที่เสี่ยง'**
  String get appLockSectionTitle;

  /// No description provided for @appLockRequirePin.
  ///
  /// In th, this message translates to:
  /// **'ต้องใช้ PIN ร้าน'**
  String get appLockRequirePin;

  /// No description provided for @appLockRequirePinHint.
  ///
  /// In th, this message translates to:
  /// **'เมื่อเปิด ระบบจะขอ PIN ก่อนยกเลิกบิล ส่งออก/กู้คืนสำรอง และแก้ PromptPay (ผ่อนผัน {minutes} นาที)'**
  String appLockRequirePinHint(int minutes);

  /// No description provided for @appLockCreatePin.
  ///
  /// In th, this message translates to:
  /// **'สร้าง PIN ร้าน'**
  String get appLockCreatePin;

  /// No description provided for @appLockEnterPin.
  ///
  /// In th, this message translates to:
  /// **'กรอก PIN ร้าน'**
  String get appLockEnterPin;

  /// No description provided for @appLockConfirmPin.
  ///
  /// In th, this message translates to:
  /// **'ยืนยัน PIN'**
  String get appLockConfirmPin;

  /// No description provided for @appLockPinLabel.
  ///
  /// In th, this message translates to:
  /// **'PIN'**
  String get appLockPinLabel;

  /// No description provided for @appLockUnlock.
  ///
  /// In th, this message translates to:
  /// **'ปลดล็อก'**
  String get appLockUnlock;

  /// No description provided for @appLockEnabled.
  ///
  /// In th, this message translates to:
  /// **'เปิดใช้ PIN ร้านแล้ว'**
  String get appLockEnabled;

  /// No description provided for @appLockDisabled.
  ///
  /// In th, this message translates to:
  /// **'ปิด PIN ร้านแล้ว'**
  String get appLockDisabled;

  /// No description provided for @appLockEnableFailed.
  ///
  /// In th, this message translates to:
  /// **'เปิดใช้ PIN ไม่สำเร็จ'**
  String get appLockEnableFailed;

  /// No description provided for @appLockDisableNeedsPin.
  ///
  /// In th, this message translates to:
  /// **'ต้องใช้ PIN เพื่อปิด'**
  String get appLockDisableNeedsPin;

  /// No description provided for @appLockPinTooShort.
  ///
  /// In th, this message translates to:
  /// **'PIN ต้องมีอย่างน้อย {min} หลัก'**
  String appLockPinTooShort(int min);

  /// No description provided for @appLockIncorrectPin.
  ///
  /// In th, this message translates to:
  /// **'PIN ไม่ถูกต้อง'**
  String get appLockIncorrectPin;

  /// No description provided for @appLockActionRequired.
  ///
  /// In th, this message translates to:
  /// **'ต้องใช้ PIN ร้าน'**
  String get appLockActionRequired;

  /// No description provided for @appLockConfirmVoid.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันยกเลิกบิลด้วย PIN ร้าน'**
  String get appLockConfirmVoid;

  /// No description provided for @appLockConfirmPromptPay.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันการเปลี่ยน PromptPay'**
  String get appLockConfirmPromptPay;

  /// No description provided for @appLockPinsMismatch.
  ///
  /// In th, this message translates to:
  /// **'PIN ไม่ตรงกัน'**
  String get appLockPinsMismatch;
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
