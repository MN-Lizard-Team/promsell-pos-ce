# Changelog — v0.4.x — Promsell POS CE

> For the most up-to-date changes and release information, see [CHANGELOG.md](/CHANGELOG.md) for version 0.8.x, including feature additions, system improvements, performance enhancements, and bug fixes.

---

## [0.4.2] - 2026-05-28

Full-system bug fix pass: VAT data integrity, product edit, report stability, localization gaps, and UX polish.

### Highlights

- **VAT data integrity** — sale-time `vatMode`, `vatRate`, `vatAmount`, and `subtotalAmount` now round-trip through the `Sale` entity; reprints always show the VAT that was charged, not current settings.
- **Report stability** — `ReportCubit` registered as `lazySingleton`; `ReportPage` initialises once via `StatefulWidget.initState()` — no more spurious reloads on locale/theme change.
- **Localization gaps closed** — 7 new ARB keys (EN + TH) replace all hardcoded English strings in `InventoryLogPage` and `ProductFormPage`.
- **Dead dependency removed** — `shared_preferences` + 6 platform plugins eliminated; settings fully Drift-backed since v0.4.1.

### Added

- **History VAT breakdown** — expanded sale tile now shows Subtotal + VAT rows (with rate %) when `vatMode != 'NONE'`
- **CI coverage** — `flutter test --coverage`; `lcov.info` uploaded as GitHub Actions artifact on every push/PR

### Fixed

#### Sale & Payments

- **Stale cart qty** — `_onProductsRefreshed` clamps item qty to refreshed stock and removes zero-stock items; prevents `StateError` on a second checkout attempt
- **VAT not persisted** — `insertSaleWithItems` writes `subtotalAmount`, `vatMode`, `vatRate`, `vatAmount` at sale time; previously always stored table defaults
- **`Sale` entity missing VAT fields** — `_buildSale` now maps all four VAT columns; receipt dialogs use `settings.copyWith(vatRate: sale.vatRate, vatMode: sale.vatMode)` for correct reprint values
- **`totalAmount` rounding** — `items.fold` result rounded to 2 dp before DB write
- **PDF receipt payment method** — `ReceiptLabels` gains `paymentMethodLabel`; PDF prints localized name instead of raw key (`"cash"` → `"เงินสด"`)
- **Payment sheet close on success** — `PaymentSheet` closes via its own `BlocListener`; `_CartPanel` no longer calls broad `Navigator.canPop()`
- **Search reset on every tab switch** — `ProductSearchChanged('')` fires only when switching to/from Sale tab (index 0)

#### Products

- **`imageUrl` lost on edit** — `ProductFormPage` passes `imageUrl` from `_imageUrlCtrl` into `copyWith`; previously any field edit silently cleared the URL
- **Top-products splits on rename** — `_topProducts` groups by `productId` instead of `productName`
- **`AdjustStockDialog` accepted qty = 0** — validator now rejects zero
- **`ProductListPage` empty state on filter** — shows `noMatchingProducts` when filter returns empty but products exist; previously showed misleading `noProductsYet`

#### Localization

- **`InventoryLogPage` labels** — `SALE`, `VOID_REVERSAL`, `ADJUSTMENT_IN/OUT` types use `l10n` keys (EN + TH)
- **`ProductFormPage` labels** — `'Image URL'`, `'Basic info'`, `'Details'` replaced with `l10n` keys

### Changed

- **`ReportCubit`** — registration changed from `registerFactory` → `registerLazySingleton`; `ReportPage` converted to `StatefulWidget` with `load()` in `initState()`; date range persists across tab navigation

### Removed

- **`shared_preferences`** — removed from `pubspec.yaml`; eliminates 7 packages (`shared_preferences` + 6 platform plugins)

`flutter analyze` → **0 issues** · `flutter test` → **187/187 passing**

---

## [0.4.1] - 2026-05-28

Receipt system overhaul with VAT-aware rendering, configurable previews, Thai PDF font embedding, and CI hardening.

### Highlights

- **Configurable receipt rendering with VAT support** — `NONE` / `INCLUSIVE` / `EXCLUSIVE` modes with correct subtotal/VAT/total breakdown.
- **On-screen receipt previews** — `thermal` and `card` styles shown before and after checkout.
- **Thai PDF font embedding** — bundled `NotoSansThai` fonts for thermal printing.
- **Automated CI validation** — `flutter analyze` + `flutter test` on every push/PR.

### Fixed

- **Safe migration guard** — `onUpgrade` uses no-op for patch releases; incremental template for v3+
- **SettingsRepository** — migrated from `SharedPreferences` to `SettingsLocalDatasource` (Drift-backed)
- **ProductBloc delete state** — consistent `saving` → `saved` emissions
- **SaleBloc stale state** — `SaleReset` clears `lastSale` without dropping the cart
- **Card overflow in dialogs** — fixed receipt preview overflow in narrow dialogs
- **PDF receipt header overflow** — fixed text collision between receipt number and date on 80mm thermal paper

### Added

