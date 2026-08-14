# Changelog

All notable changes to **Promsell POS Community Edition** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.9.2] - 2026-08-14

**Not tagged yet.** Release notes are prepared for `v0.9.2`. Disk / `pubspec` remains `0.9.1+1` until the version bump. Latest GitHub tag remains **v0.9.0**.

### Highlights

- **Cashier security** — store-PIN gates for sensitive product, sale, backup, report, settings, and day-close actions; cold-start/resume locking; persisted session grace and lockout policy.
- **Money and integrity** — schema v32 satang dual-write path, exact tender equality, stock CAS/version protection, SKU deduplication, and satang-first report aggregation.
- **Tablet and reliability** — tablet landscape support with catalog/cart dual-pane, database opening off the UI isolate, whole-catalog barcode/SKU scanning, and less-flaky integration-test helpers.
- **Architecture and release gates** — domain import fence, release-trust money-path tests, honest device-E2E status, and a v0.9.2 device smoke sheet.

### Fixed

- Receipt titles no longer flip to “ใบกำกับภาษี / Tax Invoice” when a shop Tax ID is present; receipts retain the sales-receipt disclaimer.
- Stock sale, void, and adjustment paths now use atomic updates with version bumps, preventing stale product forms from restoring old stock.
- Schema upgrade hygiene now deduplicates case-insensitive SKUs before the unique index and reapplies indexes/triggers idempotently.
- Pre-restore backup cleanup, whole-catalog scanning, checkout recovery, and integration-test timer handling were hardened.

### Added

- Expanded Store PIN settings: change/erase PIN, session-grace selector, lockout policy, PIN status, trivial-PIN rejection, and risk-confirmed disable/skip flows.
- v0.9.2 smoke documentation, stable E2E test keys, release-trust integration coverage, and Phase M migration/wiring tests.
- Tablet `SaleDualPane` layout, `DockedCartPanel`, and landscape orientation policy for devices with a shortest side of at least 600dp.

### Changed

- Disabling the PIN now keeps the PIN; erasing the PIN is a separate destructive action.
- Onboarding PIN setup can be skipped only after explicit risk confirmation.
- Domain layers are now fenced from Flutter, data, and presentation imports; affected use cases use domain ports and presentation mappers.
- Device E2E remains an explicit trust/release lane rather than a claim of green main-CI coverage.

### Security

- Sensitive screens use `FLAG_SECURE`; PIN, PromptPay, backup, report export, product, stock, and day-close operations are gated when the store lock is enabled.
- Security reports must use `SECURITY.md`; conduct reports use the private process in `CODE_OF_CONDUCT.md`.
- **Known breaking limitation:** Keystore corruption can still make the SQLCipher key unrecoverable. Phase 2b key export/recovery is the planned fix; keep encrypted backups off-device.

### Breaking / migration

- Auto-upgrade to schema **v32**: 32 nullable INTEGER `*_satang` columns across 10 money tables, including conditional amount-valued discounts/promotions. Backfill is NaN/Inf-safe and percentage values remain REAL.
- Writers dual-write satang plus legacy REAL baht; readers prefer satang and fall back to REAL for pre-v32 rows. Legacy REAL columns remain temporarily for rollback compatibility.
- This release does not add cross-device restore or cloud sync. The encrypted pre-M backup-restore fixture and eventual REAL-column removal remain deferred.

### Known limitations

- No GitHub tag `v0.9.2` yet; disk / `pubspec` remains `0.9.1+1` until the release version is bumped.
- Device/emulator E2E is not run by main CI; release-trust and operator smoke checks are still required.
- There is no server-side key escrow. A lost SQLCipher key cannot currently be recovered on the same device.

`flutter analyze` → **0 issues** · `flutter test` → **2129 passing** (incl. Phase M migration, satang-wiring, and report-precision coverage) · coverage **~63.7%**

## [0.9.1] - 2026-08-11

**Not tagged yet.** Disk / `pubspec` is `0.9.1+1`. Latest GitHub tag remains **v0.9.0**.

