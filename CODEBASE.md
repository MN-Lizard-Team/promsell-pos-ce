# CODEBASE.md — Promsell POS CE v0.5.3

## System overview

Offline-first mobile POS system — Flutter, Drift SQLite, BLoC, SettingsLocalDatasource, Material 3.

For version history and feature details, see [CHANGELOG.md](CHANGELOG.md).
For deep technical architecture (C4, data flows, ADRs), see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

## Architecture

```
┌──────────────────────────────────────────────────┐
│   main.dart — App entry point                    │
│   MaterialApp wrapped in BlocBuilder<SettingsCubit>│
│   5-tab NavigationBar shell with lazy-loaded tabs │
└────────────────────┬─────────────────────────────┘
                     ▼
┌──────────────────────────────────────────────────┐
│   lib/features/ — Feature modules               │
│   sale/       — Cart, checkout, draft, discount  │
│   product/    — CRUD inventory, ProductBloc      │
│   history/    — Sale history viewer              │
│   report/     — Analytics dashboard             │
│   settings/   — Locale, theme, shop info        │
└────────────────────┬─────────────────────────────┘
                     ▼
┌──────────────────────────────────────────────────┐
│   lib/core/ — Cross-cutting infrastructure      │
│   database/   — Drift schema, tables, DAOs       │
│   di/         — injectable + get_it DI             │
│   extensions/ — context.l10n helper             │
│   services/   — ReceiptPdfService (PDF/print)   │
│   utils/      — IdGenerator, payment_method      │
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
    ├── pages/                # Page-level UI
    └── widgets/              # Extracted reusable widgets
```

**Dependency rule:** `presentation → domain ← data`. Domain has zero external dependencies.

---

## Core modules

| Module | Path | Responsibility |
|--------|------|----------------|
| `AppDatabase` | `lib/core/database/app_database.dart` | Drift database class, schema v3, 9 tables, UUID PKs, WAL + FK pragma, batch seed |
| `injection_container.dart` | `lib/core/di/` | injectable-generated DI config (`configureDependencies`); `database_module.dart` registers `AppDatabase` |
| `l10n_extension.dart` | `lib/core/extensions/` | `context.l10n` shorthand for `AppLocalizations.of(context)!` |
| `ReceiptPdfService` | `lib/core/services/` | Build 80 mm thermal receipt PDF; expose `printReceipt` and `shareReceipt`; Thai font embedding |
| `ReceiptPreview` | `lib/core/widgets/` | On-screen receipt preview in `thermal` and `card` styles; VAT-aware |
| `OverlayToast` | `lib/core/widgets/` | Fade-in pill toast at top center via `Overlay`; non-blocking, no dependency, replaces snackbar in active cashier flow |
| `IdGenerator` | `lib/core/utils/` | UUIDv4 generation via `uuid` package — all entity PKs |
| `payment_method_helper.dart` | `lib/core/utils/` | Normalize raw DB values (`เงินสด` → `cash`) and localize for display |
| `ReceiptNumberService` | `lib/features/sale/data/services/` | Auto-generated receipt numbers (`YYMMDD-XX-NNNN`) per day/device |
| `InventoryLogService` | `lib/features/inventory/data/services/` | Audit trail for stock changes (SALE, VOID_REVERSAL, ADJUSTMENT_IN/OUT) |
| `DraftCartLocalDatasource` | `lib/features/sale/data/datasources/` | Persist/load `DraftCarts` + `DraftCartItems`; used by `DraftCartRepository` |
| `SettingsLocalDatasource` | `lib/features/settings/data/datasources/` | Drift-backed typed key-value store for app_settings table |
| `AdaptiveBreakpoints` | `lib/core/widgets/` | Compact / medium / expanded layout helpers |
| `AppEmptyState` | `lib/core/widgets/` | Consistent empty/error states with compact-height support |
| `MoneyText` | `lib/core/widgets/` | Currency text with fixed decimal formatting |
| `SectionCard` | `lib/core/widgets/` | Shared grouped card surface for settings and dashboards |

