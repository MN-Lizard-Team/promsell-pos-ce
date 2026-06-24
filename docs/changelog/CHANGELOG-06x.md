# Changelog — v0.6.x — Promsell POS CE

> ดู [CHANGELOG.md](../../CHANGELOG.md) สำหรับเวอร์ชันล่าสุด (0.8.x)

---

## [0.6.3] - 2026-06-04

InventoryLog Clean Architecture, category autocomplete, history search, cart qty input, bug fixes, platform hardening, and store submission prep.

### Highlights

- **InventoryLog Clean Architecture** — Domain/data/presentation layer split; UI no longer imports Drift directly.
- **Category Autocomplete** — Product form suggests existing categories while preserving free-text entry.
- **History Search Bar** — Filter sale history by receipt number, payment method, or amount.
- **Cart Direct Qty Input** — Tap quantity in cart to open numeric input dialog with stock info.

### Added

- `InventoryLog` domain entity, repository, use case, cubit, and DI wiring (full Clean Architecture stack).
- `_CategoryAutocomplete` widget with case-insensitive filtering.
- `HistorySearchChanged` event + `HistoryState.filteredSales` for history search.
- Cart qty tap dialog with stock clamping in `CartItemRow` and `CartReviewPage`.
- Android permissions (`INTERNET`, `CAMERA`, `READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`).
- Android release signing config with `keystore.properties` fallback to debug.
- iOS privacy strings (`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`).
- iOS App Store compliance (`ITSAppUsesNonExemptEncryption = false`) and ATS (`NSAllowsArbitraryLoads = true`).
- Play Store + App Store metadata in `fastlane/metadata/`.
- `docs/PRIVACY_POLICY.md` and `docs/STORE_SUBMISSION.md`.
- GitHub Actions CI enhancements: `dart format`, `dart pub outdated`, `flutter build apk --debug`.
- Dependabot weekly `pub` updates.
- `android:allowBackup="false"` to prevent Google Cloud DB backups.
- 2 l10n keys: `searchHistoryHint`, `noSearchResults`.

### Changed

- `InventoryLogPage` — Replaced direct Drift queries with `InventoryLogCubit` + `BlocBuilder`.
- `ProductFormPage` — Category field replaced by `_CategoryAutocomplete`.
- `HistoryBloc`/`HistoryPage` — Added search handler + filtered list view.
- App label → `"Promsell"` on Android (`AndroidManifest.xml`) and iOS (`Info.plist`).
- Version bumped `0.6.2+1` → `0.6.3+2`.

### Fixed

- Schema migration `from < 2` gap — safe migration with `_addColumnIfNotExists` guard.
- Receipt number race condition — cached device prefix in `_cachedPrefix`.
- `SettingsCubit.load` silently swallowed errors — now surfaces `errorMessage` in `failure` state.
- Void sale deleted-product log — `logVoidReversal` accepts `reason` for semantic clarity.
- VAT/discount rounding — centralized in `MoneyUtils.round()`.
- Receipt number service — batched 3 queries into single `SELECT ... WHERE key IN (...)`.
- `querySales` read consistency — wrapped in `_db.transaction()` for snapshot isolation.
- `watchSales`/`watchRecentSales` N+1 verification confirmed — already uses `saleId.isIn()` batching.

### Tests

- InventoryLog entity equality, `isPositive`, `props`.
- `WatchInventoryLogs` use case with/without `productId` filter.
- `InventoryLogCubit` initial, success, failure states.
- `HistoryBloc` search query updates and `filteredSales` behavior.

`flutter analyze` → **0 issues** · `flutter test` → **258/258 passing**

---

## [0.6.2] - 2026-06-02

UX accessibility & performance improvements plus 14 systematic bug fixes.

### Highlights

- **Cart drag performance** — `ValueNotifier` refactor eliminates frame jank during panel resize.
- **Checkout VAT efficiency** — Single `calculateVat()` call deduplicated from total + receipt preview.
- **Accessibility batch** — 48dp checkbox touch targets, drag tooltips, focus indicators, colorblind stock badge icons.
- **Delete confirmation** — Cart item removal shows `AlertDialog` confirmation; consistent with product deletion.

