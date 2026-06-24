# Changelog — v0.5.x — Promsell POS CE

> ดู [CHANGELOG.md](../../CHANGELOG.md) สำหรับเวอร์ชันล่าสุด (0.8.x)

---

## [0.5.4] - 2026-05-29

Discount policy settings with preset manager, and product image management with gallery/camera pick.

### Highlights

- **Discount Policy settings** — Toggles for item/cart discount, max % and max amount limits, and card-based preset manager.
- **Discount Presets** — Named groups with type and values; quick-apply chips in `DiscountDialog`; PERCENT/AMOUNT clamped to configured max.
- **Receipt discount visibility** — Item and cart discounts appear as localized rows on the receipt PDF.
- **Product image management** — Gallery/camera pick, local JPEG compression (800px/80%), `imagePath` takes precedence over `imageUrl`; URL field retained for future sync.

### Added

#### Discount Policy

- **`DiscountPreset` entity** — `id`, `name`, `type` (PERCENT/AMOUNT), `values` (List<double>).
- **`AppSettings` discount fields** — `enableItemDiscount`, `enableCartDiscount`, `maxDiscountPercent`, `maxDiscountAmount`, `defaultDiscountType`, `discountPresets`, `activeDiscountPresetId` + `activeDiscountPreset` getter.
- **`DiscountPresetCard` widget** — Inline name editing, type toggle, value chips with add/remove, active/set/delete.
- **SettingsPage "Discount Policy" section** — Toggles, max fields, preset card list.
- **`DiscountDialog` preset chips** — `ActionChip` buttons from active preset; auto-switches type; AMOUNT clamped to `maxAmount`.
- **Receipt PDF discount rows** — Localized `receiptItemDiscounts` / `receiptCartDiscount`.
- **18 l10n keys** (EN + TH) for discount policy, presets, and receipt labels.

#### Product Images

- **`ProductImageService`** — `pickFromGallery`, `pickFromCamera`, `deleteImage`; compresses to `/images/{productId}.jpg` (800px, 80% JPEG); `@LazySingleton`.
- **`imagePath` column** — `products` table; schema v3→v4 migration.
- **`Product.imagePath` field** — Nullable local path; takes precedence over `imageUrl` in all display widgets.
- **`ProductFormAvatar` tap-to-pick** — Bottom sheet with Gallery / Camera / Remove.
- **`ProductAvatar` local image** — `Image.file` from `imagePath` → `Image.network` from `imageUrl` → placeholder.
- **4 l10n keys** (EN + TH) — `pickImageGallery`, `pickImageCamera`, `removeImage`, `imagePickError`.
- **Dependencies** — `image_picker: ^1.2.2`, `flutter_image_compress: ^2.4.0`.

### Changed

- **`DiscountDialog`** — Accepts `maxAmount` and `presetType`; helper text shows max for AMOUNT mode.
- **`cart_item_row.dart`** — Discount button hidden when `enableItemDiscount` is `false`; passes preset values and limits to dialog.
- **`cart_total_bar.dart`** — Cart discount button hidden when `enableCartDiscount` is `false`; passes preset values and limits.
- **`ReceiptLabels`** — Added required `itemDiscounts` and `cartDiscount` fields.
- **`AppSettings`** — Replaced `presetDiscountValues: List<double>` with `discountPresets: List<DiscountPreset>`.
- **`ProductFormPage`** — Replaced imageUrl text field with `ProductFormAvatar` tap-to-pick; `_imageUrlCtrl` → `_imagePath`/`_imageUrl` state fields.
- **Product data layer** — `ProductAdded`, `AddProduct`, `ProductRepository.addProduct` accept `imagePath`; `ProductRepositoryImpl` and `ProductLocalDatasource` persist/mapped `imagePath`.
- **`product_tile.dart` / `product_grid_card.dart`** — Pass `product.imagePath` to `ProductAvatar`.

### Removed

- **`_presetValuesCtrl` / `_parsePresetValues`** — Replaced by `DiscountPresetCard` chip editor.
- **`_imageUrlCtrl`** — URL text input replaced by image picker.

### Tests

- **`app_settings_test.dart`** — `props.length` updated for new discount fields (24 total).
- **`product_test.dart`** — `props.length` → 11; `imagePath` in equality test.
- **`product_bloc_test.dart` / `product_usecases_test.dart`** — Added `imagePath` to mock `when` clauses.
- **`product_form_page_test.dart`** — TextFormField indices 5→4; mock `ProductImageService` registered in GetIt.
- **Receipt PDF / ReceiptPreview tests** — `ReceiptLabels` updated with new required fields.