---

## Feature modules

| Feature | BLoC / Cubit | Key files |
|---------|-------------|-----------|
| Sale | `SaleBloc` | `sale_page_redesign.dart`, `payment_sheet_redesign.dart`; widgets: `DiscountDialog`, `SaleCatalog`, `SaleProductCard`, `CartHeader`, `CartItemRow`, `CartTotalBar`, `DraftsBottomSheet`, `SaleReceiptDialog`, `CartPanel`, `ChangePreview`, `PaymentTotalRow` |
| Product | `ProductBloc` | `product_list_page.dart`, `product_form_page.dart`; widgets: `ProductAvatar`, `StockBadge`, `ProductTile`, `ProductGridCard`, `ProductTextField`, `ProductFormAvatar`, `ProductSectionLabel` |
| History | `HistoryBloc` | `history_page.dart`; widgets: `SaleExpansionTile`, `VoidSaleDialog` |
| Report | `ReportCubit` (lazySingleton) | `report_page.dart`; widgets: `SummaryCard` |
| Settings | `SettingsCubit` | `settings_page.dart`; widgets: `SettingsSectionHeader`, `SettingsTextField`, `LanguageTile`, `ThemeTile`, `CurrencyTile`, `DateFormatTile`, `ResponsiveSettingsPicker` |
| Inventory | — | `inventory_log_page.dart`, `adjust_stock_dialog.dart`, `InventoryLogService`, `AdjustStock` |
| Draft Cart | (via `SaleBloc`) | `DraftCartLocalDatasource`, `DraftCartRepositoryImpl`, `draft_cart_repository.dart` |

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

## Database schema (v3)