### Added

- Drag handle tooltip (`reorderItem` l10n key, EN + TH).
- Semantic labels on key icons for screen readers.
- Focus color on `_QtyButton` for keyboard navigation visibility.
- Colorblind-friendly stock badge icons (`error_outline` / `warning_amber` / `check_circle_outline`).
- Product list `SearchBar` clear button.
- `DiscountDialog` keyboard submit (`TextInputAction.done`).

### Changed

- `SalePage` drag panel uses `ValueNotifier<double>` + `ValueListenableBuilder` instead of `setState`.
- `CheckoutBody` computes `calculateVat()` once per `BlocBuilder` callback and reuses result.
- Toast now dismissible by tap (replaced `IgnorePointer` with `GestureDetector`).
- Cart minus button always shows `remove` icon; delete confirmation on last qty.
- All `showModalBottomSheet` calls use `useRootNavigator: true`.

### Fixed

- Checkbox touch target below 48dp minimum.
- BUG-1 — Cart/Checkout VAT display inconsistent in EXCLUSIVE mode.
- BUG-2/11 — Negative `preTaxTotal` when cart discount exceeds subtotal.
- BUG-3 — Void sale restored stock for non-tracked products.
- BUG-4 — `ReportState.copyWith` couldn't set `from`/`to` to null.
- BUG-5 — `AppSettings.copyWith` couldn't clear `lastBackupAt`.
- BUG-6 — `lastBackupAt` null handling in settings save/load.
- BUG-7 — `SaleCartCleared` preserved cart discount fields.
- BUG-8 — `SaleReset` carried over old items/note/discount.
- BUG-9 — Windows path separator bug in `ProductImageService`.
- BUG-10 — `ReceiptNumberService` used insecure `Random()`.
- BUG-12 — `CheckoutBody` `_effectiveTotal` side-effect in `build()`.
- BUG-13 — `SettingsCubit.load` silently marked error as `loaded`.
- BUG-14 — `_compressAndSave` didn't check source file exists.
- BUG-17 — Cart reorder fallback inserted unknown items at index 0.
- BUG-18 — Per-item `vatAmount` not persisted in `saleItems`.

`flutter analyze` → **0 issues** · `flutter test` → **243/243 passing**

---

## [0.6.1] - 2026-06-02

Sale flow UX redesign, cart panel overhaul, interactive checkout review, and product image system polish.

### Highlights

- **Cart Panel Overhaul** — Search, group-by-category, multi-select, swipe actions, drag-to-reorder, resizable panel with drag handles, compact/ultra-compact modes, landscape support.
- **Interactive Checkout Review** — Full-screen `CheckoutPage` with `CartReviewPage` for cart editing (qty +/-, delete, undo), product image zoom, and detail bottom sheet.
- **Product Image Polish** — Orphaned file cleanup, remove-then-cancel fix, image visibility throughout sale flow, avatar and form improvements.

### Added

