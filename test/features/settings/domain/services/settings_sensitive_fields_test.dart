import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/services/settings_sensitive_fields.dart';

void main() {
  test('detects promptpayId change', () {
    const a = Settings();
    final b = a.copyWith(promptpayId: '0812345678');
    expect(settingsSensitivePaymentChanged(a, b), isTrue);
  });

  test('detects billerId change', () {
    const a = Settings();
    final b = a.copyWith(billerId: '1234567890123');
    expect(settingsSensitivePaymentChanged(a, b), isTrue);
  });

  test('ignores non-payment fields', () {
    const a = Settings();
    final b = a.copyWith(currency: 'USD', shopName: 'Shop');
    expect(settingsSensitivePaymentChanged(a, b), isFalse);
  });
}
