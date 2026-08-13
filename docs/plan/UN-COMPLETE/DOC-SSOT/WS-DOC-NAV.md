# WS-DOC-NAV — Plan git, index, links, AH pause

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** DOC-N.1 … DOC-N.8  
**Status:** todo (wave DOC-1 / DOC-3)

---

## Goal

A clean clone can open `docs/plan/` without 404s, without two “NOW” needles, and without colliding bare `G3` IDs.

---

## DOC-N.1 — One commit for the plan move

Working tree today: old `docs/plan/{080-PLAN,PSPOS-PHASE-1,V090-TRUST}` are **deleted**; new trees are **untracked** under `COMPLETE/` and `UN-COMPLETE/`.

**Never** `git add -u docs/plan` alone (drops the plans).

```bash
git add docs/plan/COMPLETE docs/plan/UN-COMPLETE
git add docs/plan/index.md   # after DOC-N.2
git add -u docs/plan
```

Same commit must keep the deletions **and** the adds. Prefer `git add -A docs/plan` once `index.md` exists so rename detection can pair D+A.

Do **not** `git add -A` at repo root (unrelated dirty tree). Do **not** commit until the user asks.

Message hint: `docs(plan): rehome COMPLETE/UN-COMPLETE and restore nav`

---

## DOC-N.2 — `docs/plan/index.md`

Create (not `README.md` — keep one map file):

1. Title + SSOT rule (this file is the map; packages own detail)
2. COMPLETE vs UN-COMPLETE
3. **Active:** V092-INTEGRITY (tag `v0.9.2`) · ARCH-HARDEN (**paused until V092-GATE**) · POST-090 (after AH-GATE-1) · DOC-SSOT (this package)
4. **Complete:** V090-TRUST, 080-PLAN, PSPOS-PHASE-1
5. Gate prefixes: `V092-G*` vs `AH-G*` (never bare `G3`)
6. Sequence: V092-GATE → resume AH-0.3+ → AH-GATE-1 → POST-090 A4/A5
7. Links: `docs/readme/roadmap.md`, `CODEBASE.md`, `docs/ARCHITECTURE.md`

No links to old `docs/plan/V090-TRUST/` without `COMPLETE/`.

---

## DOC-N.3 / N.4 — Relative links

| File | Broken | Fix |
|------|--------|-----|
| `docs/architecture/adr/index.md` | `../architecture/c4-diagrams.md` | `../c4-diagrams.md` (same for deep-dive) |
| `docs/codebase/*.md` | `../CODEBASE.md` | `../../CODEBASE.md` |
| `docs/codebase/conventions.md` | `architecture/technical-deep-dive.md` | `../architecture/technical-deep-dive.md` |
| `docs/changelog/CHANGELOG-08x.md` | `docs/changelog/CHANGELOG-0Nx.md` | `CHANGELOG-0Nx.md` |

`../ARCHITECTURE.md` from `adr/index.md` is already correct.

---

## DOC-N.5 — Historical banners

First block on `docs/plan/COMPLETE/080-PLAN/080-OVERVIEW.md` and `PSPOS-PHASE-1/PSPOS-PHASE1-IMPLEMENTATION.md` (siblings if they lack a banner):

> **COMPLETE / historical.** Not a current execution queue. Current map: [`docs/plan/index.md`](../../index.md).

Do not rewrite Thai bodies.

---

## DOC-N.6 / N.7 / N.8 — AH status (wave DOC-3)

- Remove `← NOW` from AH-0. Status: **PAUSED until V092-GATE**. V092-0 remains the only NOW.
- Prefix live gate tables: `V092-G1…` in V092 package; `AH-G1…` in ARCH package.
- **AH-2.1 + AH-G3 → done** with evidence already on disk:
  - `lib/features/sale/data/datasources/sale_day_guard.dart`
  - called inside `_db.transaction` in `sale_insert_writer.dart` / `sale_void_writer.dart`
  - `test/features/sale/data/datasources/sale_day_guard_test.dart`
- Leave AH-2.2 / **AH-G7** open. Leave **V092-G3** (stock CAS) ⬜.

---

## Verify

```bash
test -f docs/plan/index.md
rg -n "docs/plan/V090-TRUST/" docs --glob '!docs/plan/COMPLETE/**'   # expect 0 live hrefs
rg -n "\]\(\.\./CODEBASE\.md\)" docs/codebase                         # expect 0
rg -n "AH-2.1" docs/plan/UN-COMPLETE/ARCH-HARDEN-1.0/BACKLOG.md     # status done
```

---

<sub>Promsell POS CE · DOC-SSOT · WS-NAV · 2026-08-13</sub>
