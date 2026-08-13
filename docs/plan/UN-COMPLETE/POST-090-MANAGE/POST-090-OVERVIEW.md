# Post-v0.9.0 — Management Plan Overview

**Version target:** `1.0.0` (Play production cut) + `1.0.x` integrity follow-ons  
**Branch base:** `main` (post v0.9.1)  
**Schema baseline:** **v30** (`lib/core/database/app_database.dart`)  
**Theme:** Play production · QA hardening · Phase M money · Phase 2b key/restore · Product UX  
**Status:** **IN EXECUTION** (2026-07-20) — Wave 0–1 mostly closed in-repo; Play Console + Phase M/2b code still open. No claim that Play production / Phase M / Phase 2b are shipped.

**Predecessor:** [`docs/plan/COMPLETE/V090-TRUST/`](../../COMPLETE/V090-TRUST/V090-TRUST-OVERVIEW.md) (COMPLETE for GitHub trust-cut)

**Architecture-before-store gate (2026-07-30):** Play **production** path (especially **A4/A5**) is **additionally blocked** until [`ARCH-HARDEN-1.0` AH-GATE-1](../ARCH-HARDEN-1.0/GATE-TO-PLAY.md) unlocks. Sequencing SSOT for hardening: [`ARCH-HARDEN-1.0/OVERVIEW.md`](../ARCH-HARDEN-1.0/OVERVIEW.md). This package remains SSOT for store/QA/Phase M·2b/UX **after** that gate.

**Integrity slice before the next tag (2026-08-13):** GitHub tag `v0.9.2` is sequenced by [`V092-INTEGRITY`](../V092-INTEGRITY/OVERVIEW.md) (tax-invoice honesty, PIN holes, stock CAS, VAT/void QA). That package **does not** replace A1–A5 / B2 / Phase M / 2b and **does not** unlock Play production.

**Docs-tree honesty (2026-08-13):** [`DOC-SSOT`](../DOC-SSOT/OVERVIEW.md) owns plan git/index, README/USAGE, data handbook, and CI.md. It **does not** own Play listing, A1–A5, or `RELEASE_1.0_SMOKE`.

---

## Goal

จัดการงานหลัง trust cut ให้มี **ลำดับชัด · Go/No-Go แยกช่องทาง · ไม่ทำลาย money-path** โดยโฟกัส 4 แกนที่เลือก:

1. **Play 1.0 production cut** — keystore, Data safety, signed AAB, listing submit (**after AH-GATE-1**)  
2. **QA hardening** — trust suite, smoke 1.0, doc honesty, coverage policy  
3. **Phase M + Phase 2b** — INTEGER satang on disk · cross-device / key export  
4. **Product UX gaps** — PIN default-on (spec), tablet dual-pane, thermal, a11y  

---

## Go / No-Go

| ช่องทาง | เป้า | เงื่อนไข |
|---------|------|----------|
| GitHub tag `v1.0.0` (code) | Conditional Go | Must backlog (A0–A3 partial, B0–B2, E0 spec) ปิด + trust green; prefer **AH-GATE-1** before production messaging |
| Play **internal / closed** testing | Go เมื่อ A1–A4 | prod keystore + Data safety + signed AAB; **prefer after AH-GATE-1** |
| Play **production** | **No-Go** จนกว่า **AH-GATE-1** + A1–A5 + B2 Must smoke | ไม่ใช้ throwaway JKS · see [GATE-TO-PLAY](../ARCH-HARDEN-1.0/GATE-TO-PLAY.md) |
| Phase M schema cut | No-Go ก่อน B1 + prefer after ARCH-HARDEN fiscal decision (AH-2.6) | dual-write + fixtures เขียว |
| Phase 2b key export | No-Go ก่อน D0 threat model + SECURITY update | envelope + tests |

---

## Principles (Locked)

| Topic | Decision |
|-------|----------|
| Money path | **Behavior-preserving** จนกว่า Phase M มี migration + fail-closed tests |
| Docs | **SSOT = code** — ห้าม claim E2E/Play/Phase เสร็จก่อน evidence |
| Delivery | PR เล็ก ทีละ concern; Wave ก่อน calendar vanity |
| Trust nets | ขยาย `release-trust` **ก่อน** Phase M / god-file ใหม่ |
| This document | Plan/checklist only until implement order |
| Scope for “1.0 store” | **Must** only — Should/Could = 1.0.x / later |

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

---

## Execution waves (no hard calendar)

```
Wave 0 (ทันที, ขนานได้):
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
  C Phase M — หลัง B1 เขียว
  D Phase 2b — หลัง D0 threat model + privacy

Wave 4 — Product depth (P1–P2):
  E1 Tablet dual-pane
  E2 Thermal BT (CE help-wanted)
  E3 A11y wiring
  B3–B5 coverage / E2E hard smoke / security test pack
```

### Ordering rules

1. **อย่า** เริ่ม Phase M ก่อน B1 (payable golden + trust expand)  
2. **อย่า** claim Play production Go ก่อน A1–A5  
3. **อย่า** ship key export ก่อน D0 + SECURITY/PRIVACY update  
4. **อย่า** vanity-split god files ก่อน money nets เขียว  
5. Implement PIN default-on (E0 code) หลัง spec ล็อก — อาจคู่ Wave 1–2  

---

## Quality gates per milestone

| Milestone | Gate |
|-----------|------|
| After **B0** | `docs/codebase/testing.md` + E2E status ไม่ overclaim |
| After **B1** | Expanded trust suite green fail-closed |
| After **B2** | `RELEASE_1.0_SMOKE.md` Must Pass on matrix |
| After **A1–A2** | Keystore runbook + Data safety draft ตรง privacy |
| After **A3–A5** | Signed prod AAB + store track + post smoke |
| Before **Phase M merge** | B1 + dual-write design review + legacy fixtures |
| Before **Phase 2b merge** | D0 + automated crypto tests + listing honesty |
| Before marketing “1.0 ready” | Must backlog closed; known limitations in CHANGELOG |

---

## RACI (ย่อ)

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
| ปล่อย Play ก่อน keystore / Data safety | M | H | A1–A2 No-Go; no throwaway JKS |
| Phase M พังยอดเงิน / รายงาน | M | C | B1 ก่อน C; dual-write; REAL fixtures |
| 2b key export offline brute / leak | M | H | D0 threat model; strong envelope; UX warnings |
| E2E overclaim → false confidence | H | M | B0 ก่อน 1.0 marketing |
| ขอบเขตใหญ่เกินไป | H | M | Waves; **Must only** for store 1.0 |
| Trust path-filter ข้าม inventory/promo | M | H | B1 expand paths or run trust on all main PRs |
| PIN optional ยังเป็น insider risk | M | H | E0 spec → default-on + domain gate |

---

## Explicit non-goals (this plan package)

- Implement feature code / CI / schema **ในรอบเขียนแผน**  
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
| [../../COMPLETE/V090-TRUST/V090-TRUST-OVERVIEW.md](../../COMPLETE/V090-TRUST/V090-TRUST-OVERVIEW.md) | Prior epic |
| [../../../readme/roadmap.md](../../../readme/roadmap.md) | Public roadmap |
| [../../../STORE_SUBMISSION.md](../../../STORE_SUBMISSION.md) | Store human checklist |
| [../../../testing/RELEASE_0.9_SMOKE.md](../../../testing/RELEASE_0.9_SMOKE.md) | Smoke SSOT until 1.0 file exists |

---

<sub>Promsell POS CE · Post-0.9 management plan · PLAN ONLY · AGPL-3.0</sub>
