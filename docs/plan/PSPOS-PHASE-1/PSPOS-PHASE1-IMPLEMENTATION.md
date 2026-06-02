# PSPOS Phase 1 — Full Implementation Plan (5 Rounds)

แผนแบ่งงาน implement Phase 1 spec ให้ตรง 100% โดยใช้ UUIDv4 ตั้งแต่ต้น แบ่งเป็น 5 รอบ release ต่อเนื่อง — แต่ละรอบจบใน state ที่ release ได้ มี test coverage ครบ และไม่ทิ้ง broken state.

---

## Decisions (Locked)

| Topic | Decision |
|---|---|
| ID strategy | **UUIDv4 TEXT ทุก table ตั้งแต่ Round 1** (breaking — pre-release fresh install) |
| Scope | **Full Phase 1** — ตรง spec ทุกหมวด |
| Sync forward-compat | เพิ่ม `device_id`, `merchant_id`, `version`, `updated_at`, `deleted_at` ตั้งแต่ Round 1 |
| Migration | Drift schema bump พร้อม `onUpgrade` จริง — ไม่ drop data |
| Testing | ทุก Round ต้องผ่าน `flutter test` 100% ก่อน merge |

---

## Round Overview

| Round | Theme | Goal | Risk |
|---|---|---|---|
| **R1** ✅ | Schema Foundation | UUID migration + new tables + indexes + migration safety | 🔴 High → DONE |
| **R2** ✅ | Sale Integrity | Inventory log + Receipt number + Sale status + Void/Refund | 🟡 Medium → DONE |
| **R3** ✅ | Cashier UX | Draft cart + Discount (item/cart) + VAT (incl/excl) + Stock policy | 🟡 Medium → DONE |
| **R4** ✅ | Merchant Tools | Receipt PDF + PromptPay QR + Backup (SQLite/CSV) | 🟢 Low — DONE (v0.6.0) |
| **R5** | Operations | Daily Close + Onboarding wizard + Final polish + Phase 4 readiness check | 🟢 Low |

Estimated effort: R1 = ~3 days, R2 = ~3 days, R3 = ~3 days, R4 = ~2 days, R5 = ~2 days. **Total ~13 dev-days.**

---

## Round 1 — Schema Foundation ✅ DONE (2026-05-27)

> Goal: ทำให้ database ตรง Phase 1 spec ทั้งหมด ก่อนเพิ่ม feature ใด ๆ

### Tasks

1. **Add `uuid` package** ลง `pubspec.yaml`
2. **Migrate all tables → UUID PK**:
   - `Products`: `id TEXT` (UUIDv4), เพิ่ม `sku`, `barcode`, `cost`, `trackStock`, `deletedAt`, `version`, `deviceId`
   - `Sales`: `id TEXT`, เพิ่ม `receiptNumber`, `status` (`COMPLETED`/`VOIDED`), `subtotalAmount`, `discountType`, `discountValue`, `discountAmount`, `vatAmount`, `vatMode`, `voidedAt`, `voidReason`, `updatedAt`, `deletedAt`, `version`, `deviceId`
   - `SaleItems`: `id TEXT`, `saleId TEXT`, เพิ่ม `discountAmount`, `vatAmount`
3. **Add new tables** (UUID PK ทั้งหมด):
   - `Categories`
   - `InventoryLogs` (productId, type, qtyChange, reason, refSaleId, createdAt, deviceId)
   - `Settings` (key, value as JSON-string)
   - `DraftCarts`
   - `DraftCartItems`
   - `DailyCloses`
4. **Add indexes** ตาม spec:
   - `idx_sales_created_at`, `idx_sales_status`
   - `idx_sale_items_sale_id`
   - `idx_inventory_logs_product_id`
   - `idx_products_category_id`, `idx_products_name`
   - `idx_draft_cart_items_cart_id`
5. **Migration strategy**:
   - `schemaVersion: 2`
   - `onUpgrade` → drop+recreate (acceptable for pre-release, document in CHANGELOG)
   - WAL mode + busy timeout config
6. **Update DI + repository signatures** (int → String everywhere)
7. **Update test fixtures + helpers** (`fake_database.dart`, `fixtures.dart`, `mocks.dart`)
8. **Run `build_runner build`** + verify generated code

### Success Gate

- ✅ `flutter analyze` → **0 errors**
- ✅ `flutter test` → **135/135 passing**
- ✅ `dart run build_runner build` clean
- ⬜ App launches, sale → checkout still works end-to-end (manual smoke)
- ✅ Migration documented in `CHANGELOG.md` (v0.4.0)

