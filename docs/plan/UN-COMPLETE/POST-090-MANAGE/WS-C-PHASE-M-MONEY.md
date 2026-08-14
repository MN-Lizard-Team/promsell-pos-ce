# Workstream C — Phase M (INTEGER money on disk)

**Parent:** [POST-090-OVERVIEW.md](./POST-090-OVERVIEW.md)  
**Backlog IDs:** C0–C4  
**Sources:** `docs/DATABASE.md`, `lib/core/domain/money.dart`, `lib/core/database/money_converter.dart`, sale writers, CHANGELOG 0.9 known limits

---

## Goal

ปิด impedance **domain satang (int) vs SQLite REAL baht** โดย migration ที่ audit ได้ + tests fail-closed — **behavior-preserving** ต่อผู้ใช้ (ยอดเดิมเท่าเดิมหลัง upgrade)

---

## Preconditions (hard)

1. **B1** trust expand เขียว (payable golden + insert/void integrity)  
2. Inventory of every money column complete (C0)  
3. Backup recommendation: export before upgrade (document in release notes)  

**Do not** land Phase M in the same PR as unrelated sale UX.

---

## C0 — Inventory & design

**Status:** Inventory locked **2026-07-20** from `lib/core/database/tables/*` (schema v30). All money amounts on disk are **SQLite REAL baht** unless noted.

### Full REAL money / rate columns

| Table | Column | Kind | Phase M target |
|-------|--------|------|----------------|
| `products` | `price` | amount | INTEGER satang |
| `products` | `cost` | amount (nullable) | INTEGER satang |
| `product_options` | `priceDelta` | amount | INTEGER satang |
| `sales` | `subtotalAmount` | amount | INTEGER satang |
| `sales` | `discountValue` | amount or % value (nullable; with `discountType`) | keep REAL if percent; satang if amount |
| `sales` | `discountAmount` | amount | INTEGER satang |
| `sales` | `totalAmount` | amount | INTEGER satang |
| `sales` | `vatRate` | rate % | keep REAL (not money) |
| `sales` | `vatAmount` | amount | INTEGER satang |
| `sales` | `serviceChargeRate` | rate % | keep REAL |
| `sales` | `serviceChargeAmount` | amount | INTEGER satang |
| `sales` | `promotionDiscountAmount` | amount | INTEGER satang |
| `sales` | `amountReceived` | amount (nullable) | INTEGER satang |
| `sales` | `changeAmount` | amount (nullable) | INTEGER satang |
| `sale_items` | `price` | amount | INTEGER satang |
| `sale_items` | `discountAmount` | amount | INTEGER satang |
| `sale_items` | `vatAmount` | amount | INTEGER satang |
| `sale_items` | `subtotal` | amount | INTEGER satang |
| `sale_payments` | `amount` | amount | INTEGER satang |
| `daily_closes` | `openingCash` | amount | INTEGER satang |
| `daily_closes` | `expectedCash` | amount | INTEGER satang |
| `daily_closes` | `countedCash` | amount | INTEGER satang |
| `daily_closes` | `overShortAmount` | amount | INTEGER satang |
| `daily_closes` | `totalRevenue` | amount | INTEGER satang |
| `daily_closes` | `totalVoid` | amount | INTEGER satang |
| `daily_closes` | `vatAmount` | amount | INTEGER satang |
| `daily_closes` | `discountAmount` | amount | INTEGER satang |
| `customers` | `totalSpent` | amount | INTEGER satang |
| `promotions` | `value` | amount or % | keep REAL if type PERCENT; satang if amount |
| `promotions` | `minPurchaseAmount` | amount | INTEGER satang |
| `draft_carts` | `cartDiscountValue` | amount or % | same as sales discount |
| `draft_carts` | `serviceChargeRate` | rate % | keep REAL |
| `draft_carts` | `promotionDiscountAmount` | amount | INTEGER satang |
| `draft_cart_items` | `price` | amount | INTEGER satang |
| `draft_cart_items` | `discountValue` | amount or % | same as sales |

**Non-money REAL rates (do not convert to satang):** `vatRate`, `serviceChargeRate`, percent-typed `discountValue` / promotion `value`.

### Design choice — **LOCKED for C1**

| Decision | Choice |
|----------|--------|
| Strategy | **Option A dual-write** for high-risk money tables: `sales`, `sale_items`, `sale_payments`, `daily_closes`, `products`, `customers` |
| Low-risk / drafts | Dual-write or same migration pass as sales (prefer same version) |
| Rates | Stay REAL percent |
| Rollback | Keep baht REAL columns until satang proven + one release later |
| Conversion | `ROUND(baht * 100)` via `Money.fromDouble` half-up rules; audit NaN/Inf before migrate |

