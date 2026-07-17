# W-C — Test & Smoke Gates (P0)

**Parent:** [V090-TRUST-OVERVIEW.md](./V090-TRUST-OVERVIEW.md)  
**Status:** 🟢 Trust suite + smoke + C2 restore + **C4 concurrent stock** (2026-07-17)  
**Risk if skipped:** Green CI with broken money/security paths; weak tag confidence

---

## Problem

- CI coverage floor 50%; integration_test often `continue-on-error`
- Freeze / restore / PIN / SQLCipher automation thin in places
- `docs/testing/RELEASE_0.9_SMOKE.md` still Partial / N/A on cashier paths

---

## Tasks

| ID | Task | Evidence / path | Done |
|----|------|-----------------|------|
| **C1** | Expand `paymentLocked` matrix (qty / remove / discount / barcode while locked) | `cart_bloc_test` payment lock group | ✅ |
| **C2** | Backup restore: reject plain SQLite; pre_restore; full encrypt→restore round-trip | `backup_restore_service_test` (6 tests, 2026-07-17) | ✅ |
| **C3** | Harden `AppLockService` tests (with W-B) | `app_lock_service_test` (min 6, lockout, mock storage) | ✅ |
| **C4** | Concurrent stock / double-sale characterization | `sale_local_datasource_test` group **concurrent stock / double-sale (C4)** — 4 tests (parallel full/partial, sequential stale cart, void+re-sale); stock conservation + never negative | ✅ |
| **C5** | Document **release trust suite** as mandatory pre-tag commands | this doc + `release-trust.yml` + smoke command list | ✅ |
| **C6** | Fill smoke: cash, draft, daily close, restore file path | cash/draft/close **Pass (device UI)**; restore encrypt→restore **Pass (automated)**; OS share re-import optional | ✅ |
| **C7** | Release job: critical integration **blocking** | `.github/workflows/release-trust.yml` — money path fail-closed (no `continue-on-error`); main `ci.yml` keeps soft device `integration_test/` | ✅ |

---

## Trust suite (minimum — must be green before tag)

```text
flutter analyze

flutter test test/features/sale/data/datasources/sale_local_datasource_test.dart
flutter test test/integration/sale_integrity_test.dart
flutter test test/features/sale/domain/usecases/create_sale_test.dart
flutter test test/features/sale/domain/usecases/void_sale_test.dart
flutter test test/features/sale/domain/services/sale_payable_calculator_test.dart
flutter test test/core/utils/money_utils_test.dart
flutter test test/features/sale/presentation/bloc/cart_bloc_test.dart
flutter test test/features/sale/presentation/bloc/checkout_bloc_test.dart
flutter test test/core/services/app_lock_service_test.dart
flutter test test/features/settings/data/services/backup_encryption_service_test.dart
flutter test test/features/settings/data/services/backup_restore_service_test.dart
flutter test test/features/sale/presentation/bloc/draft_bloc_test.dart
flutter test test/integration/checkout_flow_test.dart
flutter test test/features/daily_close
```

*(Adjust exact paths if suite moves; keep list in sync when implementing.)*

### CI mapping

| Workflow | Money path (sale/draft/integrity) | Full `integration_test/` |
|----------|-----------------------------------|---------------------------|
| `ci.yml` | Covered inside `flutter test --coverage` (blocking) | **Soft** (`continue-on-error`) |
| `release-trust.yml` | **Explicit fail-closed** trust list (blocking) | Not required (device E2E optional) |

Triggers for Release Trust: `workflow_dispatch`, tags `v*`, PRs to `main` touching sale/daily_close/money paths.

Also keep green when touching create path: `sales_day_lock_test`, repository delegation tests.

---

## Smoke exit criteria

- [ ] Cashier paths in `RELEASE_0.9_SMOKE.md` are **Pass** (not N/A) for: cold start, cash or documented PromptPay substitute, draft, daily close when in scope, backup export/restore
- [ ] Known limits still honest: no cross-device key recovery in 0.9.0

---

## D0 dependency

Workstream **D** must not start extracts until this suite is green on the branch baseline (**D0**).
