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

  /// No description provided for @tapProductToAdd.
  ///
  /// In th, this message translates to:
  /// **'แตะสินค้าเพื่อเพิ่มลงตะกร้า'**
  String get tapProductToAdd;

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
  /// **'รับเงินมา (฿)'**
  String get receivedAmount;

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

  /// No description provided for @saleError.
  ///
  /// In th, this message translates to:
  /// **'บันทึกการขายไม่สำเร็จ'**
  String get saleError;

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
  /// **'ราคา (฿) *'**
  String get priceLabel;

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
