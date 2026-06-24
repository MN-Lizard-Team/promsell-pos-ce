import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/promptpay_qr_code.dart';

void main() {
  // ─── CRC16-CCITT helper ───────────────────────────────────────────────────

  int crc16Ccitt(String data) {
    int crc = 0xFFFF;
    for (final byte in data.codeUnits) {
      crc ^= byte << 8;
      for (int i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1;
        crc &= 0xFFFF;
      }
    }
    return crc;
  }

  bool verifyCrc(String payload) {
    if (payload.length < 8) return false;
    final tag = payload.substring(payload.length - 8, payload.length - 4);
    if (tag != '6304') return false;
    final body = payload.substring(0, payload.length - 4);
    final expectedHex = payload.substring(payload.length - 4).toUpperCase();
    final crc = crc16Ccitt(body);
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0') == expectedHex;
  }

  // ─── Structure tests ──────────────────────────────────────────────────────

  group('payload structure', () {
    test('starts with EMVCo version field 000201', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.0,
      );
      expect(payload, startsWith('000201'));
    });

    test('contains PromptPay AID A000000677010111', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.0,
      );
      expect(payload, contains('A000000677010111'));
    });

    test('contains THB currency code 5303764', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.0,
      );
      expect(payload, contains('5303764'));
    });

    test('contains TH country code 5802TH', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.0,
      );
      expect(payload, contains('5802TH'));
    });

    test('ends with CRC tag 6304', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.0,
      );
      final tail = payload.substring(payload.length - 8);
      expect(tail.substring(0, 4), equals('6304'));
    });
  });

  // ─── Phone number format ──────────────────────────────────────────────────

  group('phone number format', () {
    test('converts 0812345678 to include 0066812345678', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.0,
      );
      expect(payload, contains('0066812345678'));
    });

    test('removes leading 0 and prepends 0066', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0987654321',
        amount: 50.0,
      );
      expect(payload, contains('0066987654321'));
    });
  });

  // ─── Citizen ID format ────────────────────────────────────────────────────

  group('citizen ID format', () {
    test('13-digit ID preserved in payload', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '1100700123455',
        amount: 200.0,
      );
      expect(payload, contains('1100700123455'));
    });
  });

  // ─── Static vs Dynamic ────────────────────────────────────────────────────

  group('static vs dynamic', () {
    test('static (null amount) does not include field 54', () {
      final payload = buildPromptPayQrPayload(promptpayId: '0812345678');
      // Static QR should not contain amount field tag 54
      expect(payload, isNot(contains('5406')));
    });

    test('dynamic (with amount) includes field 54', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.50,
      );
      // Field 54 with amount value
      expect(payload, contains('54'));
    });

    test('dynamic amount 100.50 appears in payload', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.50,
      );
      expect(payload, contains('100.50'));
    });

    test('dynamic amount 500.0 formats as 500.00', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 500.0,
      );
      expect(payload, contains('500.00'));
    });

    test('dynamic amount 0.01 minimum precision', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 0.01,
      );
      expect(payload, contains('0.01'));
    });
  });

  // ─── CRC16 correctness ────────────────────────────────────────────────────

  group('CRC16-CCITT', () {
    test('phone dynamic — CRC valid', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.0,
      );
      expect(verifyCrc(payload), isTrue, reason: 'CRC16 mismatch: $payload');
    });

    test('phone static — CRC valid', () {
      final payload = buildPromptPayQrPayload(promptpayId: '0812345678');
      expect(verifyCrc(payload), isTrue, reason: 'CRC16 mismatch: $payload');
    });

    test('citizen ID static — CRC valid', () {
      final payload = buildPromptPayQrPayload(promptpayId: '1100700123455');
      expect(verifyCrc(payload), isTrue);
    });

    test('citizen ID dynamic — CRC valid', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '1100700123455',
        amount: 250.75,
      );
      expect(verifyCrc(payload), isTrue);
    });

    test('large amount — CRC valid', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 99999.99,
      );
      expect(verifyCrc(payload), isTrue);
    });

    test('small amount — CRC valid', () {
      final payload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 0.01,
      );
      expect(verifyCrc(payload), isTrue);
    });
  });

  // ─── Consistency ──────────────────────────────────────────────────────────

  group('consistency', () {
    test('same input produces same output', () {
      final a = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 123.45,
      );
      final b = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 123.45,
      );
      expect(a, equals(b));
    });

    test('different amounts produce different payloads', () {
      final a = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.0,
      );
      final b = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 200.0,
      );
      expect(a, isNot(equals(b)));
    });

    test('static and dynamic produce different payloads', () {
      final staticPayload = buildPromptPayQrPayload(promptpayId: '0812345678');
      final dynamicPayload = buildPromptPayQrPayload(
        promptpayId: '0812345678',
        amount: 100.0,
      );
      expect(staticPayload, isNot(equals(dynamicPayload)));
    });
  });
}