Managed by [Drift](https://drift.simonbinder.eu/) — type-safe SQLite ORM. All IDs are UUIDv4 TEXT.

| Table | Key fields |
|-------|--------|
| `Products` | id, name, sku, barcode, price, cost, stock, categoryId, imageUrl, trackStock, isActive, createdAt, updatedAt, deletedAt, version, deviceId |
| `Sales` | id, receiptNumber, status, totalAmount, subtotalAmount, discountType/Value/Amount, vatMode/Rate/Amount, paymentMethod, amountReceived, changeAmount, note, voidedAt, voidReason, createdAt, updatedAt, deletedAt, version, deviceId |
| `SaleItems` | id, saleId, productId, productName, price, qty, subtotal, discountAmount, vatAmount |
| `Categories` | id, name, sortOrder, createdAt, updatedAt, deletedAt, version, deviceId |
| `InventoryLogs` | id, productId, type, qtyChange, balanceAfter, reason, refSaleId, createdAt, deviceId |
| `AppSettings` | key (PK), value, updatedAt |
| `DraftCarts` | id, name, note, cartDiscountType, cartDiscountValue, createdAt, updatedAt, deviceId |
| `DraftCartItems` | id, cartId, productId, productName, price, qty, discountType, discountValue |
| `DailyCloses` | id, closeDate, openingCash, expectedCash, countedCash, overShortAmount, totalRevenue, totalVoid, salesCount, voidCount, note, closedAt, deviceId |

**Indexes:** `idx_products_category_id`, `idx_products_is_active`, `idx_products_barcode`, `idx_sales_created_at`, `idx_sales_status`, `idx_sale_items_sale_id`, `idx_inventory_logs_product_id`, `idx_draft_cart_items_cart_id`, `idx_daily_closes_close_date`

**Pragmas:** WAL journal mode + `foreign_keys=ON` via `beforeOpen`

Generated code: `lib/core/database/app_database.g.dart` — **do not edit manually**.

> 📄 Full database handbook: [`docs/DATABASE.md`](docs/DATABASE.md) — ERD, column details, enum values, query patterns, migration guide, backup/restore, performance notes.

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

`SettingsRepositoryImpl` reads and writes `AppSettings` via `SettingsLocalDatasource` (Drift-backed typed key-value store).

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
| `autoPrintPrompt` | bool | `true` |
| `vatRate` | double | `7.0` |
| `vatMode` | String | `NONE` |
| `receiptPreviewStyle` | String | `thermal` |
| `showPreSalePreview` | bool | `true` |
| `showPostSalePreview` | bool | `true` |
| `allowOversell` | bool | `false` |
| `lowStockThreshold` | int | `5` |

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

`lib/core/di/injection_container.dart` — `configureDependencies()` generated by `injectable`.

Annotations on implementation classes drive registration:

| Scope | Annotation | Examples |
|-------|-----------|----------|
| Lazy singleton | `@LazySingleton(as: Abc)` | datasources, repositories, services |
| Lazy singleton | `@lazySingleton` | `ProductBloc`, `SettingsCubit`, `ReportCubit` |
| Factory | `@injectable` | use cases, `SaleBloc` |
| Module | `@module` | `DatabaseModule` provides `AppDatabase` |

Access anywhere via `sl<T>()`.

After adding/changing annotations, run:
```bash
dart run build_runner build
```

---

## Code generation

Two generators must be run after changes:

| Generator | Trigger | Command |
|-----------|---------|---------|
| Drift | Schema change | `dart run build_runner build` |
| Injectable | DI annotation change | `dart run build_runner build` |
| Flutter l10n | New ARB key | `flutter gen-l10n` |

---

## File dependency map

| If you change… | Also update… |
|----------------|-------------|
| Drift table definition (`lib/core/database/tables/`) | Run `build_runner build` |
| `app_th.arb` | `app_en.arb` (add matching key) + `flutter gen-l10n` |
| `AppSettings` entity | `SettingsRepositoryImpl`, `SettingsCubit`, `SettingsPage` |
| `injection_container.dart` / DI annotations | Run `build_runner build` |
| Payment method values in DB | `payment_method_helper.dart` normalization map |
| Shared UI behavior | `lib/core/widgets/` tests under `test/core/widgets/` |
| Feature UI strings | Both ARB files + generated localization files |
| Main Sale UI entry | `main.dart` import + Sale page widget tests/manual smoke test |
| Feature `widgets/` folder | Corresponding page file import + widget tests |
| BLoC / Cubit class | Update mock in `test/helpers/mocks.dart` |
| Domain entity | Update `test/helpers/fixtures.dart` + corresponding `_test.dart` files |
| `Sale` entity (new fields) | Update `sale_test.dart` props count, `_buildSale` in datasource |
| `SaleLocalDatasource` | Update `ReceiptNumberService`/`InventoryLogService` injection in tests |
| `CartItem` entity | Update `cart_item_test.dart` props count + discount test fixtures |
| `SaleBloc` constructor | Update `sale_bloc_test.dart` to inject `MockDraftCartRepository` |
| `DraftCart` entity (new fields) | Update `draft_cart.dart` + `DraftCartLocalDatasource` + `SaleBloc` draft event handlers + `sale_bloc_test.dart` |
| `DraftCarts` table schema | Run `build_runner build`; bump schema version + add migration in `app_database.dart` |
| `Product` entity (new fields) | Update `product_test.dart` props count + all fixtures in `fixtures.dart` |
| Parent `BlocListener` that calls `showDialog` alongside a modal's `BlocListener` | Wrap `showDialog` in `WidgetsBinding.instance.addPostFrameCallback` — see ADR-009 in `docs/ARCHITECTURE.md` |

---

## Test infrastructure

216 automated tests across 7 layers. Run with `flutter test`.

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
│   ├── checkout_flow_test.dart  # End-to-end data layer checkout
│   └── sale_integrity_test.dart # Void sale, adjust stock, full audit trail
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
