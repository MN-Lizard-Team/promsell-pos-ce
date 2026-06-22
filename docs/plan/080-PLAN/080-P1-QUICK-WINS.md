# v0.8.1 — Phase 1: Quick Wins

**Theme:** PromptPay QR automated tests + Theme token fix
**Effort:** ~1 day
**Risk:** 🟢 Low
**Depends on:** v0.8.0 baseline ✅

---

## Why First

Tasks ใน P1 เป็น independent — ไม่ต้องรอ migration ใดๆ ทำได้ทันที และเพิ่ม test confidence ก่อนแตะ core settings layer ใน P2

---

## Pre-flight

- [ ] `flutter test` → 351/351 passing (baseline)
- [ ] `flutter analyze` → 0 issues
- [ ] Branch `main` (หรือ feature branch `v0.8.1`)

---

## Task 1 — Theme Token Fix

**File:** `lib/features/sale/presentation/widgets/checkout_body.dart`

**Problem:**
```dart
// TODO: migrate to Theme.of(context).colorScheme.scrim when available
barrierColor: Colors.black.withValues(alpha: 0.92),
```

`colorScheme.scrim` พร้อมใช้ใน Flutter 3.x / Material 3 แล้ว — TODO นี้ค้างมานาน

**Fix:**
```dart
// ลบ TODO comment และเปลี่ยน barrierColor
barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.92),
```

> Note: `colorScheme.scrim` เป็น semi-opaque black by default ใน Material 3 (default `0xFF000000`) ดังนั้นผลลัพธ์ visual เหมือนกัน แต่ใช้ theme token ที่ overridable

**Verification:**
- `flutter analyze` → 0 issues
- Visual: modal barrier สีไม่เปลี่ยนสำหรับ light/dark theme ปกติ

---

## Task 2 — PromptPay QR Automated Tests

**Phase 1 Debt:** R4 Definition of Done มี `❌ Manual scan verified with real banking app` ค้างอยู่

**Goal:** เพิ่ม automated test coverage ด้วย known-good EMVCo payloads เพื่อ prevent regression และ close Phase 1 debt

**New file:** `test/features/payment/data/services/promptpay_qr_service_test.dart`

### Background — EMVCo TLV Format

PromptPay QR ใช้ EMVCo QR Code Specification for Payment Systems (MPM) พร้อม PromptPay AID:
- `A000000677010111` = PromptPay Merchant Account Identifier

CRC16-CCITT polynomial: `0x1021`, initial value: `0xFFFF`

### Known-Good Test Vectors

