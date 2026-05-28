<div align="center">
 
<pre style="background:none;border:none;">
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   🛒  PROMSELL  —  Offline-first Mobile POS for Merchants    ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
</pre>
 
<h1>Promsell — POS Community Edition</h1>
 
<p>
  <strong>An offline-first mobile POS system built with Flutter for small businesses and local merchants.</strong>
</p>
 
<p>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter 3.x"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.11-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart 3.11"></a>
  <a href="https://github.com/teeprakorn1/promsell-pos-ce/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-AGPL_3.0-10b981?style=for-the-badge&logo=opensourceinitiative&logoColor=white" alt="AGPL-3.0 License"></a>
</p>
 
<p>
  <a href="https://github.com/teeprakorn1/promsell-pos-ce/commits/main"><img src="https://img.shields.io/github/last-commit/teeprakorn1/promsell-pos-ce?style=flat-square&color=64748b" alt="Last Commit"></a>
  <a href="https://github.com/teeprakorn1/promsell-pos-ce"><img src="https://img.shields.io/github/languages/top/teeprakorn1/promsell-pos-ce?style=flat-square&color=64748b" alt="Top Language"></a>
  <a href="https://github.com/teeprakorn1/promsell-pos-ce/pulls"><img src="https://img.shields.io/badge/PRs-Welcome-ff69b4?style=flat-square&logo=git&logoColor=white" alt="PRs Welcome"></a>
</p>
 
<table align="center">
  <tr>
    <td align="center"><b>5</b><br>📱 Tabs</td>
    <td align="center"><b>2</b><br>🌐 Languages</td>
    <td align="center"><b>3</b><br>🎨 Themes</td>
    <td align="center"><b>100%</b><br>📴 Offline</td>
    <td align="center"><b>SQLite</b><br>💾 Storage</td>
  </tr>
</table>
 
</div>
 
---
 
**Promsell POS Community Edition** is an open-source point-of-sale application designed for small shops, market stalls, and local merchants who need a fast, reliable, and offline-capable cash register on their phone or tablet. Built with Flutter and Drift SQLite, it works without an internet connection, supports Thai and English with live language switching, and provides full sales tracking, inventory management, and reporting.
 
> **Latest Release: v0.4.2** — Bug fixes: payment sheet no longer gets stuck after sale (Navigator race condition); VAT values are now persisted at sale time and shown in History; ReportPage no longer reloads on every rebuild; product image URL preserved on edit; inventory log labels and ProductForm sections localized; empty-state filtering fixed; qty=0 adjustment blocked.
 
---
 
## Table of contents
 
