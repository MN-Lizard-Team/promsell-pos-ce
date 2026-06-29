# Changelog

All notable changes to **Promsell POS Community Edition** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.8.8] - 2026-06-29

Sale page redesign + cart UI overhaul + barcode scanner upgrade + product form hardening + filter/payment/cart fixes + product preview enrichment.

### Highlights

- **Sale Page Redesign** — `SaleDashboardHeader` (compact `FittedBox` row); `SaleFilterBar` with 3 dropdown filters (Category/Sort/Stock); `SaleProductCard` delivery-style with `ProductCardShell` (grid: full-width images, list: 72×72 rounded-rect); `StockIndicator` + price pills; search moved to AppBar toggle; list/grid `SegmentedButton`.
- **Cart UI Overhaul** — `CartContent` unified widget (expanded + sheet modes); delivery-style `CartBottomBar` (badge bounce, pull-up gesture, velocity snap); compact `CartItemTile` (~48px, 3-column); item note/SKU/stock in tiles; clear cart buttons; cart state persistence via `DraftBloc`.
- **Barcode Scanner Upgrade** — Continuous scan (default ON); product name + price overlay; responsive cutout; camera focus button; scan count indicator; portrait lock; alphanumeric validation; `SoundPlayer` confirmation.
- **Product Form Hardening** — Barcode → Basic section; `_AdvancedSection` auto-expand; `TextEditingController` disposal fix (11 dialogs → `StatefulWidget`); image/barcode orphan prevention (Bugs A–D); stale stock + double-submit fixes.
- **Filter/Payment/Cart Fixes** — `_CategorySelector` + reactive count + price validation; removed duplicate note/PromptPay reference; cash input `onChanged` fix; localized `cartEmpty`/`saleTimeout`; cart review empty state + `Material` bottom card; `CartProductDetailSheet` with qty/subtotal/discount/note/stock status.

### Added

- `CartContent`, `CartBottomBar`, `cart_checkout_helper.dart`, `_CategorySelector`, `_StockStatusRow`, `MoneyDetailRow`, `_DashedBorder` widgets.
- `CartItem.note` + `CartItemNoteChanged` event (schema v19); SKU/barcode + stock remaining + duplicate item in `CartItemTile`.
- Continuous scan mode, product name overlay, camera focus, scan count, `continuousScan` setting.
- `barcodeExistsAnyStatus` + `bulkUpdateBarcodesWithImages` in `ProductLocalDatasource`.
- Badge animations, haptic feedback, velocity snap, clear cart buttons, cart state persistence.
- L10n: `cartEmpty`, `saleTimeout`, `totalDiscountLabel`, `trackStockDisableConfirm`, `costHelper`, `barcodeMustBeAlphanumeric` (EN + TH).

### Changed

- `SaleProductCard` — `ProductCardShell` flat design; grid `FixedCrossAxisCount(3)`; avatar 52→40px; quantity as `จำนวน N` text.
- `PillButton` expands to fill space; `SaleCatalog` list height 76→88; `SegmentedButton` height matched.
- `CartReviewPage` — `Card` → `Material` + `boxShadow`; `CartItemCard` price `Expanded(flex: 0)`; localized strings.
- `CartProductDetailSheet` — localized + currency from `SettingsCubit`; shows qty, subtotal, discount, note, stock status.
- `CheckoutBody` — removed duplicate note; `PaymentInputSection` — removed duplicate PromptPay reference; timeout uses `saleTimeout`.
- `CartItemTile` compacted ~48px; `CartSummaryFooter` simplified; `cartCompactMode` default `true`.
- Barcode scanner: responsive cutout, portrait lock, auto-focus, laser pause on error, success 600→1000ms.
- Product form: barcode → Basic; `_AdvancedSection` auto-expand; `saveStatus` single source of truth; `_resolveStock` from bloc state.

### Fixed

- Stock filter toggle reset-to-`all` on reselect in `ProductBloc`.
- Cash input `onChanged` not updating change preview.
- `'Cart is empty'` → `cartEmpty` l10n key; `'Remove item'` → `removeItem` l10n.
- `TextEditingController` used after disposed (11 dialogs).
- Scanner orientation, invalid barcodes, `GenerateBarcode` counter init, `beepOnScan` sound, barcode case mismatch.
- Image/barcode orphan on fail (Bugs A–D); stale stock; double submit; no confirm on disable stock tracking.
- `CartBottomBar` RenderFlex overflow; `CartBottomSheet` checkout context; AppBar `endDrawer` → `CartBottomSheet`; 3 cart modes merged; `SaleCatalog` padding; `Dismissible`+`ReorderableListView` conflict; dead `onCheckout` param.

### Removed

- `sale_catalog_search_bar.dart`, `sale_catalog_category_filter.dart`, `sale_category_bar.dart`.

`flutter analyze` → **0 issues** · `flutter test` → **1302 passing**

---

## [0.8.7] - 2026-06-26

Product form unification + draft system hardening + product list dashboard redesign + tile performance optimization.

### Highlights

