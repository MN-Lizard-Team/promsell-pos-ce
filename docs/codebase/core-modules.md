# Core Modules & Feature Modules — Promsell POS CE (v0.9.2)

> **Main reference:** [`CODEBASE.md`](../../CODEBASE.md) — system overview, architecture, links

---

## Core modules

| Module | Path | Responsibility |
|--------|------|----------------|
| `AppColors` / `AppTheme` | `lib/core/theme/` | Static color palette (`#0D5D6B` primary Teal, `#FF6B00` accent Orange, `#0D1B2A` dark bg) and Material 3 `ThemeData` (light/dark) with shared `CardTheme`, `ButtonTheme`, `InputDecorationTheme` (radius 16/12). All app colors must route through here |
| `SettingsThemeExtension` | `lib/features/settings/presentation/theme/` | `ThemeExtension` for settings surfaces: `cardBackground`, `softAccent`, `softTextPrimary/Secondary`, `iconContainerBackground`, `cardRadius`, `sectionGap`. Separate light/dark consts |
| `AppDatabase` | `lib/core/database/app_database.dart` | Drift database class, **schema v32** (**16 tables**), UUID PKs, WAL + FK pragma, batch seed, SQLCipher open path. Sync metadata on core tables. Notable: v24 barcode unique; v25 product brand/unit/supplier/`is_recommended`; **v26 unique `daily_closes(close_date)`**; **v27 unique `sales.receipt_number`**; **v28 `sale_payments` multi-tender**; **v29 case-insensitive `barcode_lower` unique index**; **v30 case-insensitive `sku_lower` unique index**; **v31 SKU dedupe/index repair**; **v32 Phase M: 32 satang columns with active converter/dual-write boundary**. **v32 cursor-pagination indexes** `idx_products_created_at_id_cursor` (products: created_at DESC, id) and `idx_sales_created_at_id_cursor` (sales: created_at DESC, id) back `getProductsPage`/`searchProductsPage` and `getSalesPage`. Legacy REAL baht remains for rollback compatibility. |
| `injection_container.dart` | `lib/core/di/` | injectable-generated DI config (`configureDependencies`); `database_module.dart` registers `AppDatabase` |
| `l10n_extension.dart` | `lib/core/extensions/` | `context.l10n` shorthand for `AppLocalizations.of(context)!` |
| `ReceiptPdfService` | `lib/features/receipt/data/services/` | Build 80 mm thermal receipt PDF; expose `printReceipt` and `shareReceipt`; Thai font embedding |
| `ReceiptLabels` | `lib/features/receipt/domain/entities/` | Localized label entity for receipt rendering |
| `ReceiptPreview` | `lib/core/widgets/` | On-screen receipt preview in `thermal` and `card` styles; VAT-aware; product images inline via `ProductAvatar` |
| `OverlayToast` | `lib/core/widgets/` | Fade-in pill toast at top center via `Overlay`; non-blocking, no dependency, replaces snackbar in active cashier flow |
| `IdGenerator` | `lib/core/utils/` | UUIDv4 generation via `uuid` package — all entity PKs |
| `MoneyUtils` | `lib/core/utils/` | Centralized monetary rounding (`round(double)`) for VAT, discount, and total calculations |
| `DateFormatter` | `lib/core/utils/` | Locale-aware date/time formatting utility; maps app language codes to intl locales (`th`→`th_TH`, `en`→`en_US`); extensible for future locales via `_localeFor()` |
| `payment_method_helper.dart` | `lib/core/utils/` | Normalize raw DB values (`เงินสด` → `cash`) and localize for display |
| `SlipVerifier` | `lib/core/utils/` | Decodes Thai bank transfer slip Mini-QR; returns `SlipVerifyResult` with `SlipErrorType` categorization |
| `BarcodeScannerDialog` | `lib/core/widgets/` | Fullscreen barcode scanner supporting EAN-13/8, UPC-A/E, Code 128/39, ITF, QR Code, DataMatrix, PDF417, Aztec, Codabar; haptic feedback, first-detect lock, manual entry fallback with inline validation, auto-clearing error overlay, auto-open manual entry timer. Shared `ScanOverlayPainter` |
| `showProductBarcodeScanner()` | `lib/core/widgets/barcode_scanner_dialog.dart` | Shared helper that opens `BarcodeScannerDialog` with predefined product barcode formats |
| `showImageSourceSheet()` | `lib/core/widgets/image_source_sheet.dart` | Shared bottom-sheet helper for gallery/camera/remove image actions; used by ProductFormPage |
| `DuplicateBarcodeException` | `lib/core/exceptions/` | Thrown when barcode already exists on another product |
| `SoundPlayer` | `lib/core/utils/` | Lightweight audio player for PromptPay confirmation feedback (`audioplayers`) |
| `safe_text_controller.dart` | `lib/core/widgets/primitives/` | Dispose helpers for `TextEditingController` — `unfocusForDialogClose()` and `disposeTextEditingControllerAfterFrame()` prevent use-after-dispose races during route/IME teardown |
| `Ean13Generator` | `lib/core/utils/` | `@injectable` EAN-13 compliant barcode generator with Luhn check digit; default prefix `200` (GS1 internal use range); pads 1-2 digit prefixes to 3 digits; per-instance counter persisted via `initCounter()`/`currentCounter`; injected into `GenerateBarcode`, `BatchGenerateBarcodes`, and `SettingsCubit` |
| `GenerateBarcode` | `lib/features/product/domain/usecases/` | `@injectable` use case wrapping `Ean13Generator.generate()` with DB collision check (`barcodeExists`, `excludeId` for self-collision) + retry (max 10) + counter persistence to Settings on every attempt (not just success) |
| `BatchGenerateBarcodes` | `lib/features/product/domain/usecases/` | `@injectable` use case that syncs `Ean13Generator.initCounter()` from persisted settings, finds all active products without barcodes, generates unique EAN-13 for each, and updates them in a single `bulkUpdateBarcodes()` call (Drift batch) for single stream event |
| `PromptPayQrCode` | `lib/features/settings/presentation/widgets/` | EMVCo-compliant QR payload generator via `thai_promptpay`; optional customizable icon overlay |
| `ReceiptNumberService` | `lib/features/sale/data/services/` | Auto-generated receipt numbers (`YYMMDD-XX-NNNN`) per day/device |
| `ProductImageService` | `lib/features/product/data/services/` | Gallery/camera pick → pure Dart JPEG compression (configurable maxWidth/quality) → local `/images/{productId}.jpg` + `_thumb.jpg`; delegates delete to `ImageCacheService`; format validation (`.jpg`, `.png`, `.webp`, etc.); auto LRU cache eviction on save; `@LazySingleton` |
| `BarcodeImageService` | `lib/features/product/data/services/` | Generates barcode images from barcode text using `BarcodeWidget` off-screen rendering via `RenderRepaintBoundary` (600×200 @ 3x pixel ratio); saves to `/barcodes/{productId}.{png|jpg}`; supports both PNG and JPEG output formats; invoked by `ProductRepositoryImpl` on product add/update; used by `BarcodeImageWidget` to encode PNG to JPEG for share |
| `InventoryLogService` | `lib/features/inventory/data/services/` | Audit trail for stock changes (SALE, VOID_REVERSAL, ADJUSTMENT_IN/OUT) |
| `ReportCalculatorService` | `lib/features/report/domain/services/` | Injectable domain service for period totals, daily/hourly revenue, top products, profit analytics, and PromptPay legs; aggregates money in integer satang before display conversion |
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
| `MigrationSafetyService` | `lib/core/database/migration_safety_service.dart` | `@LazySingleton` pre-migration safety checks and status tracking. `checkFreeSpace()` requires ≥ 2× DB size (or 50 MB floor); `markMigrationStart/Success/Failure` write `migration_status.json` to app docs dir; `readMigrationStatus()` detects interrupted migrations on next launch. `MigrationStatus` enum (idle/running/succeeded/failed) + `MigrationPreflightResult` |
| `WalCheckpointService` | `lib/core/database/wal_checkpoint_service.dart` | `@LazySingleton` WAL monitoring and checkpointing. `PASSIVE` mode safe during active money transactions (10 MB threshold); `TRUNCATE` mode for backup/export/day-close (50 MB hard limit). `CheckpointResult` with busy/log/checkpointed frames + WAL size before/after. `checkpointIfNeeded()` / `forceTruncate()` |
| `DatabaseHealthService` | `lib/core/database/database_health_service.dart` | `@LazySingleton` database health reporting. `generateReport()` returns `DatabaseHealthReport` with main/WAL/SHM sizes, schema version, integrity check, free storage, WAL checkpoint recommendations. 512 MB operational guardrail (400 MB approaching) |
| `RecoveryKitService` | `lib/core/database/recovery_kit_service.dart` | `@LazySingleton` SQLCipher key export/import as `.promkey` recovery kit. AES-256-GCM + PBKDF2-HMAC-SHA256 (100K iterations, isolate-backed). `exportKit()` / `importKit()` / `hasKey()` / `removeKey()`. Min secret length 8. File format: `[uint32 headerLen][JSON header][salt(16)][nonce(12)][ciphertext+tag]` |
| `BackupExportService` | `lib/features/settings/data/services/backup_export_service.dart` | `@LazySingleton` DB backup export with `BackupMetadata` (SHA-256 checksum, schema/app version, size, encrypted flag). `exportToFiles()` / `exportWithMetadata()` / `exportAndShare()`. `BackupProgress` callback (checkpointing→copying→checksumming→encrypting→sharing→done). 512 MB size preflight (`maxBackupBytes`). Min PIN length 6 |
| `BackupRestoreService` | `lib/features/settings/data/services/backup_restore_service.dart` | `@LazySingleton` same-device SQLCipher restore with staged file swap + rollback. `restoreFromPath()` returns pre-restore backup path; `cleanupPreRestoreBackups()` deletes leftover files. `skipSqlCipherHeaderCheck` test-only param; `@ignoreParam` on `candidateValidator` and `skipSqlCipherHeaderCheck` for injectable. 512 MB size limit |

---

## Feature modules

**13 features** under `lib/features/` (source of truth):

| Feature | Path |
|---------|------|
| customer | `lib/features/customer/` |
| daily_close | `lib/features/daily_close/` |
| history | `lib/features/history/` |
| home | `lib/features/home/` |
| inventory | `lib/features/inventory/` |
| onboarding | `lib/features/onboarding/` |
| product | `lib/features/product/` |
| promotion | `lib/features/promotion/` |
| receipt | `lib/features/receipt/` |
| report | `lib/features/report/` |
| restaurant_table | `lib/features/restaurant_table/` |
| sale | `lib/features/sale/` (includes cart, checkout, drafts) |
| settings | `lib/features/settings/` |

Draft cart is **not** a top-level feature package — it lives under `sale/`.

