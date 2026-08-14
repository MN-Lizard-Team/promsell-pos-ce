# AH-GATE-1 — Unlock Play production path

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**Store SSOT after unlock:** [POST-090-MANAGE](../POST-090-MANAGE/POST-090-OVERVIEW.md) · [STORE_SUBMISSION.md](../../../STORE_SUBMISSION.md)  
**Status:** **LOCKED / Play production path BLOCKED** (2026-07-30)

---

## Purpose

Architecture hardening **gates** the claim that the project may proceed to **Play production** upload and production Go messaging.

This gate does **not** replace POST-090 Must (A1–A5, B2). It is an **additional** bar chosen for arch-before-store sequencing.

---

## Current status

| Field | Value |
|-------|--------|
| Gate name | **AH-GATE-1** |
| Play production path | **BLOCKED** |
| Unlocked at | — |
| Evidence log | — |

When all required criteria pass, change status to:

> **Play path unlocked (AH-GATE-1)** — proceed with POST-090 A4/A5 under normal store rules; still **No-Go production** until A1–A5 + B2 Must Pass.

---

## Required criteria (AH-G1–AH-G6)

| ID | Criterion | Evidence | Status |
|----|-----------|----------|--------|
| **AH-G1** | Domain import fence green on CI (`domain/**` rule) | `tool/check_domain_fence.dart` + CI step + 6 unit tests; **allowlist empty (0 violations)**; all AH-1.* done | 🟡 partial — local check green (0 violations); CI run pending |
| **AH-G2** | `CloseDay` does **not** import sale **data** layer | `close_day.dart` imports `SaleRepository` (domain); fence clean; 2118 tests green | ✅ |
| **AH-G3** | Day lock re-check **inside** create **and** void write TX | `SaleDayGuard` in writers + `sale_day_guard_test.dart` | ✅ |
| **AH-G4** | Doc honesty: coverage **60/80**; no false “sync engine ready”; ADR-027 payable; ADR-028 sync non-goals | ADR-027/028 + SECURITY 60/80 (2026-08-13) | ✅ |
| **AH-G5** | `release-trust.yml` green on current main/tag candidate | CI | ⬜ |
| **AH-G6** | No critical money-path architecture regression (integrity + payable goldens) | trust suite: 42 tests across `sale_payable_golden_test.dart` (12 goldens), `sale_payable_calculator_test.dart` (10), `sale_vat_discount_void_close_test.dart` (4), `void_after_day_close_test.dart` (4), `sale_integrity_test.dart` (10), `backup_money_continuity_test.dart` (2), `multi_tender_daily_close_test.dart` (1) — all green 2026-08-14 | ✅ local |

## Recommended (AH-G7)

| ID | Criterion | Evidence | Status |
|----|-----------|----------|--------|
| **AH-G7** | CloseDay + `lastClosedDate` atomic **or** create path fail-closed on close row | test | ⬜ |

G7 is **recommended** before production Go; may unlock internal track without G7 if explicitly accepted in this file.

---

## Explicitly NOT required for AH-GATE-1

| Item | Notes |
|------|--------|
| Phase M INTEGER columns (C1+) | After decision AH-2.6 |
| Phase 2b key export (D1+) | Separate durability program |
| Device E2E hard-gate (B4) | POST-090 Should |
| Tablet dual-pane (E1) | UX |
| A4/A5 themselves | **Blocked until this gate**; then execute under POST-090 |
| Full Clean Architecture purity everywhere | Fence + CloseDay + settings are the bar |

---

## After unlock — resume POST-090

```
AH-GATE-1 unlocked
    → A1 prod keystore dual custody (if still open)
    → A2 / A2b Console forms
    → A3 secrets dry-run (CI already fail-closed on tags)
    → A4 upload internal/closed
    → A5 + B2 Must smoke (known PIN void, M2, draft, prod build)
    → Production Go only when POST-090 says so
```

**Still forbidden after unlock without POST-090 evidence:**

- Throwaway JKS on Play  
- Claiming cross-device restore  
- Claiming tax invoice  
- Claiming E2E hard-green from soft main CI alone  

---

## Sign-off template

```text
AH-GATE-1
Date:
Commit / tag:
G1–G6 evidence links:
G7 (yes/no/deferred reason):
Maintainer:
Play path: UNLOCKED | remains BLOCKED
```

---

## Why this gate exists

Elite architecture review (v0.9): fiscal **write** path is strong; **domain leaks**, **day-lock TOCTOU**, **doc drift**, and **sync-ready overclaim** are the wrong foundations for a public production cut. This gate forces those closes **before** store production traffic.

---

<sub>GATE-TO-PLAY · ARCH-HARDEN-1.0 · BLOCKED · 2026-07-30</sub>
