# WS-AH-OPS — Doc honesty, ADRs, operability

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** AH-0.2, AH-0.3, AH-0.4, AH-3.4 (ops angle)  
**Status:** AH-0.2/0.3 **done** (2026-08-13 DOC-SSOT). Package **paused until V092-GATE**.

---

## Goal

Align **written architecture** with **code and CI**, and define minimum operability expectations so solo hardening does not ship silent footguns.

---

## AH-0.2 — Coverage / testing honesty

### Drift

| Source | Claim |
|--------|--------|
| `.github/workflows/ci.yml` | Global **≥60%**; sale-logic **≥80%** via `tool/check_path_coverage.dart` |
| `SECURITY.md` | ✅ Aligned — coverage floor **60%** (matches `ci.yml`) |
| `docs/readme/testing.md` (risk) | May lag `docs/codebase/testing.md` |

### Actions

1. Update `SECURITY.md` security testing expectations → **60% + sale-logic 80%** + release-trust fail-closed  
2. Align `docs/readme/testing.md` with `docs/codebase/testing.md`  
3. Keep E2E honesty: device tests are **not** on `ci.yml`; trust **blocks** `--flavor dev` — see `docs/testing/CI.md`  

### Done when

- No active doc claims 50% as the live CI floor  

---

## AH-0.3 — ADR / deep-dive repairs

| Issue | Fix |
|-------|-----|
| WatchReport → HistoryRepository (docs) | Document **SaleRepository** (or future SalesQueryPort) |
| CheckoutBloc owns VoidSale (docs) | Void via **HistoryBloc** + `VoidSale` use case |
| ADR-011 only cart discount before VAT | **ADR-011b** (or amend 011): item → cart → **promo** → **SC** → VAT modes |
| ADR-015 “sync-ready” overread | Add **ADR: Sync non-goals for CE v1** — columns ≠ engine; no multi-master stock |
| DI graph stale | Refresh technical-deep-dive registration notes when AH-1/3 land |

### Suggested ADR titles

1. **ADR-027 (or 011b): Payable pipeline including promotion and service charge**  
2. **ADR-028: Sync metadata non-goals for single-device CE**  
3. **ADR-029: Domain dependency fence (CI-enforced)** — when AH-1.1 ships  

### Done when

- Index + deep-dive no longer contradict code on WatchReport / Void ownership  
- Sync non-goals published  

---

## AH-0.4 — Gate publication

Maintain [GATE-TO-PLAY.md](./GATE-TO-PLAY.md) as the **only** arch→Play unlock checklist.

Roadmap and POST-090 must **link** it (not fork criteria).

---

## Operability baseline (while coding AH-*)

| Topic | Expectation during hardening |
|-------|------------------------------|
| Money TX | Never weaken single-TX sale/void for “cleanliness” |
| Migrations | No reckless reorder of v27/v28 without upgrade tests |
| Backup | Keep same-device honesty; no fake cross-device |
| Crash logs | Prefer enrich later (AH-C.2); do not remove PII sanitize |
| Day lock default | Product decision (POST-090 / UX); if changed, document + smoke |

---

## AH-3.4 cross-link

Recovery shell detailed in [WS-AH-READMODEL.md](./WS-AH-READMODEL.md). Ops acceptance:

- Merchant never gets silent black screen on key/migrate failure without CTA  
- Support path: export crash log still reachable when possible  

---

## Communication (solo)

| Audience | Cadence |
|----------|---------|
| Self (maintainer) | Update BACKLOG status when evidence lands |
| Public roadmap | Projection only — no second tracker |
| Store operator (future) | After AH-GATE only for production messaging |

---

## Out of scope

- Full SRE SLI platform  
- Remote telemetry (privacy non-goal unless explicit product change)  
- Archiving 080-PLAN / PSPOS-PHASE-1 (optional hygiene later)  

---

<sub>WS-AH-OPS · ARCH-HARDEN-1.0 · 2026-07-30</sub>
