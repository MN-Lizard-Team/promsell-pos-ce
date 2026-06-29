# Core Modules & Feature Modules — Promsell POS CE v0.8.8

> **Main reference:** [`CODEBASE.md`](../CODEBASE.md) — system overview, architecture, links

---

## Core modules

| Module | Path | Responsibility |
|--------|------|----------------|
| `AppColors` / `AppTheme` | `lib/core/theme/` | Static color palette (`#0D5D6B` primary Teal, `#FF6B00` accent Orange, `#0D1B2A` dark bg) and Material 3 `ThemeData` (light/dark) with shared `CardTheme`, `ButtonTheme`, `InputDecorationTheme` (radius 16/12). All app colors must route through here |
| `SettingsThemeExtension` | `lib/features/settings/presentation/theme/` | `ThemeExtension` for settings surfaces: `cardBackground`, `softAccent`, `softTextPrimary/Secondary`, `iconContainerBackground`, `cardRadius`, `sectionGap`. Separate light/dark consts |
| `AppDatabase` | `lib/core/database/app_database.dart` | Drift database class, schema v19, 9 tables, UUID PKs, WAL + FK pragma, batch seed. Sync columns (`updatedAt`, `deletedAt`, `version`, `deviceId`) on all 6 core tables. v13 backfills `deviceId`; v15 adds `color`/`iconName` to `Categories`; v16 adds `UNIQUE INDEX` on `barcode` with duplicate-safe migration; v17 auto-deduplicates barcodes before index creation; v18 adds `barcodeImagePath` to `Products` for generated barcode PNGs; v19 adds `note` to `CartItems` |
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
| `BarcodeScannerDialog` | `lib/core/widgets/` | Fullscreen barcode scanner supporting EAN-13/8, UPC-A/E, Code 128/39, ITF, QR Code, DataMatrix, PDF417, Aztec, Codabar; haptic feedback, first-detect lock, manual entry fallback with inline validation, auto-clearing error overlay, auto-open manual entry timer. Shared `ScanOverlayPainter` |
| `showProductBarcodeScanner()` | `lib/core/widgets/barcode_scanner_dialog.dart` | Shared helper that opens `BarcodeScannerDialog` with predefined product barcode formats |
| `showImageSourceSheet()` | `lib/core/widgets/image_source_sheet.dart` | Shared bottom-sheet helper for gallery/camera/remove image actions; used by ProductFormPage |
| `DuplicateBarcodeException` | `lib/core/exceptions/` | Thrown when barcode already exists on another product |
| `SoundPlayer` | `lib/core/utils/` | Lightweight audio player for PromptPay confirmation feedback (`audioplayers`) |
| `Ean13Generator` | `lib/core/utils/` | `@injectable` EAN-13 compliant barcode generator with Luhn check digit; default prefix `200` (GS1 internal use range); pads 1-2 digit prefixes to 3 digits; per-instance counter persisted via `initCounter()`/`currentCounter`; injected into `GenerateBarcode`, `BatchGenerateBarcodes`, and `SettingsCubit` |
| `GenerateBarcode` | `lib/features/product/domain/usecases/` | `@injectable` use case wrapping `Ean13Generator.generate()` with DB collision check (`barcodeExists`, `excludeId` for self-collision) + retry (max 10) + counter persistence to Settings on every attempt (not just success) |
| `BatchGenerateBarcodes` | `lib/features/product/domain/usecases/` | `@injectable` use case that syncs `Ean13Generator.initCounter()` from persisted settings, finds all active products without barcodes, generates unique EAN-13 for each, and updates them in a single `bulkUpdateBarcodes()` call (Drift batch) for single stream event |
| `PromptPayQrCode` | `lib/features/settings/presentation/widgets/` | EMVCo-compliant QR payload generator via `thai_promptpay`; optional customizable icon overlay |
| `ReceiptNumberService` | `lib/features/sale/data/services/` | Auto-generated receipt numbers (`YYMMDD-XX-NNNN`) per day/device |
| `ProductImageService` | `lib/features/product/data/services/` | Gallery/camera pick → pure Dart JPEG compression (configurable maxWidth/quality) → local `/images/{productId}.jpg` + `_thumb.jpg`; delegates delete to `ImageCacheService`; format validation (`.jpg`, `.png`, `.webp`, etc.); auto LRU cache eviction on save; `@LazySingleton` |
| `BarcodeImageService` | `lib/features/product/data/services/` | Generates barcode images from barcode text using `BarcodeWidget` off-screen rendering via `RenderRepaintBoundary` (600×200 @ 3x pixel ratio); saves to `/barcodes/{productId}.{png|jpg}`; supports both PNG and JPEG output formats; invoked by `ProductRepositoryImpl` on product add/update; used by `BarcodeImageWidget` to encode PNG to JPEG for share |
| `InventoryLogService` | `lib/features/inventory/data/services/` | Audit trail for stock changes (SALE, VOID_REVERSAL, ADJUSTMENT_IN/OUT) |
| `ReportCalculator` | `lib/features/report/domain/extensions/` | Domain extension on `List<Sale>`: `completedSales`, `voidedSales`, `netRevenue`, `voidedTotal`, `byPaymentMethod`, `topProducts` |
| `SettingsMapper` | `lib/features/settings/data/mappers/` | `Settings` ↔ `Map<String,String>` serialization; handles legacy themeMode integer migration (0→light, 1→dark, 2→system) |
| `SettingsPersistenceService` | `lib/features/settings/domain/services/` | Debounce Timer + persistence logic; `_isDisposed` guard prevents timer races after disposal |
| `BackupEncryptionService` | `lib/features/settings/data/services/` | AES-256-GCM encryption/decryption for SQLite backups with PIN-derived PBKDF2 key |
| `DraftCartLocalDatasource` | `lib/features/sale/data/datasources/` | Persist/load `DraftCarts` + `DraftCartItems`; used by `DraftCartRepository` |
| `SettingsLocalDatasource` | `lib/features/settings/data/datasources/` | Drift-backed typed key-value store for app_settings table |
| `AdaptiveBreakpoints` | `lib/core/widgets/` | Compact / medium / expanded layout helpers |
| `AppEmptyState` | `lib/core/widgets/` | Consistent empty/error states with compact-height support |
| `MoneyText` | `lib/core/widgets/` | Currency text with fixed decimal formatting |
| `SectionCard` | `lib/core/widgets/` | Shared grouped card surface for settings and dashboards |
| `BarcodeWidget` | `package:barcode_widget/` | Visual barcode rendering (EAN13, EAN8, UPCA, Code128) used in `ProductPreviewPage` |
| `ProductPreviewPage` | `lib/features/product/presentation/pages/` | Full-page read-only product detail: hero image + gradient overlay, price card (selling price, cost, profit + margin %), stock card with inline edit, SKU/barcode card with visual barcode + copy actions + generate-barcode button when missing + save as PDF/PNG/JPEG, system info card (product ID, timestamps). Barcode images are persisted to `product.barcodeImagePath` and reused for view/save/print |
| `ImageViewerDialog` | `lib/core/widgets/` | Full-screen image viewer with `InteractiveViewer` (pinch zoom, pan, double-tap zoom), swipe gallery, page indicators. Bottom toolbar: share button (`share_plus`) + info bottom sheet (source, path, file size). Used by product image tap and receipt preview |
| `CrashLogService` | `lib/core/services/` | Persistent local crash logging with PII sanitization (phone, PromptPay ID, citizen ID); export via share sheet; clear with confirmation. `@LazySingleton` |

