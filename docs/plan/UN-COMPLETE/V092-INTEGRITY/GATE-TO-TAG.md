# V092-GATE — Unlock GitHub tag `v0.9.2`

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**Does not unlock:** Play production (still [AH-GATE-1](../ARCH-HARDEN-1.0/GATE-TO-PLAY.md) + [POST-090 A1–A5](../POST-090-MANAGE/POST-090-BACKLOG.md))  
**Status:** **LOCKED / tag `v0.9.2` BLOCKED** (2026-08-13)

---

## Purpose

This gate unlocks only the sentence **“we may cut `v0.9.2` on GitHub.”**  
It does not unlock Play, does not unlock AH-GATE-1, and does not let us claim readiness for staffed shops or tax invoices.

---

## Current status

| Field | Value |
|-------|--------|
| Gate name | **V092-GATE** |
| Tag `v0.9.2` | **BLOCKED** |
| Play production | **still BLOCKED** (a different gate) |
| Unlocked at | — |
| Evidence log | — |

When every required criterion passes, change status to:

> **Tag path unlocked (V092-GATE)** — `v0.9.2` may be cut; Play production is still **No-Go**, and tax-invoice / sync / multi-staff claims remain forbidden.

---

## Required criteria (V092-G1–V092-G8)

| ID | Criterion | Evidence | Status |
|----|-----------|----------|--------|
| **V092-G1** | Receipts may show Tax ID, but document title/type is **not** a tax invoice | receipt code + tests + listing do not conflict | ⬜ |
| **V092-G2** | Changing stock/price/cost from the product form or quick-edit requires store PIN (when enabled) | use-case + UI tests | ⬜ |
| **V092-G3** | Sale/void/adjust/form **do not** overwrite `products.stock` from a stale read; `version++` or CAS | overwrite-regression test | ⬜ |
| **V092-G4** | PIN / schema / AAB / E2E docs match code and YAML | SECURITY, CHANGELOG note, STORE_SUBMISSION, `docs/testing/CI.md` | ⬜ |
| **V092-G5** | Host integ: EXCLUSIVE 7% + discount + void restock + day-close is one suite in trust and green | `release-trust.yml` + test file | ⬜ |
| **V092-G6** | Device: void from History with a known PIN recorded at least once | smoke addendum or `RELEASE_1.0_SMOKE` Must #3 | ⬜ |
| **V092-G7** | `release-trust.yml` green on the SHA about to be tagged | CI | ⬜ |
| **V092-G8** | Payable goldens not regressed / sale-logic ≥ 80% / analyze 0 issues | CI | ⬜ |

## Recommended (V092-G9–V092-G11)

| ID | Criterion | Evidence | Status |
|----|-----------|----------|--------|
| **V092-G9** | Cold-start / resume lock when PIN is on | test or smoke | ⬜ |
| **V092-G10** | CloseDay + report export + discount/oversell settings are sensitive | tests | ⬜ |
| **V092-G11** | Tablet can rotate **or** docs/listing do not claim tablet landscape | code or copy | ⬜ |

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

## Why this gate exists

The audit scored the product **5/10** because a shop can break from stock overwrite, staff can skip PIN, and the receipt code overclaims a tax document.  
A new tag without this gate repeats 0.9.1’s mistake — more UX, same unclosed money/docs truth.

---

<sub>Promsell POS CE · V092-INTEGRITY · gate-to-tag · 2026-08-13</sub>
