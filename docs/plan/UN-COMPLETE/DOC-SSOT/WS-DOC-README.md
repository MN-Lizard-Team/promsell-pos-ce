# WS-DOC-README — Mature the public README

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** DOC-R.1 … DOC-R.12  
**Status:** todo (wave DOC-5)  
**Does not:** merge `docs/readme/features.md` (closes DOC-C.5 as won’t-do) · touch `fastlane/metadata/**` · claim Play / tax invoice / sync

---

## Why

DOC-S.* made the README **honest**. It is still **not senior**.

Seven-track review (2026-08-13):

| Lens | Score | One line |
|------|------:|----------|
| Staff / IA | 5.0 | Dev dump above the fold |
| Product | 5.8 | No merchant path; features off-page |
| Trust | 6.4 | Limits exist but are crushed into jargon |
| Contributor | 6.5 | Commands OK; tree + triple SSOT |
| Visual | 3.5 | 2018 GitHub carnival |
| OSS comparison | — | Missing Status / Features / Security as headings |

Honesty stays. **Shape** changes: cut chrome, put status and non-goals first, keep Quick start short.

---

## Target outline (H2 order)

Lead (no H2): name + one sentence + one status line.

1. **Status** — unreleased `0.9.1+1` · latest tag `v0.9.0` · not Play production · CE
2. **Who it is for / not for** — four bullets: not multi-staff, not a tax invoice, not a sync engine, not cross-device restore
3. **What it does** — 6–8 merchant bullets (sell, stock, PromptPay, park bills, day close, encrypted backup). No class names.
4. **Screenshots** — 3 wide shots (Sale, Products, Report) + link to the rest
5. **Quick start** — doctor → clone → pub get → gen-l10n + build_runner → `flutter run --flavor dev -t lib/main_dev.dart`. No bare `flutter run`. PIN on first launch. APK build stays in `docs/DEPLOY.md`
6. **Security & data** — SQLCipher at rest · store PIN · same-device `.enc` · no developer servers · link `SECURITY.md` + `docs/PRIVACY_POLICY.md`
7. **Documentation** — one table, 5–6 rows
8. **Contributing** — one short paragraph → `CONTRIBUTING.md`
9. **License** — AGPL-3.0 + one copyleft sentence (no full license paste)

**Cut from README:** ASCII box, emoji KPI table, PRs-Welcome badge, repo tree, architecture ASCII, widget-folder sermon, split-references table, long copyright block, plan jargon (V092 / ARCH-HARDEN) in the hero.

---

## Must

| ID | Work | Done when |
|----|------|-----------|
| DOC-R.1 | Strip junior chrome (ASCII, emoji KPIs, pink PRs-Welcome) | those strings gone |
| DOC-R.2 | Delete structure tree + arch ASCII; one-line pointers to CODEBASE / ARCHITECTURE | tree gone |
| DOC-R.3 | One docs table (CODEBASE, USAGE, ARCHITECTURE, CHANGELOG, plan map, STORE) | no second “split” table |
| DOC-R.4 | Claim freeze unchanged: unreleased 0.9.1+1, tag v0.9.0, not Play, receipt ≠ tax invoice, same-device backup | `rg` below |
| DOC-R.5 | Net cut: current ~270 lines → **≤140** (stretch 120) | `wc -l` |

## Should

| ID | Work |
|----|------|
| DOC-R.6 | Four-bullet Not list + 6–8 What-it-does bullets |
| DOC-R.7 | TOC = remaining H2s only |
| DOC-R.8 | Screenshots: 3 hero columns, keep files in `screenshots/store/en/` |
| DOC-R.9 | Mark DOC-C.5 **won’t merge** in BACKLOG |

## Could

| ID | Work |
|----|------|
| DOC-R.10 | Flat badges only: CI, coverage, license |
| DOC-R.11 | Footer = version + AGPL (names stay in CONTRIBUTING / GitHub) |
| DOC-R.12 | Optional 4-line Thai box for merchants (limits only — do not fork a second README) |

---

## Principles

| Topic | Decision |
|-------|----------|
| Cut more than add | Delete ~150 lines of tree/diagram/vanity. Add ≤20 lines of Status / Not / Features |
| Two audiences | Merchant: Status + Not + Features + USAGE. Dev: Quick start + CONTRIBUTING |
| No third SSOT | Commands live here for *run*. CONTRIBUTING for *PR*. USAGE for *backup/flavors* |
| Listing freeze | Do not edit Play copy. Do not say 0.9.1 is shipped |

---

## Verify

```bash
test $(wc -l < README.md) -le 140
rg -n "╔══|5 Tabs|PRs-Welcome|Payable SSOT|Clean Architecture complete" README.md   # expect 0
rg -n "unreleased 0.9.1\\+1|latest tag \\*\\*v0.9.0\\*\\*|not on Play|store PIN|this device only|flavor dev -t lib/main_dev.dart" README.md
test -f screenshots/store/en/02_sale.png
```

---

<sub>Promsell POS CE · DOC-SSOT · WS-README · 2026-08-13</sub>
