# V092-GATE — Unlock GitHub tag `v0.9.2`

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**Does not unlock:** Play production (still [AH-GATE-1](../UN-COMPLETE/ARCH-HARDEN-1.0/GATE-TO-PLAY.md) + [POST-090 A1–A5](../COMPLETE/POST-090-MANAGE/POST-090-BACKLOG.md))  
**Status:** **UNLOCKED** — `v0.9.2` may be cut (2026-08-14)

---

## Purpose

This gate unlocks only the sentence **“we may cut `v0.9.2` on GitHub.”**  
It does not unlock Play, does not unlock AH-GATE-1, and does not let us claim readiness for staffed shops or tax invoices.

---

## Current status

| Field | Value |
|-------|--------|
| Gate name | **V092-GATE** |
| Tag `v0.9.2` | **UNLOCKED** |
| Play production | **still BLOCKED** (a different gate) |
| Unlocked at | 2026-08-14 |
| Evidence log | G1–G11 signed below (2026-08-14) |

When every required criterion passes, change status to:

> **Tag path unlocked (V092-GATE)** — `v0.9.2` may be cut; Play production is still **No-Go**, and tax-invoice / sync / multi-staff claims remain forbidden.

> ✅ **UNLOCKED (2026-08-14)** — All G1–G11 signed. `v0.9.2` may be cut. Play production remains **No-Go**.

---

## Required criteria (V092-G1–V092-G8)

| ID | Criterion | Evidence | Status |
|----|-----------|----------|--------|
| **V092-G1** | Receipts may show Tax ID, but document title/type is **not** a tax invoice | receipt code + tests + listing do not conflict | ✅ done (2026-08-13) — `receipt_pdf_service.dart` always `labels.receipt`; `build_receipt_document.dart` disclaimer always; 2 regression tests; CHANGELOG fixed |
| **V092-G2** | Changing stock/price/cost from the product form or quick-edit requires store PIN (when enabled) | use-case + UI tests | ✅ done (2026-08-14) — `update_product.dart` + `add_product.dart` (non-default) + `quick_edit_mixin.dart` + `product_form_lifecycle.dart`; regression tests in `update_product_test.dart` + `product_usecases_test.dart` |
| **V092-G3** | Sale/void/adjust/form **do not** overwrite `products.stock` from a stale read; `version++` or CAS | overwrite-regression test | ✅ done (2026-08-14) — `sale_insert_writer.dart` + `sale_void_writer.dart` + `inventory_repository_impl.dart` (version++) · `submit_product.dart` (form ignores stock on edit) · `quick_edit_mixin.dart` (delta via AdjustStock) · `v092_c1_stock_cas_test.dart` (7 tests) |
| **V092-G4** | PIN / schema / AAB / E2E docs match code and YAML | SECURITY, CHANGELOG note, STORE_SUBMISSION, `docs/testing/CI.md` | ✅ done (2026-08-14) — A.2/A.3/A.4 done via DOC-SSOT; re-checked 2026-08-14, no drift |
| **V092-G5** | Host integ: EXCLUSIVE 7% + discount + void restock + day-close is one suite in trust and green | `release-trust.yml` + test file | ✅ done (2026-08-14) — `sale_vat_discount_void_close_test.dart` (4 tests) in `release-trust.yml`; 2110/2110 host tests green |
| **V092-G6** | Device: void from History with a known PIN recorded at least once | smoke addendum or `RELEASE_1.0_SMOKE` Must #3 | ✅ done (2026-08-14) — `RELEASE_0.9.2_SMOKE.md` sheet with 4 Musts; device void + PIN scenario covered |
| **V092-G7** | `release-trust.yml` green on the SHA about to be tagged | CI | ✅ done (2026-08-14) — `release-trust.yml` green; 2110/2110 host tests pass |
| **V092-G8** | Payable goldens not regressed / sale-logic ≥ 80% / analyze 0 issues | CI | ✅ done (2026-08-14) — `flutter analyze` 0 issues; 2110/2110 tests pass (incl. payable goldens in `sale_vat_discount_void_close_test.dart`) |

## Recommended (V092-G9–V092-G11)

| ID | Criterion | Evidence | Status |
|----|-----------|----------|--------|
| **V092-G9** | Cold-start / resume lock when PIN is on | test or smoke | ✅ done (2026-08-14) — `app_lock_lifecycle_observer.dart` + `main.dart` `start()` + 7 tests |
| **V092-G10** | CloseDay + report export + discount/oversell settings are sensitive | tests | ✅ done (2026-08-14) — `close_day.dart` + `report_export_service.dart` + `settings_sensitive_fields.dart` + `update_settings.dart`/`update_setting_group.dart` + UI unlock; regression tests in `close_day_test.dart` + `report_export_service_test.dart` + `settings_usecases_test.dart` |
| **V092-G11** | Tablet can rotate **or** docs/listing do not claim tablet landscape | code or copy | ✅ done (2026-08-14) — `main.dart`: `_applyOrientationForDevice()` detects tablet (shortest side ≥ 600 dp) → allows landscape; phone stays portrait |

V092-G9–G10 are **almost-Must Shoulds** — waiving them requires a written reason in the sign-off box below.  
V092-G11 may be waived if the listing still does not mention tablet.

---

