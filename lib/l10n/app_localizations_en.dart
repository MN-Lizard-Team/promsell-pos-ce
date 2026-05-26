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
  String get tapProductToAdd => 'Tap a product to add to cart';

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
  String get receivedAmount => 'Amount received (฿)';

  @override
  String get change => 'Change';

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String get notePlaceholder => 'Note (optional)';

  @override
  String get saleError => 'Failed to save sale';

  @override
  String get productsTitle => 'Products';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get noProductsYet => 'No products yet';

  @override
  String get errorOccurred => 'An error occurred';

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
  String get priceLabel => 'Price (฿) *';

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
}