---

## Feature modules

| Feature | BLoC / Cubit | Key files |
|---------|-------------|-----------|
| Sale | `CartBloc`, `DraftBloc`, `CheckoutBloc` | `sale_page.dart`, `checkout_page.dart`, `payment_sheet_redesign.dart`, `promptpay_payment_page.dart`; widgets: `CheckoutBody`, `CartReviewPage`, `DiscountDialog`, `SaleCatalog`, `SaleProductCard`, `CartHeader`, `CartItemRow` (single-row 3-zone), `CartTotalBar`, `DraftsBottomSheet`, `SaleReceiptDialog`, `CartPanel`, `CartBottomSheet` (draggable sheet), `CartQtyStepper` (press-scale haptic), `ChangePreview`, `PaymentTotalRow`, `PaymentMethodCard`, `ImageViewerDialog`, `CompactCartFab`, `CartItemCard`, `CartDetailRow`, `CartQtyButton`, `CartDottedLineRow`, `SlipScannerDialog` |
| Product | `ProductBloc`, `CategoryBloc`, `ProductFormCubit` | `product_list_page.dart`, `product_form_page.dart`, `product_preview_page.dart`, `category_management_page.dart`, `category_picker_page.dart`; widgets organized into subfolders: `category/` (CategoryListTile, CategoryFormDialog, CategoryPickerListView, CategoryPickerBottomSheet, CategoryFilterBar), `product_tile/` (ModernProductTile, ModernProductGridCard, ProductCardShell, ProductInfoBlock, ProductAvatar, ProductFormAvatar, ProductHeroImage, ProductImageContainer, StockBadge, StockIndicator, product_navigation.dart — shared show/edit/preview/delete helpers), `product_form/` (ProductFormView, ConfirmDeleteDialog, UnsavedChangesDialog, CategoryField, FormSectionCard), `product_list/` (StatsDashboard, CategoryFilterChips, ProductSliverContent, BatchGenerateDialog), `product_preview/` (HeroSection, PriceCard, StockCard, CodesCard, SystemInfoCard, shared_widgets), `quick_edit/` (QuickEditSheet, QuickEditMixin, ProductActionSheet), `shared/` (ProductTextField, BarcodeImageWidget); services: `ProductImageService`; usecases: `AddProduct`, `UpdateProduct`, `DeleteProduct`, `ClearOrphanedImages`, `ReorderCategories` |
| History | `HistoryBloc` | `history_page.dart`; widgets: `SaleExpansionTile`, `VoidSaleDialog` |
| Report | `ReportCubit` (lazySingleton) | `report_page.dart`; widgets: `SummaryCard`, `ReportDateRangeCard`, `ReportPaymentMethodCard`, `ReportTopProductsCard`; domain: `ReportCalculator` extension |
| Settings | `SettingsCubit` | Pages: 2-level hierarchy — `settings_root_page.dart` (flat section list), `general_settings_page.dart`, `shop_info_settings_page.dart`, `sales_settings_page.dart`, `receipt_settings_page.dart`, `discount_policy_settings_page.dart` (merged with presets), `stock_settings_page.dart`, `image_settings_page.dart`, `barcode_settings_page.dart`, `backup_settings_page.dart`, `promptpay_settings_page.dart`, `db_health_page.dart`, `about_page.dart`, `privacy_policy_page.dart`, `license_page.dart`. Widgets: `SettingsCategoryTile`, `SettingsSectionCard`, `SettingsSwitchTile`, `SettingsTextTile`, `SettingsDropdownTile`, `SettingsValuePreview`, `GeneralSummaryCard`, `GeneralSettingsForm`, `ShopPreviewCard`, `ShopInfoForm`, `SettingsThemeExtension`, `AppTextDialog`, `ImagePreviewCard`, `DemoImagePreview`, `BackupStatusCard`, `BackupInfoCard`, `PromptpayPreviewCard`, `PromptpayInfoCard`; domain: `SettingsMapper`, `SettingsPersistenceService`, `Settings` aggregate root with 13 typed group entities |
| Inventory | `InventoryLogCubit` | `inventory_log_page.dart`, `adjust_stock_dialog.dart`; domain: `InventoryLog`, `InventoryLogRepository`, `WatchInventoryLogs`; data: `InventoryLogLocalDatasource`, `InventoryLogService`, `AdjustStock` |
| Receipt | `ReceiptPdfService` (lazySingleton) | `receipt_pdf_service.dart`, `receipt_labels.dart`; data services + domain entities |
| Draft Cart | `DraftBloc` | `DraftCartLocalDatasource`, `DraftCartRepositoryImpl`, `draft_cart_repository.dart` |
| Daily Close | `DailyCloseCubit` | `daily_close_page.dart`, `daily_close_list_page.dart`; widgets: `DailyCloseDateCard`, `DailyCloseSummaryCard`, `DailyCloseReconciliationCard`, `DailyCloseSummaryRow`, `DailyCloseReadOnlyRow`; domain: `DailyClose`, `CloseDay`, `ReopenDay`, `GetDailyCloseByDate`, `GetDailyCloseList` |
| Onboarding | (stateless wizard) | `onboarding_page.dart` — 6-step first-launch flow; widgets: `OnboardingHeroSection`, `OnboardingSection`, `GreenChoiceChip`, `OnboardingSheetOption` |
| DB Health | (stateful page) | `db_health_page.dart` — file size, row counts, vacuum |

---

<sub>Promsell POS CE · v0.8.8 · Core & Feature Modules</sub>
