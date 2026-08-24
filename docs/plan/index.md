# Plan map — Promsell POS CE

This file is the **map**. Packages own detail. Do not treat COMPLETE folders as a current execution queue.

---

## How to read

| Bucket | Meaning |
|--------|---------|
| **UN-COMPLETE** | Active or paused work. Follow OVERVIEW + BACKLOG. |
| **COMPLETE** | Historical record. Do not reopen as a 1.0 queue. |

---

## Active (UN-COMPLETE)

| Package | Role | Start here |
|---------|------|------------|
| [ARCH-HARDEN-1.0](./UN-COMPLETE/ARCH-HARDEN-1.0/OVERVIEW.md) | Architecture before Play. **Resumed** — V092-GATE unlocked | [BACKLOG](./UN-COMPLETE/ARCH-HARDEN-1.0/BACKLOG.md) · [GATE-TO-PLAY](./UN-COMPLETE/ARCH-HARDEN-1.0/GATE-TO-PLAY.md) |
| [DOC-SSOT](./UN-COMPLETE/DOC-SSOT/OVERVIEW.md) | Docs-tree honesty. Does **not** gate the tag or Play | [BACKLOG](./UN-COMPLETE/DOC-SSOT/BACKLOG.md) |

**Current NOW:** V092-GATE **UNLOCKED** (2026-08-14) — `v0.9.2` may be cut. Next: resume AH-0.3+ (architecture fence).

---

## Complete (historical)

| Package | Role |
|---------|------|
| [TD-SCAL-093](./COMPLETE/TD-SCAL-093/OVERVIEW.md) | Technical debt & scalability pass — bounded COUNT(*) health queries, ProductBloc failure state, shared domain entities, migration file split, cache eviction, use-case tests |
| [POST-090-MANAGE](./COMPLETE/POST-090-MANAGE/POST-090-OVERVIEW.md) | Post-v0.9 store/QA/Phase M·2b/UX — P0 scaling + P1 lifecycle + Phase M + D0/D1 done; operator Play items (A1/A2/A4/A5) and D2 device smoke remain tracked |
| [V092-INTEGRITY](./COMPLETE/V092-INTEGRITY/OVERVIEW.md) | v0.9.2 integrity slice — **GATE UNLOCKED** (2026-08-14) |
| [V090-TRUST](./COMPLETE/V090-TRUST/V090-TRUST-OVERVIEW.md) | v0.9.0 GitHub trust-cut |
| [080-PLAN](./COMPLETE/080-PLAN/080-OVERVIEW.md) | v0.8.1 quality / AppSettings |
| [PSPOS-PHASE-1](./COMPLETE/PSPOS-PHASE-1/PSPOS-PHASE1-IMPLEMENTATION.md) | Phase 1 R1–R5 |

---

## Gate ID prefix (mandatory)

| Prefix | Gate | Example |
|--------|------|---------|
| **V092-G1…G11** | Tag `v0.9.2` | **V092-G3** = stock CAS |
| **AH-G1…G7** | Play production path | **AH-G3** = day-lock inside write TX |

Never write a bare `G3` across packages. Those two G3s are different criteria.

---

## Sequencing

```
V092-GATE ✅ UNLOCKED (2026-08-14) → tag v0.9.2
    → resume AH-0.3+ (architecture)
        → AH-GATE-1
            → POST-090 A4/A5 (Play production still needs A1–A5 + B2)
```

DOC-SSOT may land in parallel. It does not unlock either gate.

---

## Related roots

- Public roadmap: [`docs/readme/roadmap.md`](../readme/roadmap.md)
- System overview: [`CODEBASE.md`](../../CODEBASE.md)
- Architecture index: [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md)

---

<sub>Promsell POS CE · plan map · updated 2026-08-14 (V092-GATE unlocked)</sub>
