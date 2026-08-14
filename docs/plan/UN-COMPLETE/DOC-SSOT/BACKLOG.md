# DOC-SSOT — Backlog

**Parent:** [OVERVIEW.md](./OVERVIEW.md)  
**Status legend:** `todo` · `in_progress` · `done` · `blocked` · `deferred`  
**Rule:** Change status only with evidence (PR / path / `rg`). Never mark V092 / AH IDs done from this folder.

**Related:** [V092 BACKLOG](../COMPLETE/V092-INTEGRITY/BACKLOG.md) · [ARCH-HARDEN BACKLOG](../ARCH-HARDEN-1.0/BACKLOG.md) · [POST-090 BACKLOG](../POST-090-MANAGE/POST-090-BACKLOG.md)

---

## Must (clone + first-impression honesty)

| ID | Description | Wave | Depends | Evidence | Status |
|----|-------------|------|---------|----------|--------|
| DOC-0.1 | Create this package + roadmap §Next row | DOC-0 | — | This folder + roadmap | **done** (2026-08-13) |
| DOC-N.1 | One commit: add `docs/plan/COMPLETE/**` + `UN-COMPLETE/**` **and** keep old-path deletions | DOC-1 | DOC-0.1 | Staged 2026-08-13: `git add COMPLETE UN-COMPLETE index.md` + `git add -u docs/plan` → 16× `R` (old→COMPLETE) + UN-COMPLETE/index `A`; no leftover unstaged `docs/plan` D/?? | **done** (2026-08-13, staged; commit when asked) |
| DOC-N.2 | Add `docs/plan/index.md` | DOC-1 | DOC-N.1 same PR OK | `docs/plan/index.md` | **done** (2026-08-13) |
| DOC-S.1 | Fix README screenshot table → `screenshots/store/en/0x_*.png` | DOC-1 | — | `README.md` Screenshots | **done** (2026-08-13) |
| DOC-S.2 | README version honesty: unreleased `0.9.1+1`, latest tag `v0.9.0` | DOC-1 | — | banner + footer | **done** (2026-08-13) |
| DOC-S.3 | README l10n `90+` → ~1700 TH/EN; overlay onboarding 6-step → 4-step | DOC-1 | — | `README.md` | **done** (2026-08-13) |
| DOC-S.4 | USAGE primary run = `flutter run --flavor dev -t lib/main_dev.dart` | DOC-1 | — | `docs/USAGE.md` | **done** (2026-08-13) |

---

## Should (current SSOT files match YAML/code)

| ID | Description | Wave | Depends | Evidence | Status |
|----|-------------|------|---------|----------|--------|
| DOC-N.3 | Fix ADR + codebase relative links | DOC-1 | — | `adr/index.md`, `docs/codebase/*` | **done** (2026-08-13) |
| DOC-N.4 | CHANGELOG-08x self-prefix links | DOC-1 | — | `CHANGELOG-08x.md` archive | **done** (2026-08-13) |
| DOC-N.5 | Historical banners on `080-PLAN` + `PSPOS-PHASE-1` | DOC-1 | DOC-N.2 | overviews | **done** (2026-08-13) |
| DOC-N.6 | Pause AH-0 until V092-GATE | DOC-3 | — | ARCH OVERVIEW | **done** (2026-08-13) |
| DOC-N.7 | Prefix live gate rows `V092-G*` / `AH-G*` | DOC-3 | — | GATE-TO-TAG + GATE-TO-PLAY | **done** (2026-08-13) |
| DOC-N.8 | Mark AH-2.1 + **AH-G3** done from `SaleDayGuard` | DOC-3 | — | AH BACKLOG + GATE-TO-PLAY | **done** (2026-08-13) |
| DOC-H.1 | AH BACKLOG changelog matches table | DOC-3 | — | changelog 2026-08-13 | **done** (2026-08-13) |
| DOC-SEC-1 | AAB fail-closed, no `require_signed_aab` | DOC-2 | — | SECURITY, STORE E4, WS-A, 0.9 smoke | **done** (2026-08-13) |
| DOC-SEC-2 | PIN required on new install (not Optional) | DOC-2 | V092-A.2 | features + usage + STORE | **done** (2026-08-13) |
| DOC-SEC-3 | PIN stock scope = AdjustStock + CSV | DOC-2 | V092-A.4 | `SECURITY.md` | **done** (2026-08-13) |
| DOC-SEC-4 | PRIVACY date + offline-first / optional image URLs | DOC-2 | V092-A.7 | `PRIVACY_POLICY.md` | **done** (2026-08-13) |
| DOC-QA-1 | Add `docs/testing/CI.md` | DOC-2 | — | `docs/testing/CI.md` | **done** (2026-08-13) |
| DOC-QA-2 | CONTRIBUTING PR commands match `ci.yml` | DOC-2 | DOC-QA-1 | `CONTRIBUTING.md` | **done** (2026-08-13) |
| DOC-UX-6 | Void sale, not Void/Refund | DOC-2 | — | `docs/readme/features.md` | **done** (2026-08-13) |
| DOC-A.1 | AH-0.3 wording (WatchReport, Void, sync non-goals) | DOC-3 | AH-0.3 | deep-dive + ADR-028 | **done** (2026-08-13) |
| DOC-A.2 | Draft ADR-027 payable + ADR-028 sync metadata | DOC-3 | DOC-A.1 | `adr/index.md` | **done** (2026-08-13) |
| DOC-A.3 | ARCHITECTURE / CODEBASE: purity is a target | DOC-3 | — | ARCHITECTURE + CODEBASE | **done** (2026-08-13) |
| DOC-M.1 | Rewrite `migration-and-ops.md` to match `onUpgrade` | DOC-4 | — | handbook | **done** (2026-08-13) |
| DOC-M.2 | schema-reference: SET NULL, receiptSequence*, unique ≠ deleted_at | DOC-4 | — | schema-reference | **done** (2026-08-13) |
| DOC-M.3 | query-patterns: `hydrateSales` batch | DOC-4 | — | query-patterns | **done** (2026-08-13) |
| DOC-M.4 | DATABASE.md: cut “16 tables all sync-ready” | DOC-4 | V092-A.4 | `DATABASE.md` | **done** (2026-08-13) |

