# Post-v0.9.0 — Management Plan Overview

**Version target:** `1.0.0` (Play production cut) + `1.0.x` integrity follow-ons  
**Branch base:** `main` (post v0.9.1)  
**Schema baseline:** **v32** (`lib/core/database/app_database.dart`)  
**Theme:** Play production · QA hardening · Phase M money · Phase 2b key/restore · Product UX  
**Status:** **COMPLETE (historical record)** — All in-repo code work is done (P0 scaling, P1 database lifecycle, Phase M, Phase 2b D0/D1, E0/E0c/E1). Operator-owned items (A1/A2/A4/A5 — Play Console submission) and future work (D2 device smoke, E2 thermal, E3 a11y, E4 microcopy) remain tracked in the backlog but are no longer active execution items in this package.

**Predecessor:** [`docs/plan/COMPLETE/V090-TRUST/`](../V090-TRUST/V090-TRUST-OVERVIEW.md) (COMPLETE for GitHub trust-cut)

**Architecture-before-store gate (2026-07-30):** Play **production** path (especially **A4/A5**) is **additionally blocked** until [`ARCH-HARDEN-1.0` AH-GATE-1](../../UN-COMPLETE/ARCH-HARDEN-1.0/GATE-TO-PLAY.md) unlocks. Sequencing SSOT for hardening: [`ARCH-HARDEN-1.0/OVERVIEW.md`](../../UN-COMPLETE/ARCH-HARDEN-1.0/OVERVIEW.md). This package remains SSOT for store/QA/Phase M·2b/UX **after** that gate.

**Integrity slice before the next tag (2026-08-13):** GitHub tag `v0.9.2` is sequenced by [`V092-INTEGRITY`](../V092-INTEGRITY/OVERVIEW.md) (tax-invoice honesty, PIN holes, stock CAS, VAT/void QA). That package **does not** replace A1–A5 / B2 / Phase M / 2b and **does not** unlock Play production.

**Docs-tree honesty (2026-08-13):** [`DOC-SSOT`](../../UN-COMPLETE/DOC-SSOT/OVERVIEW.md) owns plan git/index, README/USAGE, data handbook, and CI.md. It **does not** own Play listing, A1–A5, or `RELEASE_1.0_SMOKE`.

---

## Goal

Manage post-trust-cut work with **clear sequencing · separated Go/No-Go channels · no money-path breakage** focusing on 4 axes:

1. **Play 1.0 production cut** — keystore, Data safety, signed AAB, listing submit (**after AH-GATE-1**)  
2. **QA hardening** — trust suite, smoke 1.0, doc honesty, coverage policy  
3. **Phase M + Phase 2b** — INTEGER satang on disk · cross-device / key export  
4. **Product UX gaps** — PIN default-on (spec), tablet dual-pane, thermal, a11y  

---

## Go / No-Go

| Channel | Target | Condition |
|---------|--------|----------|
| GitHub tag `v1.0.0` (code) | Conditional Go | Must backlog (A0–A3 partial, B0–B2, E0 spec) closed + trust green; prefer **AH-GATE-1** before production messaging |
| Play **internal / closed** testing | Go when A1–A4 | prod keystore + Data safety + signed AAB; **prefer after AH-GATE-1** |
| Play **production** | **No-Go** until **AH-GATE-1** + A1–A5 + B2 Must smoke | No throwaway JKS · see [GATE-TO-PLAY](../../UN-COMPLETE/ARCH-HARDEN-1.0/GATE-TO-PLAY.md) |
| Phase M schema cut | No-Go before B1 + prefer after ARCH-HARDEN fiscal decision (AH-2.6) | dual-write + fixtures green |
| Phase 2b key export | No-Go before D0 threat model + SECURITY update | envelope + tests |

---

## Principles (Locked)

| Topic | Decision |
|-------|----------|
| Money path | **Behavior-preserving** until Phase M has migration + fail-closed tests |
| Docs | **SSOT = code** — no claiming E2E/Play/Phase done before evidence |
| Delivery | Small PRs, one concern at a time; Wave before calendar vanity |
| Trust nets | Expand `release-trust` **before** Phase M / new god-file |
| This document | Plan/checklist only until implement order |
| Scope for "1.0 store" | **Must** only — Should/Could = 1.0.x / later |

---

## Workstream Overview

| WS | Theme | Blocks | Risk |
|----|-------|--------|------|
| **A** | Play 1.0 production cut | Store Go | 🟡–🔴 operator + secrets |
| **B** | QA hardening | Tag + trust | 🟡 medium |
| **C** | Phase M (INTEGER money) | Data integrity | 🔴 if rushed |
| **D** | Phase 2b (key / cross-device) | Portability | 🔴 security design |
| **E** | Product UX (PIN, tablet, thermal, a11y) | Merchant fit | 🟡 medium |

**Child docs:**

| Doc | Content |
|-----|---------|
| [POST-090-BACKLOG.md](./POST-090-BACKLOG.md) | Must / Should / Could checklist |
| [WS-A-PLAY-PRODUCTION.md](./WS-A-PLAY-PRODUCTION.md) | Play Console + signing |
| [WS-B-QA-HARDENING.md](./WS-B-QA-HARDENING.md) | Trust, smoke, E2E honesty, coverage |
| [WS-C-PHASE-M-MONEY.md](./WS-C-PHASE-M-MONEY.md) | Satang on disk |
| [WS-D-PHASE-2B-KEY-RESTORE.md](./WS-D-PHASE-2B-KEY-RESTORE.md) | Key export / cross-device |
| [WS-E-PRODUCT-UX.md](./WS-E-PRODUCT-UX.md) | PIN default, tablet, thermal, a11y |
| [ce-scaling-management-plan.md](./ce-scaling-management-plan.md) | P0–P3 scaling roadmap with evidence |
| [p0-scaling-foundation.md](./p0-scaling-foundation.md) | P0 task breakdown (done) |

