# CODEBASE.md — Promsell POS CE v0.7.5

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
│   product/    — CRUD inventory, ProductBloc, image service │
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
│   image/      — Unified image system (UnifiedImageWidget, ImageSkeleton, ImageErrorPlaceholder, ImageCacheService) │
│   services/   — (empty — services moved to features) │
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
| `AppColors` / `AppTheme` | `lib/core/theme/` | Static color palette (`#00C853` primary, `#0D1117` dark bg) and Material 3 `ThemeData` (light/dark) with shared `CardTheme`, `ButtonTheme`, `InputDecorationTheme` (radius 16/12). All app colors must route through here |
| `SettingsThemeExtension` | `lib/features/settings/presentation/theme/` | `ThemeExtension` for settings surfaces: `cardBackground`, `softAccent`, `softTextPrimary/Secondary`, `iconContainerBackground`, `cardRadius`, `sectionGap`. Separate light/dark consts |
| `AppDatabase` | `lib/core/database/app_database.dart` | Drift database class, schema v13, 9 tables, UUID PKs, WAL + FK pragma, batch seed. Sync columns (`updatedAt`, `deletedAt`, `version`, `deviceId`) on all 6 core tables. v13 backfills `deviceId` on existing rows |
| `injection_container.dart` | `lib/core/di/` | injectable-generated DI config (`configureDependencies`); `database_module.dart` registers `AppDatabase` |
| `l10n_extension.dart` | `lib/core/extensions/` | `context.l10n` shorthand for `AppLocalizations.of(context)!` |
| `ReceiptPdfService` | `lib/features/receipt/data/services/` | Build 80 mm thermal receipt PDF; expose `printReceipt` and `shareReceipt`; Thai font embedding |
| `ReceiptLabels` | `lib/features/receipt/domain/entities/` | Localized label entity for receipt rendering |
| `ReceiptPreview` | `lib/core/widgets/` | On-screen receipt preview in `thermal` and `card` styles; VAT-aware; product images inline via `ProductAvatar` |
| `OverlayToast` | `lib/core/widgets/` | Fade-in pill toast at top center via `Overlay`; non-blocking, no dependency, replaces snackbar in active cashier flow |
| `IdGenerator` | `lib/core/utils/` | UUIDv4 generation via `uuid` package — all entity PKs |
| `MoneyUtils` | `lib/core/utils/` | Centralized monetary rounding (`round(double)`) for VAT, discount, and total calculations |
| `payment_method_helper.dart` | `lib/core/utils/` | Normalize raw DB values (`เงินสด` → `cash`) and localize for display |
| `SlipVerifier` | `lib/core/utils/` | Decodes Thai bank transfer slip Mini-QR; returns `SlipVerifyResult` with `SlipErrorType` categorization |
| `SoundPlayer` | `lib/core/utils/` | Lightweight audio player for confirmation feedback |
| `PromptPayQrCode` | `lib/features/settings/presentation/widgets/` | EMVCo-compliant QR payload generator via `thai_promptpay`; optional customizable icon overlay |
| `ReceiptNumberService` | `lib/features/sale/data/services/` | Auto-generated receipt numbers (`YYMMDD-XX-NNNN`) per day/device |
| `ProductImageService` | `lib/features/product/data/services/` | Gallery/camera pick → pure Dart JPEG compression (configurable maxWidth/quality) → local `/images/{productId}.jpg` + `_thumb.jpg`; delegates delete to `ImageCacheService`; format validation (`.jpg`, `.png`, `.webp`, etc.); auto LRU cache eviction on save; `@LazySingleton` |
| `InventoryLogService` | `lib/features/inventory/data/services/` | Audit trail for stock changes (SALE, VOID_REVERSAL, ADJUSTMENT_IN/OUT) |
| `ReportCalculator` | `lib/features/report/domain/extensions/` | Domain extension on `List<Sale>`: `completedSales`, `voidedSales`, `netRevenue`, `voidedTotal`, `byPaymentMethod`, `topProducts` |
| `SettingsMapper` | `lib/features/settings/data/mappers/` | `Settings` ↔ `Map<String,String>` serialization; handles legacy themeMode integer migration (0→light, 1→dark, 2→system) |
| `SettingsPersistenceService` | `lib/features/settings/domain/services/` | Debounce Timer + persistence logic; extracted from `SettingsCubit` |
| `BackupEncryptionService` | `lib/features/settings/data/services/` | AES-256-GCM encryption/decryption for SQLite backups with PIN-derived PBKDF2 key |
| `DraftCartLocalDatasource` | `lib/features/sale/data/datasources/` | Persist/load `DraftCarts` + `DraftCartItems`; used by `DraftCartRepository` |
| `SettingsLocalDatasource` | `lib/features/settings/data/datasources/` | Drift-backed typed key-value store for app_settings table |
| `AdaptiveBreakpoints` | `lib/core/widgets/` | Compact / medium / expanded layout helpers |
| `AppEmptyState` | `lib/core/widgets/` | Consistent empty/error states with compact-height support |
| `MoneyText` | `lib/core/widgets/` | Currency text with fixed decimal formatting |
| `SectionCard` | `lib/core/widgets/` | Shared grouped card surface for settings and dashboards |
| `ImageViewerDialog` | `lib/core/widgets/` | Full-screen image viewer with `InteractiveViewer` (pinch zoom, pan, double-tap zoom), swipe gallery, page indicators. Bottom toolbar: share button (`share_plus`) + info bottom sheet (source, path, file size). Used by product image tap and receipt preview |