---

## Could

| ID | Description | Notes | Status |
|----|-------------|-------|--------|
| DOC-C.1 | Split ADRs into `adr/00N-*.md` | After ADR-027/028 | deferred |
| DOC-C.2 | Regen C4 puml | After DOC-A.1 | deferred |
| DOC-C.3 | Archive `docs/REPORT_REFACTOR_PLAN.md` | Untracked orphan | deferred |
| DOC-C.4 | Ignore+untrack `app_localizations*.dart` | Not docs-only | deferred |
| DOC-C.5 | Merge `docs/readme/features.md` into README | **Won’t merge** — README gets 6–8 bullets only (DOC-R.6 / DOC-R.9) | deferred |
| DOC-R.1 | Strip ASCII / emoji KPIs / PRs-Welcome | README.md | **done** (2026-08-13) |
| DOC-R.2 | Delete repo tree + arch ASCII; pointer to CODEBASE | README.md | **done** (2026-08-13) |
| DOC-R.3 | One docs table (≤6 rows) | README.md | **done** (2026-08-13) |
| DOC-R.4 | Keep claim freeze (unreleased, not Play, not tax invoice) | README.md | **done** (2026-08-13) |
| DOC-R.5 | Net cut ≤140 lines | README.md (~100 lines) | **done** (2026-08-13) |
| DOC-R.6 | Status + Not-for + What-it-does (6–8 bullets) | README.md | **done** (2026-08-13) |
| DOC-R.7 | TOC = remaining H2s | no vanity TOC; H2s are the map | **done** (2026-08-13) |
| DOC-R.8 | Screenshots: 3 hero images | Sale / Products / Report | **done** (2026-08-13) |
| DOC-C.6 | Thai one-pager for merchants | After surface honesty | deferred |
| DOC-C.7 | Move this package to `docs/plan/COMPLETE/` | After a commit of the staged plan tree | deferred |

---

## Covered-by (do not duplicate)

| Finding | Owner | This package |
|---------|-------|--------------|
| Tax-invoice document type in code | **V092-A.1** | CHANGELOG Unreleased note; listing **frozen** |
| PIN default-on docs sweep | **V092-A.2** | DOC-SEC-2 landed the live sentences |
| CI/AAB/E2E YAML honesty for the tag | **V092-A.3 / D.3** | `CI.md` + CONTRIBUTING |
| Device void + PIN smoke | **V092-D.2** | `RELEASE_1.0_SMOKE` still No-Go |
| SKU dedupe / deleted_at unique policy | **V092-C.2 / C.4** | handbook links only |
| Domain fence CI | **AH-1.1** | docs do not claim it exists |
| Play A1–A5 | **POST-090** | link only |

---

## Wave exit

| Wave | Exit when |
|------|-----------|
| **DOC-0** | Package + roadmap row — **done** |
| **DOC-1** | Index + README/USAGE honesty + plan-tree staged as D+A pair — **done** |
| **DOC-2** | Live SECURITY/STORE/PRIVACY/CI.md/CONTRIBUTING — **done** |
| **DOC-3** | Architecture wording + AH-2.1/AH-G3 + AH-0 paused — **done** |
| **DOC-4** | Data handbook cannot brick an upgrade if followed — **done** |

---

## Status changelog

| Date | Change |
|------|--------|
| 2026-08-13 | Package created; DOC-0.1 done |
| 2026-08-13 | Executed Must+Should (except operator DOC-N.1 git staging) |
| 2026-08-13 | **DOC-N.1 done (staged):** COMPLETE/UN-COMPLETE paired with old-path deletions (`R`/`A`); not committed |

---

<sub>Promsell POS CE · DOC-SSOT · backlog · 2026-08-13</sub>