> 📄 Detail: [PSPOS-PHASE1-R1-SCHEMA.md](PSPOS-PHASE1-R1-SCHEMA.md)

---

## Round 2 — Sale Integrity ✅ DONE (2026-05-27)

> Goal: Sale ทุก transaction ต้อง audit ได้ + reversible + มี receipt number

### Tasks

1. **Receipt Number Generator**:
   - Format `{YYMMDD}-{devicePrefix}-{seq}` (e.g. `260526-A1-0001`)
   - Persist sequence + last date ใน `Settings` table
   - Reset sequence at midnight (per device)
   - Generate inside sale transaction (atomic)
2. **Sale Status field implementation**:
   - Default `COMPLETED` on insert
   - Filter reports/history by status
3. **Inventory Log on sale**:
   - Insert `InventoryLog(type='SALE', refSaleId, qtyChange=-N)` ใน sale transaction เดียวกัน
4. **Void Sale flow**:
   - UI: long-press history item → confirm dialog
   - Update `sales.status='VOIDED'`, `voidedAt`, `voidReason`
   - Insert `InventoryLog(type='VOID_REVERSAL', qtyChange=+N)`
   - Restore stock atomically
5. **Manual stock adjustment UI** (product detail):
   - +/- adjustment with reason note
   - Insert `InventoryLog(type='ADJUSTMENT_IN/OUT')`
6. **Reports update**: filter out `VOIDED` from totals, show void count separately

### Success Gate (2026-05-27)

- ✅ Sale always produces receipt number + inventory log atomically
- ✅ Void sale restores stock + leaves audit trail
- ✅ Tests: receipt number uniqueness, void rollback, inventory log integrity
- ✅ Reports separate gross / void / net revenue
- ✅ `flutter analyze` → **0 errors**
- ✅ `flutter test` → **170/170 passing**
- ✅ `docs/ARCHITECTURE.md` + `docs/DATABASE.md` updated

> 📄 Detail: [PSPOS-PHASE1-R2-INTEGRITY.md](PSPOS-PHASE1-R2-INTEGRITY.md)

---

## Round 3 — Cashier UX ✅ DONE (2026-05-28)

> Goal: รองรับ workflow ร้านจริง — พักบิล, ส่วนลด, VAT

### Tasks

1. **Draft Cart Persistence**:
   - Auto-save cart ใน `DraftCarts` ทุกครั้งที่ cart เปลี่ยน (debounce 500ms)
   - Multi-draft: list view, สลับ, ตั้งชื่อ (เช่น "ลูกค้า A", "โต๊ะ 3")
   - Restore cart on app launch
   - Delete draft on successful checkout
2. **Discount System**:
   - Per-item discount (THB / %)
   - Per-cart discount (THB / %)
   - Recalculate subtotal/total live
   - Store `discountType`, `discountValue`, `discountAmount` ใน sale + sale_items
3. **VAT System**:
   - Settings: `vatMode` (`NONE`/`INCLUSIVE`/`EXCLUSIVE`), `vatRate` (default 7%)
   - Calculate per sale, store `vatAmount`
   - Show breakdown ใน payment sheet + receipt
4. **Stock Policy**:
   - Setting: `allowOversell` (bool, default false)
   - Per-product `trackStock` (bool, default true)
   - Low stock warning (threshold setting)
   - Honor in cart + checkout validation
5. **Settings page expansion**: VAT, oversell, low stock threshold

### Success Gate

- ✅ Cart survive app kill/restart
- ✅ Multi-draft switch <100ms
- ✅ Discount + VAT math correct (unit tests with edge cases: rounding, zero, negative)
- ✅ Oversell toggle respected end-to-end

> 📄 Detail: [PSPOS-PHASE1-R3-CASHIER.md](PSPOS-PHASE1-R3-CASHIER.md)

---

## Round 4 — Merchant Tools � Pre-flight ✅

> Goal: ส่งใบเสร็จ + รับเงิน QR + backup ข้อมูลได้
>
> **Pre-flight complete:** deps, ReceiptPdfService move, ReceiptLabels extract, 4 AppSettings fields, schema v4→v5, l10n keys, version bump. Feature code (Tasks 1–5) pending.

### Tasks

1. **Receipt PDF**:
   - Generator using `pdf` package (already in pubspec)
   - 80mm thermal layout + A4 fallback
   - Shop info, items, discount, VAT, total, payment, change, receipt number, footer note
   - Preview + Print/Share via `printing` package