`flutter analyze` → **0 issues** · `flutter test` → **215/215 passing**

---

## [0.5.3] - 2026-05-29

VAT calculation and payment fixes, draft cart persistence overhaul, and bill UX improvements.

### Highlights

- **EXCLUSIVE VAT payment fix** — Payment sheet now charges the correct VAT-inclusive total.
- **Receipt double-VAT fix** — Reprinting receipts no longer adds VAT twice for EXCLUSIVE mode.
- **Draft cart discount round-trip** — Cart-level discounts persist across draft switch, app restart, clear, and delete.
- **Bill UX improvements** — Cart header shows bill name, New Bill button on cart, auto-named bills after sale, name dialog on create.

### Added

- **`CartHeader` bill name display** — Shows `activeDraftName` as title with `cartTitle` as subtitle.
- **New Bill button on cart** — `IconButton` in `CartHeader` opens name dialog and dispatches `SaleDraftCreated`.
- **New Draft name dialog** — `DraftsBottomSheet` "New Draft" button now prompts for a name before creating.
- **Auto-named bills** — `_onConfirmed` creates draft with name `Bill #N` based on draft count.

### Fixed

#### VAT & Payment

- **Payment sheet undercharged EXCLUSIVE VAT** — `PaymentSheet` used `SaleState.total` (pre-tax) as the amount to pay; now computes `effectiveTotal` including VAT for EXCLUSIVE mode. Affected: confirm button label, cash validation, change calculation, quick-amount chips.
- **Receipt double-VAT on reprint** — `ReceiptPdfService.calculateVat` received `sale.totalAmount` (already includes VAT for EXCLUSIVE) and added VAT again. Added `isTotalPreTax` parameter; post-sale callers now pass `isTotalPreTax: false`.
- **`calculateVat` floating-point drift** — No `toStringAsFixed(2)` rounding; could produce values like `7.0000000001`. All outputs now rounded.

#### Entity & Data Integrity

- **Sale entity missing discount fields** — `_buildSale()` did not map `discountType`, `discountValue`, `discountAmount` from `SaleData`; fields added to entity and mapped in datasource.
- **SaleItem entity missing discount/vat fields** — `_buildSale()` did not map `discountAmount`, `vatAmount` from `SaleItemData`; fields added to entity and mapped in datasource.

#### Draft Cart Persistence

- **Draft names cleared on every save** — `upsertDraft` always set `name` to `Value(null)` from auto-save; now uses `Value.absent()` to preserve existing names.
- **Cart discount lost on draft switch/restart** — `DraftCarts` table and `DraftCart` entity had no `cartDiscountType`/`cartDiscountValue` fields; added to DB schema, entity, datasource, and bloc state restoration.
- **`SaleReset` dropped cart discount** — `_onReset` emitted `SaleState` without `cartDiscountType`/`cartDiscountValue`; now preserved.
- **`_onCartCleared` dropped cart discount** — Clearing the cart lost `cartDiscountType`/`cartDiscountValue`; now preserved.
- **`_onDraftDeleted` didn't restore cart discount** — After deleting the active draft, the replacement draft's discount fields were not restored in state.
- **Draft total ignored cart discount** — `DraftCart.total` summed item subtotals only; now subtracts `discountAmount` like `SaleState.total`.

#### Bill UX

- **Delete didn't refresh draft list** — `DraftsBottomSheet` called `_reload()` synchronously after delete, but BLoC event hadn't completed yet; draft remained visible until sheet was reopened. Now uses `Future.delayed(300ms)`.
- **Rename didn't refresh draft list** — Same race condition as delete; now uses `Future.delayed(300ms)` to wait for DB write.
- **New draft after sale had no name** — `_onConfirmed` created a draft with `createDraft()` (no name); now uses `createDraft(name: 'Bill #N')` and sets `activeDraftName`.
- **CartHeader overflow** — Adding draft name subtitle + New Bill button caused `RenderFlex` overflow by 14px in compact cart; fixed with smaller text styles (`titleSmall`/`labelSmall`), compact `visualDensity`, and reduced padding.

### Changed

