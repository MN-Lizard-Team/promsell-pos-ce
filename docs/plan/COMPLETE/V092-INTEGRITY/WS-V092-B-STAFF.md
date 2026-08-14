# WS-V092-B — Staff control (PIN holes + lock + leftovers)

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** V092-B.1 … V092-B.9  
**Status:** B.1 / B.2 / B.3 / B.4 / B.5 / B.6 done (2026-08-14); B.7–B.9 still Could/deferred

---

## Implementation log (2026-08-14)

| ID | Status | Evidence |
|----|--------|----------|
| V092-B.1 | **done** | `update_product.dart` + `add_product.dart` (non-default stock/price/cost) + `quick_edit_mixin.dart` (name/price/stock) + `product_form_lifecycle.dart` submit; regression tests in `update_product_test.dart` + `product_usecases_test.dart` |
| V092-B.2 | **done** | `app_lock_lifecycle_observer.dart` (app-level `WidgetsBindingObserver`) + `main.dart` `start()` call; locks on cold start when PIN enabled + on `paused`/`hidden`/`detached`; 7 tests in `app_lock_lifecycle_observer_test.dart` |
| V092-B.3 | **done** | `close_day.dart` + `report_export_service.dart` (exportPdf/exportCsv) + `settings_sensitive_fields.dart` (`settingsSensitivePolicyChanged` + `settingsSensitiveChanged`) + `update_settings.dart`/`update_setting_group.dart` + `daily_close_page.dart`/`report_page.dart` UI unlock; regression tests in `close_day_test.dart` + `report_export_service_test.dart` + `settings_usecases_test.dart` |
| V092-B.4 | **done** | `backup_restore_service.dart` `cleanupPreRestoreBackups()` + `main.dart` startup call + 3 tests in `backup_restore_service_test.dart` |
| V092-B.5 | **done** | `app_lock_settings_page.dart` + `promptpay_settings_page.dart` toggle `SecureScreen.setSecure(true)` in initState / false in dispose |
| V092-B.6 | **done** | `AppLockService.trivialPinBlocklist` + `isTrivialPin` + `setPin`/`changePin` reject with `PIN_TOO_TRIVIAL`; l10n `appLockPinTooTrivial` (en+th); 5 tests in `app_lock_service_test.dart` |
| V092-B.7 | deferred | `resetOnError: false` + separate DB-key vs PIN storage namespaces — data-loss design risk |
| V092-B.8 | deferred | Shorten 2-minute grace or split owner vs cashier step-up — wait for actor |
| V092-B.9 | deferred | Reject backup envelope v1 — after a migrate window |

**Verification:** `flutter analyze` 0 issues; 110 affected tests pass (15 test files).

---

## Goal

CE’s permission model is still **one shared PIN**. This slice does not invent multi-user.

Target: every path docs call sensitive is gated in domain **on every entry**, and a device with PIN on must not sell / show totals the moment someone picks it up off the counter.

Already correct (do not regress):

- `VoidSale`, `AdjustStock`, `ImportProducts`, backup export/restore → `requireSensitiveSession()`
- Onboarding `_ensureStorePinBeforeComplete()`

---

## V092-B.1 — Price / stock / cost on every entry

### Problem

`AdjustStock` is PIN-gated.  
`UpdateProduct` / `product_local_datasource` write `stock` directly, and `quick_edit_sheet.dart` has price/stock fields with no PIN.  
SECURITY §8 therefore overclaims.

### Target

| Action | Requires PIN if store PIN is on |
|--------|----------------------------------|
| Adjust stock from the inventory sheet | Existing — keep |
| Set stock/price/cost on the product form | **New** |
| Quick-edit price or stock | **New** |
| CSV import (existing) | Keep |
| Sale deduct / void restock | **Do not** prompt PIN on every bill |

### Implementation sketch

1. `rg` every writer of `products.stock|price|cost`.
2. Stop the datasource short-circuit — go through a use case that calls `requireSensitiveSession()`.
3. Quick-edit: call `ensureAppUnlocked` before opening or committing price/stock **and** re-check in the use case.
4. If the session was unlocked for a void 30 seconds ago, honor the current grace (do not change M8 in the same PR).

### Tests

- unit: `UpdateProduct` throws when PIN is on and the session is locked.
- widget: quick-edit stock field shows the PIN dialog.
- Do not leave `isEnabled() => false` as the only mock in adjust-stock sheet tests — add enabled+locked.

### Done when