- **Product Form Unification** — Merged `AddProductPage` + `ProductFormPage` into single Hybrid Collapsible form; `ProductFormCubit` with typed `ProductDraft` persistence replaces raw `Map` drafts; `ExpansionTile` for advanced fields; `_VisibilitySection` card for show/hide toggle.
- **Draft System Hardening** — `Completer<void>` sync for load-before-check race; `clearDraft` resets both state + storage; restore cancels debounce (no empty re-save); empty drafts skipped on auto-save.
- **Product List Dashboard** — `StatsDashboard` redesigned with hero gradient card (total products + inventory value) and 3 mini stat cards; view toggle moved to separate row with filtered count label.
- **Tile Performance** — `BlocBuilder<CategoryBloc>` → `BlocSelector` in tiles (only changed-category tiles rebuild); `product_navigation.dart` shared helpers eliminate duplicate `_showEdit`/`_showPreview`/`_confirmDelete` across 3 files.
- **Grid Mode Parity** — `Dismissible` swipe-to-delete added to `ModernProductGridCard`; `ProductCardShell` refactored from `Card(elevation: 2)` to flat `Container` + `BoxDecoration`; `childAspectRatio` 0.75 → 0.80.

### Added

- `ProductFormCubit`, `ProductDraft`, `ProductFormState`, `ProductFormView` — typed draft system with `toJson`/`fromJson`, Equatable state, single-scroll form.
- `product_navigation.dart` — shared `showProductEditPage`, `showProductPreviewPage`, `confirmDeleteProduct`, `DeleteBackground`.
- `UnsavedDialogAction` enum; `_VisibilitySection` widget.
- L10n: `productVisibility`, `tapToAddImage`, `inventoryValue`, `totalProducts` (en + th).
- Tests: `ProductFormCubit` (8), `CategoryField` (5), `Product.copyWith` cost sentinel (3), `ProductFormPage` (5), `ProductCardShell` updated, `ProductHeroImage` updated.

### Changed

- Pinned Flutter to `3.41.4` in CI workflows.
- All add-product entry points navigate to `ProductFormPage()` instead of deleted `AddProductPage`.
- Draft key bumped `product_add_draft_v2` → `product_form_draft_v3`.
- `ProductPreviewPage._showEdit` uses shared `showProductEditPage` helper.
- `ScaffoldMessenger.showSnackBar` → `AppSnackBar.info/success/error` in `ProductPreviewPage` (5 calls).
- `_currentProduct` updates via `BlocListener` only (removed `build()` mutation).
- `StatsDashboard` receives pre-computed counts from parent (no per-build recalculation).
- `ProductCardShell` — `Card` → `Container` + `Material` + `InkWell`; `isActive` opacity handled internally.

### Fixed

- Draft data loss (`syncDraftFromControllers` sends actual form state, not `null`).
- `isClosed` guard prevents `emit` after cubit disposal.
- Cost field clearing via `Product.copyWith` sentinel pattern.
- Image URL cleared when picking new local image.
- Category race condition fallback to `widget.product!.categoryId`.
- Stale product data in `_submit` (reads latest from `ProductBloc.state`).
- Unsaved changes dialog now includes Save option.
- Stock sync on trackStock toggle restores original stock.
- Expansion state persists across rebuilds (`_AdvancedSection` as `StatefulWidget`).
- FAB moves to top-right when image present.

### Removed

- `AddProductPage`, `BasicTabView`, `AdvancedTabView`, `AddProductDraftHandler`, `ImageSourceHandler`, `AddProductDraftCubit`.
- `ProductEditTabView`, `ProductInfoTab`, `ProductPricingTab`, `ProductStockTab`, `ProductSettingsTab`.
- `category_field.dart` moved from `product_edit_tab_view/` to `product_form/`.

`flutter analyze` → **0 issues** · `flutter test` → **1294 product tests passing**

---

## [0.8.6] - 2026-06-25

NavBar overhaul + Product Preview redesign + persistent barcode images + theme polish across light/dark modes.

### Highlights

- **NavBar Overhaul** — Renamed `AnimatedNavBar` → `AppBottomNavigationBar`; long-press actions (Sale → New Draft, Product → Add Product); swipe logic extracted to `NavSwipeHelper`; `AnimatedBuilder` scoped to bouncing tab only (~96 fewer rebuilds/cycle); Semantics for VoiceOver/TalkBack; 34 new tests.
- **Product Preview Redesign** — `SliverAppBar` with collapsing hero, `ProductPreviewImage` widget (shimmer skeleton, retry, tap-to-zoom hint), `PreviewOverlay` with gradient + `StatusChip`, `StickyActionBar` with Delete + Quick Edit, per-product barcode image persistence.
- **Barcode Images** — `BarcodeImageService` renders via `RenderRepaintBoundary` (600×200, pixelRatio 3.0); persistent `barcodeImagePath` column; save as PNG/JPEG/PDF; copy SKU/barcode; generate from preview.
- **QuickEdit Upgrade** — Real-time validation, Save disabled when invalid/unchanged, stock Set/Adjust dual-mode with live preview, SnackBar feedback for all actions, 9 new l10n keys.
- **Theme Polish** — Light theme: secondary → slate gray `#475569`, fixed token collisions, WCAG AA contrast; dark mode: surfaceContainer tokens, theme-aware scrim/alpha; system-wide `colorScheme.secondary` replaces `onSurface.withValues(alpha:)` (33 widgets).
- **Category Management** — `category_icon_data.dart` single source of truth; app bars moved to `widgets/category/`; real-time search; Semantics; 13 new tests.

