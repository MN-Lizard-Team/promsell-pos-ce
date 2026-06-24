import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/utils/slip_verifier.dart';

void main() {
  group('verifySlip', () {
    test('returns emptyPayload for empty string', () {
      final result = verifySlip('');
      expect(result.isValid, isFalse);
      expect(result.errorType, SlipErrorType.emptyPayload);
    });

    test('returns emptyPayload for whitespace-only string', () {
      final result = verifySlip('   ');
      expect(result.isValid, isFalse);
      expect(result.errorType, SlipErrorType.emptyPayload);
    });

    test('returns notASlipQr for PromptPay payment QR', () {
      final result = verifySlip('000201010212...');
      expect(result.isValid, isFalse);
      expect(result.errorType, SlipErrorType.notASlipQr);
    });

    test('returns unreadable for unknown format', () {
      final result = verifySlip('some-random-data');
      expect(result.isValid, isFalse);
      expect(result.errorType, SlipErrorType.unreadable);
    });
  });

  group('SlipVerifyResult', () {
    test('toString contains key fields', () {
      const result = SlipVerifyResult(
        isValid: true,
        transRef: 'ref123',
        bankNameTh: 'กสิกร',
      );
      final str = result.toString();
      expect(str, contains('isValid: true'));
      expect(str, contains('transRef: ref123'));
      expect(str, contains('bank: กสิกร'));
    });
  });
}