#### Receipt system overhaul (PDF)
- `ReceiptPdfService` accepts `AppSettings` + localized `ReceiptLabels`; no more hardcoded strings
- **Receipt number** — uses `sale.receiptNumber` instead of UUID on header and share filename
- **Shop info** — conditional rendering via `showShopInfoOnReceipt`
- **Date format** — respects user's `dateFormat` setting
- **Footer** — uses `receiptNote` setting
- **VAT modes** — `NONE` / `INCLUSIVE` / `EXCLUSIVE` with correct subtotal/VAT/total breakdown
- **Thai font embedding** — loads bundled `NotoSansThai` fonts for Thai character support
- **Post-sale print dialog** — Print / Share / Close buttons, configurable via `autoPrintPrompt`

#### On-screen receipt preview (`ReceiptPreview`)
- `thermal` style — 80mm paper look, monospace layout, dashed dividers, centered shop info
- `card` style — modern `Card` UI with colored total row and structured layout
- **Pre-sale** — inside `PaymentSheet`, controlled by `showPreSalePreview`
- **Post-sale** — in success dialog, controlled by `showPostSalePreview`
- **`"none"` style** — hides preview entirely; falls back to text-only
- **VAT-aware** — shows subtotal/VAT/total breakdown when `vatMode != 'NONE'`

#### Settings UI
- `autoPrintPrompt` toggle — ask to print receipt after sale
- `vatMode` dropdown — None / Inclusive / Exclusive
- `vatRate` input
- `receiptPreviewStyle` dropdown — thermal / card / none
- `showPreSalePreview` toggle
- `showPostSalePreview` toggle

#### Localization
- 22 new ARB keys (EN + TH) for receipt labels, settings, VAT modes, and preview styles

#### Infrastructure
- **Input validation** — `Validators` utility; `AddProduct`, `UpdateProduct`, `CreateSale` validate before DB
- **CI/CD** — `.github/workflows/ci.yml` runs `flutter analyze` + `flutter test` on every push/PR
- **DI graph smoke test** — `test/core/di/di_graph_test.dart` verifies all `GetIt` registrations

### Deprecated

- `DailyCloses` table marked `@Deprecated` — removal in v0.5.0 (schema v3)

`flutter analyze` → **0 issues** · `flutter test` → **187/187 passing**

---

## [0.4.0] - 2026-05-27

### Added

> **BREAKING CHANGE:** This release contains a destructive database migration. Existing app data will be dropped and recreated.

Complete database overhaul: integer auto-increment IDs → UUIDv4 text IDs across all entities, 6 new tables, atomic sale transactions with receipt numbers and inventory audit trail, void/refund flow, and manual stock adjustments.

- **6 new tables**: `categories`, `inventory_logs`, `app_settings`, `draft_carts`, `draft_cart_items`, `daily_closes`
- **`IdGenerator`** — UUIDv4 generation for all entity IDs
- **Sync-ready columns** on all tables: `version`, `deviceId`, `updatedAt`, `deletedAt`
- **Extended product fields**: `sku`, `barcode`, `cost`, `trackStock`
- **Extended sale fields**: `receiptNumber`, `status`, `subtotalAmount`, discount/VAT columns, `voidedAt`, `voidReason`
- **Database indexes** — 9 new indexes for query performance
- **WAL journal mode** with foreign key enforcement
- **Batch seed** for default app settings on first run
- **`ReceiptNumberService`** — auto-generated receipt numbers (`YYMMDD-XX-NNNN`) with daily reset
- **`InventoryLogService`** — audit trail for all stock changes
- **`SettingsLocalDatasource`** — Drift-backed typed key-value store
- **Atomic sale insertion** — receipt number + sale items + stock deduction + inventory log in single DB transaction
- **Void sale flow** — marks sale as VOIDED, restores stock, logs reversal; confirmation dialog with reason
- **Manual stock adjustment** — `AdjustStock` use case + dialog for manual add/remove with audit reason
- **Inventory log viewer** — color-coded log entries, filterable by product
- **History UI** — VOIDED badge, strikethrough amount, receipt number in subtitle, void action button
- **Report UI** — net revenue (excludes voided), voided total summary card
- **Localization** — 18 new keys (EN + TH) for void, adjust, inventory log
- **Architecture documentation** — `ARCHITECTURE.md` (C4 diagrams, data flows, ADRs) + `DATABASE.md` (ERD, schema, migration)

### Changed

- **All entity IDs** migrated from `int` → `String` (UUIDv4)
- **Repository/use-case signatures** updated for String IDs
- **`ProductRepository.addProduct`** return type: `Future<int>` → `Future<String>`
- **`ProductsCompanion`** field: `category` → `categoryId`
- **Schema version**: 1 → 2
- **All 135 tests** migrated to use String UUID fixtures

### Removed

- Auto-increment integer ID generation
- `setup()` override in `AppDatabase`

`flutter analyze` → **0 errors** · `flutter test` → **170/170 passing**

---

[0.4.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.3.0...v0.4.0