ค่าเหล่านี้สามารถ verify ด้วย [PromptPay QR Generator ของ SCB](https://www.scb.co.th) หรือ [Bank of Thailand spec tools]

#### Vector 1 — Phone number, static (no amount)
- Input: `promptpayId = "0812345678"`, `amount = null`
- Expected phone in payload: `0066812345678` (66 = TH country code, remove leading 0)
- Expected structure: field `29` contains `A000000677010111` + `0066812345678`
- CRC: computed from everything before CRC field

#### Vector 2 — Citizen ID, static
- Input: `promptpayId = "1234567890123"` (13 digits)
- Expected in payload: `1234567890123` (citizen ID preserved as-is)
- Field tag: `02` (vs `01` for phone)

#### Vector 3 — Dynamic amount
- Input: `promptpayId = "0812345678"`, `amount = 100.50`
- Field `54` must contain `"100.50"`
- Point of initiation: `12` (dynamic) vs `11` (static)

#### Vector 4 — CRC16 correctness
- For any payload ending in `6304XXXX`, strip last 4 chars → compute CRC16-CCITT → must equal `XXXX` (hex uppercase)

### Test File

```dart
// test/features/payment/data/services/promptpay_qr_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/payment/data/services/promptpay_qr_service.dart';

void main() {
  late PromptpayQrService sut;

  setUp(() => sut = PromptpayQrService());

  // ─── Helper ───────────────────────────────────────────────────────────────

  /// Returns true if CRC16-CCITT of [data] matches the last 4 hex chars of payload.
  bool verifyCrc(String payload) {
    if (payload.length < 4) return false;
    final body = payload.substring(0, payload.length - 4);
    final expectedHex = payload.substring(payload.length - 4).toUpperCase();
    final crc = _crc16Ccitt(body);
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0') == expectedHex;
  }

  int _crc16Ccitt(String data) {
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

  // ─── Structure tests ───────────────────────────────────────────────────────

  group('payload structure', () {
    test('starts with EMVCo version field', () {
      final payload = sut.generatePayload(promptpayId: '0812345678');
      expect(payload, startsWith('000201'));
    });

    test('contains PromptPay AID', () {
      final payload = sut.generatePayload(promptpayId: '0812345678');
      expect(payload, contains('A000000677010111'));
    });

    test('contains THB currency code 764', () {
      final payload = sut.generatePayload(promptpayId: '0812345678');
      expect(payload, contains('5303764'));
    });

    test('contains TH country code', () {
      final payload = sut.generatePayload(promptpayId: '0812345678');
      expect(payload, contains('5802TH'));
    });

    test('ends with 63 (CRC tag)', () {
      final payload = sut.generatePayload(promptpayId: '0812345678');
      expect(payload.substring(payload.length - 8, payload.length - 4), equals('6304'));
    });
  });

  // ─── Phone format ──────────────────────────────────────────────────────────

  group('phone number format', () {
    test('converts 0812345678 → 0066812345678', () {
      final payload = sut.generatePayload(promptpayId: '0812345678');
      expect(payload, contains('0066812345678'));
    });

    test('phone uses tag 01', () {
      final payload = sut.generatePayload(promptpayId: '0812345678');
      // tag 01, length 13 = "011300668..."
      expect(payload, contains('011300668'));
    });

    test('removes leading 0 and prepends 0066', () {
      final payload = sut.generatePayload(promptpayId: '0987654321');
      expect(payload, contains('0066987654321'));
    });
  });

  // ─── Citizen ID ─────────────────────────────────────────────────────────────

  group('citizen ID format', () {
    test('13-digit ID preserved as-is', () {
      final payload = sut.generatePayload(promptpayId: '1234567890123');
      expect(payload, contains('1234567890123'));
    });

    test('citizen ID uses tag 02', () {
      final payload = sut.generatePayload(promptpayId: '1234567890123');
      expect(payload, contains('02131234567890123'));
    });

    test('citizen ID uses static point of initiation (11)', () {
      final payload = sut.generatePayload(promptpayId: '1234567890123');
      expect(payload, contains('010211'));
    });
  });

  // ─── Static vs Dynamic ────────────────────────────────────────────────────

  group('static vs dynamic', () {
    test('static (no amount) uses POI 11', () {
      final payload = sut.generatePayload(promptpayId: '0812345678');
      expect(payload, contains('010211'));
    });

    test('dynamic (with amount) uses POI 12', () {
      final payload = sut.generatePayload(promptpayId: '0812345678', amount: 100.0);
      expect(payload, contains('010212'));
    });

    test('dynamic includes field 54 with amount', () {
      final payload = sut.generatePayload(promptpayId: '0812345678', amount: 100.50);
      expect(payload, contains('5406100.50'));
    });

    test('dynamic amount zero is still included', () {
      final payload = sut.generatePayload(promptpayId: '0812345678', amount: 0.0);
      expect(payload, contains('54'));
    });

    test('static omits field 54', () {
      final payload = sut.generatePayload(promptpayId: '0812345678');
      // static payload should NOT contain amount field
      expect(payload, isNot(contains('5406')));
    });
  });

  // ─── CRC16 ────────────────────────────────────────────────────────────────

  group('CRC16-CCITT', () {
    test('phone static — CRC valid', () {
      final payload = sut.generatePayload(promptpayId: '0812345678');
      expect(verifyCrc(payload), isTrue, reason: 'CRC16 mismatch: $payload');
    });

    test('citizen ID static — CRC valid', () {
      final payload = sut.generatePayload(promptpayId: '1234567890123');
      expect(verifyCrc(payload), isTrue);
    });

    test('dynamic amount — CRC valid', () {
      final payload = sut.generatePayload(promptpayId: '0812345678', amount: 250.75);
      expect(verifyCrc(payload), isTrue);
    });

    test('large amount — CRC valid', () {
      final payload = sut.generatePayload(promptpayId: '0812345678', amount: 99999.99);
      expect(verifyCrc(payload), isTrue);
    });
  });

  // ─── Edge cases ───────────────────────────────────────────────────────────

  group('edge cases', () {
    test('amount with no decimal part formats as X.00', () {
      final payload = sut.generatePayload(promptpayId: '0812345678', amount: 500.0);
      expect(payload, contains('500.00'));
    });

    test('amount 0.01 minimum precision', () {
      final payload = sut.generatePayload(promptpayId: '0812345678', amount: 0.01);
      expect(payload, contains('0.01'));
      expect(verifyCrc(payload), isTrue);
    });
  });
}
```

**Expected test count: +20 tests** (from 351 → ~371)

---

## Success Gate — Phase 1

- [ ] `flutter analyze` → **0 issues**
- [ ] `flutter test` → **≥ 371 passing**
- [ ] `checkout_body.dart` — no `Colors.black` hardcode for barrierColor
- [ ] PromptPay tests ทุก group pass: structure, phone, citizenID, static/dynamic, CRC16, edge cases
- [ ] Phase 1 R4 debt item `❌ Manual scan verified` → เพิ่ม note ใน `PSPOS-PHASE1-R4-TOOLS.md` ว่า automated CRC tests เพิ่มแล้ว

> 📄 Next: [080-P2-APPSETTINGS-MIGRATION.md](080-P2-APPSETTINGS-MIGRATION.md)
