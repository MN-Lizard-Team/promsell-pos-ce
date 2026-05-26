# Changelog

All notable changes to **Promsell POS Community Edition** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.2.0] - 2026-05-26

### Added — UX/UI redesign foundation

- **Merchant Command Deck UI refresh** for the main app experience, focused on cashier speed, readability, and safer touch targets.
- **Shared UI primitives** under `lib/core/widgets/`:
  - `AdaptiveBreakpoints` for compact/medium/expanded layout decisions
  - `AppEmptyState` for consistent empty/error states with compact-height handling
  - `MoneyText` for consistent currency display
  - `SectionCard` for grouped settings and dashboard surfaces
- **Sale tab redesign** via `sale_page_redesign.dart`:
  - Search-first product catalog
  - Category chips
  - Responsive product grid
  - Compact mobile cart panel and expanded tablet cart pane
  - Touch-friendly quantity controls and checkout action
- **Payment sheet redesign** via `payment_sheet_redesign.dart`:
  - Clear total summary
  - Payment method segmented buttons
  - Quick cash amount chips
  - Change preview for cash payments
- **Products UX refresh**:
  - Stronger product cards with price, stock status, category, and tap-to-edit behavior
  - Responsive product form with compact single-column and wider two-column layouts
- **History, Report, and Settings refresh**:
  - Receipt-like expandable history cards
  - Report dashboard with empty/error states
  - Settings grouped into section cards with a clearer save action
- **Widget tests** for shared UI components.

### Fixed

- Prevented compact empty-state layouts from causing `RenderFlex` bottom overflow in constrained panels.

### Changed

- Updated localization strings for sale search, cart title, category filter, and quick cash actions.
- Updated theme tokens and Material 3 component defaults for the refreshed visual system.

---

## [0.1.0] - 2026-05-25

### Added — Project setup and initial public release

First public release of Promsell POS Community Edition. Complete offline-first mobile POS with full sale, inventory, history, reporting, and settings features.

#### Core architecture

- **Flutter 3.x scaffold** with Material 3 theming and `google_fonts`
- **Clean Architecture** per feature: `data/` · `domain/` · `presentation/`
- **State management** — `flutter_bloc` (BLoC + Cubit pattern)
- **Dependency injection** — `get_it` service locator (`lib/core/di/injection_container.dart`)
- **Routing** — `go_router` for declarative navigation
- **Database** — Drift SQLite ORM with code generation (`build_runner`)
- **Persistence** — `shared_preferences` for app settings

#### Features

- **Sale** (`lib/features/sale/`)
  - Product grid with category filter and search
  - Live cart with quantity adjustment and per-item subtotal
  - Multi-method payment sheet — cash, transfer, card
  - Change calculation for cash payments
  - Optional sale note
- **Products** (`lib/features/product/`)
  - Full CRUD with searchable list
  - Fields — name, price, stock, category, active/inactive
  - Inline validation on price and quantity
  - Delete confirmation dialog
- **History** (`lib/features/history/`)
  - Date-ranged sale history
  - Per-sale item breakdown and notes
  - Payment method and total display
- **Report** (`lib/features/report/`)
  - Total revenue summary card
  - Sales count for selected date range
  - Breakdown by payment method
  - Top 5 best-selling products
- **Settings** (`lib/features/settings/`)
  - Language picker (Thai / English) — **live reload**
  - Theme picker (Light / Dark / System) — **live reload**
  - Shop info — name, address, phone
  - Sales settings — currency symbol, date format
  - Receipt settings — receipt note, toggle show shop info

#### Internationalization (i18n)

- **Flutter ARB** localization (`lib/l10n/app_th.arb`, `lib/l10n/app_en.arb`)
- **80+ localized strings** covering all UI surfaces
- **`flutter gen-l10n`** integration with `l10n.yaml` config
- **`context.l10n` extension** (`lib/core/extensions/l10n_extension.dart`) for ergonomic access
- **Payment method normalization** (`lib/core/utils/payment_method_helper.dart`) — locale-neutral keys (`cash`, `transfer`, `card`) localized at display time

#### App shell

- **5-tab `NavigationBar`** — Sale · Products · History · Report · Settings
- **Reactive `MaterialApp`** wrapped in `BlocBuilder<SettingsCubit>` for live locale + theme switching
- **Material 3 ColorScheme** seeded from primary color

### Project metadata

- **App name** — Promsell
- **Team** — MN Lizard Team
- **License** — AGPL-3.0
- **Repository** — https://github.com/teeprakorn1/promsell-pos-ce

### Documentation

- `README.md` — overview, features, tech stack, quick start, project structure, roadmap, contributing, license
- `CHANGELOG.md` — this file
- `CODEBASE.md` — architecture diagram, layer structure, module reference, DB schema, DI, file dependency map
- `CONTRIBUTING.md` — fork/branch/PR workflow, commit conventions, code style, testing guide
- `CODE_OF_CONDUCT.md` — Contributor Covenant v2.1
- `SECURITY.md` — supported versions, vulnerability reporting, response timeline, security architecture
- `docs/USAGE.md` — detailed usage guide (setup, build, settings, i18n, Drift, architecture, troubleshooting)
- `docs/DEPLOY.md` — Android APK/AAB/iOS build, signing, version management, release checklist

---

[0.2.0]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.2.0
[0.1.0]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.1.0