- [Features](#features)
- [Tech stack](#tech-stack)
- [Quick start](#quick-start)
- [Project structure](#project-structure)
- [Screenshots](#screenshots)
- [Roadmap](#roadmap)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)
 
---
 
## Features
 
| Feature | Description |
|---------|-------------|
| **Sale** | Searchable product catalog, category chips, adaptive cart command panel, stock-limit controls, cart quantity badges, multi-method checkout, quick cash chips, payment references, and change calculation |
| **Products** | List/grid toggle, category filter chips, image URL avatar with live preview, `_StockBadge` (traffic-light), add/edit/delete with category, price, stock, active/inactive toggle |
| **History** | Date-ranged receipt-like sale history with expandable item breakdown, receipt numbers, VOIDED badge, VAT breakdown rows (Subtotal + VAT rate %) when VAT is active, void sale action with reason, and notes |
| **Report** | Dashboard cards for net revenue (excludes voided), voided summary, payment method breakdown, top 5 products, date filter chip, pull-to-refresh, and empty states |
| **Inventory** | Inventory audit log (SALE, VOID_REVERSAL, ADJUSTMENT_IN/OUT), manual stock adjustment dialog with reason, and per-product log viewer |
| **Settings** | Grouped settings cards for language, theme, shop info, currency, date format, receipt customization, VAT mode/rate, preview style toggles, dirty-state save behavior, and compact responsive controls |
| **Void / Refund** | Atomic void sale flow: marks VOIDED, restores stock, logs VOID_REVERSAL; receipt number generation |
| **Receipt Preview** | On-screen preview in `thermal` (80mm paper) and `card` styles, with independent pre/post-sale toggles and `"none"` option |
| **VAT** | `NONE` / `INCLUSIVE` / `EXCLUSIVE` modes with correct subtotal/VAT/total breakdown on receipts and PDFs; VAT mode and rate are snapshotted at sale time and used for accurate historical reprints |
| **Offline-first** | All data stored locally in SQLite via Drift — no internet required |
| **Material 3** | Merchant Command Deck refresh with shared theme tokens and responsive UI primitives |
| **i18n** | Full localization via Flutter ARB files, easy to add more languages |
 
---
 
## Tech stack
 
| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.x · Dart 3.11+ |
| **State management** | flutter_bloc (BLoC + Cubit pattern) |
| **Database** | Drift (SQLite ORM) with code generation — 9 tables, UUID PKs |
| **DI** | get_it service locator |
| **Routing** | Navigator + IndexedStack |
| **Persistence** | SettingsLocalDatasource (Drift-backed typed key-value store); Drift tables for receipt sequences |
| **Localization** | flutter_localizations + Flutter ARB intl |
| **PDF / Print** | pdf + printing |
| **Design** | Material 3, NotoSansThai (bundled local fonts), shared UI primitives |
 
---
 
## Quick start
 
### Prerequisites
 
- Flutter SDK ≥ 3.11 ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio or Xcode for device/emulator
- Git
 
### Install and run
 
```bash
# 1. Clone
git clone https://github.com/teeprakorn1/promsell-pos-ce.git
cd promsell-pos-ce
 
# 2. Install dependencies
flutter pub get
 
# 3. Generate code (Drift, l10n)
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
 
# 4. Run on connected device or emulator
flutter run
```
 
### Build release APK
 
```bash
flutter build apk --release
```
 
The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.
 
For more details, see [`docs/USAGE.md`](docs/USAGE.md).
 
---
 
## Project structure
 
```
promsell-pos-ce/
├── lib/
│   ├── core/
│   │   ├── database/          # Drift schema, tables, and migrations
│   │   ├── di/                # get_it service locator
│   │   ├── extensions/        # context.l10n helper
│   │   ├── utils/             # IdGenerator, payment_method, etc.
│   │   └── widgets/           # shared UI primitives
│   ├── features/
│   │   ├── sale/              # Cart + checkout
│   │   ├── product/           # CRUD inventory
│   │   ├── history/           # Sale history viewer + void dialog
│   │   ├── report/            # Analytics dashboard (net revenue)
│   │   ├── inventory/         # Inventory log viewer + stock adjust
│   │   └── settings/          # Theme, locale, shop info
│   ├── l10n/                  # ARB files (app_th.arb, app_en.arb)
│   └── main.dart              # App entry + 5-tab shell
├── docs/
│   ├── ARCHITECTURE.md        # Deep technical architecture (C4, data flow, ADRs)
│   ├── USAGE.md               # Detailed usage guide
│   ├── DEPLOY.md              # Build, signing, release checklist
│   ├── DATABASE.md            # Full database handbook (ERD, schema, migration)
│   └── architecture/          # PlantUML source files (.puml)
├── android/                   # Android platform code
├── ios/                       # iOS platform code
├── test/                      # Unit + widget tests
├── pubspec.yaml
├── l10n.yaml
├── CODEBASE.md                # Architecture, modules, file dependency map
├── CONTRIBUTING.md            # Contribution guide
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```
 
Each feature follows **Clean Architecture**:
 
```
features/<name>/
├── data/
│   ├── datasources/      # Drift DAO wrappers
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Pure Dart models
│   ├── repositories/     # Abstract interfaces
│   └── usecases/         # Business logic
└── presentation/
    ├── bloc/ or cubit/   # State management
    └── pages/            # UI widgets
```
 
---
 
## Screenshots
 
> **Help wanted!** We'd love real device screenshots here.
> To contribute: run the app in release mode, capture each tab, and open a PR adding images to `docs/screenshots/`.
> Suggested filenames: `sale.png`, `products.png`, `history.png`, `report.png`, `settings.png`.
 
| Sale | Products | History | Report | Settings |
|------|----------|---------|--------|----------|
| _TBA_ | _TBA_ | _TBA_ | _TBA_ | _TBA_ |
 
---
 
## Roadmap

### Phase 1 (in progress)

- [x] **Schema + Sale Integrity Overhaul** (v0.4.0): UUID migration, 9 tables, indexes, sync-ready columns, atomic receipt numbers, inventory logs, void/refund, stock adjustments
- [x] **R3 — Cashier UX**: Draft carts, discounts, VAT, stock policy (partial: VAT done)
- [ ] **R4 — Merchant Tools**: PromptPay QR, backup/restore
- [ ] **R5 — Operations**: Daily close, onboarding wizard, final polish

### Future

- [ ] Receipt printing via Bluetooth thermal printer
- [x] PDF receipt export and share (v0.3.0)
- [ ] Multi-shop support
- [ ] Cloud backup and restore
- [ ] Barcode / QR scanner for product entry
- [ ] CSV import / export for products and sales
- [ ] Customer management and loyalty
- [ ] More languages (Lao, Khmer, Burmese, Vietnamese)

---

## Testing

**187 tests** covering every application layer:

| Layer | What's tested | Count |
|-------|--------------|-------|
| **Domain** | Entity equality, use case delegation | ~20 |
| **BLoC / Cubit** | Event→state transitions, error handling | ~15 |
| **Repository** | Impl with mocked datasources | ~15 |
| **Datasource** | Real in-memory SQLite (Drift) | ~11 |
| **Services** | ReceiptNumberService, InventoryLogService, ReceiptPdfService | ~15 |
| **Widget** | ProductList, ProductForm, PaymentSheet, Settings, ReceiptPreview | ~20 |
| **Integration** | Checkout flow, sale integrity (void + adjust) | 13 |
| **L10n parity** | EN/TH key coverage, non-empty values, params | 8 |

### Running tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Single file
flutter test test/integration/checkout_flow_test.dart
```

### Test helpers

| File | Purpose |
|------|---------|
| `test/helpers/mocks.dart` | All mock classes (repos, datasources, use cases, BLoCs) |
| `test/helpers/pump_app.dart` | `pumpApp` extension with BlocProviders + l10n |
| `test/helpers/fake_database.dart` | In-memory Drift DB factory |

---

## Contributing

Contributions are welcome — bug reports, feature suggestions, or pull requests.

Read **[CONTRIBUTING.md](CONTRIBUTING.md)** for the full guide: branch naming, commit conventions, code style, and testing requirements.

For security vulnerabilities, see **[SECURITY.md](SECURITY.md)** — do not file public issues.

### Documentation

| Document | Contents |
|----------|----------|
| [`CODEBASE.md`](CODEBASE.md) | Architecture diagram, module reference, file dependency map |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Deep technical: C4 diagrams, data flows, transaction boundaries, DI graph, ADRs |
| [`docs/DATABASE.md`](docs/DATABASE.md) | Full database handbook: ERD, schema, indexes, migration, query patterns |
| [`docs/USAGE.md`](docs/USAGE.md) | Detailed usage guide: setup, build, settings, i18n, troubleshooting |
| [`docs/DEPLOY.md`](docs/DEPLOY.md) | Build, signing, release checklist, smoke test |
| [`CHANGELOG.md`](CHANGELOG.md) | Version history, breaking changes, migration notes |

---

## License

Licensed under the **GNU Affero General Public License v3.0** — see [`LICENSE`](LICENSE) for details.

```
Copyright (C) 2026 MN Lizard Team

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
```

---

<div align="center">

Built by **[MN Lizard Team](https://github.com/teeprakorn1)**

**Creator & Core Maintainer:**
[@teeprakorn1](https://github.com/teeprakorn1)

**Contributors:**
[@FrameHandsomez](https://github.com/FrameHandsomez)

<sub>Promsell POS Community Edition · v0.4.2 · AGPL-3.0</sub>

</div>