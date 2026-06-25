# File Dependency Map — Promsell POS CE v0.8.5

If you change a file, these are the files that must also be updated.

> **Main reference:** [`CODEBASE.md`](../CODEBASE.md) — system overview, architecture, links

---

## General rules

| If you change… | Also update… |
|----------------|-------------|
| Drift table definition (`lib/core/database/tables/`) | Run `build_runner build` |
| `app_th.arb` | `app_en.arb` (add matching key) + `flutter gen-l10n` |
| `Settings` aggregate root | `SettingsRepositoryImpl`, `SettingsCubit`, `SettingsMapper`, all settings pages & widgets |
| `injection_container.dart` / DI annotations | Run `build_runner build` |
| Payment method values in DB | `payment_method_helper.dart` normalization map |
| Shared UI behavior | `lib/core/widgets/` tests under `test/core/widgets/` |
| Feature UI strings | Both ARB files + generated localization files |
| Main Sale UI entry | `main.dart` import + Sale page widget tests/manual smoke test |
| Feature `widgets/` folder | Corresponding page file import + widget tests |
| `Settings` aggregate root (13 typed groups) | `SettingsMapper`, `SettingsRepositoryImpl`, `SettingsCubit`, all settings pages & widgets |
| `SettingsMapper` | `SettingsRepositoryImpl` tests (mock `getAll()` return values); legacy migration handling |
| Extracted widget (e.g. `CartItemCard`) | Parent page import update + widget test under `test/features/<name>/presentation/widgets/` |
| Domain extension (e.g. `ReportCalculator`) | Pure Dart test under `test/features/<name>/domain/extensions/` |
| BLoC / Cubit class | Update mock in `test/helpers/mocks.dart` |
| Domain entity | Update `test/helpers/fixtures.dart` + corresponding `_test.dart` files |

---

## Entity-specific rules

| If you change… | Also update… |
|----------------|-------------|
| `Sale` entity (new fields) | Update `sale_test.dart` props count, `_buildSale` in datasource |
| `SaleLocalDatasource` | Update `ReceiptNumberService`/`InventoryLogService` injection in tests |
| `CartItem` entity | Update `cart_item_test.dart` props count + discount test fixtures |
| `SaleBloc` constructor | Update `sale_bloc_test.dart` to inject `MockDraftCartRepository` |
| `SaleState` new field (e.g. `stockWarning`) | Update `sale_state.dart` props count + `sale_bloc_test.dart` expectations + any `copyWith` usage |
| `DraftCart` entity (new fields) | Update `draft_cart.dart` + `DraftCartLocalDatasource` + `SaleBloc` draft event handlers + `sale_bloc_test.dart` |
| `DraftCarts` table schema | Run `build_runner build`; bump schema version + add migration in `app_database.dart` |
| `Product` entity (new fields, e.g. `barcodeImagePath`) | Update `product_test.dart` props count + all fixtures in `fixtures.dart` + `ProductLocalDatasource` mapping + `ProductRepositoryImpl` constructor if services added |
| `Category` entity (new fields: color, iconName) | Update `category_test.dart` props count + fixtures + `CategoryRepositoryImpl` mapping + run `build_runner build`; bump schema version |
| `CategoryRepositoryImpl` constructor | Update tests to inject mock datasource; regenerate with `build_runner` |
| `CategoryBloc` constructor / events | Update mock in `test/helpers/mocks.dart`; add `CategoriesReordered` event handler tests; inject `ReorderCategories` use case |
| `ProductRepositoryImpl` constructor | Update `product_repository_impl_test.dart` to inject `MockProductImageService` (and `MockBarcodeImageService` if image generation is wired) |
| `ProductLocalDatasource` / `ProductRepository` new method (e.g. `bulkUpdateBarcodes`) | Update interface + impl + mock in `mocks.dart` + `batch_generate_barcodes_test.dart` |
| `Ean13Generator` constructor / annotations | Run `build_runner build`; update `GenerateBarcode`, `BatchGenerateBarcodes`, `SettingsCubit` constructors + their tests (`generate_barcode_test.dart`, `batch_generate_barcodes_test.dart`, `settings_cubit_test.dart`) |
| `GenerateBarcode` / `BatchGenerateBarcodes` constructor | Update mock in `test/helpers/mocks.dart` + corresponding test files to inject `Ean13Generator` instance |
| `BarcodeImageService.generate()` rendering method | Update `barcode_image_service_test.dart` if present; verify `BarcodeImageWidget` display still renders correctly |
| `InventoryLog` entity | Update `inventory_log_test.dart` props count + `InventoryLogRepositoryImpl` mapping |
| `InventoryLogCubit` constructor | Update mock in `test/helpers/mocks.dart` + inject `MockWatchInventoryLogs` in tests |
| `InventoryLogLocalDatasource` | Update `InventoryLogRepositoryImpl` tests to inject mock datasource |

---

<sub>Promsell POS CE · v0.8.6 · File Dependency Map</sub>