- **Cart search & grouping** — `CartPanel` search bar filters by name (appears at >5 items); group-by-category view with section headers; toggle between grouped/flat list.
- **Multi-select & swipe** — Long-press enters selection mode for bulk delete/clear discount; flat list supports swipe-right-to-delete and swipe-left-to-increment.
- **Drag-to-reorder** — Flat list uses `ReorderableListView` with explicit drag handle (`ReorderableDragStartListener`).
- **Compact modes** — `cartCompactMode` / `ultraCompactMode` settings; quick cycle button in `CartHeader` (Normal → Compact → Ultra-Compact).
- **Resizable cart panel** — Drag handle for freeform height/width resizing with hit-area (24/20px), mouse cursor hints, snap-to-preset, and landscape side-by-side layout.
- **Checkout flow** — Full-screen `CheckoutPage` with `CartReviewPage` (interactive cart editing, image zoom, product detail sheet, receipt summary); `CheckoutBody` auto-computes total from live `SaleBloc` state.
- **Receipt preview zoom** — Tap receipt to open full-screen `InteractiveViewer` dialog (pinch zoom 0.8x–3x, close button, background dismiss).
- **Centralized `ImageViewerDialog`** — Reusable `core/widgets/image_viewer_dialog.dart` with pinch zoom, double-tap zoom (2.5x), swipe gallery, page indicators. Used in `CartReviewPage` and `ProductFormAvatar`.
- **Draft system** — Configurable `maxDrafts` (5–100), draft search + sort, count badge in `CartHeader`, auto-archive after 7 days, count caching.
- **Product image polish** — `ProductAvatar` in sale flow, `ProductFormAvatar` edit badge + ripple, long-press zoom preview, loading overlay during pick, Material 3 picker bottom sheet, `renameImages()` API.
- **17 new ARB keys** (EN + TH) — `searchDrafts`, `untitledDraft`, `noMatchingItems`, `noMatchingDrafts`, `groupView`, `cartSizeMini/Half/Full`, `cartCompactNormal/Compact/Ultra`, `atStockLimit`, `justNow`, `timeAgoMinutes/Hours/Days`, `searchResultsCount`.

### Fixed

- **Orphaned product images** — `updateProduct()` deletes old file + thumbnail on replacement/removal; `addProduct()` renames temp files to match product ID.
- **Remove-then-cancel** — Image deletion deferred to repository `updateProduct()` so canceling the form doesn't leave broken references.
- **Draft cart images** — `_productFromData()` now copies `imagePath` and `imageThumbnailPath` so restored drafts preserve images.
- **Cart overflows** — `CartItemRow` overflow (5.6px), `CartPanel` bottom overflow (8.6px), `CartTotalBar` narrow layout all fixed.
- **Layer violation** — `ProductImageService` no longer depends on `SettingsCubit`; accepts `SettingsRepository` instead.
- **Draft count error state** — Badge shows `'—'` instead of `0` on `FutureBuilder` error.
- **Thai uppercase** — Category headers skip `.toUpperCase()` for Thai text.

### Changed

- **Auto-save debounce** — Increased from 500ms to 1.5s.
- **Visual design** — Unified `image_outlined` placeholder; grid avatar 72→96px; `SaleProductCard` switched to vertical layout; catalog grid sizing bumped; category chips use `primaryContainer` + fade gradient.
- **Cart widgets** — `CartItemRow` redesigned with `Card`, pill discount badge, `FittedBox` subtotal, stock tooltip; `CartTotalBar` top shadow, bold label, subtotal breakdown; `CartHeader` `PopupMenuButton` actions.
- **Payment & drafts** — `PaymentMethodCard` replaces `SegmentedButton`; `DraftsBottomSheet` rounded corners + `Card` tiles; checkout via `Navigator.push` instead of bottom sheet.

### Tests

- `ProductImageService` unit tests: `deleteImage`, `deleteImages`, `generateThumbnail`, `pickFromGallery` cancellation.
- Repository tests for orphaned-image cleanup in `updateProduct`.

`flutter analyze` → **0 issues** · `flutter test` → **243/243 passing**

---

## [0.6.0] - 2026-06-02

Merchant Tools — PDF receipt, PromptPay QR, backup/restore, and product image system overhaul.

### Highlights

- **Receipt PDF** — Print and share receipts as PDF with Thai font support (80mm thermal + A4).
- **PromptPay QR** — EMVCo-compliant QR generation for static/dynamic payments; integrated into payment sheet.
- **Backup System** — Full SQLite export/import, CSV export for sales & products, backup reminder banner.
- **Product Image Overhaul** — Pure Dart compression, thumbnail system, image cleanup lifecycle, CachedNetworkImage, compression settings.

### Added

#### Receipt PDF & PromptPay QR

