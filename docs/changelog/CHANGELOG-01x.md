# Changelog — v0.1.x — Promsell POS CE

> For the most up-to-date changes and release information, see [CHANGELOG.md](/CHANGELOG.md) for version 0.8.x, including feature additions, system improvements, performance enhancements, and bug fixes.

---

## [0.1.0] - 2026-05-25

First public release. Complete offline-first mobile POS with sale, inventory, history, reporting, and settings.

### Added

#### Core architecture

- Flutter 3.x with Material 3 theming
- Clean Architecture per feature (`data` / `domain` / `presentation`)
- BLoC/Cubit state management with `flutter_bloc`
- `get_it` dependency injection
- `go_router` declarative navigation
- Drift SQLite ORM with code generation
- `shared_preferences` for app settings

#### Features

- **Sale** — product grid with search and category filter, live cart, multi-method payment (cash/transfer/card), change calculation
- **Products** — full CRUD with validation, searchable list, delete confirmation
- **History** — date-ranged sale history with item breakdown and notes
- **Report** — revenue summary, sales count, payment breakdown, top 5 products
- **Settings** — language (Thai/English) and theme (Light/Dark/System) with live reload, shop info, currency, date format, receipt settings

#### Localization

- Flutter ARB localization (EN + TH)
- 80+ localized strings
- Payment method normalization with locale-neutral keys

#### App shell

- 5-tab `NavigationBar` (Sale · Products · History · Report · Settings)
- Reactive `MaterialApp` with live locale + theme switching
- Material 3 `ColorScheme`

---

[0.1.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.1.0...v0.1.0
