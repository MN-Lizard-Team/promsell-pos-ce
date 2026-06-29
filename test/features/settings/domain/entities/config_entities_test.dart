import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/receipt_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/ui_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/image_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/draft_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/barcode_config.dart';

void main() {
  group('ReceiptConfig', () {
    test('has default values', () {
      const config = ReceiptConfig();
      expect(config.receiptSize, '80mm');
      expect(config.receiptPreviewStyle, 'thermal');
      expect(config.showShopInfo, isTrue);
      expect(config.autoPrintPrompt, isTrue);
    });

    test('copyWith updates fields', () {
      const config = ReceiptConfig();
      final updated = config.copyWith(
        receiptNote: 'Thank you',
        showShopInfo: false,
      );
      expect(updated.receiptNote, 'Thank you');
      expect(updated.showShopInfo, isFalse);
    });
  });

  group('StockConfig', () {
    test('has default values', () {
      const config = StockConfig();
      expect(config.allowOversell, isFalse);
      expect(config.lowStockThreshold, 5);
    });

    test('copyWith updates fields', () {
      const config = StockConfig();
      final updated = config.copyWith(
        allowOversell: true,
        lowStockThreshold: 3,
      );
      expect(updated.allowOversell, isTrue);
      expect(updated.lowStockThreshold, 3);
    });
  });

  group('UiConfig', () {
    test('has default values', () {
      const config = UiConfig();
      expect(config.locale, 'th');
      expect(config.themeMode, 'system');
      expect(config.cartCompactMode, isTrue);
    });

    test('copyWith updates fields', () {
      const config = UiConfig();
      final updated = config.copyWith(locale: 'en', themeMode: 'dark');
      expect(updated.locale, 'en');
      expect(updated.themeMode, 'dark');
    });
  });

  group('ImageConfig', () {
    test('has default values', () {
      const config = ImageConfig();
      expect(config.maxWidth, 800);
      expect(config.quality, 80);
    });

    test('copyWith updates fields', () {
      const config = ImageConfig();
      final updated = config.copyWith(maxWidth: 1200, quality: 90);
      expect(updated.maxWidth, 1200);
      expect(updated.quality, 90);
    });
  });

  group('DraftConfig', () {
    test('has default values', () {
      const config = DraftConfig();
      expect(config.maxDrafts, 30);
    });

    test('copyWith updates fields', () {
      const config = DraftConfig();
      final updated = config.copyWith(maxDrafts: 20);
      expect(updated.maxDrafts, 20);
    });
  });

  group('BarcodeConfig', () {
    test('has default values', () {
      const config = BarcodeConfig();
      expect(config.scanEnabled, isTrue);
      expect(config.beepOnScan, isTrue);
      expect(config.autoGeneratePrefix, '200');
    });

    test('copyWith updates fields', () {
      const config = BarcodeConfig();
      final updated = config.copyWith(scanEnabled: false, lastCounter: 100);
      expect(updated.scanEnabled, isFalse);
      expect(updated.lastCounter, 100);
    });
  });
}
