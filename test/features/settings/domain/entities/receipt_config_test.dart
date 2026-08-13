import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/receipt_config.dart';

void main() {
  group('ReceiptConfig', () {
    test('has default values', () {
      const config = ReceiptConfig();
      expect(config.receiptSize, '80mm');
      expect(config.receiptPreviewStyle, 'thermal');
      expect(config.receiptNote, '');
      expect(config.showShopInfo, isTrue);
      expect(config.showPreSalePreview, isTrue);
      expect(config.showPostSalePreview, isTrue);
    });

    test('copyWith updates only the provided fields', () {
      const config = ReceiptConfig();
      final updated = config.copyWith(
        receiptSize: '58mm',
        receiptNote: 'Thank you',
        showShopInfo: false,
      );

      expect(updated.receiptSize, '58mm');
      expect(updated.receiptNote, 'Thank you');
      expect(updated.showShopInfo, isFalse);
      // Untouched fields keep their original values.
      expect(updated.receiptPreviewStyle, 'thermal');
      expect(updated.showPreSalePreview, isTrue);
      expect(updated.showPostSalePreview, isTrue);
    });

    test('copyWith with no arguments returns an equal instance', () {
      const config = ReceiptConfig();
      final copy = config.copyWith();
      expect(copy, equals(config));
    });

    test('supports value equality', () {
      const a = ReceiptConfig();
      const b = ReceiptConfig();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('is not equal when a field differs', () {
      const a = ReceiptConfig();
      const b = ReceiptConfig(receiptSize: 'A4');
      expect(a == b, isFalse);
    });

    group('receiptSize edge cases', () {
      test('supports 58mm paper size', () {
        const config = ReceiptConfig(receiptSize: '58mm');
        expect(config.receiptSize, '58mm');
      });

      test('supports 80mm paper size (default)', () {
        const config = ReceiptConfig(receiptSize: '80mm');
        expect(config.receiptSize, '80mm');
      });

      test('supports A4 paper size', () {
        const config = ReceiptConfig(receiptSize: 'A4');
        expect(config.receiptSize, 'A4');
      });

      test('preserves arbitrary custom size string', () {
        const config = ReceiptConfig(receiptSize: 'custom');
        expect(config.receiptSize, 'custom');
      });
    });

    group('preview flags', () {
      test('showShopInfo defaults to true', () {
        const config = ReceiptConfig();
        expect(config.showShopInfo, isTrue);
      });

      test('showPreSalePreview defaults to true', () {
        const config = ReceiptConfig();
        expect(config.showPreSalePreview, isTrue);
      });

      test('showPostSalePreview defaults to true', () {
        const config = ReceiptConfig();
        expect(config.showPostSalePreview, isTrue);
      });

      test('can disable all preview flags via copyWith', () {
        const config = ReceiptConfig();
        final updated = config.copyWith(
          showShopInfo: false,
          showPreSalePreview: false,
          showPostSalePreview: false,
        );
        expect(updated.showShopInfo, isFalse);
        expect(updated.showPreSalePreview, isFalse);
        expect(updated.showPostSalePreview, isFalse);
      });
    });

    test('receiptPreviewStyle can be updated', () {
      const config = ReceiptConfig();
      final updated = config.copyWith(receiptPreviewStyle: 'a4');
      expect(updated.receiptPreviewStyle, 'a4');
      expect(updated.receiptSize, '80mm');
    });

    test('props include all fields', () {
      const config = ReceiptConfig(
        receiptSize: 'A4',
        receiptPreviewStyle: 'a4',
        receiptNote: 'Note',
        showShopInfo: false,
        showPreSalePreview: false,
        showPostSalePreview: false,
      );
      expect(config.props, ['A4', 'a4', 'Note', false, false, false]);
    });
  });
}
