# Changelog

All notable changes to **Promsell POS Community Edition** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.2.2] - 2026-05-26

### Fixed — Stability, data integrity, and UX hardening

A stability and UX hardening release for the offline POS workflow: safer sales writes, clearer cashier feedback, tighter BLoC behavior, leaner dependencies, and better compact-screen usability.

### Highlights

- **Data safety:** Stock is validated before sale-item insertion, while checkout still remains transaction-protected.
- **Cashier UX:** Cart quantity limits, product quantity badges, cleaner add-to-cart feedback, payment references, and double-submit protection.
- **State reliability:** Product, sale, history, and settings flows now recover and refresh more predictably.
- **UI consistency:** Theme-aware danger colors, safer dialog contexts, clearer empty states, retry actions, and responsive settings controls.
- **Maintenance:** Removed unused dependencies and dead DI registrations; documented intentional singleton usage.

### Fixed

#### Sale and checkout

- Prevented partial sale-item work by validating all item stock before insert/deduct operations.
- Added stock-limit protection to cart quantity controls and kept database validation as the final authority.
- Prevented duplicate payment submissions from rapid double taps.
- Added optional transfer/card payment reference support, stored through the sale note.
- Made payment sheet dismissal safe when the sheet context is already unmounted.
- Reset sale state correctly after a completed sale when starting a new cart.

#### Products and inventory

- Reworked `ProductBloc` stream handling to avoid blocking refresh flows.
- Added reliable product save status handling so forms close only after confirmed saves.
- Reset stale product save status on product stream updates.
- Added product-card cart quantity badges in the sale catalog.
- Reduced noisy add-to-cart SnackBars for repeated taps.
- Made product delete dialogs use a captured BLoC and dialog-local navigation context.
- Improved stock-zero warning and product form feedback.

#### History and reports

- Limited initial history loading to a default 30-day range.
- Made history date picker reopen with the current selected range.
- Replaced fake refresh delays with state-based refresh completion.
- Fixed report date ranges that could go stale overnight.
- Moved report date range display out of the AppBar into a compact filter chip.
- Added pull-to-refresh support to the report dashboard.

#### Settings and localization

- Settings load failures now fall back to usable default settings instead of leaving the app in a failure state.
- Removed duplicate settings save notifications for live locale/theme changes.
- Added dirty-state awareness for manually saved text settings.
- Improved responsive settings dropdown layout on compact screens.
- Added EN/TH strings for retry actions, no-match states, stock limits, and payment references.

#### UI, accessibility, and resilience

- Replaced hardcoded destructive colors with `colorScheme.error`.
- Added retry actions to shared empty/error states.
- Improved dialog context safety for cart clearing and product deletion.
- Clarified intentional `SaleItems.productId` behavior so sale history survives product deletion.
- Documented the intentional singleton lifecycle for `ProductBloc`.

### Removed

- Removed unused direct dependencies: `go_router`, `uuid`, `permission_handler`, `image_picker`, `cached_network_image`, `qr_flutter`, and `path`.
- Removed unused DI registrations for `GetReport` and `GetSaleHistory` while keeping their source/test coverage for future use.
- Deleted the empty `date_formatter.dart` file.

### Changed

- Updated generated localization files after adding new EN/TH keys.
- Updated SettingsCubit tests to match the load-failure fallback behavior.
- Updated documentation and audit notes for the completed stability and UX hardening work.
- Bumped version to `0.2.2+1`.

### Verification

- `flutter gen-l10n` completed successfully.
- `flutter test` passed: **130/130 tests**.
- `flutter analyze` completed with **0 errors** and only pre-existing info-level hints in tests.

---

## [0.2.1] - 2026-05-26

### Added — Comprehensive test suite & UI/UX improvements

- **130 automated tests** covering 7 layers of the application:
  - **Domain** — entity equality, use case delegation for all features
  - **BLoC / Cubit** — event-to-state transitions for `SaleBloc`, `ProductBloc`, `HistoryBloc`, `SettingsCubit`
  - **Repository** — `SaleRepositoryImpl`, `ProductRepositoryImpl`, `HistoryRepositoryImpl`, `SettingsRepositoryImpl`
  - **Datasource** — `ProductLocalDatasourceImpl`, `SaleLocalDatasourceImpl` with in-memory SQLite
  - **Widget** — `ProductListPage`, `ProductFormPage`, `PaymentSheet`, `SettingsPage` with mocked BLoC states
  - **Integration** — end-to-end checkout flow (add → sale → stock deduction → history)
  - **L10n parity** — EN/TH key completeness, parameterized messages, locale-specific values
- **Test helpers** (`test/helpers/`):
  - `mocks.dart` — shared mock classes using `mocktail` + `bloc_test`
  - `pump_app.dart` — `pumpApp` extension with `MultiBlocProvider` and full localization
  - `fake_database.dart` — in-memory Drift database factory
- **4 new localization keys** for both EN and TH:
  - `productAddedToCart` — cart feedback message
  - `productSaved` — form success message
  - `insufficientCash` — payment validation hint
  - `stockZeroWarning` — product form warning
- **4 regression tests** for critical UI bug fixes (UI-BUG-1, UI-BUG-8, UI-BUG-11)

### Fixed

- **Search state bleed across tabs** — `ProductBloc.searchQuery` resets on navigation; `BlocListener` syncs text controllers automatically
- **Cart quantity overflow** — replaced fixed `SizedBox(width: 28)` with `ConstrainedBox(minWidth: 32)` to support 3+ digit quantities
- **Cart subtotal clipping** — replaced fixed `SizedBox(width: 82)` with `ConstrainedBox(minWidth: 82)` for large amounts
- **No feedback on add-to-cart** — floating `SnackBar` now confirms product addition
- **No feedback on product save** — success `SnackBar` shown after form submission
- **Report AppBar overflow** — date range text wrapped in `Flexible` with `TextOverflow.ellipsis`
- **Redundant tap hint** — "Tap product to add" hidden when cart already has items
- **Unclear disabled button** — payment confirm shows "Insufficient cash" explanation when amount is below total
- **Missing transaction reference** — sale ID (`#N`) now displayed in History list subtitle
- **No refresh mechanism** — pull-to-refresh added to History and Product list pages
- **Silent stock=0 state** — product form shows warning when stock is zero ("won't appear in sale")

### Changed

- Added `sqlite3_flutter_libs: ^0.5.28` to `dev_dependencies` for FFI-based in-memory database testing.

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

[0.2.2]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.2.2
[0.2.1]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.2.1
[0.2.0]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.2.0
[0.1.0]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.1.0
