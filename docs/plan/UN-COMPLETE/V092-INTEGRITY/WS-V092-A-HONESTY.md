# WS-V092-A — Honesty SSOT (docs + receipt claim)

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** V092-A.1 … V092-A.7  
**Status:** todo (wave V092-0 / V092-1)

---

## Goal

Make **code · listing · SECURITY · CHANGELOG · test docs** speak the same language.

Audit reds: the receipt path claims a Thai tax invoice, PIN is still written as Optional, CI/AAB/E2E contradict YAML, and we still say sync-ready / Void-Refund / full POS.

---

## V092-A.1 — Withdraw tax invoice as document type

### Problem

Listing / SECURITY / STORE_SUBMISSION / GATE-TO-PLAY all say a receipt is **not** a tax invoice.  
v0.9.1 made a Tax ID flip the document title to a tax invoice and drop the disclaimer.

Evidence:

- `lib/features/receipt/domain/entities/receipt_document.dart` — comment `qualifies as a tax invoice`
- `lib/features/receipt/domain/services/build_receipt_document.dart` — hides disclaimer when taxId is set
- `CHANGELOG.md` v0.9.1 — “Receipt compliance — Tax ID field for Thai tax invoices”
- Conflicts with `fastlane/metadata/android/th/full_description.txt`

### Target

| Tax ID present | Correct behavior |
|----------------|------------------|
| Yes | Print the shop tax-ID line on a **sales receipt** |
| No | Sales receipt + existing “not a tax invoice” disclaimer |
| Always | Do **not** change the document type to tax invoice / ใบกำกับภาษี |

Do not delete the Tax ID field — delete only the **document-type promotion**.

### Implementation sketch

1. Audit `ReceiptDocument` / `ReceiptLabels` / PDF builder / settings preview.
2. Keep the document title on l10n `receiptTitle` (ใบเสร็จรับเงิน / Receipt).
3. Show the disclaimer always until a separate e-Tax program exists (out of scope).
4. Add a 0.9.2 CHANGELOG note that 0.9.1 overclaimed — do not silently rewrite history.
5. Sweep `app_th.arb` / `app_en.arb` for tax-invoice strings used as a **document title**.

### Tests

- `test/features/receipt/domain/` — with taxId, title is still a receipt and the disclaimer remains.
- Widget/PDF goldens for the header if they exist.

### Done when

- No path promotes document type from Tax ID.
- Listing and code do not conflict.
- A test fails if someone restores the old logic.

---

## V092-A.2 — PIN default-on in docs

### Problem

A fresh 0.9.1 install forces PIN at onboarding finish/skip.  
Older docs still say Optional (CHANGELOG 0.9.0, `docs/readme/features.md`, `docs/usage/features.md`, STORE_SUBMISSION Should).

### Target

| Doc | Wording |
|-----|---------|
| SECURITY.md | default-on for new installs (already true in code — make sure it does not regress) |
| features / usage | PIN **required on new install**; may be turned off later in Settings if the code still allows it |
| STORE_SUBMISSION | Move E0c from Should to “shipped in 0.9.1” |
| CHANGELOG 0.9.2 | Record that docs caught up — do not describe a second behavior change |

### Done when

- `rg -n "Optional PIN|PIN optional|opt-in"` in docs no longer means the pre-0.9.1 world.

---

## V092-A.3 — CI / AAB / E2E docs = YAML

### Problem

YAML is fail-closed AAB + blocking trust emulator.  
**Live SSOT docs were aligned 2026-08-13 (DOC-SSOT).** Re-check before tag if new copy drifts.

### Files to reconcile (minimum)

| File | Reality |
|------|---------|
| `SECURITY.md` | AAB on `v*` tags requires secrets; coverage 60/80 |
| `docs/STORE_SUBMISSION.md` E4 / Should `require_signed_aab` | That input is gone |
| `docs/plan/UN-COMPLETE/POST-090-MANAGE/WS-A-PLAY-PRODUCTION.md` A3 | Update wording — **do not mark A1/A4 done** |
| `docs/codebase/testing.md` | main CI = format/analyze `integration_test/` only; trust = blocking **dev** smoke |
| `integration_test/README.md` | Same |
| `docs/testing/E2E_IMPLEMENTATION_STATUS.md` / `E2E_TEST_GUIDE.md` | Remove stale YAML samples |
| `docs/DEPLOY.md` | Mention `release-aab.yml` + `v*` tags |

### Done when

- A reader of docs alone will not think a tag without secrets still goes green.
- A reader will not think every PR runs device E2E.

---

## V092-A.4 — Withdraw other overclaims

| Claim | Where | Replace with |
|-------|-------|--------------|
| 16 tables sync-ready / ADR-015 | `docs/DATABASE.md`, ADR | Columns exist; there is **no** sync engine — CE non-goal |
| full sales tracking / inventory / reporting | `README.md` | Single device, no shifts, no partial refund |
| Void / Refund | `docs/readme/features.md` | Whole-sale void only |
| schema v28 in SECURITY / usage | SECURITY, `docs/usage/features.md` | v30 |
| Works fully offline | PRIVACY if it conflicts with INTERNET + URL images | Offline for selling; remote images are optional |

Full ADR set (011b, Money on disk, SQLCipher lifecycle) = **AH-0.3** — this item only withdraws sentences a store reader would misunderstand.

### Done when

- `rg -n "sync-ready|tax invoice|ใบกำกับภาษี"` in docs+listing only remains as denials or 0.9.1 history.

---

## V092-A.5 — In-app backup copy (Should)

Backup and About must have a box a merchant can actually read (TH/EN):

1. A backup restores on **this device only**.
2. Uninstall / clear data without the `.enc` file + envelope PIN = data gone.
3. Do not send `.enc` files in chat without a PIN you can remember that is not `123456`.

Do not promise Phase 2b.

---

## V092-A.6 / A.7 — Small docs (Could)

- README stack table: SQLite **+ SQLCipher**.
- PRIVACY: new date, PIN default-on, URL images use INTERNET.

---

## Ordering

```
A.1 (receipt code)  ∥  A.2–A.4 (docs)
        → A.5 in-app copy
        → A.6 / A.7 if time
```

Do not do A.5 before A.1 — the shop would see a tax-invoice header and a backup warning at two different honesty levels.

---

<sub>Promsell POS CE · V092-INTEGRITY · WS-A honesty · 2026-08-13</sub>
