# Changelog

All notable changes to **Promsell POS Community Edition** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.4.0] - 2026-05-27

### BREAKING — Schema + Sale Integrity Overhaul

Complete database overhaul: integer auto-increment IDs → UUIDv4 text IDs across all entities, 6 new tables, atomic sale transactions with receipt numbers and inventory audit trail, void/refund flow, and manual stock adjustments. This is a **destructive migration** — existing app data will be dropped and recreated. Production migrations will use incremental `onUpgrade` steps.

### Added

- **6 new tables**: `categories`, `inventory_logs`, `app_settings`, `draft_carts`, `draft_cart_items`, `daily_closes`
- **`IdGenerator` utility** — UUIDv4 generation via `uuid` package
- **Sync-ready columns** on all tables: `version`, `deviceId`, `updatedAt`, `deletedAt`
- **Extended product fields**: `sku`, `barcode`, `cost`, `trackStock`
- **Extended sale fields**: `receiptNumber`, `status`, `subtotalAmount`, discount/VAT columns, `voidedAt`, `voidReason`
- **9 database indexes** for query performance
- **WAL journal mode** + `foreign_keys=ON` via `beforeOpen` hook
- **Batch seed** for default app settings on first run
- **`ReceiptNumberService`** — auto-generated receipt numbers (`YYMMDD-XX-NNNN`) with daily reset
- **`InventoryLogService`** — audit trail for all stock changes (SALE, VOID_REVERSAL, ADJUSTMENT_IN/OUT)
- **`SettingsLocalDatasource`** — Drift-backed typed key-value store (getString/Int/Bool/Double)
- **Atomic sale insertion** — receipt number + sale items + stock deduction + inventory log in single DB transaction
- **Void sale flow** — marks sale as VOIDED, restores stock, logs VOID_REVERSAL; confirmation dialog with reason
- **Manual stock adjustment** — `AdjustStock` use case + dialog for manual add/remove with audit reason
- **Inventory log viewer** — color-coded log entries, filterable by product
- **History UI** — VOIDED badge, strikethrough amount, receipt number in subtitle, void action button
- **Report UI** — net revenue (excludes voided), voided total summary card
- **L10n** — 18 new keys (EN + TH) for void, adjust, inventory log
- **`docs/ARCHITECTURE.md`** — deep technical architecture: C4 diagrams, data flows, transaction boundaries, DI graph, ADRs
- **`docs/DATABASE.md`** — full database handbook: ERD, schema, indexes, migration, query patterns
- **`docs/architecture/*.puml`** — PlantUML source files for C4 + sequence diagrams

### Changed

- **All entity IDs** (`Product.id`, `Sale.id`, `SaleItem.id/saleId/productId`) migrated from `int` → `String` (UUIDv4)
- **All repository/use-case/datasource/BLoC signatures** updated for String IDs
- **`ProductRepository.addProduct`** return type: `Future<int>` → `Future<String>`
- **`ProductLocalDatasource.insertProduct`** return type: `Future<int>` → `Future<void>` (ID generated upstream)
- **`ProductsCompanion`** field: `category` → `categoryId`
- **Schema version**: 1 → 2 (with drop+recreate migration for pre-release)
- **All 135 tests** migrated to use String UUID fixtures

### Removed

- Auto-increment integer ID generation (replaced by `IdGenerator.newId()`)
- `setup()` override in `AppDatabase` (replaced by `beforeOpen` in `MigrationStrategy`)

`flutter analyze` → **0 errors** · `flutter test` → **170/170 passing**

---

## [0.3.0] - 2026-05-26

### Added — UI milestone: product redesign, offline fonts & receipt export

A feature milestone that overhauls the product management UI, ships fully offline font bundling, PDF receipt export, a centralised SnackBar/toast system, and hardens the database upgrade path.

### Highlights

- **Product catalog:** Toggleable list/grid views, category filter chips, traffic-light `_StockBadge`, and `Image.network` avatar with fallback.
- **Product form:** Live image URL preview, `BASIC INFO` / `DETAILS` section grouping, and `imageUrl` wired to `ProductAdded`.
- **Offline fonts:** `NotoSansThai` bundled locally — no network call on first launch; `google_fonts` dependency removed.
- **PDF receipts:** 80 mm thermal receipt PDF with Print and Share actions in history page.
- **Feedback system:** `AppSnackBar` + `OverlayToast` replace all 9 inline `ScaffoldMessenger` calls; cart toast no longer blocks the checkout panel.
- **DB safety:** Step-based `onUpgrade` loop — an incomplete schema bump fails at the exact step, not silently at startup.

### Added

#### Product page redesign
- **List/Grid toggle** — `_ViewMode` enum; AppBar shows `view_list` / `grid_view` icon pair with active colour highlight.
- **Category filter chips** — horizontal scroll row below SearchBar; categories derived live from products; combined with search filter; hidden when no categories exist.
- **`_ProductTile` upgrade** — `_ProductAvatar` (`Image.network` + icon fallback), `_StockBadge` (green > 5 / orange 1–5 / red 0), inactive dim 40 % + strikethrough name.
- **`_ProductGridCard`** — 2-column `GridView.builder`, aspect ratio 0.76; tap = edit, long-press = context menu bottom sheet.
- **Product form: image URL + preview** — `imageUrl` field in header row with live `_FormAvatar` (80 px rounded); wired to `ProductAdded.imageUrl`.
- **Form section grouping** — `BASIC INFO` / `DETAILS` uppercase section labels.

#### Local font bundling (offline-first)
- Removed `google_fonts` dependency; bundled four `NotoSansThai` weights (400/500/600/700) under `assets/fonts/`.
- `AppTheme` rewritten to use `TextStyle(fontFamily: 'NotoSansThai', ...)` throughout.

