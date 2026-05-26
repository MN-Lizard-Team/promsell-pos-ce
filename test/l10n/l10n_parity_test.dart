import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/l10n/app_localizations_en.dart';
import 'package:promsell_pos_ce/l10n/app_localizations_th.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations th;

  setUp(() {
    en = AppLocalizationsEn();
    th = AppLocalizationsTh();
  });

  group('L10n parity', () {
    test('supported locales include en and th', () {
      final codes =
          AppLocalizations.supportedLocales.map((l) => l.languageCode).toList();
      expect(codes, contains('en'));
      expect(codes, contains('th'));
    });

    test('all simple getters return non-empty strings for EN', () {
      final values = _allSimpleGetters(en);
      for (final entry in values.entries) {
        expect(entry.value, isNotEmpty,
            reason: 'EN key "${entry.key}" is empty');
      }
    });

    test('all simple getters return non-empty strings for TH', () {
      final values = _allSimpleGetters(th);
      for (final entry in values.entries) {
        expect(entry.value, isNotEmpty,
            reason: 'TH key "${entry.key}" is empty');
      }
    });

    test('EN and TH have identical key sets', () {
      final enKeys = _allSimpleGetters(en).keys.toSet();
      final thKeys = _allSimpleGetters(th).keys.toSet();
      expect(enKeys, thKeys);
    });

    test('parameterized messages return non-empty for EN', () {
      expect(en.checkout(1), isNotEmpty);
      expect(en.receivedAmount('฿'), isNotEmpty);
      expect(en.stockLabel(10), isNotEmpty);
      expect(en.confirmDeleteProduct('X'), isNotEmpty);
      expect(en.priceLabel('฿'), isNotEmpty);
      expect(en.noteLabel('test'), isNotEmpty);
      expect(en.salesCount(5), isNotEmpty);
      expect(en.units(3), isNotEmpty);
    });

    test('parameterized messages return non-empty for TH', () {
      expect(th.checkout(1), isNotEmpty);
      expect(th.receivedAmount('฿'), isNotEmpty);
      expect(th.stockLabel(10), isNotEmpty);
      expect(th.confirmDeleteProduct('X'), isNotEmpty);
      expect(th.priceLabel('฿'), isNotEmpty);
      expect(th.noteLabel('test'), isNotEmpty);
      expect(th.salesCount(5), isNotEmpty);
      expect(th.units(3), isNotEmpty);
    });

    test('EN and TH differ for locale-specific keys', () {
      expect(en.navSale, isNot(th.navSale));
      expect(en.navProducts, isNot(th.navProducts));
      expect(en.navHistory, isNot(th.navHistory));
      expect(en.navSettings, isNot(th.navSettings));
      expect(en.cash, isNot(th.cash));
      expect(en.transfer, isNot(th.transfer));
      expect(en.save, isNot(th.save));
    });
  });
}

Map<String, String> _allSimpleGetters(AppLocalizations l) => {
      'appTitle': l.appTitle,
      'navSale': l.navSale,
      'navProducts': l.navProducts,
      'navHistory': l.navHistory,
      'navReport': l.navReport,
      'navSettings': l.navSettings,
      'salePageTitle': l.salePageTitle,
      'clearCart': l.clearCart,
      'confirmClearCart': l.confirmClearCart,
      'cartTitle': l.cartTitle,
      'allCategories': l.allCategories,
      'saleSearchProducts': l.saleSearchProducts,
      'quickCashExact': l.quickCashExact,
      'noProducts': l.noProducts,
      'saleSavedSuccess': l.saleSavedSuccess,
      'tapProductToAdd': l.tapProductToAdd,
      'cartTotal': l.cartTotal,
      'paymentTitle': l.paymentTitle,
      'totalAmount': l.totalAmount,
      'cash': l.cash,
      'transfer': l.transfer,
      'card': l.card,
      'change': l.change,
      'confirmPayment': l.confirmPayment,
      'notePlaceholder': l.notePlaceholder,
      'saleError': l.saleError,
      'productsTitle': l.productsTitle,
      'searchProducts': l.searchProducts,
      'noProductsYet': l.noProductsYet,
      'errorOccurred': l.errorOccurred,
      'noCategory': l.noCategory,
      'edit': l.edit,
      'delete': l.delete,
      'deleteProduct': l.deleteProduct,
      'cancel': l.cancel,
      'addProduct': l.addProduct,
      'editProductTitle': l.editProductTitle,
      'productNameLabel': l.productNameLabel,
      'productNameRequired': l.productNameRequired,
      'priceRequired': l.priceRequired,
      'invalidPrice': l.invalidPrice,
      'quantityLabel': l.quantityLabel,
      'quantityRequired': l.quantityRequired,
      'invalidQuantity': l.invalidQuantity,
      'categoryLabel': l.categoryLabel,
      'showProduct': l.showProduct,
      'save': l.save,
      'historyTitle': l.historyTitle,
      'noSalesYet': l.noSalesYet,
      'reportTitle': l.reportTitle,
      'totalRevenue': l.totalRevenue,
      'byPaymentMethod': l.byPaymentMethod,
      'topProducts': l.topProducts,
      'settingsTitle': l.settingsTitle,
      'settingsGeneral': l.settingsGeneral,
      'settingsLanguage': l.settingsLanguage,
      'settingsTheme': l.settingsTheme,
      'settingsThemeLight': l.settingsThemeLight,
      'settingsThemeDark': l.settingsThemeDark,
      'settingsThemeSystem': l.settingsThemeSystem,
      'settingsShopInfo': l.settingsShopInfo,
      'settingsShopName': l.settingsShopName,
      'settingsAddress': l.settingsAddress,
      'settingsPhone': l.settingsPhone,
      'settingsSales': l.settingsSales,
      'settingsCurrency': l.settingsCurrency,
      'settingsDateFormat': l.settingsDateFormat,
      'settingsReceipt': l.settingsReceipt,
      'settingsReceiptNote': l.settingsReceiptNote,
      'settingsShowShopInfo': l.settingsShowShopInfo,
      'settingsSaved': l.settingsSaved,
      'langThai': l.langThai,
      'langEnglish': l.langEnglish,
    };
