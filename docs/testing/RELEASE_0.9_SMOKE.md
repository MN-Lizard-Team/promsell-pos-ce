# Release smoke checklist — v0.9.0

Run on a **real device or emulator** after schema upgrade / fresh install. Mark Pass / Fail / N/A.

| # | Case | Pass? | Notes |
|---|------|-------|-------|
| 1 | Cold start: encrypted DB opens (or first-run plain→SQLCipher migrate) | Manual | Device required |
| 2 | Sale: add product → cart → cash checkout → success | Manual / unit | Covered by sale DS + integrity tests |
| 3 | PromptPay: open wait → confirm (cart snapshot; edit cart mid-wait should not change sale lines) | Manual / unit | `checkout_bloc_test` freeze + `CartPaymentLock` |
| 4 | Draft: hold bill → reopen → totals sensible | Manual | |
| 5 | Daily close: close today once (unique `close_date`) | Manual | |
| 6 | Backup export with encryption + PIN ≥ 6 | Manual / unit | `backup_encryption_service_test` |
| 7 | Product full search + Sale full search (exact barcode paths) | Manual | |
| 8 | `flutter analyze lib` clean on release branch | **Pass** | 2026-07-15 CI-local: no issues |
| 9 | Critical unit/integration trust suite green | **Pass** | 2026-07-15: 100 tests (checkout/cart/sale DS/integrity/app lock/backup crypto+restore) |
| 10 | Same-device restore (Settings → Backup → Restore) + app restart | Manual | Service unit: SOURCE_MISSING / PIN_REQUIRED |
| 11 | Store PIN: enable → void / export / PromptPay change re-auth | Manual | `app_lock_service_test` session + min length |

## Known gaps (document at tag)

- No SQLCipher **key recovery** / cross-device restore (same-device only)
- CI `integration_test/` job may still `continue-on-error` (coverage floor raised to 50%)
- Full `flutter test --exclude-tags stress` not re-run in this sign-off pass (critical suite only)

## Command reference

```bash
flutter analyze lib
flutter test \
  test/features/sale/presentation/bloc/checkout_bloc_test.dart \
  test/features/sale/presentation/bloc/cart_bloc_test.dart \
  test/features/sale/data/datasources/sale_local_datasource_test.dart \
  test/integration/sale_integrity_test.dart \
  test/core/services/app_lock_service_test.dart \
  test/features/settings/data/services/backup_restore_service_test.dart \
  test/features/settings/data/services/backup_encryption_service_test.dart
# Optional full suite:
# flutter test --exclude-tags stress
```

Record runner, OS, build number, and date below when signing off.

- Runner: ZCode agent (automated items 8–9 + critical suite)
- Device/OS: win32 host — items 1–7, 10–11 need physical/emulator pass before store tag
- Date: 2026-07-15
- Sign-off: automated subset only
