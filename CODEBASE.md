# CODEBASE.md — Promsell POS CE v0.9.3

## System overview

Offline-first mobile POS system — Flutter, Drift SQLite, BLoC, SettingsLocalDatasource, Material 3.

For version history and feature details, see [CHANGELOG.md](CHANGELOG.md).
For deep technical architecture (C4, data flows, ADRs), see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — index to [`docs/architecture/c4-diagrams.md`](docs/architecture/c4-diagrams.md), [`docs/architecture/technical-deep-dive.md`](docs/architecture/technical-deep-dive.md), and [`docs/architecture/adr/index.md`](docs/architecture/adr/index.md).

---

## Architecture

```
┌──────────────────────────────────────────────────────┐
│   main.dart — App entry point (shared)               │
│   main_dev.dart / main_prod.dart — Flavor entry pts  │
│   MaterialApp wrapped in BlocBuilder<SettingsCubit>  │
│   5-tab NavigationBar shell with lazy-loaded tabs    │
└────────────────────────┬─────────────────────────────┘
                         │
┌────────────────────────▼──────────────────────────────────────────────────────────────┐
│   lib/features/ — 13 feature modules                                                  │
│   sale/       — Cart, checkout, drafts, discounts, restaurant order type/channel,     │
│               table selector, service charge, product options, adaptive tablet sale   │
│   product/    — CRUD inventory, images, barcode/SKU scan + generation, modifiers      │
│   customer/   — Customer CRUD, search, spend/visit statistics                         │
│   promotion/  — Percent/fixed promotions, date windows, active filtering              │
│   home/       — Dashboard, statistics, menu grid, promotion banner                    │
│   report/     — Revenue/profit/margin analytics, history tab, PDF/CSV export          │
│   settings/   — Locale, theme, shop/business settings, Store PIN, backup              │
│   history/    — Sale history search and void presentation                             │
│   inventory/  — Stock adjustments and inventory audit log                             │
│   daily_close/ — Expected/count cash, reconciliation, close-day lock                  │
│   receipt/    — Sales receipt document, preview, PDF/share                            │
│   restaurant_table/ — Table/floor status and dine-in support                          │
│   onboarding/ — First-launch setup and Store PIN choice                               │
└────────────────────────┬──────────────────────────────────────────────────────────────┘
                         │
┌────────────────────────▼──────────────────────────────────────────────────────┐
│   lib/core/ — Cross-cutting infrastructure                                    │
│   database/   — Drift schema v32, SQLCipher opener, satang converters         │
│   di/         — injectable + get_it DI                                        │
│   extensions/ — context.l10n helper                                           │
│   image/      — Unified image system (UnifiedImageWidget,                     │
│                 ImageSkeleton, ImageErrorPlaceholder, ImageCacheService)      │
│   services/   — AppLock lifecycle, CrashLogService, secure-screen helpers     │
│   utils/      — Money, IdGenerator, payment methods, EAN-13, date formatting  │
│   widgets/    — shared UI primitives                                          │
└───────────────────────┬───────────────────────────────────────────────────────┘
                        │
┌───────────────────────▼──────────────────────────────────┐
│   lib/l10n/ — Localization                               │
│   app_th.arb  — Thai (template)                          │
│   app_en.arb  — English                                  │
│   app_localizations.dart — GENERATED                     │
└──────────────────────────────────────────────────────────┘
```

---

## Layer structure (per feature)

Each feature under `lib/features/<name>/` follows Clean Architecture:

```
features/<name>/
├── data/
│   ├── datasources/          # Drift DAO wrappers
│   └── repositories/         # Repository implementations
├── domain/
│   ├── entities/             # Pure Dart domain models and value objects
│   ├── repositories/         # Abstract interfaces / ports
│   └── usecases/             # Business logic
└── presentation/
    ├── bloc/ or cubit/       # State management
    ├── pages/                # Page-level UI
    └── widgets/              # Subfoldered by domain (ADR-024)
        ├── <domain>/         #   MANDATORY — e.g. cart/, checkout/, forms/
        │   ├── <widget>/     #   OPTIONAL — extracted subcomponents for large widgets (>300 lines)
        │   └── <widget>.dart #   Main widget, composes subcomponents
        ├── shared/           #   OPTIONAL — cross-domain reuse (2+ importers)
        └── deprecated/       #   OPTIONAL — backward-compat aliases only
```

