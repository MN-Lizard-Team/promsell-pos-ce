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

    test('isVatRateValid is true for in-range rate', () {
      const config = TaxConfig(vatRate: 7.0);
      expect(config.isVatRateValid, isTrue);
    });

    test('isVatRateValid is false for negative rate', () {
      const config = TaxConfig(vatRate: -1.0);
      expect(config.isVatRateValid, isFalse);
    });

    test('isVatRateValid is false for rate above max', () {
      const config = TaxConfig(vatRate: 50.0);
      expect(config.isVatRateValid, isFalse);
    });

    test('copyWith clamps vatRate to max', () {
      const config = TaxConfig();
      final updated = config.copyWith(vatRate: 100.0);
      expect(updated.vatRate, TaxConfig.maxVatRate);
    });

    test('copyWith clamps vatRate to min', () {
      const config = TaxConfig();
      final updated = config.copyWith(vatRate: -5.0);
      expect(updated.vatRate, TaxConfig.minVatRate);
    });

    test('copyWith keeps existing rate when NaN passed', () {
      const config = TaxConfig(vatRate: 7.0);
      final updated = config.copyWith(vatRate: double.nan);
      expect(updated.vatRate, 7.0);
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

    test('billerIdError is null for empty biller ID', () {
      const config = PaymentConfig();
      expect(config.billerIdError, isNull);
      expect(config.isBillerIdValid, isTrue);
    });

    test('billerIdError is BILLER_ID_LENGTH for 12 digits', () {
      const config = PaymentConfig(billerId: '123456789012');
      expect(config.billerIdError, 'BILLER_ID_LENGTH');
      expect(config.isBillerIdValid, isFalse);
    });

    test('billerIdError is BILLER_ID_LENGTH for 14 digits', () {
      const config = PaymentConfig(billerId: '12345678901234');
      expect(config.billerIdError, 'BILLER_ID_LENGTH');
    });

    test('billerIdError is BILLER_ID_CHECKSUM for bad checksum', () {
      // 13 digits but wrong checksum (last digit should be 7, not 0)
      const config = PaymentConfig(billerId: '1234567890120');
      expect(config.billerIdError, 'BILLER_ID_CHECKSUM');
      expect(config.isBillerIdValid, isFalse);
    });

    test('billerIdError is null for valid 13-digit checksum', () {
      // 1100701367081 is a valid Thai national ID (checksum verified)
      const config = PaymentConfig(billerId: '1100701367081');
      expect(config.billerIdError, isNull);
      expect(config.isBillerIdValid, isTrue);
    });

    test('billerIdError is null for valid 15-digit checksum', () {
      // Corporate tax ID 15 digits — use a synthetic valid one.
      // 12345678901234 → checksum = (11 - (sum % 11)) % 10
      // sum = 1*15+2*14+3*13+4*12+5*11+6*10+7*9+8*8+9*7+0*6+1*5+2*4+3*3+4*2 = 465
      // 465 % 11 = 3, (11-3)%10 = 8 → last digit should be 8
      const config = PaymentConfig(billerId: '123456789012348');
      expect(config.billerIdError, isNull);
    });

    test('billerIdError ignores non-digit characters', () {
      const config = PaymentConfig(billerId: '1-1007-01367-08-1');
      expect(config.billerIdError, isNull);
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
