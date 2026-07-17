# Changelog

All notable changes to **Promsell POS Community Edition** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.9.0] - 2026-07-17

Trust cut for offline single-device POS: money-path integrity, encryption, store PIN, same-device backup restore, release gates, and store-facing honesty. Schema **v28** (15 tables, incl. `sale_payments`).

### Highlights

- **Money path** — Integer satang `Money` VO + `SalePayableCalculator` SSOT; hard cart freeze + `paymentLocked` on confirm; multi-tender (`sale_payments`); atomic stock SQL; day lock on create/void.
- **Data at rest** — SQLCipher production path; key in secure storage; backup AES-GCM (default on) + **same-device** restore only.
- **Store PIN** — Optional PIN (min 6, PBKDF2 v2); gates void, backup, stock adjust, CSV import, PromptPay, encryption-off; lockout **persists** across cold start; session clear on background; FLAG_SECURE on sensitive UI.
- **Release** — Coverage floor 50%; release signing fail-closed; `release-trust.yml` (money path); `release-aab.yml` (optional signed AAB); smoke checklist + staged Play assets (EN/TH).
- **POS product** — Full-page cart, saved bills / multi-draft, split tender + PromptPay, receipt SSOT (not tax invoice), settings Clean Index, catalog/search/CSV, restaurant path retained from 0.8.x line.

### Fixed

- Checkout **failure left cart payment-locked** (stock/day/DB errors); now unlocks without clearing lines.
- PromptPay / pay wait could diverge from live cart edits mid-wait.
- Stock RMW absolute writes (lost updates); sale/void/adjust use conditional `stock = stock ± ?`.
- Backup export after failed WAL checkpoint; restore rejects plain SQLite.
- Release signing silent debug fallback without keystore.
- Store PIN: weak hash / short PIN / in-memory-only lockout / no background session clear.
- Privacy overclaim “does not collect any personal data” (docs + in-app); TH Play title over 30 chars.
- Settings seed/mapper key drift; receipt totals vs stored sale fields; void share as paid receipt; many dispose/IME races on dialogs.

### Added

- `AppLockService` + settings UI; PIN on stock adjust & CSV import entry points.
- `BackupRestoreService` + Settings restore CTA; encrypt→restore tests.
- Cart/checkout freeze types; sale write split (insert/void/query helpers); multi-tender model.
- CI: `release-trust.yml`, `release-aab.yml`; store screenshots + feature graphic tooling.
- Receipt domain `ReceiptDocument` / builder; day-close + report tender-aware totals.
- Trust epic docs under `docs/plan/V090-TRUST/`; expanded unit/integration trust suite.

### Changed

- Privacy / SECURITY / DATABASE / STORE_SUBMISSION / smoke aligned to v28 + same-device restore + honest local PII.
- Fastlane TH title: `Promsell — POS ร้านค้าเล็ก` (≤30).
- Sale cart is full-page review (not docked dual-pane); settings root attention banner + risk chips.
- Backup encryption default **on** when setting missing; PIN min 6 on export path.
- Maintainability splits: cart mixins, checkout helpers, product form coordinators, barcode scanner session (behavior unchanged).

### Security

- SQLCipher + Keystore/Keychain key; key loss without export = permanent loss (no Phase 2b recovery).
- Store PIN PBKDF2 100k + ** lockout; gated sensitive actions listed above.
- Crash log PII sanitize on write; image delete sandboxed under `images/`.
- Never commit JKS; CI AAB only with operator secrets.

### Breaking / migration

- Auto-upgrade to schema **v28** (incl. unique receipt numbers, `sale_payments`, daily close unique date path).
- Backup encryption default on for new installs / missing key (stored `false` stays off).
- SQLCipher: uninstall / keystore wipe without export loses the DB.

### Known limitations

- No cross-device restore / SQLCipher key export (Phase 2b).
- Money columns still SQLite `REAL` baht on disk (domain satang; Phase M deferred).
- Production Play still needs operator keystore, Data safety form, console submit.
- Device `integration_test/` may soft-fail on main CI; money path is hard-gated via Release Trust.
- Tablet dual-pane sale / landscape POS layout still incomplete.

---

## Older releases

Full notes for **0.8.x** and earlier live under [`docs/changelog/`](docs/changelog/):

| Series | File |
|--------|------|
| 0.8.x | [CHANGELOG-08x.md](docs/changelog/CHANGELOG-08x.md) |
| 0.7.x | [CHANGELOG-07x.md](docs/changelog/CHANGELOG-07x.md) |
| 0.6.x | [CHANGELOG-06x.md](docs/changelog/CHANGELOG-06x.md) |
| 0.5.x | [CHANGELOG-05x.md](docs/changelog/CHANGELOG-05x.md) |
| 0.4.x | [CHANGELOG-04x.md](docs/changelog/CHANGELOG-04x.md) |
| 0.3.x | [CHANGELOG-03x.md](docs/changelog/CHANGELOG-03x.md) |
| 0.2.x | [CHANGELOG-02x.md](docs/changelog/CHANGELOG-02x.md) |
| 0.1.x | [CHANGELOG-01x.md](docs/changelog/CHANGELOG-01x.md) |

