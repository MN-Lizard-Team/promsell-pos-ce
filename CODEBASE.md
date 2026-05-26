# CODEBASE.md — Promsell POS CE v0.3.0

## System overview

Offline-first mobile POS system — Flutter, Drift SQLite, BLoC, SharedPreferences, Material 3.

For version history and feature details, see [CHANGELOG.md](CHANGELOG.md).

---

## Architecture

```
┌──────────────────────────────────────────────────┐
│   main.dart — App entry point                    │
│   MaterialApp wrapped in BlocBuilder<SettingsCubit>│
│   5-tab NavigationBar shell with IndexedStack     │
└────────────────────┬─────────────────────────────┘
                     ▼
┌──────────────────────────────────────────────────┐
│   lib/features/ — Feature modules               │
│   sale/       — Cart, checkout, PaymentSheet     │
│   product/    — CRUD inventory, ProductBloc      │
│   history/    — Sale history viewer              │
│   report/     — Analytics dashboard             │
│   settings/   — Locale, theme, shop info        │
└────────────────────┬─────────────────────────────┘
                     ▼
┌──────────────────────────────────────────────────┐
│   lib/core/ — Cross-cutting infrastructure      │
│   database/   — Drift schema, tables, DAOs       │
│   di/         — get_it service locator           │
│   extensions/ — context.l10n helper             │
│   services/   — ReceiptPdfService (PDF/print)   │
│   utils/      — payment_method_helper            │
│   widgets/    — shared UI primitives             │
└────────────────────┬─────────────────────────────┘
                     ▼
┌──────────────────────────────────────────────────┐
│   lib/l10n/ — Localization                       │
│   app_th.arb  — Thai (template)                  │
│   app_en.arb  — English                          │
│   app_localizations.dart — GENERATED             │
└──────────────────────────────────────────────────┘
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
    └── pages/                # Widgets
```

**Dependency rule:** `presentation → domain ← data`. Domain has zero external dependencies.

---

## Core modules

| Module | Path | Responsibility |
|--------|------|----------------|
| `AppDatabase` | `lib/core/database/app_database.dart` | Drift database class, schema version, step-loop migration framework |
| `injection_container.dart` | `lib/core/di/` | get_it registrations for all repositories, BLoCs, cubits, services |
| `l10n_extension.dart` | `lib/core/extensions/` | `context.l10n` shorthand for `AppLocalizations.of(context)!` |
| `ReceiptPdfService` | `lib/core/services/` | Build 80 mm thermal receipt PDF; expose `printReceipt` and `shareReceipt` |
| `AppSnackBar` | `lib/core/widgets/` | Static helpers `success` / `error` / `info` — consistent snackbar styling across all features |
| `OverlayToast` | `lib/core/widgets/` | Fade-in pill toast at top center via `Overlay`; non-blocking, no dependency, replaces snackbar in active cashier flow |
| `payment_method_helper.dart` | `lib/core/utils/` | Normalize raw DB values (`เงินสด` → `cash`) and localize for display |
| `AdaptiveBreakpoints` | `lib/core/widgets/` | Compact / medium / expanded layout helpers |
| `AppEmptyState` | `lib/core/widgets/` | Consistent empty/error states with compact-height support |
| `MoneyText` | `lib/core/widgets/` | Currency text with fixed decimal formatting |
| `SectionCard` | `lib/core/widgets/` | Shared grouped card surface for settings and dashboards |

---

## Feature modules

| Feature | BLoC / Cubit | Key files |
|---------|-------------|-----------|
| Sale | `SaleBloc` | `sale_page_redesign.dart`, `payment_sheet_redesign.dart` |
| Product | `ProductBloc` | `product_list_page.dart`, `product_form_page.dart` |
| History | `HistoryBloc` | `history_page.dart` (+ print/share receipt via `ReceiptPdfService`) |
| Report | `ReportCubit` | `report_page.dart`, `report_cubit.dart`, `report_state.dart` |
| Settings | `SettingsCubit` | `settings_page.dart`, `settings_cubit.dart`, `settings_state.dart` |

---

## UI and design system notes

- The current UI refresh follows a **Merchant Command Deck** direction: cashier-first, fast scanning, strong money hierarchy, and large touch targets.
- Shared visual behavior should live in `lib/core/theme/` and `lib/core/widgets/` before being duplicated in feature pages.
- Sale layouts are adaptive:
  - Compact screens use a product catalog with a bottom cart command panel.
  - Expanded screens keep the cart pane visible beside the product grid.
- User-facing strings must remain localized through ARB files and accessed with `context.l10n`.
- Empty/error states should prefer `AppEmptyState`; money values should prefer `MoneyText`.
- Compact constrained areas should avoid fixed-height `Column` content that can trigger `RenderFlex` overflow.

