# WS-AH-FISCAL — Fiscal concurrency & money boundary

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** AH-2.1 … AH-2.6  
**Status:** todo (wave AH-2)  
**Related:** [POST-090 WS-C Phase M](../POST-090-MANAGE/WS-C-PHASE-M-MONEY.md)

---

## Goal

Keep the **strong sale write spine** (atomic insert/void, payable SSOT, inventory logs) and close residual **concurrency / type-boundary** holes before Play production claims.

**Do not regress:** `SaleInsertWriter` / `SaleVoidWriter` single-TX design, `SalePayableCalculator`, host integrity tests.

---

## AH-2.1 — Day lock inside write TX (Must)

### Problem

`CreateSale` / void path evaluate `SalesDayLock` **before** the Drift transaction in writers. CloseDay can finish in the gap → sale after “closed” (TOCTOU).

### Target

1. Keep cheap pre-check in use case (fast UX fail).  
2. **Re-check** day-lock conditions **inside** the same `_db.transaction` as insert/void (read settings and/or `daily_closes` row under the writer lock).  
3. Fail with existing `BusinessRuleError` / day-closed rule if blocked.

### Primary paths

- `lib/features/sale/domain/usecases/create_sale.dart`  
- `lib/features/sale/domain/usecases/void_sale.dart`  
- `lib/features/sale/data/datasources/sale_insert_writer.dart`  
- `lib/features/sale/data/datasources/sale_void_writer.dart`  
- `lib/features/sale/domain/services/sales_day_lock.dart`

### Tests

- Unit/integration: close day then concurrent create attempt loses  
- Existing day-lock and void-closed-day trust cases stay green  

### Done when

- G3 in [GATE-TO-PLAY.md](./GATE-TO-PLAY.md) satisfiable  
- No reliance on pre-TX check alone for fiscal enforcement  

---

## AH-2.2 — CloseDay + lastClosedDate atomicity (Must for G7)

### Problem

Close row persist and `lastClosedDate` settings write can be **sequential non-atomic** → UI lock desync.

### Target options (pick one, document in PR)

**A.** Single DB transaction spanning daily_close insert + settings key write  
**B.** Ordered fail-closed: if settings write fails after close row, compensate or block sales via close-row check on create (prefer both close row **and** settings in create path)

Align with AH-1.2 port so domain does not call sale DS.

### Done when

- Test proves mid-failure does not leave “closed in DB / open in settings” sellable state (or create path honors close row)  

---

## AH-2.3 — Cart/Checkout Money boundary (Must)

### Problem

Domain payable is satang `Money`; cart/checkout still carry **double** promo (and dual `grandTotal` vs `payableTotals` APIs).

### Target

- `promotionDiscountAmount` (and siblings on critical path) as `Money`  
- UI charge path uses `SalePayableCalculator` / `payableTotals` only  
- Deprecate or tightly comment legacy `grandTotal` if it excludes VAT  

### Tests

- Payable goldens unchanged  
- Checkout bloc unlock-on-failure still green  

---

## AH-2.4 — Inventory log write unify (Should)

### Problem

Sale path uses `InventoryLogService` (ambient TX); adjust path may insert via datasource — dual APIs / deviceId discipline.

### Target

One write API for append-only logs; always set `deviceId` when available; still **no nested TX** (ADR-004).

---

## AH-2.5 — Domain policy extraction (Should)

Move **decisions** to domain; keep **mechanisms** in data:

| Policy | Today | Target |
|--------|-------|--------|
| Discount max clamp | CreateSale + presentation `CartDiscountPolicy` | Single domain function |
| Tender == payable | `SaleInsertWriter` | Domain assert + writer enforces |
| Oversell / stock fulfill | Writer SQL + pre-check | Domain policy result → writer CAS |

Do **not** move raw SQL out of writers.

---

## AH-2.6 — MoneyConverter vs Phase M (Should decision)

| Option | When |
|--------|------|
| **Wire `MoneyConverter`** on REAL columns | Lower risk; improves type boundary without v31 |
| **Phase M INTEGER satang (C1+)** | After AH-GATE + C0 design; dual-write + fixtures |

**Solo rule:** Do not start C1 large migration in the same week as AH-2.1.

Record decision in this file’s status changelog + POST-090 WS-C pointer.

---

## Trust nets (must stay green)

- `.github/workflows/release-trust.yml`  
- `test/integration/sale_integrity_test.dart`  
- `test/integration/checkout_flow_test.dart`  
- `test/integration/multi_tender_daily_close_test.dart`  
- `test/features/sale/domain/services/sale_payable_golden_test.dart` (or equivalent path)  

---

## Out of scope

- Multi-currency  
- Multi-device stock authority  
- Changing soft-void (ADR-007)  

---

<sub>WS-AH-FISCAL · ARCH-HARDEN-1.0 · 2026-07-30</sub>