- No path changes price/stock/cost without the domain gate.
- SECURITY §8 is true without a footnote.

---

## V092-B.2 — Lock on cold start / return from background

### Problem

`main.dart` + `MainShell` never ask for PIN on cold start.  
`lockSession()` runs on background but does not prompt on resume.  
Anyone who picks up an OS-unlocked device can sell, open reports, see PromptPay, and see customers immediately.

### Target (minimum for 0.9.2)

1. If store PIN is on: show the PIN gate **before** `MainShell` (after onboarding).
2. Returning from background past a short threshold (keep current grace or shorten — decide in the PR, record in SECURITY).
3. Fail/cancel = do not sit on the sale tab.

Do not add two PINs (owner/cashier) — that is multi-user.

### Implementation sketch

- Existing service: `lib/core/services/app_lock_service.dart`
- Composition point: `PromsellApp` / an overlay similar to onboarding
- Do not sprinkle gates on every page — one root layer
- FLAG_SECURE already wraps this dialog — keep it

### Tests

- widget: PIN on → pump app → sale tabs not visible until unlock
- PIN off (if Settings still allows it) → enter as today

### Done when

- Audit H2 is closed for installs with PIN on (the 0.9.1+ default).

---

## V092-B.3 — Day-close / export / money policy

### Problem

`CloseDay` has no PIN.  
`ReportExportService` can send PDF/CSV of totals + cost + margin with no PIN.  
`settingsSensitivePaymentChanged` only covers PromptPay / biller.  
`maxDiscountPercent` / `maxDiscountAmount` / `allowOversell` / `dailyCloseLock` / `backupEncryptionEnabled` are not sensitive.

### Target

Call `requireSensitiveSession()` on:

- `CloseDay`
- report and history export (PDF/CSV)
- persisting settings: max discount, oversell, day-lock, backup encryption on/off

A UI prompt alone is not enough — domain must refuse.

### Tests

- CloseDay with locked session → throws, does not write `daily_closes`
- export blocked when locked
- changing `allowOversell` while locked → does not persist

---

## V092-B.4 — Restore leftovers (Should)

`backup_restore_service.dart` writes `promsell_pos.pre_restore_<stamp>.db` and never deletes it.

- Delete after the new DB opens successfully.
- Keep the file if open fails (rollback).
- Tests: success leaves no pre_restore; failure still has it.

Do not fail restore silently if leftover delete fails — log, then continue after the new DB is healthy.

---

## V092-B.5 — FLAG_SECURE on PIN settings (Should)

`SecureScreen` is used in `app_lock_pin_dialog.dart` and PromptPay.  
`app_lock_settings_page.dart` has its own PIN fields without it.

Wrap create/disable/change PIN with `SecureScreen`.  
Whole-app FLAG_SECURE = later (hits cashier Recents — decide later).

---

## V092-B.6 — Block trivial PINs (Should)

Reject at least: `000000` `111111` `123456` `654321` `012345` and any 6 identical digits.  
Apply to onboarding `setPin` and Settings `changePin`.  
Do not bump length to 8 in this slice (backup envelopes are 6-digit — different KDF).

---

## Deferred (B.7–B.9)

### V092-B.7 — `resetOnError: false` + separate DB-key vs PIN storage namespaces

**Status:** deferred to Phase 2b (POST-090 D — key export / recovery). Not in v0.9.2.

#### What it would fix

`FlutterSecureStorage` defaults to `AndroidOptions(resetOnError: true)`. If the Android Keystore is corrupted (rare OS upgrade edge cases, Keystore bug on specific OEM builds), secure storage **silently deletes the existing key and creates a new one** instead of throwing. For the SQLCipher DB key this means:

- New key generated → `PRAGMA key` no longer matches the encrypted DB file → **DB unreadable → permanent data loss** (sales, catalog, settings, PIN hash — everything).
- No crash, no warning — the app just opens an empty DB and the shop discovers the loss when they look for history.

`AppLockService` shares the same default `FlutterSecureStorage` instance, so a Keystore reset would also wipe the PIN hash at the same time — the shop cannot even tell something went wrong because the app behaves as if PIN was never set.

#### Why deferred (trade-offs)