#### PDF receipt export
- `ReceiptPdfService` — 80 mm thermal PDF with `printReceipt` / `shareReceipt` methods.
- Print / Share buttons added to each sale's `ExpansionTile` in history page.
- `printReceipt` / `shareReceipt` localisation keys added to `app_en.arb` and `app_th.arb`.
- Registered as `lazySingleton` in `injection_container.dart`.

#### AppSnackBar + OverlayToast — centralised feedback
- `AppSnackBar` — static `success` (2 s) / `error` (4 s) / `info` (1.2 s) helpers with `context.mounted` guard.
- Refactored all 9 inline `ScaffoldMessenger` callsites across 5 pages to use `AppSnackBar`.
- `OverlayToast` — fade-in pill toast via Flutter `Overlay`; `IgnorePointer` prevents checkout panel obstruction.

#### ReportCubit — state management consistency
- `ReportPage` migrated from `StatefulWidget` + `StreamSubscription` to `BlocProvider<ReportCubit>`.
- Added `report_cubit_test.dart` covering load success, failure, and `changeDateRange`.
- Registered as `factory` in `injection_container.dart`.

#### DB migration loop framework
- `onUpgrade` replaced with step-based `for` loop; each schema version bump requires an explicit `case N:` block.

### Fixed

- `RenderFlex` overflow (1 px) in sale product card: `padding: all(14)` → `symmetric(horizontal: 14, vertical: 10)`.
- `_StockBadge` dark-theme contrast: `shade300` tones + 22 % background alpha in dark mode (vs `shade700` + 12 % in light).
- Add product button visibility in dark theme: `IconButton.filled` background darkened via `Color.lerp(primary, black, 0.30)`, foreground forced white.

### Changed

- Add product AppBar button: `FilledButton.icon` → compact `IconButton.filled` (M3 pattern, tooltip retained).
- `README.md` screenshots section: replaced "Coming soon" placeholder with contributor call-to-action.
- `pubspec.yaml` version bumped to `0.3.0+1`.

### Verification

- `flutter test` passed: **135/135 tests**.
- `flutter analyze` completed with **0 issues**.

---

## [0.2.3] - 2026-05-26

### Fixed — RenderFlex overflow hotfix + system-wide bug fixes

Layout hotfix for three `RenderFlex` overflows in the sale page, combined with a targeted sweep on data integrity, stale cart state, and cashier UX.

### Highlights

- **Layout correctness:** Removed a phantom `Text` after `Expanded` that received 0dp and caused a 3px overflow on every launch.
- **Thai-locale resilience:** Increased card `mainAxisExtent` and zeroed implicit `Card` margin to fit Noto Sans Thai diacritic metrics.
- **DB safety:** `onUpgrade` now throws `UnimplementedError` — schema bumps without a migration fail loudly instead of silently wiping data.
- **Cart integrity:** Cart snapshots sync live from `ProductBloc`; hard-deleted products are removed automatically before checkout.
- **Checkout integrity:** Deleted product at confirm time throws a clear `StateError`; DB reads per item halved (2N → N).

### Fixed

#### Sale page

- Removed `BlocBuilder<SaleBloc>` returning `Text` after `Expanded` in `_SaleCatalog` — 0dp allocation caused a 3px bottom overflow.
- Replaced `Expanded(Text(name))` with `Text(name)` + `Spacer()` in `_ProductCard` to prevent 3–9px overflow from font-metric rounding at high DPI.
- Increased `mainAxisExtent` (`122→136` narrow, `132→148` wide) for Noto Sans Thai stacked-diacritic height.
- Added `margin: EdgeInsets.zero` to `_ProductCard`'s `Card` — default `EdgeInsets.all(4)` silently consumed 8dp per grid slot.

#### `AppEmptyState`

- Added `veryCompact` tier (< 120dp): icon `32→24dp`, padding `12→8dp`, style `titleMedium→bodyMedium`, `maxLines: 1`.

#### Database

- `onUpgrade` now throws `UnimplementedError` instead of a silent no-op, preventing data loss on future schema version bumps.

#### Cart state

- Added `SaleCartProductsRefreshed` event: `BlocListener<ProductBloc>` in `_SaleView` syncs cart item snapshots on every product update and auto-removes hard-deleted items.

#### Sale checkout

- Null product now throws `StateError("… no longer exists")` instead of silently bypassing stock validation.
- Products fetched once into a map and reused across validation and deduction loops — eliminates duplicate DB reads per item.

#### Payment sheet

- `_quickAmounts()` always generates three distinct chips; round totals (e.g. ฿100) no longer collapse to a single "Exact" chip.

### Added

- Regression test: `AppEmptyState fits in very compact height` (96dp bounded height, verifies no overflow).

### Changed

- Removed dead `onChanged: SaleNoteChanged(value)` from the payment sheet note field — note is read from the controller directly at confirm time.
- Cleaned up 5 lint warnings in test files: `no_leading_underscores_for_local_identifiers`, `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`.
- Updated documentation (`README.md`, `CODEBASE.md`) and bumped version to `0.2.3+1`.

### Verification

- `flutter test` passed: **131/131 tests**.
- `flutter analyze` completed with **0 issues**.

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

[0.4.0]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.3.1
[0.3.0]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.3.0
[0.2.3]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.2.3
[0.2.2]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.2.2
[0.2.1]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.2.1
[0.2.0]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.2.0
[0.1.0]: https://github.com/teeprakorn1/promsell-pos-ce/releases/tag/v0.1.0
