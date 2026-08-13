import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 (RFC 2898 / PKCS #5 v2.0).
///
/// Shared implementation used by PIN hashing and backup encryption.
/// Designed as a top-level function so callers can pass it to
/// [Isolate.run] without capturing `this`.
///
/// Test vectors: RFC 6070 (see test/core/utils/crypto_utils_test.dart).
Uint8List pbkdf2({
  required String password,
  required Uint8List salt,
  required int iterations,
  required int keyLength,
}) {
  final passwordBytes = Uint8List.fromList(utf8.encode(password));
  final hmac = Hmac(sha256, passwordBytes);
  const blockLength = 32; // SHA-256 output length
  final blocksNeeded = (keyLength + blockLength - 1) ~/ blockLength;
  final result = <int>[];

  for (var blockIndex = 1; blockIndex <= blocksNeeded; blockIndex++) {
    final saltAndIndex = Uint8List(salt.length + 4);
    saltAndIndex.setAll(0, salt);
    saltAndIndex[salt.length] = (blockIndex >> 24) & 0xFF;
    saltAndIndex[salt.length + 1] = (blockIndex >> 16) & 0xFF;
    saltAndIndex[salt.length + 2] = (blockIndex >> 8) & 0xFF;
    saltAndIndex[salt.length + 3] = blockIndex & 0xFF;

    var u = hmac.convert(saltAndIndex).bytes;
    final block = Uint8List.fromList(u);

    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < block.length; j++) {
        block[j] ^= u[j];
      }
    }

    result.addAll(block);
  }

  return Uint8List.fromList(result.sublist(0, keyLength));
}