### Added

- `AppBottomNavigationBar`: long-press → New Draft / Add Product; `Semantics(button, label, selected)` per tab.
- `NavSwipeHelper.handleSwipe()` — shared swipe logic for shell + nav bar.
- `ProductPreviewImage` widget: shimmer skeleton (200ms delay), error + retry, tap-to-zoom hint (once per session), `hasImage(Product)` static method, full-resolution (no `ResizeImage`).
- `PreviewOverlay`: gradient + `StatusChip`; no-image mode uses `black 0.45` gradient.
- `StickyActionBar`: Delete (confirm dialog) + Quick Edit Price actions.
- `BarcodeImageService.generate()`: `BarcodeWidget` off-screen render, PNG/JPEG/PDF export via share sheet.
- `Product.barcodeImagePath` + `barcodeImagePath` DB column; auto-generated on add/update.
- `CodesCard`: copy icon for SKU + barcode; "Generate barcode" button when no barcode exists.
- `ProductInfoTab`: `isGeneratingBarcode` loading state on Generate Barcode button (prevents double-tap).
- `category_icon_data.dart`: single source of truth for `categoryIconMap` + `parseCategoryIcon()`.
- `CategorySearchAppBar` / `CategoryBulkAppBar` (renamed from `CategoryManagement*`).
- L10n: `inStock`, `codesCardTitle`, `barcodeGenerationError`, `productNameTooLong`, `quickEditStock*`, `quickEditName/Price Saved/Cancelled/Invalid` (EN/TH).
- **Tests**: 23 NavBar + 11 regression + 28 `ProductPreviewImage` + 18 Preview UX + 13 Category + 8 Preview regression = **101 new tests**.

### Changed

- `Ean13Generator` → `@injectable` instance (was static); counter per-instance, eliminating cross-test contamination.
- `BarcodeImageService`: size 400×160 → 600×200, `pixelRatio: 3.0`; `BarcodeImageWidget` height 80 → 120px.
- `ProductBloc` error events emit l10n keys instead of raw `e.toString()`.
- `ModernProductTile`: `ProductDeleted` dispatched in `confirmDismiss` (returns `false` to prevent actual dismiss) — fixes "Dismissible still in tree" error.
- `ProductPreviewPage`: `StatelessWidget` → `StatefulWidget` with `BlocListener`; stale product reads via `_latestProduct()`.
- `SliverAppBar`: title/icons use `Color.lerp(onSurface, white, _expandRatio)` for smooth scroll transition.
- `QuickEditSheet`: validation + Save disable; stock Set/Adjust modes; `easeOutCubic` 300ms; haptic on Save.
- Dropdowns: `DropdownButton` for ≤3 options, `SettingsDropdownTile` for ≥4; haptic on all `onChanged`.
- `CategoryPickerBottomSheet` + `SettingsDropdownTile`: `elevation: 0`, `borderRadius: 28`, `enableDrag: true`.
- Light theme: `primary` `#0E7C8A` → `#0D5D6B` (WCAG AA), `secondary` → slate gray `#475569`, token collisions fixed, `inputFillColor` → `surface`.
- Dark theme: `secondary` → `#94A3B8`, `surfaceContainerLow/Medium/High` tokens added, scrim alpha 0.6 (was uncapped).
- `PreviewCard` bg → `surface`; `PriceCard` selling price box → `surface` with border; profit % → `AppColors.success`.
- 33 widgets: `onSurfaceVariant`/`onSurface.withValues(alpha:)` → `colorScheme.secondary`.

### Removed

- `hero_section.dart` + test file — replaced by `ProductPreviewImage`.
- `product_image_container.dart` — dead code, removed with its test group.
- `ProductPreviewImage.heroTag` — Hero animation was one-sided; parameter removed.
- `imageThumbnailPath` usage in preview — full image loaded directly.

### Fixed

- `_animatingIndex` not reset after bounce animation; missing `setState` in `didUpdateWidget`.
- Category Management: unnecessary `ProductBloc` rebuilds; bulk delete concurrent modification; dialog `context` use-after-dispose.
- `ProductPreviewImage`: `FlexibleSpaceBar` uses `CollapseMode.pin`; `SizedBox.expand` + `ClipRect` fills background; no-image gradient `black 0.45`.
- `Navigator.of(context, rootNavigator: true).push()` — prevents double bottom bar on preview.
- `extendBodyBehindAppBar: true` — fixes status bar bleed on preview page.
- `GenerateBarcode`: counter persisted after every retry exit (including failure).
- `BatchGenerateBarcodes`: `initCounter()` called at start to prevent drift.
- `ProductFormPage._generateBarcode()`: passes `excludeId` to prevent self-collision.
- Light theme: divider `#CBD5E1`, text contrast (`textSecondary` `#475569`, `onSurfaceVariant` `#334155`), SnackBar bg → `inverseSurface`.

`flutter analyze` → **0 issues** · `flutter test` → **1259 passing** · coverage **54.5%** (21,562 lines)

---

## [0.8.5] - 2026-06-24
 
