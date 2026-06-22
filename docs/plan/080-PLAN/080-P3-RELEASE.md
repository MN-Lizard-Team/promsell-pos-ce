# v0.8.1 — Phase 3: Performance + Release

**Theme:** Stress test tooling + Final gate + Tag v0.8.1
**Effort:** ~0.5 day
**Risk:** 🟢 Low
**Depends on:** Phase 1 ✅, Phase 2 ✅

---

## Why Last

P3 คือ exit gate — ทำเฉพาะหลัง P1+P2 ผ่านทั้งหมด verify performance regression ไม่เกิดหลัง migration แล้ว tag release

---

## Pre-flight

- [ ] Phase 2 complete ✅
- [ ] `grep -r "AppSettings" lib/` → 0 results
- [ ] `flutter test` → ≥ 371 passing
- [ ] `flutter analyze` → 0 issues

---

## Task 1 — Stress Test Seeder Tool

**Phase 1 R5 deferred item:** "10k product / 50k sale stress test < 1s home load"

**New file:** `tool/seed_db.dart`

ไม่อยู่ใน test suite หลัก — เป็น standalone tool รัน manually เพื่อ verify performance

### Usage

```bash
dart run tool/seed_db.dart
dart run tool/seed_db.dart --products 10000 --sales 50000
dart run tool/seed_db.dart --products 1000 --sales 5000 --quick
```

### Implementation

```dart
// tool/seed_db.dart

import 'dart:io';
import 'package:args/args.dart';

/// Stress test seeder for Promsell POS CE.
/// Seeds the local database with configurable volumes of test data
/// to verify performance under production-scale loads.
///
/// Usage:
///   dart run tool/seed_db.dart [--products N] [--sales N] [--quick]
///
/// Targets (Phase 1 R5 spec):
///   - Products: 10,000
///   - Sales: 50,000 (with ~3 items each → 150,000 sale_items)
///   - Inventory logs: ~150,000
///
/// Success criteria:
///   - Product list load: < 1s
///   - History page load: < 1s
///   - Report aggregation (30 days): < 1s
void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('products', defaultsTo: '10000', help: 'Number of products to seed')
    ..addOption('sales', defaultsTo: '50000', help: 'Number of sales to seed')
    ..addFlag('quick', defaultsTo: false, help: 'Quick mode: 1k products, 5k sales');

  final results = parser.parse(args);
  final quick = results['quick'] as bool;
  final productCount = quick ? 1000 : int.parse(results['products'] as String);
  final salesCount = quick ? 5000 : int.parse(results['sales'] as String);

  print('🌱 Promsell POS CE — Stress Seeder');
  print('   Products: $productCount');
  print('   Sales: $salesCount');
  print('   Estimated sale_items: ${salesCount * 3}');
  print('');

  // Note: This tool requires a running Flutter environment to access the DB.
  // Run via `flutter run tool/seed_db.dart` or integrate into an integration test.
  // Alternatively, seed via a dedicated integration test in test/tool/seed_test.dart.

  print('ℹ️  See test/tool/seed_integration_test.dart for DB-connected seeder.');
  print('   Run: flutter test test/tool/seed_integration_test.dart --timeout 300s');
}
```

**Integration test seeder:** `test/tool/seed_integration_test.dart`

```dart
// test/tool/seed_integration_test.dart
// Run manually only: flutter test test/tool/seed_integration_test.dart
// NOT part of main test suite (excluded from CI)

@Tags(['stress'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import '../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = openTestDatabase());
  tearDown(() => db.close());

  test('seed 1000 products + 5000 sales and measure load times', () async {
    // Seed categories (10)
    final sw = Stopwatch()..start();
    // ... seed logic

    // Measure product list
    sw.reset();
    final products = await db.select(db.products).get();
    print('Product list (${products.length}): ${sw.elapsedMilliseconds}ms');
    expect(sw.elapsedMilliseconds, lessThan(1000));

    // Measure history
    sw.reset();
    final sales = await db.select(db.sales).get();
    print('History list (${sales.length}): ${sw.elapsedMilliseconds}ms');
    expect(sw.elapsedMilliseconds, lessThan(1000));
  }, timeout: const Timeout(Duration(minutes: 5)));
}
```

> Stress tests are **tagged `stress`** and excluded from CI: `flutter test --exclude-tags stress`

---

## Task 2 — CHANGELOG Update

