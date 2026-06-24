import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/utils/customer_qr_decoder.dart';

void main() {
  group('decodeCustomerQr', () {
    test('returns invalid for empty payload', () {
      final result = decodeCustomerQr('');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, 'Invalid PromptPay QR code');
    });

    test('returns invalid for non-PromptPay payload', () {
      final result = decodeCustomerQr('not-a-qr');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, 'Invalid PromptPay QR code');
    });
  });

  group('CustomerQrDecodeResult', () {
    test('amountBaht converts satang to baht', () {
      const result = CustomerQrDecodeResult(isValid: true, amountSatang: 1050);
      expect(result.amountBaht, 10.5);
    });

    test('amountBaht is null when amountSatang is null', () {
      const result = CustomerQrDecodeResult(isValid: true);
      expect(result.amountBaht, isNull);
    });

    test('toString contains key fields', () {
      const result = CustomerQrDecodeResult(
        isValid: true,
        targetValue: '0812345678',
        amountSatang: 1000,
      );
      final str = result.toString();
      expect(str, contains('isValid: true'));
      expect(str, contains('target: 0812345678'));
      expect(str, contains('amountSatang: 1000'));
    });
  });
}
