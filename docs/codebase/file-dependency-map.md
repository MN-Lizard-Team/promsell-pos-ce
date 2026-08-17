# File Dependency Map — Promsell POS CE (v0.9.2)

If you change a file, these are the files that must also be updated.

> **Main reference:** [`CODEBASE.md`](../../CODEBASE.md) — system overview, architecture, links

---

## General rules

| If you change… | Also update… |
|----------------|-------------|
| Drift table definition (`lib/core/database/tables/`) | Run `dart run build_runner build`; bump schema version, add an idempotent migration, and add a legacy-fixture test |
| `*_satang` money column or `Money` persistence boundary | Update writer dual-writes, satang-first readers/REAL fallback, migration/backfill tests, and `docs/DATABASE.md` |
| `app_th.arb` | `app_en.arb` (add matching key) + `flutter gen-l10n` |
| `injection_container.dart` / DI annotations | Run `dart run build_runner build` |
| Payment method values in DB | `payment_method_helper.dart` normalization map |
| Shared UI behavior | `lib/core/widgets/` tests under `test/core/widgets/` |
| Feature UI strings | Both ARB files + generated localization files |
| Main Sale UI entry | `main.dart` import + Sale page widget tests/manual smoke test |
| Feature `widgets/` folder | Corresponding page file import + widget tests |
| `Settings` aggregate root (14 typed groups) | `SettingsMapper`, `SettingsRepositoryImpl`, `SettingsCubit`, all settings pages & widgets |
| `SettingsMapper` | `SettingsRepositoryImpl` tests (mock `getAll()` return values); legacy migration handling |
| Extracted widget (e.g. `CartItemCard`) | Parent page import update + widget test under `test/features/<name>/presentation/widgets/` |
| Domain service (e.g. `ReportCalculatorService`) | Pure Dart test under `test/features/<name>/domain/services/` |
| BLoC / Cubit class | Update mock in `test/helpers/mocks.dart` |
| Domain entity | Update `test/helpers/fixtures.dart` + corresponding `_test.dart` files |

---

## Entity-specific rules