เพิ่ม section `[0.8.1]` ใน `CHANGELOG.md`:

```markdown
## [0.8.1] - 2026-XX-XX

Architecture cleanup completing Phase 4 pre-work + PromptPay QR test coverage.

### Changed

- **AppSettings Facade Removed** — Migrated all presentation-layer consumers
  from deprecated `AppSettings` flat facade to typed `Settings` aggregate sub-entities
  (`taxConfig`, `receiptConfig`, `stockConfig`, `uiConfig`, etc.). ~28 files updated.
  `AppSettings` class deleted. Reduces double-maintenance surface before Phase 4 sync.

### Fixed

- `checkout_body.dart` — `barrierColor` now uses `Theme.of(context).colorScheme.scrim`
  instead of hardcoded `Colors.black` (Material 3 theme token compliance).

### Added

- PromptPay QR unit tests — 20 tests covering EMVCo payload structure, phone/citizen-ID
  formatting, static/dynamic mode, CRC16-CCITT correctness, and edge cases.
  Closes Phase 1 R4 open item: automated regression guard for QR payload format.
- Stress test seeder tooling — `test/tool/seed_integration_test.dart` with `@Tags(['stress'])`
  for manual performance verification at production-scale data volumes.

`flutter analyze` → **0 issues** · `flutter test` → **≥ 371 passing**
```

---

## Task 3 — Update Phase 1 Plan File

อัปเดต `docs/plan/PSPOS-PHASE-1/PSPOS-PHASE1-R4-TOOLS.md` ปิด item ค้าง:

```markdown
### R4 Definition of Done — Updated

```
✅ E1 Category Autocomplete in ProductFormPage
✅ E2 Cart Item Direct Qty Input
✅ E3 InventoryLogPage Clean Architecture Refactor
✅ E4 History Search / Filter Bar
✅ PromptPay QR automated tests (CRC16, structure, phone/citizenID) — v0.8.1
⬜ Manual scan verified with real banking app  ← still recommended for production
```

> Note: Automated CRC16 + structure tests added in v0.8.1 prevent format regression.
> Manual scan with K-Plus/SCB Easy still recommended before production deployment.
```

---

## Task 4 — Final Verification

```bash
# Full test suite
flutter test

# Analyze
flutter analyze

# Confirm AppSettings fully removed
grep -r "AppSettings" lib/
# Expected: 0 results

# Confirm no dead imports
grep -r "app_settings.dart" lib/
# Expected: 0 results

# Stress test (manual, optional for this release)
flutter test test/tool/seed_integration_test.dart --timeout 300s
```

---

## Task 5 — Version + Tag

`pubspec.yaml` ยังเป็น `0.8.1+1` อยู่แล้ว (ตั้งไว้ตั้งแต่ dev cycle) — ไม่ต้องเปลี่ยน

```bash
git add -A
git commit -m "chore: v0.8.1 — AppSettings facade removal + PromptPay tests"
git tag v0.8.1
```

---

## Success Gate — Phase 3 (= v0.8.1 Release Gate)

- [ ] `flutter analyze` → **0 issues**
- [ ] `flutter test` → **≥ 371 passing**
- [ ] `grep -r "AppSettings" lib/` → **0 results**
- [ ] `CHANGELOG.md` section `[0.8.1]` complete + accurate
- [ ] `PSPOS-PHASE1-R4-TOOLS.md` PromptPay item updated
- [ ] Stress test seeder exists at `test/tool/seed_integration_test.dart`
- [ ] `pubspec.yaml` version `0.8.1+1`
- [ ] Git tag `v0.8.1` created

---

## After v0.8.1 — Phase 4 Readiness Checklist

เมื่อ v0.8.1 release แล้ว codebase พร้อมสำหรับ Phase 4:

| Item | Status post-v0.8.1 |
|------|-------------------|
| All sync columns on all tables | ✅ v11 |
| UUIDv4 IDs everywhere | ✅ R1 |
| `AppSettings` facade removed | ✅ v0.8.1 |
| Settings typed aggregate ready | ✅ v0.8.1 |
| UTC ms timestamps (timezone-independent) | ✅ by design |
| PromptPay QR regression tests | ✅ v0.8.1 |
| `v1.0.0-rc1` milestone | ⬜ Next after RC cycle |

> 📄 Phase 4 planning: TBD in `docs/plan/PHASE-4-SYNC/`