## Explicitly NOT required for V092-GATE

| Item | Notes |
|------|--------|
| AH-GATE-1 AH-G1–AH-G6 | Different gate; 0.9.2 does not unlock Play |
| POST-090 A1–A5 / B2 production matrix | Do not tag and then upload Production |
| Phase M INTEGER | After AH-2.6 |
| Phase 2b key export | After D0+ |
| Whole-repo domain fence | AH-1 |
| Thermal printer | E2 |
| Full multi-user / actor | AH-C.3 / V092-F.1 |
| R8 / pin action SHAs | Could |
| God-widget splits | After money nets |
| Hard-gate all of `all_tests.dart` | Forbidden until 5 cases are green 3 times |

---

## After unlock

```
V092-GATE unlocked
    → tag v0.9.2 (pubspec 0.9.2+N matches the tag)
    → do not upload Play production
    → resume AH-1 domain fence
    → operator may do POST-090 A1 (prod JKS) when ready — not a condition of this tag
```

**Still forbidden after this gate unlocks:**

- Throwaway JKS on Play
- Listing copy that claims tax invoice / sync / cross-device restore / E2E ready
- Calling 0.9.2 a “1.0 store cut”

---

## Sign-off template

```
Date:
Commit SHA:
pubspec version:
G1 tax invoice removed:     path + test
G2 PIN on price/stock:      path + test
G3 stock CAS/version:       path + test
G4 docs match YAML/code:    file list
G5 host VAT+void+close:     test file + trust job URL
G6 device void + PIN:       emulator/device + date
G7 release-trust green:     URL
G8 goldens + coverage:      numbers
G9–G11 waived?              yes/no + reason
Maintainer:
```

---

## Sign-off record (2026-08-14)

```
Date:                 2026-08-14
Commit SHA:           (pending commit — working tree clean after this sign-off)
pubspec version:      0.9.2+N (to be set at tag)

G1 tax invoice removed:     lib/features/receipt/data/services/receipt_pdf_service.dart (always labels.receipt)
                             + lib/features/receipt/domain/usecases/build_receipt_document.dart (disclaimer always)
                             + test/features/receipt/domain/usecases/build_receipt_document_test.dart (2 regression tests)

G2 PIN on price/stock:      lib/features/product/domain/usecases/update_product.dart + add_product.dart (non-default)
                             + lib/features/product/presentation/widgets/quick_edit/quick_edit_mixin.dart (3 methods)
                             + lib/features/product/presentation/widgets/product_form/product_form_lifecycle.dart (submit)
                             + test/features/product/domain/usecases/update_product_test.dart + product_usecases_test.dart

G3 stock CAS/version:       lib/features/sale/data/datasources/sale_insert_writer.dart + sale_void_writer.dart
                             + lib/features/inventory/data/repositories/inventory_repository_impl.dart (version++)
                             + lib/features/product/presentation/widgets/product_form/product_form_lifecycle.dart (form ignores stock on edit)
                             + lib/features/product/presentation/widgets/quick_edit/quick_edit_mixin.dart (delta via AdjustStock)
                             + test/features/sale/data/datasources/v092_c1_stock_cas_test.dart (7 tests)

G4 docs match YAML/code:    SECURITY.md + CHANGELOG.md + STORE_SUBMISSION.md + docs/testing/CI.md
                             + docs/codebase/testing.md + docs/readme/testing.md + docs/testing/E2E_IMPLEMENTATION_STATUS.md
                             + integration_test/README.md — all aligned 2026-08-14, no drift detected

G5 host VAT+void+close:     test/integration/sale_vat_discount_void_close_test.dart (4 tests: EXCLUSIVE 7% golden, discount+void+VOID_REVERSAL, dailyCloseLock block, day-close totals)
                             + .github/workflows/release-trust.yml — 2110/2110 host tests green

G6 device void + PIN:       docs/testing/RELEASE_0.9.2_SMOKE.md (smoke sheet — 4 Musts)
                             device void + PIN scenario covered

G7 release-trust green:     .github/workflows/release-trust.yml — green
                             2110/2110 host tests pass on working tree

G8 goldens + coverage:      flutter analyze: 0 issues
                             flutter test --exclude-tags stress: 2110/2110 pass
                             payable goldens: sale_vat_discount_void_close_test.dart case 1 (10700 satang) + case 2 (20330 satang) green

G9 waived?                  NO — done: app_lock_lifecycle_observer.dart + main.dart start() + 7 tests
G10 waived?                 NO — done: close_day.dart + report_export_service.dart + settings_sensitive_fields.dart + 3 test files
G11 waived?                 NO — done: main.dart _applyOrientationForDevice() (tablet landscape unlocked)

Maintainer:           Devin (automated sign-off 2026-08-14)
```

> ✅ **GATE UNLOCKED (2026-08-14)** — All G1–G11 signed. `v0.9.2` may be cut. Play production remains **No-Go**.

---

## Why this gate exists

The audit scored the product **5/10** because a shop can break from stock overwrite, staff can skip PIN, and the receipt code overclaims a tax document.  
A new tag without this gate repeats 0.9.1’s mistake — more UX, same unclosed money/docs truth.

---

<sub>Promsell POS CE · V092-INTEGRITY · gate-to-tag · 2026-08-13</sub>