### Dual-write sketch
- Writers: compute `Money` → write `*_satang` (+ temporary baht `.value` for compat)  
- Readers: prefer satang; fallback `Money.fromDouble(baht)` for old rows  
- Remove baht amount columns only after N releases + migration proof  
- Tender equality: satang integer (retire 0.009 float tolerance after cutover)

**C0 exit:** inventory table above + design locked — **done 2026-07-20**.

---

## C1 — Migration

**Status:** Schema + backfill done **2026-08-14**. Writer/reader rewiring is C2.

- [x] New schema version **v32** in `app_database.dart`
- [x] Non-finite / NaN audit: backfill WHERE clause excludes NaN (`baht = baht` → NULL for NaN) and Inf (`abs(baht) < 1e15`)
- [x] Partial indexes / checks unchanged unless needed
- [ ] Backup restore of **pre-M** encrypted DB still upgrades cleanly — needs integration test (C3)
- [x] Document downtime: local only; seconds–minutes on large DBs (migration is ALTER TABLE + UPDATE per column)

---

## C2 — Type layer

**Status:** Wired **2026-08-14**. Legacy REAL columns remain as compatibility dual-writes.

- [x] Wire Drift `TypeConverter<Money, int>` (satang) — nullable `*_satang` columns use `NullableMoneySatangConverter`; readers prefer satang with REAL fallback
- [x] Sale/product/option/draft/customer/promotion/daily-close writers dual-write `Money` satang plus legacy REAL baht
- [x] Void/customer-spend reversal reads satang-first and writes both representations
- [x] Tender equality: exact integer satang (removed the old `0.009` tolerance from sale creation)
- [x] CSV import/export keeps baht display while product data writes/reads satang through the data layer

---

## C3 — Tests

**Status:** Green **2026-08-14** (migration, satang-wiring, precision coverage, and full suite 2129).

| Test | Assert | Status |
|------|--------|--------|
| Satang columns exist on all money tables | Schema query | ✅ done |
| Backfill: products price/cost | `ROUND(baht*100)` matches | ✅ done |
| Backfill: sales all 8 amount columns | Exact satang | ✅ done |
| Backfill: daily_closes all 8 columns | Exact satang | ✅ done |
| Backfill: customers total_spent | Exact satang | ✅ done |
| Nullable cost stays NULL | `cost_satang IS NULL` when `cost IS NULL` | ✅ done |
| Half-up rounding 99.995 | `10000` not `9999` | ✅ done |
| Idempotent backfill | `WHERE satang IS NULL` prevents overwrite | ✅ done |
| File-backed v31 fixture → v32 | Columns recreated, REAL values backfilled, Drift converter returns `Money` | ✅ done |
| Create sale dual-write | Header/item/payment satang columns populated | ✅ done |
| Satang-first sale reader | Changed REAL ignored; NULL satang falls back to REAL | ✅ done |
| Tender equality | One-satang mismatch rejected; exact multi-tender accepted | ✅ done |
| Void reverse | Customer spent satang reverses exactly | ✅ done |
| Daily close | Cash expected from payment lines | ✅ done |
| Payable golden | Matrix unchanged vs 0.9 domain | ✅ done |
| Report aggregates | Fractional money aggregates without float drift | ✅ done |

Must run under release-trust or dedicated Phase M job.

---

## C4 — Docs honesty

**Status:** Updated **2026-08-14** after C2/C3 wiring.

- [x] `docs/DATABASE.md` — v32 schema row, active converter/dual-write status, migration timeline, and REAL compatibility note
- [x] `CHANGELOG.md` — 0.9.1 highlights, breaking/migration v32 entry, compatibility limitation, and current test count
- [x] `SECURITY.md` — 0.9.2 entry explains that satang storage/readers are active while REAL columns remain for rollback compatibility
- [x] Honest about what is **not** done: dropping legacy REAL columns and encrypted pre-M backup-restore fixture are still deferred
- [x] No claim that Phase M removes all floating-point values from SQLite yet

---

## Risks

| Risk | Mitigation |
|------|------------|
| Off-by-one satang on half-up | Use existing `Money` half-up; golden tests |
| Old backups | Migration path + reject plain SQLite still |
| Dual-write bugs | Feature flag or single-version cut with heavy tests |
| Report UI formatting | Keep `CurrencyFormatter` baht display |

---

## Explicit non-goals

- Multi-currency  
- Changing payable formula order (ADR-011) without separate ADR  
- Cloud money ledger  

---

## Exit criteria

- All C0–C4 checklists done with PR evidence  
- Trust + Phase M fixtures green  
- No REAL money columns left **or** documented dual-write deprecation timeline  

---

<sub>WS-C · PLAN ONLY · Do not start before B1</sub>
