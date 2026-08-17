# RELEASE 0.9.3 — Device Smoke Sheet

**Status:** Pass required before 0.9.3 tag
**Device:** _AVD model + Android API level (fill in when run)_
**Date:** _YYYY-MM-DD (fill in when run)_
**Test PIN:** _from TestApp onboarding seed — not a merchant PIN_

> **Do not call this a 1.0 Go.** The `RELEASE_1.0_SMOKE.md` sheet is still **No-Go** (M2, prod AAB belong to 1.0). This sheet covers the 0.9.3 scope: **refactor verification** — same money path as 0.9.2 (cold-start + PIN + void + stock restore) plus a 0.9.2→0.9.3 migration check. No new features; the goal is to confirm the god-file extraction (`app_database_migrations.dart`, `PinHasher`, `LockoutPolicy`, `DraftSaveCoordinator`, `SavedBillsCheckoutHelper`) did not regress the money path.

---

## Must — required before tag

| # | Must | Required before tag | Result | Notes |
|---|------|---------------------|--------|-------|
| 1 | Cold start + PIN unlock | **Pass** | ☐ | App locks on cold start when PIN is enabled. Unlock with test PIN. |
| 2 | One cash sale | **Pass** | ☐ | Add product to cart → checkout → cash payment → receipt generated. Stock decremented. |
| 3 | Void + PIN + stock restored | **Pass** | ☐ | History → tap sale → void → enter test PIN → stock restored. `VOID_REVERSAL` log in inventory. |
| 4 | Day-close (if time) | Pass or N/A with reason | ☐ | Close day → expected cash matches. If not tested, write N/A + reason. |
| 5 | DB migration 0.9.2 → 0.9.3 | **Pass** | ☐ | Install 0.9.2 build → create sale + draft → install 0.9.3 build → cold start → data intact. Schema v32 unchanged, no new migration step. |

---

## Test PIN source

The test PIN must come from one of:

1. **TestApp onboarding seed** — `integration_test/helpers/test_app.dart` seeds `onboardingCompleted=true`. If the test seeds a PIN via `AppLockService.setPin`, document the PIN here.
2. **Documented seed** — if using a manual emulator walk, set the PIN during onboarding and record it here. **Do not use a real merchant PIN.**

| Field | Value |
|-------|-------|
| Test PIN | _fill in_ |
| Source | _TestApp seed / manual onboarding_ |
| Set by | _test harness / human_ |

---

## How to run (manual emulator walk)

```bash
# 1. Build dev flavor
flutter build apk --flavor dev -t lib/main_dev.dart

# 2. Install on emulator
adb install build/app/outputs/flutter-apk/app-dev-debug.apk

# 3. Walk the 5 Musts above
# 4. Record results in this file
# 5. Commit this file with the date + device filled in
```

### Migration verification (Must #5)

```bash
# 1. Install 0.9.2 build, create a sale + a saved draft
# 2. adb install -r build/app/outputs/flutter-apk/app-dev-debug.apk  (0.9.3)
# 3. Cold start → confirm sale history + draft list intact
# 4. Reopen draft → checkout → receipt sequence continues
```

---

## What this sheet does NOT cover

- Multi-tender (cash + PromptPay) — covered by host `multi_tender_daily_close_test.dart`
- VAT EXCLUSIVE 7% full path — covered by host `sale_vat_discount_void_close_test.dart` (V092-D.1)
- Void after day-close — covered by host `void_after_day_close_test.dart` (V092-D.4)
- Backup encrypt/restore — covered by host `backup_money_continuity_test.dart`
- 10k-SKU stress — `@Tags(['stress'])`, not on every PR
- Prod AAB / Play Store — belongs to 1.0
- **New features** — 0.9.3 is a refactor-only release; no new user-facing behavior

---

<sub>Promsell POS CE · v0.9.3 · Device Smoke · Refactor verification</sub>