2. **PromptPay QR**:
   - Settings: `promptpayId` (phone or citizen ID)
   - EMVCo QR generation (static — no amount lock, or dynamic with amount)
   - Display QR in payment sheet when method = `PROMPTPAY`
   - Manual cashier confirm button → mark sale as paid
   - Add `PROMPTPAY` to payment method enum
3. **Backup System**:
   - Export full SQLite file → user-chosen location
   - Export sales CSV (date range) → share sheet
   - Backup reminder notification (settings: every N days)
   - Restore SQLite file (with confirmation + version check)

### Success Gate

- ✅ Receipt PDF renders correctly TH + EN
- ✅ PromptPay QR scannable by real banking app (manual test)
- ✅ Backup roundtrip: export → wipe → restore → data identical

> 📄 Detail: [PSPOS-PHASE1-R4-TOOLS.md](PSPOS-PHASE1-R4-TOOLS.md)

---

## Round 5 — Operations 🟢

> Goal: ปิดรอบวันได้ + onboarding ครั้งแรก + Phase 4 ready

### Tasks

1. **Daily Close**:
   - Page: select date → show sales summary (count, gross, void, net, by method, by VAT)
   - Cash count input → calculate over/short
   - Save to `DailyCloses` table
   - Optional `dailyCloseLock`: block sales after close (setting toggle)
   - Reopen day requires confirmation
2. **First Launch / Onboarding**:
   - Detect `onboardingCompleted=false`
   - 6-step wizard: Welcome → Shop info → Currency/locale → VAT → PromptPay (optional) → Done
   - Auto-populate default settings on first launch
   - Empty state UI on first open of each tab (Sale/Product/etc.)
3. **Final Polish**:
   - Database growth UI: show DB size in settings, warn at 500MB
   - Add `idx` for any missed query hot path (run `EXPLAIN QUERY PLAN`)
   - Phase 4 readiness checklist: verify all tables have `version`, `updatedAt`, `deletedAt`, `deviceId` for sync compatibility
   - Update `CODEBASE.md` + `README.md` + `CHANGELOG.md` with full Phase 1 feature list
4. **Documentation**:
   - Update `docs/USAGE.md` with new flows
   - Mark `PSPOS-PHASE-1.md` as fully implemented

### Success Gate

- ✅ Daily close produces accurate over/short
- ✅ Fresh install runs onboarding, never asks twice
- ✅ All tables have sync-ready fields
- ✅ Test count grows from 130 → ~250+ with new feature coverage
- ✅ `flutter test` 100% pass, `flutter analyze` 0 errors

> 📄 Detail: [PSPOS-PHASE1-R5-OPERATIONS.md](PSPOS-PHASE1-R5-OPERATIONS.md)

---

## Cross-Cutting Concerns (Every Round)

| Concern | Action |
|---|---|
| **Tests** | Add unit + widget + integration tests with each feature. Maintain >80% coverage |
| **L10n** | EN + TH for every new string in same commit |
| **CHANGELOG** | Update at end of each round |
| **Version bump** | R1+R2→0.4.0, R3→0.5.0, R4→0.6.0, R4.5→0.6.1 (Cart UX Redesign), R5→1.0.0-rc1 |
| **No partial commits** | Each round is a self-contained release |

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| UUID migration breaks tests | High | High | R1 dedicated to migration; tests fixed before any feature added |
| Drift codegen drift | Medium | Medium | Run `build_runner` in CI; commit generated files |
| Receipt number race condition | Low | High | Generate inside DB transaction with row lock |
| PromptPay QR format wrong | Medium | High | Use vetted package or test with real bank app before merge |
| Backup data corruption | Low | Critical | Roundtrip test in CI; checksum verification |
| Scope creep | Medium | Medium | Strict round boundaries; defer extras to Phase 2 |

---

## Out of Scope (Phase 2+)

- Multi-device sync
- Cloud backup
- Customer database / loyalty
- Multi-shop support
- Advanced reports (forecast, ML)
- Hardware integrations (cash drawer, barcode scanner deep integration)
- User auth / role-based access

---

## Execution Sequence

```
R1 (Schema) → verify → release v0.4.0 ✅
   ↓
R2 (Integrity) → verify → merged into v0.4.0 ✅
   ↓
R3 (Cashier) → verify → release v0.5.0 ✅
   ↓
R4 (Tools) → verify → release v0.6.0 ✅
   ↓
R4.5 (Cart UX) → verify → release v0.6.1 ✅
   ↓
R5 (Ops) → verify → release v1.0.0-rc1 → Phase 1 DONE
```

แต่ละ Round เริ่มเฉพาะหลัง Round ก่อนหน้าผ่าน Success Gate ครบ.
