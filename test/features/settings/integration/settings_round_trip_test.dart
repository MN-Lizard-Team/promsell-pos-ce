import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/backup_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/barcode_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/draft_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/image_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/receipt_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/ui_config.dart';

/// In-memory fake of [SettingsLocalDatasource].
///
/// Stores all values as strings in a simple [Map], mirroring the real
/// Drift-backed implementation which persists everything as text rows.
class FakeSettingsLocalDatasource implements SettingsLocalDatasource {
  final Map<String, String> _store = {};

  @override
  Future<String?> getString(String key) async => _store[key];

  @override
  Future<int?> getInt(String key) async {
    final raw = _store[key];
    return raw == null ? null : int.tryParse(raw);
  }

  @override
  Future<bool?> getBool(String key) async {
    final raw = _store[key];
    if (raw == null) return null;
    return raw == 'true' || raw == '1';
  }

  @override
  Future<double?> getDouble(String key) async {
    final raw = _store[key];
    return raw == null ? null : double.tryParse(raw);
  }

  @override
  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> setInt(String key, int value) =>
      setString(key, value.toString());

  @override
  Future<void> setBool(String key, bool value) =>
      setString(key, value.toString());

  @override
  Future<void> setDouble(String key, double value) =>
      setString(key, value.toString());

  @override
  Future<Map<String, String>> getAll() async => Map.of(_store);

  @override
  Future<void> setAll(Map<String, String> values) async {
    _store.addAll(values);
  }
}

void main() {
  group('Settings round-trip integration', () {
    late FakeSettingsLocalDatasource datasource;
    late SettingsRepositoryImpl repo;

    setUp(() {
      datasource = FakeSettingsLocalDatasource();
      repo = SettingsRepositoryImpl(datasource);
    });

    test('round-trip with default Settings preserves all defaults', () async {
      const settings = Settings();

      await repo.save(settings);
      final loaded = await repo.load();

      expect(loaded, equals(settings));
      expect(loaded.shopInfo, equals(const ShopInfo()));
      expect(loaded.receiptConfig, equals(const ReceiptConfig()));
      expect(loaded.taxConfig, equals(const TaxConfig()));
      expect(loaded.paymentConfig, equals(const PaymentConfig()));
      expect(loaded.uiConfig, equals(const UiConfig()));
      expect(loaded.stockConfig, equals(const StockConfig()));
      expect(loaded.imageConfig, equals(const ImageConfig()));
      expect(loaded.draftConfig, equals(const DraftConfig()));
      expect(loaded.backupConfig, equals(const BackupConfig()));
      expect(loaded.barcodeConfig, equals(const BarcodeConfig()));
    });

    test('round-trip with custom values preserves every field', () async {
      const settings = Settings(
        shopInfo: ShopInfo(name: 'Test Shop'),
        paymentConfig: PaymentConfig(
          currency: '\$',
          promptpayId: '0812345678',
          billerId: '1100701367081',
        ),
        taxConfig: TaxConfig(vatRate: 10.0, vatMode: 'INCLUSIVE'),
        receiptConfig: ReceiptConfig(
          receiptSize: 'A4',
          receiptNote: 'Thanks!',
          showShopInfo: false,
        ),
        stockConfig: StockConfig(lowStockThreshold: 10, allowOversell: true),
        uiConfig: UiConfig(locale: 'en', themeMode: 'dark'),
        imageConfig: ImageConfig(maxWidth: 1024, quality: 90),
        draftConfig: DraftConfig(maxDrafts: 50),
        backupConfig: BackupConfig(reminderDays: 14),
        barcodeConfig: BarcodeConfig(scanEnabled: false),
      );

      // Sanity: biller ID must pass checksum validation.
      expect(settings.paymentConfig.isBillerIdValid, isTrue);

      await repo.save(settings);
      final loaded = await repo.load();

      expect(loaded.shopName, 'Test Shop');
      expect(loaded.currency, '\$');
      expect(loaded.vatRate, 10.0);
      expect(loaded.vatMode, 'INCLUSIVE');
      expect(loaded.receiptSize, 'A4');
      expect(loaded.receiptNote, 'Thanks!');
      expect(loaded.showShopInfoOnReceipt, isFalse);
      expect(loaded.localeCode, 'en');
      expect(loaded.themeModeName, 'dark');
      expect(loaded.promptpayId, '0812345678');
      expect(loaded.billerId, '1100701367081');
      expect(loaded.lowStockThreshold, 10);
      expect(loaded.allowOversell, isTrue);
      expect(loaded.imageMaxWidth, 1024);
      expect(loaded.imageQuality, 90);
      expect(loaded.maxDrafts, 50);
      expect(loaded.ultraCompactMode, isFalse);
      expect(loaded.backupReminderDays, 14);
      expect(loaded.barcodeScanEnabled, isFalse);
    });

    test(
      'legacy snake_case keys are migrated to canonical values on load',
      () async {
        // Write legacy keys directly to the datasource (simulating an old seed).
        await datasource.setAll({
          SettingsMapperKeys.legacyShopName: 'Legacy Shop',
          SettingsMapperKeys.legacyVatRate: '15.0',
          SettingsMapperKeys.legacyVatMode: 'EXCLUSIVE',
          SettingsMapperKeys.legacyCurrency: 'USD',
          SettingsMapperKeys.legacyReceiptNote: 'Legacy Footer',
        });

        final loaded = await repo.load();

        expect(loaded.shopName, 'Legacy Shop');
        expect(loaded.vatRate, 15.0);
        expect(loaded.vatMode, 'EXCLUSIVE');
        expect(loaded.currency, 'USD');
        expect(loaded.receiptNote, 'Legacy Footer');
      },
    );

    test(
      'VAT rate is clamped to maxVatRate through copyWith on save',
      () async {
        // TaxConfig.copyWith clamps vatRate into [0, maxVatRate].
        // Settings.copyWith delegates to taxConfig.copyWith, so the value
        // is sanitized *before* it reaches the mapper/repository.
        final settings = const Settings().copyWith(vatRate: 100.0);

        expect(settings.vatRate, TaxConfig.maxVatRate);

        await repo.save(settings);
        final loaded = await repo.load();

        expect(loaded.vatRate, TaxConfig.maxVatRate);
      },
    );

    test('partial counter writes are preserved across a full load', () async {
      // Save a baseline settings document first.
      await repo.save(const Settings());

      // Patch only the counters (as the barcode/SKU generators do).
      await repo.saveBarcodeLastCounter(42);
      await repo.saveSkuLastCounter(99);

      final loaded = await repo.load();

      expect(loaded.barcodeLastCounter, 42);
      expect(loaded.skuLastCounter, 99);
    });
  });
}
