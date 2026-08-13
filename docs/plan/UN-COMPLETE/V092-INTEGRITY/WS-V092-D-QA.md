# WS-V092-D — QA nets (host + device + CI honesty)

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** V092-D.1 … V092-D.8  
**Status:** todo (wave V092-2)

---

## Goal

Host money math is already strong (satang goldens, parallel-sale CAS, tender mismatch).  
What merchants touch is still thin: **no full-path VAT bill, device void never finished, E2E docs contradict CI**.

This slice does not chase whole-app 80% coverage and does not hard-gate all of `all_tests.dart`.

---

## V092-D.1 — Host integ, full money path (Must)

### Problem

All five files under `test/integration/` send `vatMode: 'NONE'`.  
VAT/discount are tested at the datasource, but nothing proves one path:

real bill → persist → void restock → day-close totals match `SalePayableCalculator`

### Target — one file, one story

`test/integration/sale_vat_discount_void_close_test.dart` (name may vary)

Minimum cases:

1. SKU 100, EXCLUSIVE 7%, no discount → `totalAmount` matches golden 10700 satang / stock down.
2. Cart + discount or promo + EXCLUSIVE 7% → total matches calculator → void → stock back + `VOID_REVERSAL` log.
3. (Should, same file or next) `dailyCloseLock` on, close day, `VoidSale` use case throws — do **not** call `saleDs.voidSale` directly.

Add the file to `.github/workflows/release-trust.yml`.  
Do not treat `vatMode: NONE` as a stand-in for a Thai shop.

### Done when

- Trust goes red if payable and post-void stock disagree.
- GATE G5 can be ticked.

---

## V092-D.2 — Device void + known PIN (Must)

### Problem

`RELEASE_1.0_SMOKE.md` Must #3 = Blocked because the emulator PIN was unknown.  
`integration_test/` has no void journey (`rg void` only hits `void main`).

### Target

One of (preferred first):

1. **Best:** an `integration_test/` case — cash sale → History → void → type the test PIN → stock restored.
2. **Acceptable for the tag:** a manual emulator walk recorded in `docs/testing/RELEASE_0.9.2_SMOKE.md` (create new; do not overwrite the still-No-Go 1.0 sheet).

The test PIN must come from TestApp onboarding / a documented seed — do not guess.

Create a thin `docs/testing/RELEASE_0.9.2_SMOKE.md`:

| Must | Required before tag |
|------|---------------------|
| Cold start + PIN unlock (if B.2 landed) | Pass |
| One cash sale | Pass |
| Void + PIN + stock restored | **Pass** |
| Day-close (if time) | Pass or N/A with reason |

Do not call this file a 1.0 Go.

### Done when

- G6 has a date + AVD/device name + a test PIN, not a merchant PIN.

---

## V092-D.3 — E2E docs = workflow (Must, pairs with A.3)

Update to 2026-08-13+ reality:

| Point | Reality |
|-------|---------|
| `ci.yml` | Does not run device; format + analyze `integration_test/` |
| `release-trust.yml` | Runs `integration_test/all_tests.dart --flavor dev` **blocking** on money paths and tags |
| `screenshots.yml` | Visual; does not assert money |
| Whole device E2E suite | Still scaffold / flake — do not market it as ready |

Files: `docs/codebase/testing.md`, `docs/readme/testing.md` (stamp or drop the 2026-07-23 table), `docs/testing/E2E_*.md`, `integration_test/README.md`.

---

## V092-D.4 — Void after day-close, full stack (Should)

`void_sale_test.dart` mocks the repo.  
`sale_integrity_test.dart` calls the datasource and skips day-lock / PIN.

Add a test that walks `VoidSale` on a real DB + `dailyCloseLock` + a `daily_closes` row.  
Must live in trust.

---

## V092-D.5 — TestApp less flake (Should)

`integration_test/helpers/test_app.dart`

- Drop `pumpAndSettle` in `restartApp`.
- Do not rely on EN strings (`Cash`, `Coffee`) as the primary selector — add `Key`s.
- Watch double `configureDependencies()`.

Do not make `android-smoke` a harder gate on the whole suite until the 5 cases below are green 3 times.

Five-case target (POST-090 B4 roots — this slice starts them):

1. Add product → exact cash → stock down
2. History void + PIN → stock back
3. Discount → on-screen total = DB total
4. Day-close + lock → cannot pay
5. Park bill → reopen, same total

Case 2 = D.2.  
The others are Should for 0.9.2.

---

## V092-D.6 / D.7 / D.8 — Could the audit still named

| ID | Work |
|----|------|
| D.6 | Restore case that opens a real SQLCipher file and reads totals/stock — do not rely on `PROMSNAP1` alone |
| D.7 | Add `onboarding_first_sale_test.dart` to the trust list |
| D.8 | Split or add `--flavor prod` smoke — overlaps POST-090 A5; do not mark A5 done |

---

## Out of this slice

- Chase global coverage 70/80
- Ten screenshots as a money gate
- 10k-SKU stress on every PR
- Call 0.9.2 a close of the whole `RELEASE_1.0_SMOKE` sheet (M2, prod AAB still belong to 1.0)

---

## Ordering

```
D.3 docs (pairs A.3, can start now)
D.1 host VAT suite   ★ after or with C.1
D.5 Keys / TestApp
D.2 device void      ★ after B.2 at least has a PIN entry path
D.4 / D.6 / D.7 as nets allow
```

---

<sub>Promsell POS CE · V092-INTEGRITY · WS-D QA · 2026-08-13</sub>