Project quality improvements: CHANGELOG archive, generated code gitignore, dependency vulnerability scanning, and god file decomposition round 2.
 
### Highlights
 
- **CHANGELOG archive** — Versions 0.1.0–0.7.x moved to `docs/changelog/` archive files. Main `CHANGELOG.md` reduced from 1,618 → ~300 lines.
- **Generated code untracked** — `*.g.dart` and `*.config.dart` removed from git and added to `.gitignore`; `.gitattributes` marks them `linguist-generated`.
- **Dependency vulnerability scan** — CI runs `tool/check_outdated.dart` to flag direct deps behind by ≥ 1 major version. Dependabot updated; security alerts documented in `docs/DEPLOY.md`.
- **God file decomposition (Round 2)** — 20+ large widget/page files split into modular subfolders across sale, product, settings, and core widgets (Batches E–I). ADR-024 domain subfolder convention applied to all 8 feature `widgets/` directories and `lib/core/widgets/`; 71 feature files + 27 core files moved, ~134 import paths updated.
- **Documentation split** — `ARCHITECTURE.md`, `CODEBASE.md`, `DATABASE.md`, `USAGE.md`, and `README.md` each split into slim index + `docs/` sub-files.
### Added
 
- `docs/changelog/` — 7 archive files (`CHANGELOG-01x.md` through `CHANGELOG-07x.md`).
- `tool/check_outdated.dart` — exits with error if any direct dependency is behind by ≥ 1 major version.
- `.gitattributes` — `linguist-generated=true` for `*.g.dart` and `*.config.dart`.
- `.github/dependabot.yml` — `allow: dependency-type: "all"` for security + version updates.
### Changed
 
- **God file decomposition (Round 2, Batches E–I)** — `barcode_scanner_dialog`, `image_viewer_dialog`, `receipt_preview`, `cart_item_row`, `cart_header`, `sale_catalog`, `sale_expansion_tile`, `backup_settings_page`, `animated_nav_bar`, and others split into subfolder patterns. All verified `flutter analyze` 0 issues + 436 tests.
- **Earlier god files** — `cart_bottom_sheet` (667→~120), `promptpay_payment_page` (793→~410), `product_preview_page` (1,051→106), `barcode_settings_page` (748→~110), `checkout_body` (767→~391), `sale_page` (432→~230), and 10+ settings/product pages decomposed into domain subfolders.
- **ADR-024 widget folder standardization** — All feature and core `widgets/` directories reorganized into domain subfolders (`cart/`, `checkout/`, `catalog/`, `forms/`, `tiles/`, etc.). 71 feature files + 27 core files moved, test subfolder structure aligned.
- **Documentation** — `ARCHITECTURE.md`, `CODEBASE.md`, `DATABASE.md`, `USAGE.md`, `README.md` each split into slim index + sub-files under `docs/`.
- `.gitignore` / CI — `*.g.dart` and `*.config.dart` patterns added; "Dependency audit" step added to CI.
### Removed
 
- `lib/core/database/app_database.g.dart` and `lib/core/di/injection_container.config.dart` — removed from git tracking (now gitignored).
### Fixed
 
- **P0: CategoryBloc race condition** — `_startWatching()` moved after all `on<>` handler registrations to prevent dropped events.
- **P0: ReportCubit / InventoryLogCubit emit after close** — `isClosed` guard added before `emit()` in stream callbacks.
- **P1: TextEditingController leaks** — `ctrl.dispose()` added after `showDialog()` in 12 dialog methods across settings, sale, and product widgets.
- **P1: InventoryLogCubit DI scope** — Changed `@injectable` → `@lazySingleton`.
- **P2: Hardcoded English strings** — `'Save'`, `'Cancel'`, `'OK'`, `'Close'`, etc. replaced with `context.l10n.*`; 5 new l10n keys added (TH/EN).
- **P2: HistoryBloc missing DI annotation** — Added `@lazySingleton`.
- **P2: SettingsPersistenceService uncaught exception** — `_repository.save()` wrapped in try-catch with `AppLogger.error()`.
- **P2: ImagePermissionException** — Typed `ImagePermissionException` replaces fragile `e.toString().contains('PERMISSION_DENIED_*')` matching.
- **P3: Silent catch blocks + raw errors to UI** — `catch (_) {}` replaced with `AppLogger.warning()`; raw `e.toString()` errors replaced with l10n keys in `CartBloc`/`CheckoutBloc`.

`flutter analyze` → **0 issues** · `flutter test` → **1121 passing**
 
---

## [0.8.4] - 2026-06-23

