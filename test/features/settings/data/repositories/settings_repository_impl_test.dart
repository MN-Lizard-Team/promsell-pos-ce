import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/receipt_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/ui_config.dart';

class MockSettingsLocalDatasource extends Mock
    implements SettingsLocalDatasource {}

void main() {
  group('SettingsRepositoryImpl', () {
    late MockSettingsLocalDatasource mockDatasource;
    late SettingsRepositoryImpl repo;

    setUp(() {
      mockDatasource = MockSettingsLocalDatasource();
      repo = SettingsRepositoryImpl(mockDatasource);
    });

    test('load returns defaults when datasource is empty', () async {
      when(() => mockDatasource.getAll()).thenAnswer((_) async => {});

      final settings = await repo.load();

      expect(settings.uiConfig.locale, 'th');
      expect(settings.uiConfig.themeMode, 'system');
      expect(settings.shopInfo.name, '');
      expect(settings.paymentConfig.currency, '฿');
      expect(settings.receiptConfig.showShopInfo, isTrue);
      expect(settings.receiptConfig.autoPrintPrompt, isTrue);
      expect(settings.taxConfig.vatRate, 7.0);
      expect(settings.taxConfig.vatMode, 'NONE');
      expect(settings.receiptConfig.receiptPreviewStyle, 'thermal');
      expect(settings.receiptConfig.showPreSalePreview, isTrue);
      expect(settings.receiptConfig.showPostSalePreview, isTrue);
    });

    test('load returns saved values from datasource', () async {
      when(() => mockDatasource.getAll()).thenAnswer(
        (_) async => {
          'locale': 'en',
          'theme': 'dark',
          'shopName': 'My Shop',
          'currency': '\$',
          'showShopInfo': 'false',
        },
      );

      final settings = await repo.load();

      expect(settings.uiConfig.locale, 'en');
      expect(settings.uiConfig.themeMode, 'dark');
      expect(settings.shopInfo.name, 'My Shop');
      expect(settings.paymentConfig.currency, '\$');
      expect(settings.receiptConfig.showShopInfo, isFalse);
      expect(settings.receiptConfig.autoPrintPrompt, isTrue);
      expect(settings.taxConfig.vatRate, 7.0);
      expect(settings.taxConfig.vatMode, 'NONE');
      expect(settings.receiptConfig.receiptPreviewStyle, 'thermal');
      expect(settings.receiptConfig.showPreSalePreview, isTrue);
      expect(settings.receiptConfig.showPostSalePreview, isTrue);
    });

    test('save persists all settings to datasource via setAll', () async {
      when(() => mockDatasource.setAll(any())).thenAnswer((_) async {});

      final settings = const Settings(
        shopInfo: ShopInfo(
          name: 'Test Shop',
          address: '123 Street',
          phone: '0812345678',
        ),
        receiptConfig: ReceiptConfig(
          receiptSize: '80mm',
          receiptPreviewStyle: 'card',
          receiptNote: 'Thank you!',
          showShopInfo: false,
          autoPrintPrompt: false,
          showPreSalePreview: false,
          showPostSalePreview: false,
        ),
        taxConfig: TaxConfig(vatRate: 10.0, vatMode: 'INCLUSIVE'),
        paymentConfig: PaymentConfig(currency: '\$'),
        uiConfig: UiConfig(
          locale: 'en',
          themeMode: 'light',
          dateFormat: 'yyyy-MM-dd',
        ),
      );

      await repo.save(settings);

      final captured =
          verify(() => mockDatasource.setAll(captureAny())).captured.single
              as Map<String, String>;
      expect(captured['locale'], 'en');
      expect(captured['theme'], 'light');
      expect(captured['shopName'], 'Test Shop');
      expect(captured['address'], '123 Street');
      expect(captured['phone'], '0812345678');
      expect(captured['currency'], '\$');
      expect(captured['dateFormat'], 'yyyy-MM-dd');
      expect(captured['receiptNote'], 'Thank you!');
      expect(captured['showShopInfo'], 'false');
      expect(captured['autoPrintPrompt'], 'false');
      expect(captured['vatRate'], '10.0');
      expect(captured['vatMode'], 'INCLUSIVE');
      expect(captured['receiptPreviewStyle'], 'card');
      expect(captured['showPreSalePreview'], 'false');
      expect(captured['showPostSalePreview'], 'false');
    });

    test('load normalizes invalid theme string to system', () async {
      when(
        () => mockDatasource.getAll(),
      ).thenAnswer((_) async => {'theme': 'invalid'});

      final settings = await repo.load();

      expect(settings.uiConfig.themeMode, 'system');
    });

    test('load converts legacy theme index 2 to system', () async {
      when(
        () => mockDatasource.getAll(),
      ).thenAnswer((_) async => {'theme': '2'});

      final settings = await repo.load();

      expect(settings.uiConfig.themeMode, 'system');
    });

    test('load converts legacy theme index 0 to light', () async {
      when(
        () => mockDatasource.getAll(),
      ).thenAnswer((_) async => {'theme': '0'});

      final settings = await repo.load();

      expect(settings.uiConfig.themeMode, 'light');
    });
  });
}