- **`PaymentSheet`** — Constructor changed from `total` to `preTaxTotal` + `vatInfo`; computes `effectiveTotal` internally.
- **`CartTotalBar`** — Now computes `vatInfo` via `ReceiptPdfService.calculateVat` and passes it to `PaymentSheet`.
- **`calculateVat`** — New `isTotalPreTax` parameter (default `true` for backward compatibility with pre-sale usage).
- **`DraftCarts` table** — Schema v2→v3; added `cart_discount_type` and `cart_discount_value` columns via `ALTER TABLE` migration.
- **`DraftCart` entity** — Added `cartDiscountType`, `cartDiscountValue`, `discountAmount`, and corrected `total` getter.
- **`SaleBloc`** — All `saveDraft` calls now pass `activeDraftName`; `_onDraftInitialized`, `_onDraftSwitched`, `_onReset`, `_onCartCleared`, `_onDraftDeleted` restore cart discount fields; `_onConfirmed` auto-names new draft `Bill #N`.
- **`CartHeader`** — Shows `activeDraftName` as title with `cartTitle` as subtitle; added New Bill button with name dialog.
- **`DraftsBottomSheet`** — `_reload()` delayed 300ms after rename/delete to avoid race condition; New Draft button now prompts for name before creating.

`flutter analyze` → **0 issues** · `flutter test` → **216/216 passing**

---

## [0.5.2] - 2026-05-29

Drift build optimization and page structure refactoring across all features.

### Highlights

- **Drift build optimization** — `build.yaml` added with `generate_manager: false` and `skip_verification_code: true`, reducing `app_database.g.dart` from 8,549 lines / 293KB to 4,769 lines / 150KB (-44% lines, -49% size).
- **Page structure refactoring** — Private widgets extracted into public widget files under `widgets/` subfolders across 6 features; helper functions converted to static methods. No behavior changes.

### Changed

- **`build.yaml`** — New file at project root configuring Drift code generation options.
- **`app_database.g.dart`** — Regenerated without Manager/Composer classes (FilterComposer, OrderingComposer, AnnotationComposer, TableManager, ProcessedTableManager typedefs) and without verification metadata code. These APIs were not used by the project.
- **Sale page** — Extracted 9 widgets (`DiscountDialog`, `SaleCatalog`, `SaleProductCard`, `CartHeader`, `CartItemRow`, `CartTotalBar`, `DraftsBottomSheet`, `SaleReceiptDialog`, `CartPanel`) into `lib/features/sale/presentation/widgets/`; helper functions → static methods (`DiscountDialog.showItemDiscount`, `DraftsBottomSheet.show`, `SaleReceiptDialog.show`).
- **Product page** — Extracted 7 widgets (`ProductAvatar`, `StockBadge`, `ProductTile`, `ProductGridCard`, `ProductTextField`, `ProductFormAvatar`, `ProductSectionLabel`) into `lib/features/product/presentation/widgets/`.
- **Settings page** — Extracted 7 widgets (`SettingsSectionHeader`, `SettingsTextField`, `LanguageTile`, `ThemeTile`, `CurrencyTile`, `DateFormatTile`, `ResponsiveSettingsPicker`) into `lib/features/settings/presentation/widgets/`.
- **Payment sheet** — Extracted 2 widgets (`ChangePreview`, `PaymentTotalRow`) into `lib/features/sale/presentation/widgets/payment_widgets.dart`.
- **History page** — Extracted 2 widgets (`SaleExpansionTile`, `VoidSaleDialog`) into `lib/features/history/presentation/widgets/`; `_showVoidDialog` → `VoidSaleDialog.show()`.
- **Report page** — Extracted `SummaryCard` into `lib/features/report/presentation/widgets/`.

`flutter analyze` → **0 issues** · `flutter test` → **208/208 passing**

---

## [0.5.1] - 2026-05-29

Theme accessibility, overlay toast, UX fixes, and DI compile-time safety.

### Highlights

- **Theme accessibility** — Explicit ColorScheme overrides, visible borders on all components, higher contrast for elderly readability.
- **Overlay-based toast** — `AppSnackBar` migrated from `ScaffoldMessenger` to `Overlay` with reliable auto-dismiss.
- **Cart undo** — Clear-cart and item-removal show undo toast via `SaleCartRestored` event.
- **Category filter sync** — `categoryFilter` moved into `ProductState`; shared across Sale and Product pages.
- **History void via BLoC** — Void routes through `HistoryBloc` with loading/success/failure states.
- **Injectable DI** — `get_it` registrations replaced by `injectable` annotations + code generation.
- **Lazy-loaded tabs** — Only active tab is built; visited tabs kept alive.

### Added