Brand theme migration (Teal + Orange) + Product Preview Page — Promsell Teal (#0E7C8A) and Orange (#FF6B00) replacing green/amber across FAB, FilledButton, Chip, Progress, Switch, and SnackBar action.

### Highlights

- **Product Preview Page** — New read-only `ProductPreviewPage` with hero image + gradient overlay, price/cost/profit card, stock card with inline edit, SKU/barcode card with visual rendering (EAN13/EAN8/UPCA/Code128) and actions (view full, save PDF, print), and system info card.
- **Barcode Widget** — Added `barcode_widget` package dependency for barcode rendering on the preview page.
- **Navigation Update** — `ModernProductTile` + `ModernProductGridCard`: tap → Preview, long-press → Edit Form.
- **AppBadge + SnackBar Variants** — New `AppBadge` widget with 4 types (success/info/warning/error); `AppSnackBar` 4 variants with icons and brand colors.
- **7 New Theme Definitions** — dialog, bottomSheet, floatingActionButton, tabBar, progressIndicator, listTile, popupMenu; TextTheme now has explicit color, line-height, and letter-spacing across all 13 styles.
- **Brand Identity** — Primary changed from Green (#2E7D32) → Promsell Teal (#0E7C8A); accent from Amber → Promsell Orange (#FF6B00); `tertiary` = Orange in ColorScheme, auto-propagates to stock indicators, badges, and report cards.

### Changed

- `AppColors` — 25 color values updated (light/dark/semantic); added onTertiary, onTertiaryContainer, accentShadow, overlay constants, and skeleton colors.
- `app_theme.dart` — ColorScheme tertiary=Orange; AppBar white + Teal border 1.5px; FilledButton → Orange CTA; NavBar active pill → Teal tint; Chip selected → Orange; 11 new theme definitions for dark mode.
- `SettingsThemeExtension` — Added `activeAccent` + `activeAccentContainer` (Orange); 10 color values updated (light/dark).
- 9 settings widgets — `softAccent`/`softAccentContainer` → `activeAccent`/`activeAccentContainer` in selected/active states.
- `GreenChoiceChip` → `BrandChoiceChip`; `accentGreen` → `accentBrand` (16 references in onboarding).
- `animated_nav_bar.dart` — Active tab changed from Orange dot to `primaryContainer` (Teal tint) pill.
- `product_list_page.dart` — Search moved into AppBar; category filter → `ChoiceChip` + ShaderMask fade; body → `CustomScrollView` with slivers.
- `modern_product_tile.dart` + `modern_product_grid_card.dart` — Full redesign with avatar-first layout and category dot/label widgets.
- Replaced ~34 hardcoded `Colors.green/amber/orange/black/white` references with `AppColors` equivalents.

### Fixed

- Dark mode text invisible — root cause: shared `_textTheme` (light colors) used in dark `ThemeData`; fixed by creating separate `_darkTextTheme` with white/Slate-400 colors.
- Switch thumb inconsistency — 5 widgets had `activeThumbColor` overrides conflicting with theme track color; fixed by removing overrides and using SwitchThemeData defaults.

`flutter analyze` → **0 issues** · `flutter test` → **438 passing**

---

## [0.8.3] - 2026-06-23

CI/CD coverage gates, schema v17 barcode dedup migration, persistent crash logging, dev/prod flavor separation, barcode scanner hardening, and product/category UX fixes.

### Highlights

- **CI/CD** — Coverage threshold gate (≥30%), Codecov upload, weekly stress test workflow.
- **Database** — Schema v17 with automatic barcode deduplication migration.
- **Crash Logging** — Persistent local crash log with PII sanitization and export/clear UI.
- **Flavors** — `dev`/`prod` environment separation with Android product flavors.
- **Product UX** — AddProductPage, ProductFormPage, and CategoryManagement fixes (validators, cost field, nested Scaffold, delete confirmations, bulk delete, reorder bug).
- **Barcode Scanner** — Camera freeze fix, torch toggle, scan from gallery, manual entry improvements.

### Added

- GitHub Actions CI badge, Codecov badge, coverage threshold (≥30%), weekly stress test workflow.
- `CrashLogService` — persistent local crash logging with PII sanitization, export, and clear UI.
- `dev`/`prod` product flavors with separate entry points (`main_dev.dart`, `main_prod.dart`).
- Integration test screenshot capture + optional screenshots CI workflow.
- Barcode deduplication migration (schema v17).
- `ProductFormPage` cost field, barcode validator, generate barcode button, `PopScope` back guard.
- `AddProductPage` cost/barcode validators, `TextInputAction.done`, stock hidden when `trackStock=false`, 2-column advanced tab.
- `CategoryManagementPage` bulk delete confirmation, `CategoryFormDialog` sortOrder removed.
- `QuickEditMixin` — shared quick-edit logic for `ModernProductTile` and `ModernProductGridCard`.
- `BarcodeScannerDialog` torch toggle, scan from gallery, scan success animation, error repositioning.
- L10n: `invalidBarcode`, `stockTrackingDisabled`, `unsavedChangesTitle`, `deleteCategory`, `confirmDeleteCategory`, `bulkDeleteConfirm`, `activate`, `deactivate`.

### Changed

- `_addColumnIfNotExists` refactored to use `PRAGMA table_info` for cross-platform reliability.
- Schema version bumped v16 → v17.
- `BackupEncryptionService` moved to `lib/features/settings/data/services/`.
- `main.dart` extracted to `runPromsellApp()` for flavor entry points.
- CI/DEPLOY/README updated with flavor commands.
- `CartBloc`, `DraftBloc`, `CheckoutBloc` changed from `@injectable` to `@lazySingleton`.
- `SalePage` simplified to flat `BlocProvider.value` (removed nested `Builder`).
- `CartHeader` ultraCompact toggle merged into PopupMenu.
- `PromptPayPaymentPage` auto-confirm snackbar localized, `resizeToAvoidBottomInset: true`.
- `CheckoutBody` `listenWhen` checks `prev.status != curr.status`, `context.read` instead of `watch`, BlocListener moved to parent of BlocBuilder.
- `ProductEditTabView` inner Scaffold removed; AppBar+TabBar moved to outer `ProductFormPage`.
- `CategoryListTile` always shows product count (including 0).

### Fixed

- **CheckoutBloc shared instances (critical)** — `@injectable` factory created separate BLoC instances, causing silent checkout failure; now `@lazySingleton`.
- **SettingsPersistenceService.dispose()** — Final save was blocked by `_isDisposed` guard.
- **CrashLogService** — StackTrace now written to log entries; PromptPay PII pattern requires context prefix.
- **ShopInfoForm / CartHeader / CartItemRow / SaleProductCard** — `TextEditingController` leak in dialogs fixed.
- **DraftBloc._onRotated** — Unhandled exceptions now caught.
- **CartBottomSheet** — Checkout from compact mode no longer crashes.
- **SaleReceiptDialog** — `barrierDismissible: false` + `CartPanel` resets CheckoutBloc via `.then()`.
- **SaleCatalog** — Search result tap now adds product to cart (was no-op).
- **CompactCartFab** — Watches `SettingsCubit` for currency, long-press confirmation before exiting compact mode.
- **SaleProductCard** — Low-stock indicator uses `tertiary` color, snackbar dedup on rapid taps.
- **PromptPayPaymentPage** — No longer pops itself; CheckoutBody is single source of truth for navigation.
- **CartPanel** — `_isShowingReceipt` flag prevents duplicate receipt dialog.
- **CheckoutBody** — Processing timeout (30s), confirm button disables on tap + empty cart, receipt preview uses VAT-inclusive total, reference field clears on payment method switch, removed duplicate insufficient-cash text.
- **FAB Hero tag collision** — All FABs now have unique `heroTag` values.
- **ProductLocalDatasource** — `getProductByBarcode` no longer throws on duplicates, filters `isActive=true`.
- **CartState** — `errorNonce` field ensures repeated identical errors still fire snackbar.
- **CartBloc** — `errorMessage` cleared on `CartProductRemoved`/`CartItemQtyChanged`.
- **BarcodeScannerDialog** — Camera freeze on second scan fixed, manual entry keyboard `visiblePassword`, torch toggle, scan from gallery, scan success animation, error text repositioned, bottom panel opacity 1.0.
- **ProductImageService** — Permission requests before `ImagePicker.pickImage` with specific error messages.
- **ProductListPage** — Search result tap opens `ProductFormPage`, respects grid view mode.
- **ProductActionSheet** — Activate/deactivate labels localized.
- **ProductFormPage** — Delete dialog uses `confirmDeleteProduct(name)`, waits for BLoC before popping, `PopScope` back guard, `resizeToAvoidBottomInset` fixed, nested Scaffold removed, cost field added, barcode validator, price validator `<= 0` → `< 0`, stock hidden when `trackStock=false`, `_markDirty` moved to image success path, generate barcode button, unsaved dialog title fixed.
- **AddProductPage** — Draft restore price type cast crash fixed, draft restore price display fixed, cost/barcode validators, `TextInputAction.done`, stock hidden when `trackStock=false`, 2-column advanced tab, `CategoryBloc` crash fixed.
- **CategoryManagementPage** — Delete dialog shows category name, bulk delete confirmation, reorder merges filtered subset into full list, search hint fixed.
- **CategoryFormDialog** — sortOrder field removed (drag-to-reorder manages order).
- **QuickEditMixin** — Extracted shared quick-edit logic, eliminates ~60 lines duplication.

`flutter analyze` → **0 issues** · `flutter test` → **438 passing**

---

## [0.8.2] - 2026-06-22

SaleBloc decomposition into focused BLoCs (CartBloc, DraftBloc, CheckoutBloc), critical checkout/draft bug-hunt fixes, and barcode/receipt image fixes.

### Highlights

- **SaleBloc Decomposition** — Split into `CartBloc`, `DraftBloc`, and `CheckoutBloc`; 17 widgets/pages, DI, and test infrastructure migrated.
- **Checkout Stuck After Receipt (critical)** — `CheckoutReset` now dispatches correctly after print/share/close; cart no longer stuck in `success` state.
- **Draft Auto-Save Data Loss (high)** — Pending cart state is now actually flushed on switch/create/delete instead of being discarded.
- **Scanner Black Screen on Android 6+ (critical)** — Runtime camera permission now requested before scanning.
- **Receipt Images Missing** — Product images now embedded in receipt preview, PDF, print, and share.
- 37 new BLoC tests + 8 barcode/receipt tests added.

### Added

- `MockCartBloc`, `MockCheckoutBloc`, `MockDraftBloc`, and `pumpApp` test helper.
- `permission_handler` package for camera permission requests.
- L10n strings: `cameraPermissionDenied`, `openSettings` (TH/EN).

### Changed

- `SaleBloc` split into `CartBloc` (cart), `DraftBloc` (draft persistence), and `CheckoutBloc` (checkout/payment).
- Obsolete `sale_bloc_test.dart`, `sale_bloc_discount_test.dart`, `sale_bloc_barcode_test.dart` removed.
- `ReceiptPdfService.printReceipt`/`shareReceipt` now accept an optional `productImages` map.
- `SaleReceiptDialog.show()` is now async and fetches product images before rendering.

### Fixed

- **Receipt dialog leaves checkout stuck (critical)** — `CheckoutBloc` reference was captured after `Navigator.pop`, so `CheckoutReset` never fired; now captured before pop in all 3 receipt actions.
- **Draft auto-save discarded on switch/delete (high)** — `_flushPendingSave` now saves the pending state instead of just cancelling the timer.
- **Cart stock=0 guard missing (high)** — Added `stock <= 0` check in `CartBloc._onProductAdded`, matching the barcode-scan path.
- **DraftBloc unhandled repository errors (medium)** — Added try-catch to switch/create/delete/rename handlers.
- **Deleted products silently dropped from cart (medium)** — Now surfaced in the `stockWarning` message instead of disappearing silently.
- **Scanner double-pop (critical)** — Dialog popped twice (via callback + directly), closing the page behind it; now pops once.
- **Batch barcode counter not persisted (high)** — Counter now persisted via `SettingsRepository` after batch generation.
- **Scanner black screen on Android 6+ (critical)** — Camera permission was never requested; added permission flow + denied-state UI.
- **Receipt preview/PDF/print/share missing product images (high)** — Image fields now passed through and embedded as 28×28 thumbnails.
- **CheckoutBody test crash** — `BlocBuilder` replaces `context.select` inside `Builder` to fix a Flutter framework assertion during tests.
- Multi-barcode frame could select a `null` barcode value; EAN-13 prefix accepted invalid input without validation.

`flutter analyze` → **0 issues** · `flutter test` → **425 passing**

---

## [0.8.1] - 2026-06-22

PromptPay static QR support, AppSettings facade removal, full barcode system overhaul, and category/settings UX fixes.

### Highlights

- **Barcode System Overhaul** — Reliable scan (first-detect lock pattern), all 12 formats supported, EAN-13 generator with collision check + persistent counter, format selector, auto-open manual entry, prefix validation.
- **Category System Fixes** — Removed double filtering, fixed reactive category lookup race, added "no category" option/filter, unified picker, consistent styling, batch reorder.
- **Settings UX Overhaul** — Flattened 3-level → 2-level hierarchy, merged discount pages, rebalanced groups (Barcode moved to General).
- **AppSettings Facade Removed** — ~30 files migrated to typed `Settings` aggregate ahead of Phase 4 multi-device sync.
- **Critical Sale/Product Fixes** — Cart items no longer silently dropped on stock=0 refresh; SaleCatalog no longer disappears on empty category/loading state; draft name race fixed.
- **About App Page** — Version info, in-app Privacy Policy, and License pages.
- Static PromptPay QR support (no amount embedded) for tip/top-up use cases.

### Added

- PromptPay QR unit tests (22 tests) — EMVCo payload, formatting, CRC16, static/dynamic modes.
- Stress test seeder tooling (`tool/seed_db.dart`) for production-scale data volumes.
- EAN-13 compliant barcode generator (Luhn check digit, GS1 prefix `"200"`).
- Barcode format selector, length validation, case normalization, auto-open manual entry timer, prefix input validation with live preview.
- Batch barcode generation for products missing barcodes.
- "No category" filter chip in Sale Catalog and Product List.
- About App, Privacy Policy, and License in-app pages.

### Changed

- `buildPromptPayQrPayload` — `amount` now nullable; `null` generates a static QR.
- `AppSettings` facade removed in favor of typed `Settings` aggregate (~30 files updated).
- "Play sound on scan" relabeled to "Vibrate on scan" to match actual behavior.
- `BarcodeConfig` expanded with `enabledFormats` and `autoOpenManualDelay`.
- `Product.category` named parameter removed; `categoryId` is now the sole source of truth.
- `CategoryFilterBar` now prefers DB-stored color/icon over name-based guessing.
- `CategoryRepository.reorderCategories` batched into a single transaction.

### Fixed

- **Scan never confirms (critical)** — Debounce restart bug replaced with first-detect lock pattern.
- **Error overlay stuck (critical)** — Error text now auto-clears after 3 seconds.
- **Barcode settings not persisting (critical)** — Mapper was missing barcode keys; settings reset every restart.
- **Cart items silently removed on stock refresh (critical)** — Items now kept with clamped qty + stock warning instead of being dropped.
- **Category lookup race (critical)** — Reactive `BlocListener` replaces one-shot lookup that could fall back to a fake "Uncategorized".
- **Prefix padding bug (critical)** — EAN-13 prefixes now zero-padded to 3 digits.
- **No barcode collision check** — Generation now checks the database and retries up to 10 times.
- **Barcode counter resets on restart** — Now persisted in Settings.
- **`add()` after `close()` crash (critical)** — Inlined cart update to avoid late event dispatch on bloc close.
- **SaleCatalog disappears on empty category / during batch loading (critical)** — Early-return and loading-state bugs removed.
- **Out-of-stock products hidden** — Now shown dimmed instead of filtered out.
- **Draft name race condition** — Switched to timestamp-based unique naming.
- **Double category filtering** — Removed redundant UI-level filter.
- **Cannot remove category from product** — `showNoneOption` now enabled.
- Camera lifecycle, manual entry validation, and `SliverFillRemaining` crash fixes for the barcode scanner UI.

`flutter analyze` → **0 issues** · `flutter test` → **405 passing**

## [0.8.0] - 2026-06-12

Full barcode system (scan, manual entry, generation, settings) + image UX cleanup and orphaned file fixes.

### Highlights

- **Barcode Scanning** — `BarcodeScannerDialog` supports EAN-13/8, UPC-A/E, Code 128/39, ITF. Sale page scan auto-adds to cart; product form scan auto-fills barcode field. Manual entry fallback for slow cameras.
- **Barcode Settings** — `BarcodeSettingsPage` with scan toggle, haptic feedback toggle, auto-generate prefix, and expandable help section for non-technical staff.
- **Duplicate Barcode Prevention** — Schema v16 `UNIQUE INDEX`; app-level `DuplicateBarcodeException` with localized error; case-insensitive lookup via `lower()`.
- **AddProductPage Redesign** — 2-tab layout (Basic + Advanced) with category bottom sheet, barcode scan/generate, SKU, cost, and draft save/restore.
- **Image System Fixes** — shared `showImageSourceSheet()`, temp file lifecycle tracking, draft path validation, error handling with feedback, remove confirmation, orphaned image cleanup in Settings.
- **Category Picker UX** — bottom sheet with auto-pop selection, "None" clear option, and no more separate Save tap.

### Added

- `BarcodeScannerDialog`, `ScanOverlayPainter`, `showProductBarcodeScanner()` helper.
- `DuplicateBarcodeException`, schema v16 migration (duplicate-safe index).
- `SaleBarcodeScanned` event + `SaleBloc._onBarcodeScanned` handler.
- `BarcodeConfig` entity + `BarcodeSettingsPage` (scan toggle, beep toggle, prefix input, help section).
- `showImageSourceSheet()` shared bottom-sheet helper + `ImageSourceAction` enum.
- `ClearOrphanedImages` usecase + cache clear button in `ImageSettingsPage`.
- `ProductLocalDatasource.getProductByBarcode()`, `ProductRepository.barcodeExists()`.
- `ProductTextField.suffix` parameter.
- `AddProductPage` 2-tab layout + `AddProductDraftCubit` (save/restore/discard).
- `CategoryPickerBottomSheet` with auto-pop and `showNoneOption`.
- L10n: barcode scan/generate/settings/help keys + image pick/remove/cache keys (TH/EN).

### Changed

- `AddProductPage` — single form → 2-tab (Basic/Advanced); category picker → bottom sheet.
- `SlipScannerDialog` — uses shared `ScanOverlayPainter`.
- `SaleBloc` — added `ProductRepository` dependency; `BlocListener` for error toasts.
- `AddProduct` / `UpdateProduct` — async with `barcodeExists()` pre-check + `Validators.barcode()`.
- `ProductFormPage` / `AddProductPage` — image source sheet uses shared helper with try/catch + feedback.
- `getProductByBarcode` — case-insensitive via `p.barcode.lower().equals(lowerBarcode)`.

### Fixed

- `BarcodeScannerDialog` unused `_showError` removed.
- `CategoryPickerPage` `ProviderNotFoundException` — wrapped with `Builder` for descendant context.
- `_lookupCategory` missing `setState` — category field showed wrong initial value.
- Quick Edit rejected price `0` — clamp changed to `price >= 0`.
- `_lookupCategory` swallowed errors — narrowed catch to `ProviderNotFoundException` + logging.
- `CategoryPickerPage` required double Save tap — auto-pop on selection.
- `CategoryPickerBottomSheet` layout crash — removed conflicting `mainAxisSize: min`.
- `Validators.barcode()` dead code — now called before duplicate check.
- Barcode lookup case-sensitive — explicit `lower()` match.
- Duplicate barcode scanner code — extracted `showProductBarcodeScanner()`.
- Image temp files orphaned — `_tempImagePaths` tracked and cleaned on dispose/discard.
- Image draft paths stale — `File.existsSync()` validation on restore.
- Image pick silent failures — try/catch + `AppSnackBar.error()`.
- Image remove no confirmation — added AlertDialog before clearing.

`flutter analyze` → **0 issues** · `flutter test` → **351 passing**

## Archive

Older versions are archived by minor version:

- [v0.7.x](docs/changelog/CHANGELOG-07x.md)
- [v0.6.x](docs/changelog/CHANGELOG-06x.md)
- [v0.5.x](docs/changelog/CHANGELOG-05x.md)
- [v0.4.x](docs/changelog/CHANGELOG-04x.md)
- [v0.3.x](docs/changelog/CHANGELOG-03x.md)
- [v0.2.x](docs/changelog/CHANGELOG-02x.md)
- [v0.1.x](docs/changelog/CHANGELOG-01x.md)

---

[0.8.8]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.7...v0.8.8
[0.8.7]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.6...v0.8.7
[0.8.6]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.5...v0.8.6
[0.8.5]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.4...v0.8.5
[0.8.4]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.3...v0.8.4
[0.8.3]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.2...v0.8.3
[0.8.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.1...v0.8.2
[0.8.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.6...v0.8.0