**Dependency rule:** `presentation → domain ← data`. The import fence (`dart run tool/check_domain_fence.dart`) is enforced in CI for `lib/**/domain/**`; the current allowlist is empty. Keep domain code pure Dart and use domain ports plus presentation mappers when crossing boundaries.

> **Widget folder convention (ADR-024):** Every widget file MUST be in a subfolder — no flat files in `widgets/` root. Domain subfolders are mandatory; `shared/` and `deprecated/` are created only when needed.

### Data flow (per feature)

```
┌──────────────┐    events   ┌──────────────┐    calls    ┌──────────────┐
│ Presentation │ ──────────▶ │  BLoC/Cubit  │ ──────────▶ │  Use Cases   │
│  (Widgets)   │             │  (State)     │             │  (Domain)    │
└──────────────┘ ◀────────── └──────────────┘ ◀────────── └──────────────┘
                    state         │ result                      │ interface
                                  ▼                             ▼
                            ┌──────────────┐               ┌──────────────┐
                            │ Repositories │ ────────────▶ │ Datasources  │
                            │  (Domain)    │               │  (Data)      │
                            └──────────────┘               └──────┬───────┘
                                                                  │ Drift queries
                                                                  ▼
                                                            ┌───────────────┐
                                                            │  AppDatabase  │
                                                            │  (SQLite WAL) │
                                                            └───────────────┘
```

### Database and money boundary

- `AppDatabase` is schema **v32**. Production storage uses SQLCipher; tests use in-memory Drift.
- Domain `Money` is integer satang. The 32 nullable `*_satang` columns use Drift `NullableMoneySatangConverter`.
- Writers dual-write exact satang plus legacy REAL baht for rollback compatibility. Readers prefer satang and fall back to REAL for pre-v32 rows.
- Percentage rates and percentage-valued discounts remain REAL; conditional `AMOUNT` values also receive satang storage.
- Migration code lives in `lib/core/database/app_database_migrations.dart` (a `part of app_database.dart` file exposing an `extension on AppDatabase`); update the schema version and add a migration test for every schema change.

### State management overview

```
┌─────────── BLoC (event-driven) ───────────┐  ┌─── Cubit (method-driven) ────┐
│                                           │  │                              │
│  CartBloc    DraftBloc   CheckoutBloc     │  │  SettingsCubit               │
│  ProductBloc CategoryBloc HistoryBloc     │  │  ReportCubit                 │
│  CustomerBloc PromotionBloc TableBloc     │  │  InventoryLogCubit           │
│                                           │  │  ProductFormCubit            │
│  Events → States (Equatable)              │  │  Methods → States            │
│                                           │  │  @LazySingleton              │
└───────────────────────────────────────────┘  └──────────────────────────────┘
```

### Navigation structure

```
┌─────────────────── MaterialApp ──────────────────────┐
│  BlocBuilder<SettingsCubit> (locale, theme, mode)    │
│                                                      │
│  ┌─── NavigationBar (5 tabs, lazy-loaded) ───────┐   │
│  │                                               │   │
│  │  Tab 1    Tab 2    Tab 3    Tab 4    Tab 5    │   │
│  │  Home    Product  Sale     Report  Settings   │   │
│  │  │       │        │        │        │         │   │
│  │  ▼       ▼        ▼        ▼        ▼         │   │
│  │  Home   Product   Sale    Report  Settings    │   │
│  │  Page   List Page  Page    Page    Root Page  │   │
│  │         │                                     │   │
│  │         ├──▶ Product Preview Page             │   │
│  │         │    (via product_navigation.dart)    │   │
│  │         ├──▶ Product Form Page (Add + Edit)   │   │
│  │         │    (via product_navigation.dart)    │   │
│  │         └──▶ Category Management Page         │   │
│  │                                               │   │
│  │  Sale Page → Checkout Page → Receipt Dialog   │   │
│  │            ↕ Cart Review Page                 │   │
│  │            ↕ PromptPay Payment Page           │   │
│  │            ↕ Table Selector (restaurant)      │   │
│  │                                               │   │
│  │  Home Page → Customer/Promotion Pages         │   │
│  │            ↕ Menu Grid (6 buttons)            │   │
│  │                                               │   │
│  │  Settings Root → 16 sub-pages (2-level)       │   │
│  └───────────────────────────────────────────────┘   │
│                                                      │
│  Overlay: Onboarding (4-step, first-launch)          │
└──────────────────────────────────────────────────────┘
```

