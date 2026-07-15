# Release smoke checklist — v0.9.0

Run on a **real device or emulator** after schema upgrade / fresh install. Mark Pass / Fail / N/A.

| # | Case | Pass? | Notes |
|---|------|-------|-------|
| 1 | Cold start: encrypted DB opens (or first-run plain→SQLCipher migrate) | **Pass** | Emulator API 37: `Starting Promsell POS CE (dev flavor)` + `sqlcipher` log; process stayed up; home loaded |
| 2 | Sale: add product → cart → cash checkout → success | Partial | PromptPay path completed instead (item 3); product add + cart OK |
| 3 | PromptPay: open wait → confirm (cart snapshot; edit cart mid-wait should not change sale lines) | **Pass** | Waiting QR showed frozen line `Hot Americano x13 ฿767`; confirm → receipt `#260715-LSR-0001`; home **฿767 / 1 บิล** |
| 4 | Draft: hold bill → reopen → totals sensible | N/A | Not exercised this run |
| 5 | Daily close: close today once (unique `close_date`) | N/A | Not exercised this run |
| 6 | Backup export with encryption + PIN ≥ 6 | **Pass (gate)** | After force-stop, **Backup Now** shows store PIN dialog `ยืนยันการส่งออกสำรอง` before export PIN |
| 7 | Product full search + Sale full search | N/A | Not exercised this run |
| 8 | `flutter analyze lib` clean | **Pass** | 2026-07-15: no issues |
| 9 | Critical unit/integration trust suite | **Pass** | 100 tests green |
| 10 | Same-device restore CTA + re-auth | **Pass (gate)** | Restore button visible (TH); after force-stop shows store PIN `ยืนยันการกู้คืนสำรอง` (file pick not completed — no shared backup file on emulator) |
| 11 | Store PIN: enable → PromptPay change re-auth | **Pass** | Enabled PIN `1234`; after force-stop, PromptPay ID save shows `ยืนยันการเปลี่ยน PromptPay`; unlock updates mask `••••9999` |

## Device evidence (this run)

- Device: `sdk gphone16k x86 64` · `emulator-5554` · Android 17 (API 37)
- Package: `com.promsell.promsell_pos_ce.dev`
- Build: `app-dev-debug.apk` (2026-07-15)
- DB path present: `app_flutter/promsell_pos.db` (+ wal/shm); SQLCipher load logged
- Screenshots (workspace): `smoke_screen1.png`, `smoke_promptpay_done.png`

## Known gaps (document at tag)

- No SQLCipher **key recovery** / cross-device restore (same-device only)
- Full encrypted-file restore round-trip (export → share → re-import) not completed on emulator (OS share/file pick)
- CI `integration_test/` job may still `continue-on-error` (coverage floor 50%)
- `injection_container.config.dart` is gitignored — run `dart run build_runner build` after clone

## Command reference

```bash
dart run build_runner build
flutter analyze lib
flutter build apk --debug --flavor dev -t lib/main_dev.dart
flutter test \
  test/features/sale/presentation/bloc/checkout_bloc_test.dart \
  test/features/sale/presentation/bloc/cart_bloc_test.dart \
  test/features/sale/data/datasources/sale_local_datasource_test.dart \
  test/integration/sale_integrity_test.dart \
  test/core/services/app_lock_service_test.dart \
  test/features/settings/data/services/backup_restore_service_test.dart \
  test/features/settings/data/services/backup_encryption_service_test.dart
```

- Runner: ZCode agent + Android emulator
- Device/OS: emulator-5554 Android 17
- Date: 2026-07-15
- Sign-off: automated suite + emulator UI smoke for cold start, PromptPay sale, PIN gates (export/restore/PromptPay)
