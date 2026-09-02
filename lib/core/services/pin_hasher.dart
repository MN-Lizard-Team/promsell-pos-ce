import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:promsell_pos_ce/core/utils/crypto_utils.dart';

/// PIN hashing utilities for [AppLockService].
///
/// Supports two schemes:
/// - **v2** (current): PBKDF2-HMAC-SHA256, 100k iterations, 32-byte key
/// - **v1** (legacy): SHA-256(`salt::pin`) — verified once then upgraded to v2
class PinHasher {
  const PinHasher();

  static const schemeV1 = 'v1';
  static const schemeV2 = 'v2';

  static const _pbkdf2Iterations = 100000;
  static const _keyLength = 32;

  /// Generates a 16-byte random salt as a hex string.
  String randomSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Legacy v1 hash: SHA-256(`salt::pin`).
  String hashV1(String pin, String salt) {
    final bytes = utf8.encode('$salt::$pin');
    return sha256.convert(bytes).toString();
  }

  /// Current v2 hash: PBKDF2-HMAC-SHA256, 100k iterations.
  String hashV2(String pin, String salt) {
    final saltBytes = Uint8List.fromList(utf8.encode(salt));
    final key = pbkdf2(
      password: pin,
      salt: saltBytes,
      iterations: _pbkdf2Iterations,
      keyLength: _keyLength,
    );
    return key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Verifies [pin] against [expectedHash] using the given [scheme] and
  /// [salt]. Returns `true` on match.
  bool verify({
    required String pin,
    required String expectedHash,
    required String salt,
    required String scheme,
  }) {
    final trimmed = pin.trim();
    return scheme == schemeV2
        ? _constantTimeEquals(hashV2(trimmed, salt), expectedHash)
        : _constantTimeEquals(hashV1(trimmed, salt), expectedHash);
  }

  /// Constant-time string comparison — XOR-accumulates byte differences so
  /// execution time does not leak the position of the first mismatch.
  /// Length differences fold into the accumulator (shorter side zero-padded).
  static bool _constantTimeEquals(String a, String b) {
    final aBytes = utf8.encode(a);
    final bBytes = utf8.encode(b);
    final maxLen = aBytes.length > bBytes.length
        ? aBytes.length
        : bBytes.length;
    var acc = 0;
    for (var i = 0; i < maxLen; i++) {
      final x = i < aBytes.length ? aBytes[i] : 0;
      final y = i < bBytes.length ? bBytes[i] : 0;
      acc |= x ^ y;
    }
    return acc == 0;
  }
}