---

## Execution waves (no hard calendar)

```
Wave 0 (immediate, parallelizable):
  B0 Docs honesty (E2E claims)  ∥  A0 Play operator checklist freeze

Wave 1 — 1.0 readiness (P0):
  B1 Trust suite expand + path floors design
  B2 RELEASE_1.0_SMOKE + device matrix
  A1 Production keystore dual-custody runbook
  A2 Data safety + listing freeze
  E0 PIN default-on / domain gate (spec only first)

Wave 2 — Store cut (P0):
  A3 Signed AAB require_signed_aab on tags
  A4 Play Console submit
  A5 Post-submit smoke on prod build

Wave 3 — Integrity & portability (P1):
  C Phase M — after B1 green
  D Phase 2b — after D0 threat model + privacy

Wave 4 — Product depth (P1–P2):
  E1 Tablet dual-pane
  E2 Thermal BT (CE help-wanted)
  E3 A11y wiring
  B3–B5 coverage / E2E hard smoke / security test pack
```

### Ordering rules

1. **Do not** start Phase M before B1 (payable golden + trust expand)  
2. **Do not** claim Play production Go before A1–A5  
3. **Do not** ship key export before D0 + SECURITY/PRIVACY update  
4. **Do not** vanity-split god files before money nets green  
5. Implement PIN default-on (E0 code) after spec locked — may overlap Wave 1–2  

---

## Quality gates per milestone

| Milestone | Gate |
|-----------|------|
| After **B0** | `docs/codebase/testing.md` + E2E status not overclaiming |
| After **B1** | Expanded trust suite green fail-closed |
| After **B2** | `RELEASE_1.0_SMOKE.md` Must Pass on matrix |
| After **A1–A2** | Keystore runbook + Data safety draft aligned with privacy |
| After **A3–A5** | Signed prod AAB + store track + post smoke |
| Before **Phase M merge** | B1 + dual-write design review + legacy fixtures |
| Before **Phase 2b merge** | D0 + automated crypto tests + listing honesty |
| Before marketing "1.0 ready" | Must backlog closed; known limitations in CHANGELOG |

---

## RACI (summary)

| Area | Maintainer | Operator (store) | Community |
|------|------------|------------------|-----------|
| Docs / this plan | A/R | C | I |
| CI / trust / tests | R | I | C (PRs) |
| Keystore / Play Console | C | **A/R** | — |
| Phase M / 2b code | R | I | C |
| Tablet / a11y / PIN code | R | C | C |
| Thermal / extra l10n | C | I | **R** (help wanted) |

A = accountable · R = responsible · C = consulted · I = informed

---

## Risk register

| Risk | L | I | Mitigation |
|------|---|---|------------|
| Release Play before keystore / Data safety | M | H | A1–A2 No-Go; no throwaway JKS |
| Phase M breaks money totals / reports | M | C | B1 before C; dual-write; REAL fixtures |
| 2b key export offline brute / leak | M | H | D0 threat model; strong envelope; UX warnings |
| E2E overclaim → false confidence | H | M | B0 before 1.0 marketing |
| Scope too large | H | M | Waves; **Must only** for store 1.0 |
| Trust path-filter skips inventory/promo | M | H | B1 expand paths or run trust on all main PRs |
| PIN optional still insider risk | M | H | E0 spec → default-on + domain gate |

---

## Explicit non-goals (this plan package)

- Implement feature code / CI / schema **during the planning round**  
- Cloud multi-shop / SaaS / SOC2  
- Raising global coverage to 80% in one PR  
- iOS App Store full submission (track separately if needed)  
- Closed proprietary relicense  

---

## Evidence sources (read-only inputs)

- Elite orchestration: project analysis + full QA system analysis (session)  
- `CHANGELOG.md` §0.9.0 known limitations  
- `docs/readme/roadmap.md` Next / Future  
- `docs/STORE_SUBMISSION.md`, `docs/DEPLOY.md`, `SECURITY.md`  
- `docs/testing/RELEASE_0.9_SMOKE.md`, `.github/workflows/release-trust.yml`  
- `docs/plan/COMPLETE/V090-TRUST/*`  

---

## Related

| Doc | Role |
|-----|------|
| [POST-090-BACKLOG.md](./POST-090-BACKLOG.md) | Executable checklist |
| [../V090-TRUST/V090-TRUST-OVERVIEW.md](../V090-TRUST/V090-TRUST-OVERVIEW.md) | Prior epic |
| [../../readme/roadmap.md](../../readme/roadmap.md) | Public roadmap |
| [../../STORE_SUBMISSION.md](../../STORE_SUBMISSION.md) | Store human checklist |
| [../../testing/RELEASE_0.9_SMOKE.md](../../testing/RELEASE_0.9_SMOKE.md) | Smoke SSOT until 1.0 file exists |

---

<sub>Promsell POS CE · Post-0.9 management plan · COMPLETE (historical record) · AGPL-3.0</sub>
