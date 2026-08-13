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
| [V092-INTEGRITY](./UN-COMPLETE/V092-INTEGRITY/OVERVIEW.md) | Next GitHub tag `v0.9.2` only | [BACKLOG](./UN-COMPLETE/V092-INTEGRITY/BACKLOG.md) · [GATE-TO-TAG](./UN-COMPLETE/V092-INTEGRITY/GATE-TO-TAG.md) |
| [ARCH-HARDEN-1.0](./UN-COMPLETE/ARCH-HARDEN-1.0/OVERVIEW.md) | Architecture before Play. **Paused until V092-GATE** | [BACKLOG](./UN-COMPLETE/ARCH-HARDEN-1.0/BACKLOG.md) · [GATE-TO-PLAY](./UN-COMPLETE/ARCH-HARDEN-1.0/GATE-TO-PLAY.md) |
| [POST-090-MANAGE](./UN-COMPLETE/POST-090-MANAGE/POST-090-OVERVIEW.md) | Store / QA / Phase M / 2b after **AH-GATE-1** | [BACKLOG](./UN-COMPLETE/POST-090-MANAGE/POST-090-BACKLOG.md) |
| [DOC-SSOT](./UN-COMPLETE/DOC-SSOT/OVERVIEW.md) | Docs-tree honesty. Does **not** gate the tag or Play | [BACKLOG](./UN-COMPLETE/DOC-SSOT/BACKLOG.md) |

**Current NOW:** V092-0 / V092-GATE (tag path). AH-0 is paused.

---

## Complete (historical)

| Package | Role |
|---------|------|
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
V092-GATE (tag v0.9.2)
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

<sub>Promsell POS CE · plan map · 2026-08-13</sub>
