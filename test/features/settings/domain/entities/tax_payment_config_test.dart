import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';

void main() {
  group('TaxConfig', () {
    test('has default values', () {
      const config = TaxConfig();
      expect(config.vatRate, 7.0);
      expect(config.vatMode, 'NONE');
    });

    test('copyWith updates fields', () {
      const config = TaxConfig();
      final updated = config.copyWith(vatRate: 10.0, vatMode: 'INCLUSIVE');
      expect(updated.vatRate, 10.0);
      expect(updated.vatMode, 'INCLUSIVE');
    });

    test('supports value equality', () {
      const a = TaxConfig();
      const b = TaxConfig();
      expect(a, equals(b));
    });
  });

  group('PaymentConfig', () {
    test('has default values', () {
      const config = PaymentConfig();
      expect(config.currency, '฿');
      expect(config.promptPayTimeout, 180);
      expect(config.promptPaySoundEnabled, isTrue);
      expect(config.defaultQrType, 'transfer');
    });

    test('isPromptpayActive is false when promptpayId is empty', () {
      const config = PaymentConfig();
      expect(config.isPromptpayActive, isFalse);
    });

    test('isPromptpayActive is true when promptpayId is set', () {
      const config = PaymentConfig(promptpayId: '0812345678');
      expect(config.isPromptpayActive, isTrue);
    });

    test('copyWith updates fields', () {
      const config = PaymentConfig();
      final updated = config.copyWith(
        currency: '\$',
        promptpayId: '1234567890',
        autoConfirmAfterSlip: true,
      );
      expect(updated.currency, '\$');
      expect(updated.promptpayId, '1234567890');
      expect(updated.autoConfirmAfterSlip, isTrue);
    });

    test('supports value equality', () {
      const a = PaymentConfig();
      const b = PaymentConfig();
      expect(a, equals(b));
    });
  });
}