---

## Feature modules

| Feature | BLoC / Cubit | Key files |
|---------|-------------|-----------|
| Sale | `SaleBloc` | `sale_page.dart`, `checkout_page.dart`, `payment_sheet_redesign.dart`, `promptpay_payment_page.dart`; widgets: `CheckoutBody`, `CartReviewPage`, `DiscountDialog`, `SaleCatalog`, `SaleProductCard`, `CartHeader`, `CartItemRow` (single-row 3-zone), `CartTotalBar`, `DraftsBottomSheet`, `SaleReceiptDialog`, `CartPanel`, `CartBottomSheet` (draggable sheet), `CartQtyStepper` (press-scale haptic), `ChangePreview`, `PaymentTotalRow`, `PaymentMethodCard`, `ImageViewerDialog`, `CompactCartFab`, `CartItemCard`, `CartDetailRow`, `CartQtyButton`, `CartDottedLineRow`, `SlipScannerDialog` |
| Product | `ProductBloc` | `product_list_page.dart`, `product_form_page.dart`; widgets: `ProductAvatar` (wrapper around `UnifiedImageWidget`), `StockBadge`, `ProductTile`, `ProductGridCard`, `ProductTextField`, `ProductFormAvatar` (wrapper with edit badge), `ProductSectionLabel`, `ProductCategoryAutocomplete`; services: `ProductImageService` |
| History | `HistoryBloc` | `history_page.dart`; widgets: `SaleExpansionTile`, `VoidSaleDialog` |
| Report | `ReportCubit` (lazySingleton) | `report_page.dart`; widgets: `SummaryCard`, `ReportDateRangeCard`, `ReportPaymentMethodCard`, `ReportTopProductsCard`; domain: `ReportCalculator` extension |
| Settings | `SettingsCubit` | Pages: 3-level hierarchy — `settings_root_page.dart`, `general_settings_page.dart`, `shop_info_settings_page.dart`, `sales_settings_page.dart`, `receipt_settings_page.dart`, `discount_policy_settings_page.dart`, `stock_policy_settings_page.dart`, `image_settings_page.dart`, `backup_settings_page.dart`, `promptpay_settings_page.dart`, `db_health_page.dart`. Widgets: `SettingsCategoryTile`, `SettingsSectionCard`, `SettingsSwitchTile`, `SettingsTextTile`, `SettingsDropdownTile`, `SettingsValuePreview`, `GeneralSummaryCard`, `GeneralSettingsForm`, `ShopPreviewCard`, `ShopInfoForm`, `SettingsThemeExtension`, `AppTextDialog`, `ImagePreviewCard`, `DemoImagePreview`, `BackupStatusCard`, `BackupInfoCard`, `PromptpayPreviewCard`, `PromptpayInfoCard`; domain: `SettingsMapper`, `SettingsPersistenceService`, `Settings` aggregate root with 12 typed group entities |
| Inventory | `InventoryLogCubit` | `inventory_log_page.dart`, `adjust_stock_dialog.dart`; domain: `InventoryLog`, `InventoryLogRepository`, `WatchInventoryLogs`; data: `InventoryLogLocalDatasource`, `InventoryLogService`, `AdjustStock` |
| Receipt | `ReceiptPdfService` (lazySingleton) | `receipt_pdf_service.dart`, `receipt_labels.dart`; data services + domain entities |
| Draft Cart | (via `SaleBloc`) | `DraftCartLocalDatasource`, `DraftCartRepositoryImpl`, `draft_cart_repository.dart` |
| Daily Close | `DailyCloseCubit` | `daily_close_page.dart`, `daily_close_list_page.dart`; widgets: `DailyCloseDateCard`, `DailyCloseSummaryCard`, `DailyCloseReconciliationCard`, `DailyCloseSummaryRow`, `DailyCloseReadOnlyRow`; domain: `DailyClose`, `CloseDay`, `ReopenDay`, `GetDailyCloseByDate`, `GetDailyCloseList` |
| Onboarding | (stateless wizard) | `onboarding_page.dart` — 6-step first-launch flow; widgets: `OnboardingHeroSection`, `OnboardingSection`, `GreenChoiceChip`, `OnboardingSheetOption` |
| DB Health | (stateful page) | `db_health_page.dart` — file size, row counts, vacuum |