- **`ReceiptPdfService`** — `printReceipt()` / `shareReceipt()` with Thai font; moved to feature-based architecture.
- **`ReceiptLabels`** — Localized label entity extracted to `domain/entities/`.
- **80mm thermal layout** — Shop info, items, VAT breakdown, payment details, footer note.
- **`PromptpayQrService`** — EMVCo TLV payload generation (phone/citizen ID, static/dynamic).
- **Payment sheet QR** — QR display with amount, confirm button.
- **6 `AppSettings` fields** — `promptpayId`, `receiptSize`, `backupReminderDays`, `lastBackupAt`, `imageMaxWidth`, `imageQuality`.
- **24 l10n keys** (EN + TH) — PromptPay (7), receipt size (3), backup/data (14).

#### Backup System

- **`BackupService`** — SQLite export with WAL checkpoint, import with schema validation + confirm dialog.
- **CSV export** — Sales (date-range) and products via `csv` + `share_plus`.
- **Backup reminder** — Configurable days threshold, banner on Settings page.

#### Product Image Overhaul

- **Pure Dart compression** — Replaced `flutter_image_compress` with `image` package; no native dependency.
- **Thumbnail system** — 200px thumbnails alongside 800px full images; `ProductAvatar` uses thumbnails for sizes ≤100px.
- **`imageThumbnailPath`** — Added to `Product` entity, `products` table, all data/domain/presentation layers.
- **Image cleanup on delete** — `ProductRepositoryImpl` deletes images before DB row removal.
- **`CachedNetworkImage`** — Replaced `Image.network` in `ProductAvatar` and `ProductFormAvatar` with caching + placeholders.
- **Async file check** — `File.existsSync()` → `File.exists()` in both avatar widgets (converted to `StatefulWidget`).
- **Image naming fix** — New products no longer get `new.jpg`; UUID-based naming.
- **Compression settings** — `imageMaxWidth` (800) / `imageQuality` (80) in `AppSettings`; `ProductImageServiceImpl` reads from `SettingsCubit`.
- **Schema migration v5→v6** — `image_thumbnail_path` column; `_seedR45Settings()` seeds image defaults.
- **6 dependencies** — `share_plus`, `file_picker`, `csv`, `qr_flutter`, `image`, `cached_network_image`.

### Changed

- **`AppSettings.props`** — Count updated 24 → 30 (6 new fields).
- **`SettingsRepositoryImpl`** — Added load/save keys for 6 new settings fields.
- **`app_database.dart`** — Schema version bumped 4 → 6; `_seedR4Settings()` + `_seedR45Settings()` migration steps.
- **`ProductImageServiceImpl`** — Requires `SettingsCubit` injection; reads `_maxWidth`/`_quality` from settings.
- **`ProductRepositoryImpl`** — Requires `ProductImageService` injection; deletes images on product removal.
- **`ProductAvatar` / `ProductFormAvatar`** — Rewritten as `StatefulWidget` with async file check, thumbnail support, `CachedNetworkImage`.
- **`ProductFormPage`** — Tracks `_imageThumbnailPath`; generates thumbnail on pick; deletes both images on remove.
- **Product data layer** — `ProductAdded`, `AddProduct`, `ProductRepository.addProduct` accept `imageThumbnailPath`.

### Removed

- **`flutter_image_compress`** — Replaced by pure Dart `image` package.

### Tests

- **`app_settings_test.dart`** — `props.length` 24 → 30; default assertions for 6 new fields.
- **`product_test.dart`** — `props.length` → 12; `imageThumbnailPath` in equality test.
- **`product_repository_impl_test.dart`** — `MockProductImageService`; deleteProduct verifies image cleanup.
- **`checkout_flow_test.dart`** — `_NoOpImageService` stub for `ProductRepositoryImpl`.
- **All `Product()` constructors** in tests updated with `imageThumbnailPath: null`.

`flutter analyze` → **0 issues** · `flutter test` → **215/215 passing**

---

[0.6.3]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.5.0...v0.6.0