Sale / Report / History / Onboarding redesign, product soft-delete, schema **v31** (v30 sku_lower + v31 dedupe repair). Receipts stay **sales receipts** even when a shop Tax ID is printed.

### Highlights

- **Cashier UX** — full-page cart review, sticky settle dock, multi-bill board, payment-lock while checking out.
- **Onboarding** — four steps, store-PIN gate on finish/skip, ready-to-sell summary.
- **Reports** — net revenue hero, profit/margin when cost is set, period delta, History as a Report sub-tab, PDF/CSV export.
- **Catalog integrity** — soft-delete + undo; `barcodeLower` (v29) and `skuLower` (v30) unique indexes.
- **Receipt Tax ID** — prints the shop tax-ID line; multi-page A4; live preview. **Do not treat this as a Thai tax invoice.** A 0.9.1 code path still flips the PDF title when Tax ID is set (V092-A.1).

### Fixed

- `barcodeLower` was always NULL; now written on insert/update/bulk.
- Soft-delete order: DB row first, then images (no orphan paths on DB failure).
- Barcode validator now strips spaces/hyphens; CSV import rejects intra-file duplicate barcodes.
- Tax ID dropped on onboarding Skip; onboarding vs settings length rules disagreed.
- Checkout failure left the cart payment-locked; now unlocks without clearing lines.
- History void reported success on failure; search fired every keystroke; empty-items crash.
- Report CSV formula injection (`" =SUM…"`); PDF row cap ignored `maxRows`; date/time padding.
- Draft rotation deleted the active draft before creating its replacement.
- PDF font crash on missing assets; `SaleReceiptActions` global busy flag; `changeAmount` null crash.

### Added

- Store-PIN dialog on onboarding; SKU auto-generate settings.
- Product pagination, `product_audits`, grid view, restore-after-soft-delete.
- `CreateSale` recomputes payable from lines; `VoidSale` requires a sensitive session.
- Backup 512 MB cap + isolate PBKDF2; CI performance job.
- Host tests expanded (~2028 passing, coverage ~63.7% at cut).

### Changed

- Sale split into catalog / cart / checkout; cash change from the cash tender only.
- Settings rebuilds narrowed with `buildWhen`; backup `changePin` requires the current PIN.
- `grandTotal` removed — use `payableTotals` SSOT.
- Docs honesty (DOC-SSOT) + README refresh: PIN default-on for new installs; AAB on `v*` fail-closed; README is the public map; CI behaviour in `docs/testing/CI.md`.

### Security

- Soft-deleted products are rejected on update, adjust, and sale insert.
- Unique barcode/SKU checks include soft-deleted rows so restore cannot collide.

### Breaking / migration

- Auto-upgrade to schema **v31** (v29 barcode_lower + dedupe; v30 sku_lower unique; v31 SKU dedupe repair and idempotent index/trigger setup).
- Delete is soft-delete; recover with `restoreProduct`.
- `AppLockService.setPin` throws if a PIN already exists — use `changePin`.

### Known limitations

- No GitHub tag `v0.9.1` yet.
- Receipt title can still become ใบกำกับภาษี when Tax ID is set (code; listing denies it).
- `file_picker 12.0.0-beta.7` and pinned `image_picker_android 0.8.13+19`.

## [0.9.0] - 2026-07-17

Trust cut for offline single-device POS: money-path integrity, encryption, store PIN, same-device backup restore, release gates, and store-facing honesty. Schema **v28** at this cut (15 tables, incl. `sale_payments`).

> **Historical:** PIN was still described as Optional, AAB as secrets-optional, coverage floor 50%. Those are **not** current — see 0.9.2. Do not copy this block into store copy.

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
- Trust epic docs under `docs/plan/COMPLETE/V090-TRUST/`; expanded unit/integration trust suite.

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

---

[0.9.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.9.0...HEAD
[0.9.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.9.0...HEAD
[0.9.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.9...v0.9.0