---

## UI and design system notes

- The current UI refresh follows a **Merchant Command Deck** direction: cashier-first, fast scanning, strong money hierarchy, and large touch targets.
- **Theme system** lives in `lib/core/theme/` — `AppColors` (static palette), `AppTheme` (light/dark `ThemeData` with Material 3), and `SettingsThemeExtension` (settings-specific surface/accent tokens). All hardcoded `Color(0xFF...)` outside this folder is forbidden.
- Shared visual behavior should live in `lib/core/theme/` and `lib/core/widgets/` before being duplicated in feature pages.
- Sale layouts are adaptive:
  - **Phone / narrow**: catalog + sticky `CartBottomBar` (count badge + **payable** total + open review / pay). Tap opens full-page cart via `openCartReviewPage` → `CartReviewPage` (not a bottom sheet).
  - **Tablet / wide** (≥ `tabletSplitBreakpoint`): `SaleDualPane` — catalog + always-on `DockedCartPanel` (line parity with review + shared `CartReviewFooter`).
  - **Ultra compact**: `CompactCartFab` over catalog (same payable SSOT).
  - Amount due / pay labels use `CartState.payableTotals(settings)` only — not legacy `grandTotal`.
  - `SaleDashboardHeader` shows shop name + today's revenue/sales count/cart total in a horizontal scrollable row.
  - `SaleFilterBar` provides 3 dropdown filters (Category/Sort/Stock) replacing the old category chips.
- User-facing strings must remain localized through ARB files and accessed with `context.l10n`.
- Empty/error states should prefer `AppEmptyState`; money values should prefer `MoneyText`.
- Compact constrained areas should avoid fixed-height `Column` content that can trigger `RenderFlex` overflow.
- **Product tiles** use `BlocSelector<CategoryBloc>` (not `BlocBuilder`) to rebuild only when the relevant category changes; `context.select` is used for `SettingsCubit` fields (`currency`, `lowStockThreshold`) — not `context.watch`.
- **Product cards** (`ProductCardShell`) use flat `Container` + `BoxDecoration` (no `Card` elevation) for clean `Dismissible` integration in both list and grid modes.
- **Navigation helpers** (`showProductEditPage`, `showProductPreviewPage`, `confirmDeleteProduct`, `DeleteBackground`) are centralized in `product_navigation.dart` — no duplicate `_showEdit`/`_showPreview` in tiles or pages.
- **Snackbars** should use `AppSnackBar.info/success/error` — not raw `ScaffoldMessenger.showSnackBar`.

---

## Reference documents

| Document | Content |
|----------|---------|
| [`docs/codebase/core-modules.md`](docs/codebase/core-modules.md) | Core modules table (60+ entries) + Feature modules table (13 features under `lib/features/`) |
| [`docs/codebase/conventions.md`](docs/codebase/conventions.md) | State management, Settings persistence (14 group entities), Localization, DI, Code generation |
| [`docs/codebase/file-dependency-map.md`](docs/codebase/file-dependency-map.md) | If-you-change-X-update-Y rules for all entities, BLoCs, datasources |
| [`docs/codebase/testing.md`](docs/codebase/testing.md) | Test directory structure, test layers, and host/device E2E workflow |
| [`docs/DATABASE.md`](docs/DATABASE.md) | Schema **v32** overview + ERD + satang dual-write boundary + migration/ops references |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Architecture index → C4 diagrams, technical deep-dive, ADRs (001-028), and DI graph |

---

<sub>Promsell POS CE · v0.9.3 · Codebase Reference</sub>