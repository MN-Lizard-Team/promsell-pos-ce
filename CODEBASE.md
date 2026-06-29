# CODEBASE.md — Promsell POS CE v0.8.8

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
                         ▼
┌───────────────────────────────────────────────────────────────────────────────────────┐
│   lib/features/ — Feature modules                                                     │
│   sale/       — Cart, checkout, draft, discount                                       │
│   product/    — CRUD inventory, ProductBloc, image service, barcode scan + generation │
│               + BarcodeImageService (RenderRepaintBoundary off-screen render)         │
│               + ProductFormCubit (typed draft state, Hybrid Collapsible form)         │
│               + product_navigation.dart (shared show/edit/preview/delete helpers)     │
│               + StatsDashboard (hero gradient card: total products + inventory value) │
│   history/    — Sale history viewer                                                   │
│   report/     — Analytics dashboard                                                   │
│   settings/   — Locale, theme, shop info                                              │
└────────────────────────┬──────────────────────────────────────────────────────────────┘
                         ▼
┌───────────────────────────────────────────────────────────────────────────────┐
│   lib/core/ — Cross-cutting infrastructure                                    │
│   database/   — Drift schema, tables, DAOs                                    │
│   di/         — injectable + get_it DI                                        │
│   extensions/ — context.l10n helper                                           │
│   image/      — Unified image system (UnifiedImageWidget,                     │
│                 ImageSkeleton, ImageErrorPlaceholder, ImageCacheService)      │
│   services/  — CrashLogService (PII sanitization, export/clear)               │
│   utils/      — IdGenerator, payment_method, Ean13Generator (@injectable)     │
│   widgets/    — shared UI primitives                                          │
└───────────────────────┬───────────────────────────────────────────────────────┘
                        ▼
┌──────────────────────────────────────────────────────────┐
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
│   ├── entities/             # Pure Dart models (no Flutter imports)
│   ├── repositories/         # Abstract interfaces
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

**Dependency rule:** `presentation → domain ← data`. Domain has zero external dependencies.

> **Widget folder convention (ADR-024):** Every widget file MUST be in a subfolder — no flat files in `widgets/` root. Domain subfolders are mandatory; `shared/` and `deprecated/` are created only when needed.

### Data flow (per feature)

```
┌──────────────┐    events   ┌──────────────┐    calls     ┌──────────────┐
│ Presentation │ ──────────▶ │  BLoC/Cubit  │ ──────────▶ │  Use Cases   │
│  (Widgets)   │             │  (State)     │              │  (Domain)    │
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

### State management overview

```
┌─────────── BLoC (event-driven) ───────────┐  ┌─── Cubit (method-driven) ────┐
│                                           │  │                              │
│  CartBloc    DraftBloc   CheckoutBloc     │  │  SettingsCubit               │
│  ProductBloc CategoryBloc HistoryBloc     │  │  ReportCubit                 │
│                                           │  │  InventoryLogCubit           │
│  Events → States (Equatable)              │  │  ProductFormCubit            │
│  @LazySingleton (shared instances)        │  │  Methods → States            │
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
│  │  Sale    Product  History  Report  Settings   │   │
│  │  │       │        │        │        │         │   │
│  │  ▼       ▼        ▼        ▼        ▼         │   │
│  │  Sale   Product   History  Report  Settings   │   │
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
│  │                                               │   │
│  │  Settings Root → 13 sub-pages (2-level)       │   │
│  └───────────────────────────────────────────────┘   │
│                                                      │
│  Overlay: Onboarding (6-step, first-launch)          │
└──────────────────────────────────────────────────────┘
```

---

## UI and design system notes

- The current UI refresh follows a **Merchant Command Deck** direction: cashier-first, fast scanning, strong money hierarchy, and large touch targets.
- **Theme system** lives in `lib/core/theme/` — `AppColors` (static palette), `AppTheme` (light/dark `ThemeData` with Material 3), and `SettingsThemeExtension` (settings-specific surface/accent tokens). All hardcoded `Color(0xFF...)` outside this folder is forbidden.
- Shared visual behavior should live in `lib/core/theme/` and `lib/core/widgets/` before being duplicated in feature pages.
- Sale layouts are adaptive:
  - Compact screens use a product catalog with a delivery-style `CartBottomBar` (item count badge + total + checkout; tap/pull-up to open `CartBottomSheet`).
  - Expanded screens keep the cart pane visible beside the product grid via `CartContent` (expanded mode with `ReorderableListView` + `Dismissible`).
  - **Compact Cart Mode** (toggle in Settings → General, default ON) shows `CartBottomBar`; OFF shows classic `CartPanel` with vertical drag handle.
  - `SaleDashboardHeader` shows shop name + today's revenue/sales count/cart total in a horizontal scrollable row.
  - `SaleFilterBar` provides 3 dropdown filters (Category/Sort/Stock) replacing the old category chips.
- User-facing strings must remain localized through ARB files and accessed with `context.l10n`.
- Empty/error states should prefer `AppEmptyState`; money values should prefer `MoneyText`.
- Compact constrained areas should avoid fixed-height `Column` content that can trigger `RenderFlex` overflow.
- **Product tiles** use `BlocSelector<CategoryBloc>` (not `BlocBuilder`) to rebuild only when the relevant category changes.
- **Product cards** (`ProductCardShell`) use flat `Container` + `BoxDecoration` (no `Card` elevation) for clean `Dismissible` integration in both list and grid modes.
- **Navigation helpers** (`showProductEditPage`, `showProductPreviewPage`, `confirmDeleteProduct`, `DeleteBackground`) are centralized in `product_navigation.dart` — no duplicate `_showEdit`/`_showPreview` in tiles or pages.
- **Snackbars** should use `AppSnackBar.info/success/error` — not raw `ScaffoldMessenger.showSnackBar`.

---

## Reference documents

| Document | Content |
|----------|---------|
| [`docs/codebase/core-modules.md`](docs/codebase/core-modules.md) | Core modules table (52 entries) + Feature modules table (11 features) |
| [`docs/codebase/conventions.md`](docs/codebase/conventions.md) | State management, Settings persistence (13 group entities), Localization, DI, Code generation |
| [`docs/codebase/file-dependency-map.md`](docs/codebase/file-dependency-map.md) | If-you-change-X-update-Y rules for all entities, BLoCs, datasources |
| [`docs/codebase/testing.md`](docs/codebase/testing.md) | Test directory structure (1302 tests, 8 layers) + test layer techniques |
| [`docs/DATABASE.md`](docs/DATABASE.md) | Schema v19 overview + ERD + sync columns → links to schema-reference, query-patterns, migration-and-ops |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Architecture index → C4 diagrams, technical deep-dive, ADRs (001-024) + barcode DI graph |

---

<sub>Promsell POS CE · v0.8.8 · Codebase Reference</sub>