---

## Database schema

Managed by [Drift](https://drift.simonbinder.eu/) — type-safe SQLite ORM.

| Table | Fields |
|-------|--------|
| `Products` | id, name, price, stock, category, imageUrl, isActive, createdAt, updatedAt |
| `Sales` | id, totalAmount, paymentMethod, cashReceived, note, createdAt |
| `SaleItems` | id, saleId, productId, productName, price, quantity, subtotal |

Generated code: `lib/core/database/app_database.g.dart` — **do not edit manually**.

To regenerate after schema changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## State management patterns

| Pattern | When used |
|---------|-----------|
| **BLoC** (event → state) | Complex flows with multiple event types — sale, product, history |
| **Cubit** (method → state) | Simpler state without event classes — settings, report |

All state classes extend `Equatable` for efficient rebuilds.

---

## Settings persistence

`SettingsRepositoryImpl` reads and writes `AppSettings` via `SharedPreferences`.

| Key | Type | Default |
|-----|------|---------|
| `locale` | String | `th` |
| `themeMode` | String | `system` |
| `shopName` | String | `''` |
| `shopAddress` | String | `''` |
| `shopPhone` | String | `''` |
| `currency` | String | `฿` |
| `dateFormat` | String | `dd/MM/yyyy` |
| `receiptNote` | String | `''` |
| `showShopInfo` | bool | `true` |

---

## Localization system

- **Template:** `lib/l10n/app_th.arb` (Thai — source of truth)
- **Translation:** `lib/l10n/app_en.arb` (English)
- **Config:** `l10n.yaml` (`template-arb-file: app_th.arb`)
- **Generated:** `lib/l10n/app_localizations.dart` — do not edit
- **Access:** `context.l10n.keyName` via `l10n_extension.dart`

To regenerate after adding keys:

```bash
flutter gen-l10n
```

---

## Dependency injection

`lib/core/di/injection_container.dart` — all registrations via `get_it`.

Registration order matters: database → DAOs → repositories → use cases → BLoCs/cubits.

Access anywhere via `sl<T>()`.

---

## Code generation

Two generators must be run after changes:

| Generator | Trigger | Command |
|-----------|---------|---------|
| Drift | Schema change | `dart run build_runner build` |
| Flutter l10n | New ARB key | `flutter gen-l10n` |

---

## File dependency map

| If you change… | Also update… |
|----------------|-------------|
| Drift table definition | Run `build_runner build` |
| `app_th.arb` | `app_en.arb` (add matching key) + `flutter gen-l10n` |
| `AppSettings` entity | `SettingsRepositoryImpl`, `SettingsCubit`, `SettingsPage` |
| `injection_container.dart` | Ensure load order is correct |
| Payment method values in DB | `payment_method_helper.dart` normalization map |
| Shared UI behavior | `lib/core/widgets/` tests under `test/core/widgets/` |
| Feature UI strings | Both ARB files + generated localization files |
| Main Sale UI entry | `main.dart` import + Sale page widget tests/manual smoke test |
| BLoC / Cubit class | Update mock in `test/helpers/mocks.dart` |
| Domain entity | Update test fixtures in corresponding `_test.dart` files |

---

## Test infrastructure

135 automated tests across 7 layers. Run with `flutter test`.

### Test directory structure

```
test/
├── helpers/
│   ├── mocks.dart              # All mock classes (repos, datasources, use cases, BLoCs/Cubits)
│   ├── pump_app.dart           # pumpApp extension for widget tests
│   └── fake_database.dart      # In-memory Drift DB factory
├── core/
│   └── utils/                  # Core utility tests
├── features/
│   ├── sale/                   # Use case, BLoC, repo, datasource, widget tests
│   ├── product/                # Use case, BLoC, repo, datasource, widget tests
│   ├── history/                # Use case, BLoC, repo tests
│   ├── report/                 # ReportCubit tests
│   └── settings/               # Cubit, repo, widget tests
├── integration/
│   └── checkout_flow_test.dart  # End-to-end data layer checkout
└── l10n/
    └── l10n_parity_test.dart   # EN/TH key parity and non-empty validation
```

### Test layers

| Layer | Technique | Dependencies |
|-------|-----------|-------------|
| Domain | Unit test | None (pure Dart) |
| BLoC / Cubit | `bloc_test` | Mocked use cases |
| Repository | Unit test with `mocktail` | Mocked datasources |
| Datasource | In-memory Drift DB | `sqlite3_flutter_libs` (FFI) |
| Widget | `pumpApp` + `MockBloc` | Mocked BLoC states |
| Integration | In-memory DB end-to-end | Real repos + datasources |
| L10n | Direct class instantiation | None |
