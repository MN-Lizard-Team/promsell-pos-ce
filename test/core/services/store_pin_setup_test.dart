import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/services/store_pin_setup.dart';

void main() {
  group('StorePinSetup.validateNewPin', () {
    test('accepts matching non-trivial pin of min length', () {
      expect(StorePinSetup.validateNewPin('158260', '158260'), isNull);
      expect(StorePinSetup.validateNewPin(' 918273 ', '918273'), isNull);
    });

    test('rejects trivial pins before setPin can throw', () {
      expect(StorePinSetup.validateNewPin('123456', '123456'), 'trivial');
      expect(StorePinSetup.validateNewPin('111111', '111111'), 'trivial');
    });

    test('rejects empty', () {
      expect(StorePinSetup.validateNewPin('', ''), 'empty');
      expect(StorePinSetup.validateNewPin('   ', '   '), 'empty');
    });

    test('rejects too short', () {
      expect(StorePinSetup.validateNewPin('12345', '12345'), 'too_short');
    });

    test('rejects mismatch', () {
      expect(StorePinSetup.validateNewPin('123456', '123457'), 'mismatch');
    });

    test('minLength matches AppLockService policy', () {
      expect(StorePinSetup.minLength, 6);
    });
  });
}