- **BLoC events** — `SaleCartRestored`, `ProductCategoryFilterChanged`, `SaleVoidRequested`; `HistoryStatus.voiding`.
- **`AppSnackBar.withAction`** — Overlay-based undo toast with action button.
- **Payment sheet close button** — Visible `✕` for non-technical staff.
- **8 l10n strings** (EN + TH) — Cart, view-mode, payment, discount labels.
- **Theme colors** — All ColorScheme properties explicitly defined for both light and dark themes; borders added to Card, Button, Chip, Input, Cart panel, SearchBar.

### Changed

- **Toast system** — `AppSnackBar` → `Overlay`-based; `OverlayToast` merged and removed.
- **Light theme** — Softer surfaces, darker borders/dividers, all ColorScheme properties overridden.
- **Dark theme** — All ColorScheme properties overridden; no more overly bright greens.
- **Component borders** — Card, ElevatedButton, FilledButton, Chip, Cart panel, Input all have visible outlines.
- **Hardcoded colors removed** — Feature pages now use `colorScheme` instead of `Colors.*`.
- **Cart panel** — Responsive height (120 empty / 200–360 with items); border added.
- **Qty=1** — Minus button becomes delete icon; removal shows undo toast.
- **Discount preview** — Shows `15%` for PERCENT type instead of `฿15.00`.
- **Confirm payment** — Shows amount: "Confirm ฿150.00".
- **Report date range** — `ActionChip` → prominent `Card` with edit icon.
- **VAT rate field** — Persistent `TextEditingController`; saves correctly.
- **DI** — `initDependencies()` → `configureDependencies()` with `@injectable` annotations.
- **Tab navigation** — Eager `IndexedStack` → lazy `_pageBuilders` + `_cachedPages`.

### Fixed

- **SnackBar persistence** — Stayed on screen indefinitely; fixed by Overlay migration.
- **SnackBar not showing** — After `hideCurrentSnackBar()`; fixed by eliminating `ScaffoldMessenger`.
- **Sale search not filtering** — Used `state.products` instead of `state.filtered`.
- **Light theme `onPrimary`** — Icon on green buttons was dark; fixed by explicit `onPrimary`.
- **Dark theme bright greens** — `ColorScheme.fromSeed` auto-gen; fixed by overriding all properties.
- **Invisible component boundaries** — No borders; fixed by adding `side: BorderSide(...)`.

`flutter analyze` → **0 issues** · `flutter test` → **208/208 passing**

---

## [0.5.0] - 2026-05-28

Draft cart persistence, discount system, and stock policy for real-shop workflow.

### Highlights

- **Draft cart persistence** — Cart auto-saves every 500 ms. Up to 10 simultaneous drafts (switch customers/tables, rename, delete). Active draft restores on app launch; cleared on checkout.
- **Discount system** — Per-item discount (% or ฿) and per-cart discount. Payment sheet shows full breakdown: Subtotal → discounts → Total. VAT applied after discounts.
- **Stock policy** — Per-product `trackStock` toggle (service items show ∞, no stock deduction). `allowOversell` setting permits selling beyond available stock.
- **Low stock indicator** — Product card stock label turns red when stock ≤ configurable threshold.

### Added

- **Draft cart** — Bookmarks icon in Sale AppBar opens draft sheet; list, switch, rename, delete drafts; new-draft button; cap enforced at 10.
- **Per-item discount** — Tag icon in cart row → dialog (% / ฿, live preview, apply / clear); discount badge shown on item.
- **Cart-level discount** — "Apply cart discount" button below subtotal; discount line in cart summary.
- **Payment sheet breakdown** — Subtotal / item discounts / cart discount / TOTAL when any discount is active.
- **`trackStock` per-product** — Switch in product form; `∞` stock display and no DB deduction when off.
- **Stock Policy settings section** — Allow oversell toggle + Low stock threshold input.
- **30 new localization keys** (EN + TH) — Stock policy, discount dialog, draft cart labels.

### Changed

- **VAT calculation** — Now calculated on pre-discount total (`preTaxTotal`) in sale datasource.
- **`DailyCloses` `@Deprecated` removed** — Table stays in schema v2 for upcoming R5 Daily Close UI.

### Fixed

- **Non-tracked products removed from cart** — Products with `trackStock=false` (stock = 0) no longer removed from cart on product refresh.
- **Qty clamp for non-tracked products** — Skipped for non-tracked products (no artificial stock ceiling).

`flutter analyze` → **0 issues** · `flutter test` → **208/208 passing**

---

[0.5.4]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.4.0...v0.5.0
