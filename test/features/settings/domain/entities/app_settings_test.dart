import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('has correct defaults', () {
      final settings = AppSettings();
      expect(settings.locale, const Locale('th'));
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.shopName, '');
      expect(settings.currency, '฿');
      expect(settings.dateFormat, 'dd/MM/yyyy');
      expect(settings.showShopInfoOnReceipt, isTrue);
      expect(settings.autoPrintPrompt, isTrue);
      expect(settings.vatRate, 7.0);
      expect(settings.vatMode, 'NONE');
      expect(settings.receiptPreviewStyle, 'thermal');
      expect(settings.showPreSalePreview, isTrue);
      expect(settings.showPostSalePreview, isTrue);
      expect(settings.allowOversell, isFalse);
      expect(settings.lowStockThreshold, 5);
      expect(settings.enableItemDiscount, isTrue);
      expect(settings.enableCartDiscount, isTrue);
      expect(settings.maxDiscountPercent, 100.0);
      expect(settings.maxDiscountAmount, 0.0);
      expect(settings.defaultDiscountType, 'PERCENT');
      expect(settings.discountPresets.length, 1);
      expect(settings.discountPresets.first.id, 'default');
      expect(settings.activeDiscountPresetId, 'default');
      expect(settings.promptpayId, '');
      expect(settings.receiptSize, '80mm');
      expect(settings.backupReminderDays, 7);
      expect(settings.lastBackupAt, isNull);
      expect(settings.imageMaxWidth, 800);
      expect(settings.imageQuality, 80);
    });

    test('supports value equality', () {
      final a = AppSettings();
      final b = AppSettings();
      expect(a, equals(b));
    });

    test('copyWith updates selected fields', () {
      final settings = AppSettings();
      final updated = settings.copyWith(
        shopName: 'My Shop',
        currency: '\$',
        themeMode: ThemeMode.dark,
      );
      expect(updated.shopName, 'My Shop');
      expect(updated.currency, '\$');
      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.locale, const Locale('th'));
    });

    test('props contains aggregate Settings', () {
      final settings = AppSettings();
      expect(settings.props.length, 1);
    });
  });
}