| Option | Pro | Con | Verdict |
|--------|-----|-----|---------|
| **A. Do nothing (current)** | No migration risk; app keeps working on the common path | Silent permanent data loss on Keystore corrupt (rare but catastrophic, no recovery) | Accepted for v0.9.2 with explicit known-limitation doc |
| **B. `resetOnError: false` on DB key only** | Key not silently wiped; data still on disk (just inaccessible until recovery) | App crashes on every launch until recovery path exists; without Phase 2b key export there is **no recovery path** — shop is locked out of their own data with no way back | Rejected for v0.9.2 — turns "silent data loss" into "hard lockout with no escape hatch", worse UX for the shop |
| **C. `resetOnError: false` + separate namespaces** | Same as B + reduces blast radius (PIN reset does not take DB key with it) | Same no-recovery problem as B; namespace migration adds complexity and its own risk on existing installs | Rejected for v0.9.2 — same reason as B |
| **D. Full B.7 + Phase 2b key export** | Closes the hole end-to-end: key survives Keystore corrupt AND shop can recover via exported key | Requires key-export UI, secure key wrapping, user-managed recovery secrets — a full work package, not a v0.9.2 patch | Targeted for Phase 2b (POST-090 D) |

**Decision rationale:** Options B and C make the **common case worse** (crash loop on the rare Keystore-corrupt device) while only helping the **rare case** partially (data preserved but still inaccessible). Without a recovery path, "data on disk but unreadable" is not meaningfully better than "data gone" for the shop — both mean they cannot sell or see history. The honest trade-off is to keep the current behavior, document it loudly as a known breaking limitation, and ship the real fix with Phase 2b key export so recovery is possible.

#### Additional trade-offs accepted by deferring

1. **No blast-radius isolation between DB key and PIN.** A single Keystore reset takes both. Splitting namespaces (part of B.7) would at least let the shop re-set their PIN while the DB key issue is being diagnosed — but only matters if the DB key itself is recoverable, which requires Phase 2b.
2. **No telemetry / detection.** Without `resetOnError: false` we cannot tell that a reset happened, so the app will not warn the shop or prompt them to restore from a backup. A future hardening could detect "DB file exists but key is fresh" and surface a recovery dialog — but that also needs the recovery path.
3. **Backup is the only mitigation today.** The shop must export encrypted backups regularly and store them off-device. Same-device restore still needs this device's SQLCipher key, so after a Keystore wipe the only recovery is: restore the `.enc` backup **on a different device** that still has its key, or wait for Phase 2b. This is already documented in `SECURITY.md` §"Backup & recovery" but is now called out as the explicit workaround for B.7.
4. **CE-only scope.** This is Community Edition — there is no server-side key escrow or account-based recovery. The fix must be fully on-device, which is why Phase 2b designs a user-managed recovery key rather than a server restore.

#### Mitigation shipped in v0.9.2

- `SECURITY.md` §"Backup & recovery" now explicitly states that `resetOnError: true` is the current behavior and that Keystore corruption can cause silent data loss.
- `CHANGELOG.md` marks this as a **known breaking limitation** of v0.9.2 so operators see it before upgrading.
- Backup encryption default-on (already in 0.9.0) + B.4 pre-restore cleanup reduce (but do not eliminate) the risk window.
- The recommended practice (regular encrypted backup export, stored off-device) is the only recovery path until Phase 2b.

#### When it will be done

Phase 2b (POST-090 D — `WS-D-PHASE-2B-KEY-RESTORE.md`) designs the key export / recovery flow. B.7 (`resetOnError: false` + split namespaces) should land in the same PR as the recovery path so the shop is never locked out without a way back.

| B.7 sub-item | Lands with |
|--------------|-----------|
| `resetOnError: false` on `DbKeyStore` | Phase 2b recovery UI |
| Separate `FlutterSecureStorage` namespace for DB key vs PIN | Phase 2b (same PR) |
| Detect "fresh key + existing DB" → recovery dialog | Phase 2b |
| Telemetry / log on key reset | Optional, Phase 2b or later |

---

### V092-B.8 / B.9 — deferred (unchanged)

| ID | Why later |
|----|-----------|
| B.8 shorten grace / step-up | Wait for actor; changing now hits cashiers |
| B.9 reject backup envelope v1 | Needs a migrate window |

---

## Ordering

```
B.1 (in-shop money hole)     ★ before tag
B.3 (day-close / export / policy)
B.2 (app lock)               ★ almost Must (GATE G9)
B.4 leftovers ∥ B.5 FLAG ∥ B.6 blocklist
```

Do not combine B.2 and B.8 in one PR.

---

<sub>Promsell POS CE · V092-INTEGRITY · WS-B staff · 2026-08-13</sub>
