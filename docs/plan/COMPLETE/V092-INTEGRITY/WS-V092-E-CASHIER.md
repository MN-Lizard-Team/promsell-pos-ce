# WS-V092-E — Cashier survive (tablet / ANR / scan)

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** V092-E.1 … V092-E.5  
**Status:** E.1 + E.3 done · E.2 partial (DB isolate ✓, PDF isolate deferred) · E.4 + E.5 deferred (wave V092-3)

---

## Goal

A counter that actually works on a tablet and a HID scanner — without expanding into thermal printers or a Play tablet listing.

This wave **does not block the tag** unless we claim tablet on the store (GATE G11).  
If 0.9.2 copy will say “tablet supported”, E.1 is required.

---

## V092-E.1 — Unlock tablet

### Problem

`lib/main.dart` locks the whole app to `DeviceOrientation.portraitUp`.  
`SaleDualPane` / `NavigationRail` almost never show on a real tablet.  
iOS `Info.plist` still allows landscape — the two platforms disagree.

### Target

- Phone: portrait is fine (avoid flip mid-tender).
- Tablet (shortest side ≥ 600): allow landscape.
- Do not upload 7"/10" Play shots in this slice (POST-090 A6).

### Done when

- Rotate a tablet and dual-pane appears **or** docs say plainly that 0.9.2 does not certify landscape.

---

## V092-E.2 — Open DB / PDF off the UI isolate

### Problem

`EncryptedDatabaseOpener.open()` uses `NativeDatabase(file)`, not `createInBackground`.  
First-run SQLCipher migrate and `ReceiptPdfService.printReceipt` sit on the UI isolate.

### Target

- Open the file with `NativeDatabase.createInBackground` or the SQLCipher-safe equivalent.
- Build PDFs in `Isolate.run`, same pattern as backup encryption.
- Do not move sale writes off Drift’s isolate without integrity tests.

### Tests

- Host DB-open tests still pass.
- At least a unit test that PDF layout does not throw on an isolate (if possible without binding the plugin).

### Done when

- DB open does not block the UI thread in the way Drift’s API documents.
- A long receipt does not synchronously stall the sale button on the UI (best-effort, review).

---

## V092-E.3 — Scan the whole catalog, not the first 500

### Problem

`ProductBloc` pages at 500.  
If the scanner / `getProductByBarcode` runs against the in-memory page, SKU 501+ misses silently.

### Target

Barcode/SKU lookup always goes through the repository/DB for **all non-deleted rows**.  
Pagination stays for the on-screen grid only.

### Tests

- Fixture larger than the page size + barcode of the last item → lands in the cart.
- Existing miss → create-product CTA still works.

---

## V092-E.4 / E.5 — Could

| ID | Work | Do not confuse with |
|----|------|---------------------|
| E.4 | After a successful sale, send an 80mm PDF to the system printer without opening a menu every time | Bluetooth ESC/POS (POST-090 E2) |
| E.5 | Keep `BarcodeWedgeListener` focus when HID is present; do not steal it from the cash field | Serial scanner SDKs |

---

## Audit items that are not this wave

| Topic | Goes to |
|-------|---------|
| God `saved_bills_page` / `draft_bloc` | AH-C.5 after nets |
| R8 / minify | V092-F.3 / POST-090 |
| Text scale 1.3 | POST-090 E3 |
| No cash drawer / auto-cut | Out of this CE slice |
| PromptPay slip is not a bank confirmation | Docs A.4 — do not claim it |

---

## Ordering

```
After V092-1 is green:
  E.3 scan     (low money risk, fast cashier win)
  E.2 isolate  (treat opener carefully)
  E.1 tablet   (UX + rotation tests)
```

Do not land E.1 in the same PR as C.1.

---

<sub>Promsell POS CE · V092-INTEGRITY · WS-E cashier · 2026-08-13</sub>
