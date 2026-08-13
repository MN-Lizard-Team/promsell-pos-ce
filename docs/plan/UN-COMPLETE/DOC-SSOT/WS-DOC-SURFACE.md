# WS-DOC-SURFACE — README, USAGE, trust copy, CI.md

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** DOC-S.* · DOC-SEC-* · DOC-QA-* · DOC-UX-6  
**Status:** todo (wave DOC-1 / DOC-2)

---

## Goal

First-run and first-read stop lying. Play listing tax-invoice **denials stay frozen** until V092-A.1.

---

## DOC-S.1 — Screenshots

`README.md` table still points at deleted `screenshots/{products,sale,report,history,settings}.png`.

Retarget to files that exist:

| Caption | Path |
|---------|------|
| Home | `screenshots/store/en/01_home.png` |
| Sale | `screenshots/store/en/02_sale.png` |
| Products | `screenshots/store/en/05_products.png` |
| History | `screenshots/store/en/06_history.png` |
| Report | `screenshots/store/en/07_report.png` |
| Settings | `screenshots/store/en/08_settings.png` |

Note: captured via `integration_test/screenshot_test.dart` (dev flavor). Do not move smoke folders.

---

## DOC-S.2 / S.3 — Version + l10n + onboarding

Latest **tag** is `v0.9.0`. Disk / `pubspec.yaml` is **unreleased `0.9.1+1`**.

- Banner: “Unreleased 0.9.1+1 (latest tag **v0.9.0**). Schema **v30**.”
- Footer: same. Do not market `v0.9.1` as shipped.
- `lib/l10n/`: “~1700 keys (TH/EN)” not `90+`.
- Overlay: “Onboarding (4-step…)” — code `_totalSteps = 4`.

---

## DOC-S.4 — USAGE run

Replace bare `flutter run` / `flutter run --release` as the **primary** recipe:

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --release --flavor prod -t lib/main_prod.dart
```

One line: “Bare `flutter run` is not supported; flavors are required.”

---

## DOC-SEC-1 — AAB fail-closed (live SSOT)

YAML: missing `ANDROID_KEYSTORE_*` → `exit 1`. No `require_signed_aab` input.

| File | Replace |
|------|---------|
| `SECURITY.md` (~L90) | Signed prod AAB on `v*` **requires** secrets |
| `docs/STORE_SUBMISSION.md` Should + E4 | Delete `require_signed_aab`; E4 = fail-closed |
| `POST-090 WS-A` A3 note | dispatch also fail-closed |
| `docs/testing/RELEASE_0.9_SMOKE.md` | drop “optional signed AAB” |

Leave `V090-TRUST-E-RELEASE.md` as 2026-07-17 history (stamp if needed). Overlaps V092-A.3 — land once.

---

## DOC-SEC-2 / 3 / 4 — PIN + Privacy

- New installs: PIN **required** (`docs/readme/features.md`, `docs/usage/features.md`, STORE E0c = shipped 0.9.1). Covered-by **V092-A.2**.
- SECURITY stock gate: VoidSale, AdjustStock, ImportProducts, backup, PromptPay — **not** product-form / quick-edit. Do not say “PIN protects inventory.”
- `PRIVACY_POLICY.md`: date **August 13, 2026**. “Core POS is offline. Optional INTERNET only for merchant-supplied product image URLs.” Cross-link §2 and §7.

**DOC-SEC-5 listing freeze:** do **not** edit `fastlane/metadata/**` tax-invoice denials until V092-A.1. Add a 0.9.2 CHANGELOG **note** that 0.9.1 overclaimed document type.

---

## DOC-QA-1 / 2 — `docs/testing/CI.md` + CONTRIBUTING

New human SSOT. Other docs link it. Do not restate YAML in five places.

| Workflow | Device | Gate |
|----------|--------|------|
| `ci.yml` | No | analyze, `flutter test --coverage --exclude-tags stress`, perf, format+analyze `integration_test/`, 60/80 |
| `release-trust.yml` | Yes (job 2) | host money list + blocking `all_tests.dart --flavor dev` |
| `release-aab.yml` | via trust | trust then signed prod AAB; secrets fail-closed |
| screenshots / stress | visual / weekly | not money |

State: green `ci.yml` ≠ device E2E. Trust smoke ≠ `RELEASE_1.0_SMOKE` Pass. **Do not flip 1.0 smoke.**

CONTRIBUTING checklist = commands in V092/DOC-QA plan (`--exclude-tags stress`, coverage script, format includes `integration_test/`). Clarify: `*.g.dart` / `*.config.dart` untracked; `lib/l10n/app_localizations*.dart` still tracked.

E2E_* file rewrite stays **V092-D.3** (may point at `CI.md`).

---

## DOC-UX-6 / 7

- `docs/readme/features.md`: row title **Void sale** (not Void / Refund). Whole-sale void only.
- Two-line pointer: capability index here; cashier walkthrough in `docs/usage/features.md`. Do not merge folders this slice.

---

## Verify

```bash
test -f screenshots/store/en/01_home.png
rg -n "90\\+ keys|6-step|Void / Refund|flutter run --release$" README.md docs/USAGE.md docs/readme/features.md
rg -n "optional signed AAB|require_signed_aab|entirely offline" SECURITY.md docs/STORE_SUBMISSION.md docs/PRIVACY_POLICY.md
```

---

<sub>Promsell POS CE · DOC-SSOT · WS-SURFACE · 2026-08-13</sub>