---

## UI and design system notes

- The current UI refresh follows a **Merchant Command Deck** direction: cashier-first, fast scanning, strong money hierarchy, and large touch targets.
- **Theme system** lives in `lib/core/theme/` — `AppColors` (static palette), `AppTheme` (light/dark `ThemeData` with Material 3), and `SettingsThemeExtension` (settings-specific surface/accent tokens). All hardcoded `Color(0xFF...)` outside this folder is forbidden.
- Shared visual behavior should live in `lib/core/theme/` and `lib/core/widgets/` before being duplicated in feature pages.
- Sale layouts are adaptive:
  - Compact screens use a product catalog with a bottom cart command panel.
  - Expanded screens keep the cart pane visible beside the product grid.
  - **Compact Cart Mode** (toggle in Settings → General) hides the full panel and shows a floating cart icon that opens `CartBottomSheet`.
- User-facing strings must remain localized through ARB files and accessed with `context.l10n`.
- Empty/error states should prefer `AppEmptyState`; money values should prefer `MoneyText`.
- Compact constrained areas should avoid fixed-height `Column` content that can trigger `RenderFlex` overflow.

---

## Database schema (v13)

Managed by [Drift](https://drift.simonbinder.eu/) — type-safe SQLite ORM. All IDs are UUIDv4 TEXT.

| Table | Key fields |
|-------|--------|
| `Products` | id, name, sku, barcode, price, cost, stock, categoryId, imageUrl, imagePath, imageThumbnailPath, trackStock, isActive, createdAt, **updatedAt**, **deletedAt**, **version**, **deviceId** |
| `Sales` | id, receiptNumber, status, totalAmount, subtotalAmount, discountType/Value/Amount, vatMode/Rate/Amount, paymentMethod, amountReceived, changeAmount, paymentReference, sendingBankCode, note, voidedAt, voidReason, createdAt, **updatedAt**, **deletedAt**, **version**, **deviceId** |
| `SaleItems` | id, saleId, productId, productName, price, qty, subtotal, discountAmount, vatAmount |
| `Categories` | id, name, sortOrder, createdAt, **updatedAt**, **deletedAt**, **version**, **deviceId** |
| `InventoryLogs` | id, productId, type, qtyChange, balanceAfter, reason, refSaleId, createdAt, **deviceId** |
| `AppSettings` | key (PK), value, updatedAt |
| `DraftCarts` | id, name, note, cartDiscountType, cartDiscountValue, createdAt, **updatedAt**, **deviceId** |
| `DraftCartItems` | id, cartId, productId, productName, price, qty, discountType, discountValue |
| `DailyCloses` | id, closeDate, openingCash, expectedCash, countedCash, overShortAmount, totalRevenue, totalVoid, salesCount, voidCount, paymentBreakdown, vatAmount, discountAmount, note, closedAt, **deviceId** |

**Indexes:** `idx_products_category_id`, `idx_products_is_active`, `idx_products_barcode`, `idx_sales_created_at`, `idx_sales_status`, `idx_sale_items_sale_id`, `idx_inventory_logs_product_id`, `idx_draft_cart_items_cart_id`, `idx_daily_closes_close_date`

**Pragmas:** WAL journal mode + `foreign_keys=ON` via `beforeOpen`

Generated code: `lib/core/database/app_database.g.dart` — **do not edit manually**.

> 📄 Full database handbook: [`docs/DATABASE.md`](docs/DATABASE.md) — ERD, column details, enum values, query patterns, migration guide, backup/restore, performance notes.

To regenerate after schema changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Phase 4 Sync Readiness Audit

**Date:** 2026-06-05 | **Schema:** v10

All tables require 4 sync columns: `updatedAt`, `deletedAt`, `version`, `deviceId`.

| Table | updatedAt | deletedAt | version | deviceId | Status |
|---|---|---|---|---|---|
| `Products` | ✅ | ✅ | ✅ | ✅ | Ready |
| `Sales` | ✅ | ✅ | ✅ | ✅ | Ready |
| `SaleItems` | ❌ | ❌ | ❌ | ❌ | **Gap** |
| `Categories` | ✅ | ✅ | ✅ | ✅ | Ready |
| `InventoryLogs` | ❌ | ❌ | ❌ | ✅ | Partial |
| `DraftCarts` | ✅ | ❌ | ❌ | ✅ | Partial |
| `DraftCartItems` | ❌ | ❌ | ❌ | ❌ | **Gap** |
| `DailyCloses` | ❌ | ❌ | ❌ | ✅ | Partial |
| `AppSettings` | ✅ | ❌ | ❌ | ❌ | Partial (K/V store) |

**Gap mitigation:** SaleItems, DraftCartItems, and DailyCloses need migration to add missing sync columns. Tracked as `phase-4-prep` issues. AppSettings as key-value store may use a different sync strategy.

---

## State management patterns

| Pattern | When used |
|---------|-----------|
| **BLoC** (event → state) | Complex flows with multiple event types — sale, product, history |
| **Cubit** (method → state) | Simpler state without event classes — settings, report |

All state classes extend `Equatable` for efficient rebuilds.

---

## Settings persistence

`SettingsRepositoryImpl` reads and writes a `Settings` aggregate root via `SettingsLocalDatasource`. `SettingsMapper` handles serialization to/from `Map<String,String>`.

### Architecture

```
SettingsCubit
  └── SettingsPersistenceService (debounce + save)
        └── SettingsRepositoryImpl
              ├── SettingsMapper (Settings ↔ Map<String,String>)
              └── SettingsLocalDatasource (Drift key-value store)
```

### `Settings` aggregate root — 12 typed group entities

| Group | Entity | Key fields |
|-------|--------|-----------|
| Shop | `ShopInfo` | name, address, phone |
| Receipt | `ReceiptConfig` | receiptSize, receiptPreviewStyle, receiptNote, showShopInfo, autoPrintPrompt, showPreSalePreview, showPostSalePreview |
| Tax | `TaxConfig` | vatRate, vatMode |
| Discount | `DiscountConfig` | enableItemDiscount, enableCartDiscount, maxDiscountPercent, maxDiscountAmount, defaultDiscountType, discountPresets, activeDiscountPresetId |
| Stock | `StockConfig` | allowOversell, lowStockThreshold |
| Image | `ImageConfig` | maxWidth, quality |
| Payment | `PaymentConfig` | currency, promptpayId, billerId, promptPayTimeout, promptPaySoundEnabled, defaultQrType, autoConfirmAfterSlip, qrOverlayIcon |
| Device | `DeviceConfig` | deviceId, devicePrefix |
| UI | `UiConfig` | locale, themeMode, dateFormat, cartCompactMode, ultraCompactMode, accessibilityMode |
| Daily Close | `DailyCloseConfig` | dailyCloseLock, lastClosedDate |
| Backup | `BackupConfig` | reminderDays, lastBackupAt, encryptionEnabled |
| Draft | `DraftConfig` | maxDrafts |

### `@Deprecated` facade

`AppSettings` is a temporary facade over `Settings` for backward compatibility during migration. Use `AppSettings.fromSettings()` / `toSettings()` at presentation layer boundaries.

### Legacy migration

`SettingsMapper` normalizes legacy integer `themeMode` values (`0`→`light`, `1`→`dark`, `2`→`system`) and falls back invalid values to `system`.

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
| `Settings` aggregate root (12 typed groups) | `SettingsMapper`, `SettingsRepositoryImpl`, `SettingsCubit`, all `AppSettings` consumers |
| `SettingsMapper` | `SettingsRepositoryImpl` tests (mock `getAll()` return values); legacy migration handling |
| Extracted widget (e.g. `CartItemCard`) | Parent page import update + widget test under `test/features/<name>/presentation/widgets/` |
| Domain extension (e.g. `ReportCalculator`) | Pure Dart test under `test/features/<name>/domain/extensions/` |
| BLoC / Cubit class | Update mock in `test/helpers/mocks.dart` |
| Domain entity | Update `test/helpers/fixtures.dart` + corresponding `_test.dart` files |
| `Sale` entity (new fields) | Update `sale_test.dart` props count, `_buildSale` in datasource |
| `SaleLocalDatasource` | Update `ReceiptNumberService`/`InventoryLogService` injection in tests |
| `CartItem` entity | Update `cart_item_test.dart` props count + discount test fixtures |
| `SaleBloc` constructor | Update `sale_bloc_test.dart` to inject `MockDraftCartRepository` |
| `DraftCart` entity (new fields) | Update `draft_cart.dart` + `DraftCartLocalDatasource` + `SaleBloc` draft event handlers + `sale_bloc_test.dart` |
| `DraftCarts` table schema | Run `build_runner build`; bump schema version + add migration in `app_database.dart` |
| `Product` entity (new fields) | Update `product_test.dart` props count + all fixtures in `fixtures.dart` + `ProductRepositoryImpl` constructor if services added |
| `ProductRepositoryImpl` constructor | Update `product_repository_impl_test.dart` to inject `MockProductImageService` |
| `InventoryLog` entity | Update `inventory_log_test.dart` props count + `InventoryLogRepositoryImpl` mapping |
| `InventoryLogCubit` constructor | Update mock in `test/helpers/mocks.dart` + inject `MockWatchInventoryLogs` in tests |
| `InventoryLogLocalDatasource` | Update `InventoryLogRepositoryImpl` tests to inject mock datasource |

---

## Test infrastructure

343 automated tests across 8 layers. Run with `flutter test`.

### Test directory structure

```
test/
├── helpers/
│   ├── mocks.dart              # All mock classes (repos, datasources, use cases, BLoCs/Cubits)
│   ├── fixtures.dart           # Test entity fixtures
│   ├── pump_app.dart           # pumpApp extension for widget tests
│   └── fake_database.dart      # In-memory Drift DB factory
├── core/
│   └── utils/                  # Core utility tests (MoneyUtils, etc.)
├── features/
│   ├── sale/                   # Use case, BLoC, repo, datasource, widget tests
│   │   └── presentation/widgets/  # CartItemCard, CartDetailRow, CartQtyButton, CartDottedLineRow, CompactCartFab
│   ├── product/                # Use case, BLoC, repo, datasource, widget tests
│   │   └── presentation/widgets/  # ProductCategoryAutocomplete
│   ├── history/                # Use case, BLoC, repo tests
│   ├── inventory/              # InventoryLog entity, use case, cubit, repo tests
│   ├── report/                 # ReportCubit tests + ReportCalculator domain tests
│   │   └── domain/extensions/   # ReportCalculator_test.dart
│   ├── settings/               # Cubit, repo, widget tests
│   │   └── presentation/widgets/  # ImagePreviewCard, DemoImagePreview, BackupStatusCard, BackupInfoCard, PromptpayPreviewCard, PromptpayInfoCard, image_settings_labels
│   ├── daily_close/            # Cubit, repo, widget tests
│   │   └── presentation/widgets/  # DailyCloseDateCard, DailyCloseSummaryCard, DailyCloseReconciliationCard, DailyCloseSummaryRow, DailyCloseReadOnlyRow
│   └── onboarding/             # Widget tests
│       └── presentation/widgets/  # OnboardingHeroSection, OnboardingSection, GreenChoiceChip, OnboardingSheetOption
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
