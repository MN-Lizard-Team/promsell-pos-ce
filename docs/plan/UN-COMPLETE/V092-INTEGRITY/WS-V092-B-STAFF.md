# WS-V092-B — Staff control (PIN holes + lock + leftovers)

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** V092-B.1 … V092-B.9  
**Status:** todo (wave V092-1)

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

| ID | Why later |
|----|-----------|
| B.7 `resetOnError: false` + split namespaces | Wrong setting makes the DB unreadable; design with Phase 2b |
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
