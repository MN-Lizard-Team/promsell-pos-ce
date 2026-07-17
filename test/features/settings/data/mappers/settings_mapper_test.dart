import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/business_config.dart';

void main() {
  final mapper = SettingsMapper();

  group('SettingsMapper.fromMap', () {
    test('uses defaults for empty map', () {
      final s = mapper.fromMap({});
      expect(s.shopName, '');
      expect(s.currency, '฿');
      expect(s.vatRate, 7.0);
      expect(s.vatMode, 'NONE');
      expect(s.businessType, BusinessType.retail);
      expect(s.backupEncryptionEnabled, isTrue);
    });

    test('reads legacy snake_case seed keys', () {
      final s = mapper.fromMap({
        'shop_name': 'Legacy Shop',
        'receipt_footer': 'Thanks',
        'vat_rate': '10',
        'vat_mode': 'EXCLUSIVE',
        'currency_symbol': '\$',
      });
      expect(s.shopName, 'Legacy Shop');
      expect(s.receiptNote, 'Thanks');
      expect(s.vatRate, 10.0);
      expect(s.vatMode, 'EXCLUSIVE');
      expect(s.currency, '\$');
    });

    test('canonical keys win over legacy', () {
      final s = mapper.fromMap({
        'shopName': 'New',
        'shop_name': 'Old',
        'vatRate': '7',
        'vat_rate': '10',
      });
      expect(s.shopName, 'New');
      expect(s.vatRate, 7.0);
    });

    test('invalid businessType does not throw', () {
      final s = mapper.fromMap({'businessType': 'not-a-type'});
      expect(s.businessType, BusinessType.retail);
    });

    test('bool parse uses fallback for garbage and empty', () {
      final s = mapper.fromMap({
        'backupEncryptionEnabled': 'yes',
        'showShopInfo': '',
        'allowOversell': 'TRUE',
      });
      // garbage → fallback true for backup encryption
      expect(s.backupEncryptionEnabled, isTrue);
      // empty → fallback true for showShopInfo
      expect(s.showShopInfoOnReceipt, isTrue);
      // TRUE (case-insensitive) → true
      expect(s.allowOversell, isTrue);
    });

    test('toMap does not write autoPrintPrompt', () {
      final map = mapper.toMap(mapper.fromMap({}));
      expect(map.containsKey('autoPrintPrompt'), isFalse);
      expect(map.containsKey('barcodeLastCounter'), isTrue);
    });
  });
}