| If you change… | Also update… |
|----------------|-------------|
| `Sale` entity (new fields) | Update `sale_test.dart` props count, `_buildSale` in datasource |
| `SaleLocalDatasource` | Update `ReceiptNumberService`/`InventoryLogService` injection in tests |
| `CartItem` entity | Update `cart_item_test.dart` props count + discount test fixtures |
| `CartBloc` / `DraftBloc` / `CheckoutBloc` | Prefer these over legacy `SaleBloc` references; update related tests under `test/features/sale/` |
| `SaleState` new field (e.g. `stockWarning`) | Update `sale_state.dart` props count + `sale_bloc_test.dart` expectations + any `copyWith` usage |
| `DraftCart` entity (new fields) | Update `draft_cart.dart` + `DraftCartLocalDatasource` + `DraftBloc` handlers + draft tests |
| `DraftCarts` table schema | Run `dart run build_runner build`; bump schema version + add migration in `app_database.dart` + legacy fixture test |
| `Product` entity (new fields, e.g. `barcodeImagePath`) | Update `product_test.dart` props count + all fixtures in `fixtures.dart` + `ProductLocalDatasource` mapping + `ProductRepositoryImpl` constructor if services added |
| `Category` entity (new fields: color, iconName) | Update `category_test.dart` props count + fixtures + `CategoryRepositoryImpl` mapping + run `dart run build_runner build`; bump schema version |
| `CategoryRepositoryImpl` constructor | Update tests to inject mock datasource; regenerate with `build_runner` |
| `CategoryBloc` constructor / events | Update mock in `test/helpers/mocks.dart`; add `CategoriesReordered` event handler tests; inject `ReorderCategories` use case |
| `ProductRepositoryImpl` constructor | Update `product_repository_impl_test.dart` to inject `MockProductImageService` (and `MockBarcodeImageService` if image generation is wired) |
| `ProductLocalDatasource` / `ProductRepository` new method (e.g. `bulkUpdateBarcodes`) | Update interface + impl + mock in `mocks.dart` + `batch_generate_barcodes_test.dart` |
| `Ean13Generator` constructor / annotations | Run `dart run build_runner build`; update `GenerateBarcode`, `BatchGenerateBarcodes`, `SettingsCubit` constructors + their tests (`generate_barcode_test.dart`, `batch_generate_barcodes_test.dart`, `settings_cubit_test.dart`) |
| `GenerateBarcode` / `BatchGenerateBarcodes` constructor | Update mock in `test/helpers/mocks.dart` + corresponding test files to inject `Ean13Generator` instance |
| `BarcodeImageService.generate()` rendering method | Update `barcode_image_service_test.dart` if present; verify `BarcodeImageWidget` display still renders correctly |
| `InventoryLog` entity | Update `inventory_log_test.dart` props count + `InventoryLogRepositoryImpl` mapping |
| `InventoryLogCubit` constructor | Update mock in `test/helpers/mocks.dart` + inject `MockWatchInventoryLogs` in tests |
| `InventoryLogLocalDatasource` | Update `InventoryLogRepositoryImpl` tests to inject mock datasource |
| `ProductBloc._onProductsUpdated` | Update `product_bloc_test.dart` expectations — `saveStatus` is now preserved when `saving`/`saved` (not reset to `idle`) |
| `ProductListPage` (stream/pagination/refresh) | Verify `product_list_page_test.dart` — periodic stream is now `StreamController`-based; `_onRefresh` uses `Completer` not `Future.delayed`; `_resolveProductBloc` catches `ProviderNotFoundException` only |
| `ProductFormPage` callbacks | Verify `product_form_page_test.dart` — callbacks now use single `setState` (no double rebuild); create flow matches product by name + `createdAt` |
| `ProductSearchBar` controller sync | Verify search bar tests — cursor position is preserved when syncing from bloc state |
| `RichProductListTile` / `ProductFormView` | Uses `context.select` for `SettingsCubit` fields — if new settings fields are needed, add specific `context.select` lines |
| `SaleAppBar` (clock stream) | Now `StatefulWidget` with `StreamController` in `initState`/`dispose` — verify `sale_page_test.dart` still passes; do not create `Stream.periodic` inline in `build` |
| `SaleDashboardHeader` | Now `StatefulWidget` with cached `_salesStream` in `initState` — stream is created once, not per rebuild; uses `context.select` for `shopName`/`currency` |
| `SaleCatalog` | Uses `context.select` for `currency`/`lowStockThreshold`/`ultraCompactMode` (in `State.build`, not `BlocBuilder.builder`); catches `ProviderNotFoundException` only |
| `CartBottomBar` | Uses `context.select` for `currency`/`dayClosed`; `_bounceTimer` is a `Timer` cancelled in `dispose` — do not use `Future.delayed` for bounce |
| `SaleProductCard` | Uses `context.select` for `allowOversell`/`lowStockThreshold` (not `context.read`) — ensures rebuild when settings change |
| `_SaleViewState` (SalePage) | Uses `context.select` for `barcodeScanEnabled`; `dispose()` catches `StateError` only (not catch-all) |
| `CheckoutBody` restaurant seeding | Deferred to `addPostFrameCallback` — do not mutate `_orderType`/`_orderChannel`/`_selectedTableId`/`_externalRefCtrl` inside `BlocBuilder.builder` |
| `OnboardingPage` (locale/currency/progress) | Locale now read from `SettingsCubit` state (not local `_locale`); currency read from `_currencyCtrl.text`; `BlocBuilder` has `buildWhen` for `settings` only; `_finish()` validates shopName before proceeding |
| `OnboardingPage` (layout redesign) | Now uses `PageView` with `_pageController` (4 steps: Shop → Preferences → Business → Done); `_currentStep` tracks page index; `_goToStep`/`_onNext`/`_onBack` handle navigation; `bottomNavigationBar` is `OnboardingBottomBar` (sticky) |
| `OnboardingShopSection` | shopName `TextField` has `onChanged` callback wired to `setState` for progress bar updates — do not remove |
| `OnboardingHeroSection` | **Redesigned**: gradient background (primary → primaryLight) + PNG image at 25% opacity as texture overlay + icon + text; uses `context.l10n.appTitle`; `isDark` selects gradient colors and image variant; `errorBuilder` returns empty `SizedBox` |
| `OnboardingProgressBar` | **Redesigned**: step dots (4 `AnimatedContainer` dots with connecting lines) instead of `LinearProgressIndicator`; active dot expands to 28px |
| `OnboardingSection` | **Redesigned**: `Card` with rounded 20px, no border (was 16px + outline border); no `Container` wrapper |
| `OnboardingDoneSection` | Simplified: no inline `FilledButton` (moved to `OnboardingBottomBar`); shows completion text only |
| `OnboardingBottomBar` | **New file**: sticky bottom navigation bar with Back/Skip (left) + Next/Finish (right); step-aware labels; uses `theme.colorScheme.surface` background with top border |
| `BrandChoiceChip` | `selectedColor` uses `colorScheme.tertiary` (orange accent) not `colorScheme.primary` (teal) — matches `chipTheme.selectedColor` |
| `MigrationSafetyService` | Update `migration_safety_service_test.dart` (preflight, status tracking, interrupted-migration detection); if status file format changes, update `readMigrationStatus` parsing + test fixtures |
| `WalCheckpointService` | Update `wal_checkpoint_service_test.dart` (PASSIVE/TRUNCATE modes, threshold checks); if thresholds change, update `DatabaseHealthService` tests that assert `walNeedsCheckpoint`/`walNeedsTruncate` |
| `DatabaseHealthService` | Update `database_health_service_test.dart` (`DatabaseHealthReport` fields, integrity check, guardrail getters); depends on `WalCheckpointService` — update mock injection if constructor changes |
| `RecoveryKitService` | Update `recovery_kit_service_test.dart` (export/import round-trip, wrong-secret, corrupt file, key-already-exists); if PBKDF2 iterations or file format change, update `kRecoveryKitVersion` + import parsing + test fixtures |
| `BackupExportService` | Update `backup_export_service_test.dart` (`BackupMetadata` checksum, size preflight, progress callback, encryption); if `maxBackupBytes` changes, update `BackupRestoreService` (shares the constant) + tests |
| `BackupRestoreService` | Update `backup_restore_service_test.dart` (staged swap, rollback, SQLCipher header check, `skipSqlCipherHeaderCheck`); if `@ignoreParam` annotations change, run `dart run build_runner build`; update `cleanupPreRestoreBackups` tests if file naming changes |
| Cursor pagination index (`idx_products_created_at_id_cursor` / `idx_sales_created_at_id_cursor`) | Indexes are within schema v32 — no version bump. Update `ProductLocalDatasource.getProductsPage`/`searchProductsPage` + `SaleQueryLocalDatasource.querySalesPage` cursor logic tests; verify `ProductPage`/`SalePage` `nextCursor` boundary conditions |
| `ReportExportService.exportCsvStream()` | Update streaming CSV export tests (row cap `kExportMaxRows`, `startSignal` future, truncation flag); if `SaleRepository.getSalesPage` signature changes, update the paging loop + tests |

---

<sub>Promsell POS CE · v0.9.2 · File Dependency Map</sub>
