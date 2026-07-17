# Release smoke checklist — v0.9.0

Run on a **real device or emulator** after schema upgrade / fresh install. Mark Pass / Fail / N/A with honest evidence (device UI vs automated suite).

| # | Case | Pass? | Notes |
|---|------|-------|-------|
| 1 | Cold start: encrypted DB opens (or first-run plain→SQLCipher migrate) | **Pass (device UI)** | **2026-07-17** after `flutter build apk --debug --flavor dev` + install on emulator-5554: log `Starting Promsell POS CE (dev flavor)` + `sqlcipher`. Screenshot: `screenshots/smoke_home_2026-07-17.png`. |
| 2 | Sale: add product → cart → cash checkout → success | **Pass (device UI)** | **2026-07-17** interactive: cart ฿177 (Hot Americano x3) → ชำระ → เงินสด → รับพอดี → ยืนยัน → receipt **#260717-LSR-0001** เงินสด ฿177.00. Screenshots: `smoke_checkout_2026-07-17.png`, `smoke_cash_done_2026-07-17.png`. Home later showed **฿177.00 จาก 1 บิล**. |
| 3 | PromptPay: open wait → confirm (cart snapshot; edit cart mid-wait should not change sale lines) | **Pass** | 2026-07-15 emulator: waiting QR frozen line; confirm → receipt. Not re-run 2026-07-17 (cash path exercised instead). |
| 4 | Draft: hold bill → reopen → totals sensible | **Pass (device UI)** | **2026-07-17**: add ฿59 line → บิลเปิด → บิลใหม่ → บันทึก/ยืนยัน park → list shows **B-16001 | 1 รายการ | ฿59.00** + empty active bill → reopen B-16001 → cart **฿59.00 | 1**. Screenshots: `smoke_draft_*_2026-07-17.png`. |
| 5 | Daily close: close today once (unique `close_date`) | **Pass (device UI)** | **2026-07-17**: Home → ปิดยอดวัน → 17/07/2026 เปิดอยู่ → ปิดยอด → ยืนยัน → status **ปิดแล้ว**; summary 1 bill, net **฿177.00**, cash expected **฿177.00**. Screenshot: `smoke_daily_close_done_2026-07-17.png`. |
| 6 | Backup export with encryption + PIN ≥ 6 | **Pass (gate)** | 2026-07-15: store PIN dialog before export PIN. Store PIN min length **6**. Not re-walked 2026-07-17. |
| 7 | Product full search + Sale full search | **N/A** | Not exercised on device this trust cut; not blocking money path. |
| 8 | `flutter analyze lib` clean | **Pass** | Re-checked on changed modules during trust work (2026-07-17). |
| 9 | Critical unit/integration trust suite | **Pass** | 2026-07-17 automated suites green (sale DS, integrity, cart, draft, daily_close, app_lock, backup, product_form, checkout_flow). |
| 10 | Same-device restore CTA + re-auth + encrypt→restore round-trip | **Pass (automated + gate)** | **2026-07-17 unit:** `backup_restore_service_test` full round-trip encrypt SQLCipher-like DB → restore `.enc` → live file matches + `pre_restore_*` + WAL/SHM purge; plain SQLite rejected; wrong PIN leaves live unchanged. Device UI: Restore button + store PIN re-auth (2026-07-15). Full OS share→file-pick on emulator still optional. |
| 11 | Store PIN: enable → PromptPay change re-auth | **Pass** | PIN min **6**; re-auth after force-stop / background `lockSession` (B6). FLAG_SECURE on PIN/PromptPay in this build. |
| 12 | Checkout failure unlocks cart (day closed / stock / error) without clearing lines | **Pass (unit)** | **2026-07-17** `checkout_bloc_test`: failure → `CartPaymentLockChanged(false)` + no `CartCleared`. Device re-walk optional. |
| 13 | PIN lockout persists across cold start; stock adjust + CSV import gated when lock on | **Pass (unit + code)** | **2026-07-17** `app_lock_service_test` hydrate/restart; `showAdjustStockSheet` / `openProductCsvImport` call `ensureAppUnlocked`. Device re-walk optional. |

## Device evidence

### 2026-07-17 (manual UI walk — this agent run)
- Device: `emulator-5554` · Android API **37** (Medium_Phone)
- Build: **rebuilt** `app-dev-debug.apk` (`flutter build apk --debug --flavor dev -t lib/main_dev.dart`) · installed via `adb install -r`
- Package: `com.promsell.promsell_pos_ce.dev`
- Cash: receipt `#260717-LSR-0001` · home revenue **฿177 / 1 บิล**
- Draft: park **B-16001** ฿59 → reopen cart ฿59
- Daily close: **17/07/2026 ปิดแล้ว** · net ฿177 · cash ฿177
- Screenshots under `screenshots/smoke_*_2026-07-17.png`

### 2026-07-15 (prior)
- PromptPay freeze sale · PIN gates · backup export/restore dialogs
- Screenshots: `smoke_screen1.png`, `smoke_promptpay_done.png`

## Automated evidence (still useful for regression)

| Area | Suite | Result (2026-07-17) |
|------|-------|---------------------|
| Cash data path | `checkout_flow_test.dart` | 3/3 |
| Draft bloc | `draft_bloc_test.dart` | 20/20 |
| Daily close | `test/features/daily_close` + `sales_day_lock_test` | 38 + 9 |

## Known gaps (document at tag)

- No SQLCipher **key recovery** / cross-device restore (same-device only)
- ~~Full encrypted-file restore round-trip~~ **automated Pass 2026-07-17** (`backup_restore_service_test`); OS share-sheet re-import on device still optional
- Main CI device `integration_test/` may still `continue-on-error`. **Money path fail-closed:** `.github/workflows/release-trust.yml` (C7); optional signed AAB: `.github/workflows/release-aab.yml` (E4)
- `injection_container.config.dart` is gitignored — run `dart run build_runner build` after clone
- **Signed AAB dry-run (E2):** **Pass 2026-07-17** — throwaway keystore (gitignored) produced `build/app/outputs/bundle/prodRelease/app-prod-release.aab` (91.5MB). **Do not use throwaway key for Play Store.** Production keystore remains merchant/operator owned.

## Command reference

```bash
flutter build apk --debug --flavor dev -t lib/main_dev.dart
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-dev-debug.apk

flutter test   test/features/sale/presentation/bloc/checkout_bloc_test.dart   test/features/sale/presentation/bloc/cart_bloc_test.dart   test/features/sale/data/datasources/sale_local_datasource_test.dart   test/integration/sale_integrity_test.dart   test/integration/checkout_flow_test.dart   test/core/services/app_lock_service_test.dart   test/features/settings/data/services/backup_restore_service_test.dart   test/features/settings/data/services/backup_encryption_service_test.dart   test/features/sale/presentation/bloc/draft_bloc_test.dart   test/features/sale/domain/services/sales_day_lock_test.dart   test/features/daily_close   test/features/product/presentation/pages/product_form_page_test.dart
```

- Runner: ZCode agent + Android emulator
- Date: **2026-07-17**
- Sign-off: **device UI** cash + draft park/reopen + daily close on rebuilt debug APK; prior PromptPay/PIN evidence retained
