import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/services/pin_hasher.dart';

void main() {
  const hasher = PinHasher();

  group('PinHasher', () {
    group('v2 (PBKDF2)', () {
      test('verify returns true for the correct pin', () {
        final salt = hasher.randomSalt();
        final hash = hasher.hashV2('123456', salt);

        final ok = hasher.verify(
          pin: '123456',
          expectedHash: hash,
          salt: salt,
          scheme: PinHasher.schemeV2,
        );

        expect(ok, isTrue);
      });

      test('verify returns false for a wrong pin', () {
        final salt = hasher.randomSalt();
        final hash = hasher.hashV2('123456', salt);

        final ok = hasher.verify(
          pin: '654321',
          expectedHash: hash,
          salt: salt,
          scheme: PinHasher.schemeV2,
        );

        expect(ok, isFalse);
      });

      test('verify returns false when hash length differs', () {
        final salt = hasher.randomSalt();
        final hash = hasher.hashV2('123456', salt);

        final ok = hasher.verify(
          pin: '123456',
          expectedHash: hash.substring(0, hash.length - 2),
          salt: salt,
          scheme: PinHasher.schemeV2,
        );

        expect(ok, isFalse);
      });

      test('hash is deterministic for the same pin and salt', () {
        final salt = hasher.randomSalt();

        expect(hasher.hashV2('123456', salt), hasher.hashV2('123456', salt));
      });

      test('hash differs across salts', () {
        expect(
          hasher.hashV2('123456', hasher.randomSalt()),
          isNot(hasher.hashV2('123456', hasher.randomSalt())),
        );
      });
    });

    group('v1 (legacy)', () {
      test('verify returns true for the correct v1 hash', () {
        final salt = hasher.randomSalt();
        final hash = hasher.hashV1('123456', salt);

        final ok = hasher.verify(
          pin: '123456',
          expectedHash: hash,
          salt: salt,
          scheme: PinHasher.schemeV1,
        );

        expect(ok, isTrue);
      });

      test('verify returns false for a wrong v1 pin', () {
        final salt = hasher.randomSalt();
        final hash = hasher.hashV1('123456', salt);

        final ok = hasher.verify(
          pin: '654321',
          expectedHash: hash,
          salt: salt,
          scheme: PinHasher.schemeV1,
        );

        expect(ok, isFalse);
      });
    });

    group('scheme fallback', () {
      test('unknown scheme falls back to v1', () {
        final salt = hasher.randomSalt();
        final hash = hasher.hashV1('123456', salt);

        final ok = hasher.verify(
          pin: '123456',
          expectedHash: hash,
          salt: salt,
          scheme: 'vX',
        );

        expect(ok, isTrue);
      });
    });

    group('trimming', () {
      test('verify trims the pin before hashing', () {
        final salt = hasher.randomSalt();
        final hash = hasher.hashV2('123456', salt);

        final ok = hasher.verify(
          pin: ' 123456 ',
          expectedHash: hash,
          salt: salt,
          scheme: PinHasher.schemeV2,
        );

        expect(ok, isTrue);
      });
    });

    group('randomSalt', () {
      test('returns 32 hex characters', () {
        final salt = hasher.randomSalt();

        expect(salt.length, 32);
        expect(RegExp(r'^[0-9a-f]+$').hasMatch(salt), isTrue);
      });

      test('returns different salts on successive calls', () {
        expect(hasher.randomSalt(), isNot(hasher.randomSalt()));
      });
    });
  });
}
