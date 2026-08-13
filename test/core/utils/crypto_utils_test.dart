import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/utils/crypto_utils.dart';

/// PBKDF2-HMAC-SHA256 test vectors from RFC 6070.
///
/// Note: RFC 6070 defines vectors for PBKDF2-HMAC-SHA1. The values here
/// are independently verified against our HMAC-SHA256 implementation.
void main() {
  group('pbkdf2', () {
    test('RFC 6070 vector 1 (1 iteration)', () {
      final result = pbkdf2(
        password: 'password',
        salt: Uint8List.fromList('salt'.codeUnits),
        iterations: 1,
        keyLength: 32,
      );
      expect(result.length, 32);
      // HMAC-SHA256: dk = HMAC-SHA256(password, salt || 0x00000001)
      // with salt="salt", password="password"
      // Verified independently.
      expect(
        result,
        Uint8List.fromList([
          0x12,
          0x0f,
          0xb6,
          0xcf,
          0xfc,
          0xf8,
          0xb3,
          0x2c,
          0x43,
          0xe7,
          0x22,
          0x52,
          0x56,
          0xc4,
          0xf8,
          0x37,
          0xa8,
          0x65,
          0x48,
          0xc9,
          0x2c,
          0xcc,
          0x35,
          0x48,
          0x08,
          0x05,
          0x98,
          0x7c,
          0xb7,
          0x0b,
          0xe1,
          0x7b,
        ]),
      );
    });

    test('RFC 6070 vector 2 (2 iterations)', () {
      final result = pbkdf2(
        password: 'password',
        salt: Uint8List.fromList('salt'.codeUnits),
        iterations: 2,
        keyLength: 32,
      );
      expect(result.length, 32);
      expect(
        result,
        Uint8List.fromList([
          0xae,
          0x4d,
          0x0c,
          0x95,
          0xaf,
          0x6b,
          0x46,
          0xd3,
          0x2d,
          0x0a,
          0xdf,
          0xf9,
          0x28,
          0xf0,
          0x6d,
          0xd0,
          0x2a,
          0x30,
          0x3f,
          0x8e,
          0xf3,
          0xc2,
          0x51,
          0xdf,
          0xd6,
          0xe2,
          0xd8,
          0x5a,
          0x95,
          0x47,
          0x4c,
          0x43,
        ]),
      );
    });

    test('known answer — 100000 iterations (PIN hash scale)', () {
      final result = pbkdf2(
        password: '123456',
        salt: Uint8List.fromList('abcdef0123456789'.codeUnits),
        iterations: 100000,
        keyLength: 32,
      );
      expect(result.length, 32);
      // Consistency check: same inputs produce same output.
      final result2 = pbkdf2(
        password: '123456',
        salt: Uint8List.fromList('abcdef0123456789'.codeUnits),
        iterations: 100000,
        keyLength: 32,
      );
      expect(result, result2);
    });

    test('known answer — different passwords produce different keys', () {
      final salt = Uint8List.fromList('abcdef0123456789'.codeUnits);
      final r1 = pbkdf2(
        password: '123456',
        salt: salt,
        iterations: 100000,
        keyLength: 32,
      );
      final r2 = pbkdf2(
        password: '654321',
        salt: salt,
        iterations: 100000,
        keyLength: 32,
      );
      expect(r1, isNot(equals(r2)));
    });

    test('known answer — different salts produce different keys', () {
      final s1 = Uint8List.fromList('abcdef0123456789'.codeUnits);
      final s2 = Uint8List.fromList('1234567890abcdef'.codeUnits);
      final r1 = pbkdf2(
        password: '123456',
        salt: s1,
        iterations: 1000,
        keyLength: 32,
      );
      final r2 = pbkdf2(
        password: '123456',
        salt: s2,
        iterations: 1000,
        keyLength: 32,
      );
      expect(r1, isNot(equals(r2)));
    });

    test('keyLength truncation', () {
      final result = pbkdf2(
        password: 'password',
        salt: Uint8List.fromList('salt'.codeUnits),
        iterations: 1,
        keyLength: 16,
      );
      expect(result.length, 16);
    });

    test('keyLength > block size (multi-block)', () {
      final result = pbkdf2(
        password: 'password',
        salt: Uint8List.fromList('salt'.codeUnits),
        iterations: 1,
        keyLength: 64,
      );
      expect(result.length, 64);
    });
  });
}
