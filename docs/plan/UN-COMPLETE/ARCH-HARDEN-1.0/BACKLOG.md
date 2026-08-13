# Architecture Hardening 1.0 — Backlog

**Parent:** [OVERVIEW.md](./OVERVIEW.md)  
**Status legend:** `todo` · `in_progress` · `done` · `blocked` · `deferred`  
**Rule:** Change status only with evidence (PR / CI / doc path). Never mark done from plan text alone.

**Related store backlog (do not duplicate):** [POST-090-BACKLOG.md](../POST-090-MANAGE/POST-090-BACKLOG.md)  
**Related next-tag slice (do not duplicate):** [V092-INTEGRITY BACKLOG](../V092-INTEGRITY/BACKLOG.md) — tax invoice / PIN holes / stock CAS / QA nets; does **not** move AH-* to done.  
**Related docs-tree slice (do not duplicate):** [DOC-SSOT BACKLOG](../DOC-SSOT/BACKLOG.md) — plan index / handbook / ARCH wording; AH-0.3 evidence still lands on this file.

---

## Must (AH-GATE-1 / arch-before-store)

| ID | Description | Wave | Depends | Evidence | Status |
|----|-------------|------|---------|----------|--------|
| AH-0.1 | Create `docs/plan/UN-COMPLETE/ARCH-HARDEN-1.0/` package (7 files) + roadmap pointer | AH-0 | — | This folder + roadmap §Next + POST-090 gate note | **done** (2026-07-30) |
| AH-0.2 | Doc honesty: coverage floor **60%** global + **80%** sale-logic in `SECURITY.md` and testing readme (match `ci.yml`) | AH-0 | — | `SECURITY.md` line 90 updated | **done** |
| AH-0.3 | ADR/doc repair: WatchReport→**ReportRepository**; Void via History not Checkout; ADR-027 payable; ADR-028 sync **non-goals** | AH-0 | — | `docs/architecture/*` + ADR-027/028 (DOC-SSOT 2026-08-13) | **done** (2026-08-13) |
| AH-0.4 | Publish AH-GATE-1: Play production path **blocked** until gate | AH-0 | AH-0.1 | [GATE-TO-PLAY.md](./GATE-TO-PLAY.md) status BLOCKED | **done** (2026-07-30) |
| AH-1.1 | CI domain import fence (`domain/**` ↛ presentation/data/flutter) + dated allowlist | AH-1 | AH-0.1 | `tool/` + `ci.yml` | todo |
| AH-1.2 | CloseDay: remove `SaleLocalDatasource` dependency → SaleRepository / SalesReadPort | AH-1 | AH-1.1 partial OK | code + daily_close / multi_tender tests | todo |
| AH-1.3 | Fix domain leaks: `ClearOrphanedImages`, `SubmitProduct` (no domain→data/presentation) | AH-1 | AH-1.1 | code + unit tests | todo |
| AH-1.4 | Settings domain: drop Flutter `Locale`/`ThemeMode`; map at presentation | AH-1 | AH-1.1 | settings tests | todo |
| AH-2.1 | Day lock **re-check inside** create/void write transactions (close TOCTOU) | AH-2 | AH-1.2 optional | `SaleDayGuard` in `sale_insert_writer` / `sale_void_writer` TX + `sale_day_guard_test.dart` | **done** (2026-08-13, code already shipped) |
| AH-2.2 | CloseDay + `lastClosedDate` atomic or ordered fail-closed | AH-2 | AH-1.2 | test | todo |
| AH-2.3 | Cart/Checkout promo as `Money`; clarify charge SSOT (`payableTotals`) | AH-2 | — | sale tests / goldens | todo |
| AH-GATE | All **AH-G1–AH-G6** in GATE-TO-PLAY (**AH-G7** recommended) | AH-4 | AH-1.* AH-2.1+ | checklist signed | todo |

---

## Should (quality / 1.0.x arch)

| ID | Description | Wave | Depends | Evidence | Status |
|----|-------------|------|---------|----------|--------|
| AH-1.5 | History uses domain read API (no direct sale **data** import) | AH-1 | AH-1.2 | history tests | todo |
| AH-2.4 | Unify inventory log writes (one service + deviceId) | AH-2 | — | inventory + sale integrity | todo |
| AH-2.5 | Domain `CartDiscountPolicy` + tender/stock **policy** (SQL CAS stays data) | AH-2 | AH-2.3 | unit tests | todo |
| AH-2.6 | Decision: wire `MoneyConverter` **or** defer INTEGER to Phase M C1 after gate | AH-2 | AH-2.3 | note in WS-C / this backlog | todo |
| AH-3.1 | `SalesQueryPort` (or expanded SaleRepository reads) for Home/Report/History/Close | AH-3 | AH-1.2 | code | todo |
| AH-3.2 | Reduce money-path `sl<Repo|DS|AppDatabase>()` in widgets → composition root | AH-3 | AH-3.1 partial | review | todo |
| AH-3.3 | CheckoutBloc provider scope consistent (shell **or** sale-only) | AH-3 | — | sale_page / main | todo |
| AH-3.4 | Boot recovery shell minimum (DB open/migrate fail → restore/export/retry) | AH-3 | — | UI or documented stub + issue | todo |

---

## Could (later)

| ID | Description | Notes | Status |
|----|-------------|-------|--------|
| AH-C.1 | Extract path packages `domain_money` / `domain_selling` | After gate | todo |
| AH-C.2 | Local OpsEventSink (boot/sale/backup SLIs) | Offline-first metrics | todo |
| AH-C.3 | CashierSession / nullable actor columns | Multi-staff prep only | todo |
| AH-C.4 | Outbox spike (no production sync) | Design only | todo |
| AH-C.5 | God-widget splits (>500 LOC sale/product) | After money nets green | todo |

---

## POST-090 items gated (reference only)

| POST-090 ID | Relationship to ARCH-HARDEN |
|-------------|----------------------------|
| **V092-*** | Integrity tag slice — may land **before** AH-1; still **does not** unlock this gate or Play |
| **A4, A5** | **Blocked for production path** until **AH-GATE** (see GATE-TO-PLAY) |
| A1–A3 | Operator/CI may proceed; do not claim production Go |
| B2 | Still required for production Go **after** gate |
| C1–C4 Phase M | After AH-2.6 + AH-GATE recommended |
| D1+ Phase 2b | Not required for AH-GATE; required for multi-device durability claims |
| E1–E4 | Product UX — parallel, not AH-GATE |

---

## Wave exit checklist

| Wave | Exit when |
|------|-----------|
| **AH-0** | Package live; GATE doc says blocked; coverage/ADR tasks filed or done |
| **AH-1** | Fence green on main; CloseDay has no sale **data** import |
| **AH-2** | Day-lock-in-TX + trust suite green; goldens not regressed |
| **AH-3** | Read port adopted on ≥2 consumers; sl sprawl reduced on money UI |
| **AH-4** | [GATE-TO-PLAY.md](./GATE-TO-PLAY.md) status = **Play path unlocked** |

---

## Status changelog

| Date | Change |
|------|--------|
| 2026-07-30 | Package created (7 files); roadmap + POST-090 gate links; **AH-0.1 / AH-0.4 done**; AH-0.2 / AH-0.3 next |
| 2026-08-13 | AH-0.2 already done; **AH-0.3 done** (ADR-027/028 + WatchReport/Void wording); **AH-2.1 / AH-G3 done** from `SaleDayGuard`; package **PAUSED until V092-GATE** |

---

<sub>Promsell POS CE · ARCH-HARDEN-1.0 · Backlog · 2026-07-30</sub>
