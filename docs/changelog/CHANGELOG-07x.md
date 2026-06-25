# Changelog — v0.7.x — Promsell POS CE

> For the most up-to-date changes and release information, see [CHANGELOG.md](/CHANGELOG.md) for version 0.8.x, including feature additions, system improvements, performance enhancements, and bug fixes.

---

## [0.7.6] - 2026-06-11

Category system overhaul with color/icon picker, drag-drop reordering, and 22 system-wide bug fixes.

### Highlights

- **Category Management Overhaul** — `CategoryManagementPage` with drag & drop reordering, color + icon picker, product count badges, search, and bulk delete. Schema v15 adds `color`/`iconName` columns. `CategoryFormDialog` offers 10 preset colors and 21 Material icons.
- **Product Page Category Support** — `SaleProductCard`, `SaleCatalog` chips, `ProductEditTabView`, and `CategoryPickerListView` all display category-specific colors and icons instead of generic folder icons.
- **Product UI Redesign** — unified card family (`ProductCardShell`, `ProductImageContainer`, `ProductInfoBlock`), tab-based editor (`ProductEditTabView`), inline quick edit, search with highlighting, and dual-mode sale search (grid ↔ list).
- **System-Wide Bug Fixes (22 issues)** — fixed stream subscription races, stale context crashes, silent timer deadlocks, oversell clamp, empty-list guards, and search debounce lag across `SaleBloc`, `ProductBloc`, `HistoryBloc`, `ReportCubit`, `CategoryFilterBar`, `DiscountPresetsPage`, `SettingsPersistenceService`, and `AppSearchBar`.
- **App Icon** — replaced launcher icon with new logo via `flutter_launcher_icons`.

### Added

- `Category` entity with `color`, `iconName`; schema v15 migration.
- `CategoriesReordered` event + `CategoryBloc._onReordered` handler for batch sortOrder updates.
- `CategoryManagementPage` — `ReorderableListView`, search, bulk delete, drag handle (`ReorderableDragStartListener`).
- `CategoryFormDialog` — color circle picker + icon grid picker.
- `AddProductPage` with `AddProductDraftCubit` (save/restore/discard on back press).
- `CategoryPickerBottomSheet`, `CategoryPickerPage`, `CategoryPickerListView`.
- `ProductCard Shell`, `ProductImageContainer`, `ProductInfoBlock`, `ProductActionSheet`.
- `ModernProductTile`, `ModernProductGridCard` with stock indicators, SKU display, and swipe-to-delete.
- `AppSearchBar`, `SearchResultTile`, `SearchHighlightText`, `SearchEmptyState`, `SearchHistoryCubit`.
- `ProductHeroImage`, `FormSectionCard`, `StockStepper`, `ModernToggleCard`, `StickyActionBar`, `DangerZoneCard`.
- `QuickEditSheet` for inline name/price/stock editing from product list.
- L10n: `categoryColor`, `categoryIcon`, `categoryManagementTitle`, `noCategoriesYet`, `addCategory`, `editCategory`, `deleteCategoryConfirm`, `categoryName`, `chooseCategory`, `manageCategories`, `sortOrder`, `addProductTitle`, `noCategorySelected`, `saveDraft`, `discardDraft`, `restoreDraft`, `draftSaved`, `unsavedChangesMessage`, `restore`.

### Changed

- **Navigation** — Add Product moved from bottom sheet to full-page `AddProductPage`; Edit Product converted to `Navigator.push`.
- **Product List** — FAB now adds product directly; "Manage Categories" moved to AppBar overflow.
- **Category Bloc** — auto-subscribes in constructor; removed manual `CategoriesSubscribed` event from all pages.
- **Category ID storage** — `products.category_id` stores UUID (was name string); schema v14 migration backfills via name lookup. Added FK constraint to `categories.id`.
- **Theme** — removed hardcoded `Colors.black/white/grey/orange` across product widgets; all use `theme.colorScheme` tokens.

### Fixed

- `SaleBloc.close()` deadlock — await timer cancellation before save.
- `SaleProductCard` stale context — capture `SaleBloc` before `showDialog`.
- `CategoryPickerPage` `StateError` — guard empty list before `cats.first`.
- `ProductBloc`/`ReportCubit`/`HistoryBloc` double subscription — await `_sub?.cancel()` before new stream.
- `DraftsBottomSheet` not refreshing after create.
- `CategoryFilterBar` empty-string `selectedId` not treated as `null`.
- `SaleBloc` oversell clamp ceiling 99 999 → 999 999.
- `StockStepper` no visual feedback — `GestureDetector` → `InkWell`.
- `SaleCatalog` stale search query on return.
- `DiscountPresetsPage` timestamp ID collision → `IdGenerator.newId()`.
- `SettingsPersistenceService` timer race after disposal.
- `AppSearchBar` per-keystroke lag — 300 ms debounce.
- `DeleteCategory` orphaned inactive products — checks all products, not just active.
- `UpdateCategory` duplicate name — validates uniqueness (skips self).
- `ProviderNotFoundException` — `ProductFormPage` receives `CategoryBloc` via `MultiBlocProvider`.
- `UnifiedImageWidget` infinity crash — guard `cacheWidth` with `isFinite`.
- `ModernProductGridCard` bottom overflow — aspect ratio 1.0 → 1.1.

`flutter analyze` → **0 issues** · `flutter test` → **340 passing**

---

## [0.7.5] - 2026-06-09

Unified image system, sync-ready schema, PBKDF2 encryption, and dark-mode UI overhaul.

### Highlights

- **Sync Readiness** — `deviceId` populated on all datasource writes (`Sales`, `SaleItems`, `DraftCarts`, `InventoryLogs`); soft-delete drafts; schema v13 backfill migration.
- **Security Fix** — `BackupEncryptionService` replaces weak key derivation with PBKDF2-HMAC-SHA256 (100K iterations); v2 format with backward-compatible v1 decryption.
- **Image System** — Unified `UnifiedImageWidget` with skeleton loading and dark-mode-safe placeholders; `ImageCacheService` with LRU eviction; `ImageViewerDialog` with share/info overlays.
- **UI/UX Overhaul** — Forest green theme, iOS-style `AnimatedNavBar` with active indicators, larger payment/cart touch targets, `NotoSansThai` everywhere, dark mode fixes across payment, cart, and receipt preview.

### Added

- `deviceId` population on all `Companion.insert()` writes across sync-enabled tables.
- `deleteDraft` soft delete (`deletedAt` + `isArchived`) with cascade to items.
- `BackupEncryptionService` v2 format (version byte `0x02`) + PBKDF2-HMAC-SHA256.
- `ImageCacheService` — LRU cache eviction, `clearCache()`, paired image/thumbnail delete.
- `UnifiedImageWidget` + `ImageSkeleton` + `ImageErrorPlaceholder` in `core/image/`.
- `ImageViewerDialog` share button and info bottom sheet.
- `AnimatedNavBar` — frosted glass, active pill, bounce animation, swipe navigation, double-tap scroll-to-top, keyboard shortcuts (`1`–`5`/`F1`–`F5`), tablet `NavigationRail`.
- `AppLogger` — structured logging utility replacing `debugPrint` in catch blocks.
- `FakeSettingsRepository` test helper; onboarding → first sale integration test.
- Schema v13 migration — backfills `device_id` on all sync tables.
- `image_cropper` dependency `^8.0.0`.

### Changed

- **Theme** — primary `#00C853` → `#2E7D32`; light background `#F0EDE4` → `#F5F5F5`; dark `#0D1117` → `#121212`; surfaces pure white/neutral; added `darkSurfaceContainerHighest`.
- **Navbar** — height 56dp → 64dp, icon 24dp → 28dp, touch target `HitTestBehavior.opaque`, active tab rounded rect background, label active `w700`/inactive `w600`.
- **Payment** — `PaymentMethodCard` selected → `primary` background with `onPrimary` text; quick-amount `ActionChip` → `FilledButton`; confirm button 56dp; total section bordered with `surfaceContainerHighest` background; `AnimatedScale`/`AnimatedSwitcher` animations.
- **Cart** — stepper height 36dp → 44dp, button 24dp → 32dp with primary tint; item row `AnimatedContainer` + pill discount badge; checkout button 56dp.
- **Cart review** — MoneyText `primary` → `onSurface`; qty button `primaryContainer` → `surfaceContainerHighest`; buttons `FilledButton` + `NotoSansThai`.
- **Receipt preview** — thermal style `Colors.white`/`black` → `surface`/`onSurface` with border; card total `primaryContainer` → `primary` 0.08 alpha + border; product images via `ProductAvatar` inline.
- `ProductAvatar` / `ProductFormAvatar` — thin wrappers around `UnifiedImageWidget`.
- `ProductImageService` — integrated `ImageCacheService`, format validation, auto-evict on save.
- `SaleLocalDatasourceImpl`, `DraftCartLocalDatasourceImpl`, `InventoryLogService` — inject `SettingsRepository` for `deviceId`.

### Fixed

- Weak `BackupEncryptionService` key derivation (~3 HMAC rounds → 100K PBKDF2).
- `deleteDraft` orphaned `draft_cart_items` rows.
- Silent error swallowing — 20 `debugPrint` catch blocks → `AppLogger` across 11 files.
- `catch (_) {}` anti-pattern in `SettingsMapper`, `SoundPlayer`, `ReceiptPdfService`, `DailyCloseRepository`.
- `SaleBloc._scheduleSave` race condition — stale state read after async gap.
- Missing `labelSmall`/`labelMedium` causing navbar Roboto fallback.
- Receipt preview dark mode — hardcoded white/black colors unreadable in dark theme.

`flutter analyze` → **0 issues** · `flutter test` → **343/343 passing**

---

## [0.7.4] - 2026-06-09

PromptPay system overhaul, data loss prevention, settings atomicity, and UI polish.

### Highlights

- **Data Loss Prevention** — `SaleBloc.close()` and `SettingsPersistenceService.dispose()` await pending saves.
- **Settings Atomicity** — `save()` wrapped in Drift transaction.
- **PromptPay System** — EMVCo QR generation, slip verification, auto-confirm, configurable timeout/sound/QR-type.
- **PromptPayPaymentPage v2** — Responsive split-screen, timer progress bar, cart summary, status card, sticky footer.
- **SlipScannerDialog** — Camera lifecycle management, debounce, error overlays, colored borders.

### Added

- `SettingsLocalDatasource.setAll()` — atomic multi-key batch write.
- `Product` fields — `sku`, `barcode`, `cost`.
- `PromptPayQrCode` — EMVCo payload via `thai_promptpay` library.
- `PromptPayPaymentPage` — fullscreen payment page (replaces `AlertDialog`).
- `SlipScannerDialog` — QR camera scanner with slip verification.
- `SlipVerifier` + `SlipErrorType` — bank slip Mini-QR decoding.
- `SoundPlayer` — confirmation audio feedback.
- `PaymentConfig` settings — `defaultQrType`, `autoConfirmAfterSlip`, `qrOverlayIcon`.
- `Sale` fields — `paymentReference`, `sendingBankCode`.
- `ReportPromptPayCard` — Thai bank name chip.
- `Validators.promptpayId()` — mod-11 + mobile prefix validation.
- Tap QR → fullscreen view (320px, dark overlay).
- Customizable QR overlay icon — 8 choices, default none, 12% size for scannability.

### Changed

- `SaleBloc.close()` — awaits `_immediateSave()`.
- `SaleBloc._scheduleSave` — debounce 500ms → 1500ms.
- `SettingsRepositoryImpl.save()` — uses `setAll()` for atomic writes.
- `SettingsPersistenceService.dispose()` — `Future<void>`, saves before close.
- `DiscountConfig.activeDiscountPreset` — returns default on empty list.
- `voidSale` — `balanceAfter: -1` for deleted products.
- `CheckoutBody` — PromptPay pushes `PromptPayPaymentPage`; records `amountReceived` for non-cash.
- Theme colors — hardcoded `Colors.xxx` → `colorScheme`.
- All user-facing strings → l10n ARB keys.

### Fixed

- `sendingBankCode` missing from `Sales` Drift table.
- `sendingBankCode` not wired through `SalePaymentConfirmed` → DB.
- `PromptPayConfirmationDialog` `LayoutBuilder` crash → replaced with page.
- `buildPromptPayQrPayload` unhandled `FormatException` in `build()`.
- Duplicate QR in checkout (inline + dialog).
- `SlipScannerDialog` no camera permission error handling.
- Draft data loss on `SaleBloc.close()`.
- Settings partial write / data loss on `dispose()`.
- `AppSettings.copyWith` reset `receiptSize`.
- `ReportCalculator.topProducts()` merged duplicate names.
- `activeDiscountPreset` crash on empty list.
- Product form defaults to 0 on parse failure.
- `querySales` unnecessary transaction.
- `deleteDraft` orphaned items.
- Cart qty accepts `0` without feedback.
- PromptPay missing from checkout / QR not generated / ID unused.
- PromptPay ID validation (no mod-11, no prefix checks).
- Onboarding accepted invalid PromptPay ID.
- `SaleReceiptDialog` stale `context` after async print/share.
- Timer progress bar no animation (`_lastProgress`).
- Status card showed raw bank code → Thai bank name.
- Sticky footer overlapped keyboard.
- QR pulse `ScaleTransition` clip.
- Missing accessibility labels.
- AppBar redundant spacing.
- Status didn't reset on reference clear.
- Cart "Show more" with exactly 5 items.

`flutter analyze` → **0 issues** · `flutter test` → **339/339 passing**

---

## [0.7.3] - 2026-06-08

Settings Clean Architecture + widget decomposition of 9 largest presentation pages + domain logic extraction.

### Highlights

- **Settings Aggregate Root** — `Settings` with 12 typed group entities; `SettingsMapper` for serialization; `SettingsPersistenceService` owns debounce + save logic.
- **Domain Scaffolding** — Failure types for all 6 non-settings features; missing Sale Use Cases (`GetSales`, `GetSaleById`, `WatchSales`, `WatchRecentSales`).
- **Widget Decomposition** — 9 pages refactored, 16 widgets extracted (~3,800 lines moved from pages → widgets/domain).
- **Report Domain Logic** — `_completedSales`, `_netRevenue`, `_byMethod`, `_topProducts` moved to `ReportCalculator` extension on `List<Sale>`.

### Added

- `Settings` aggregate root + 12 typed group entities + `SettingsMapper` + `SettingsPersistenceService`.
- Settings Use Cases — `GetSettings`, `UpdateSettings`, `UpdateSettingGroup` with `SettingsFailure` types.
- Failure types — `SaleFailure`, `ProductFailure`, `DailyCloseFailure`, `InventoryFailure`, `HistoryFailure`, `ReportFailure`.
- Sale Use Cases — `GetSales`, `GetSaleById`, `WatchSales`, `WatchRecentSales`.
- Extracted widgets — `OnboardingHeroSection`, `OnboardingSection`, `GreenChoiceChip`, `OnboardingSheetOption`, `CartItemCard`, `CartDetailRow`, `CartQtyButton`, `CartDottedLineRow`, `CompactCartFab`, `ImagePreviewCard`, `DemoImagePreview`, `BackupStatusCard`, `BackupInfoCard`, `DailyCloseDateCard`, `DailyCloseSummaryCard`, `DailyCloseReconciliationCard`, `DailyCloseSummaryRow`, `DailyCloseReadOnlyRow`, `ProductCategoryAutocomplete`, `PromptpayPreviewCard`, `PromptpayInfoCard`, `ReportDateRangeCard`, `ReportPaymentMethodCard`, `ReportTopProductsCard`.
- Domain extension — `ReportCalculator` on `List<Sale>`.
- Widget tests for all 16 extracted widgets + `ReportCalculatorTest`.

### Changed

- `SettingsRepositoryImpl` — returns `Settings` aggregate via `SettingsMapper`; serialization delegated to mapper.
- `AppSettings` — marked `@Deprecated` as facade over `Settings`.
- `SettingsCubit` → delegates persistence to `SettingsPersistenceService`.
- `DailyCloseCubit`, `ProductImageService`, `SaleBloc` — updated to typed group accessors.
- 9 pages decomposed — `onboarding`, `cart_review`, `image_settings`, `backup_settings`, `daily_close`, `sale_page` (renamed from `sale_page_redesign`), `product_form`, `promptpay_settings`, `report_page`.

### Fixed

- Updated all consumers to typed group accessors or `@Deprecated` facade pattern.
- Removed dead code (old private widget classes) from 8 refactored pages.
- `SettingsRepositoryImplTest` — mocks `getAll()` instead of individual getters.

`flutter analyze` → **0 issues** · `flutter test` → **337/337 passing**

---

## [0.7.2] - 2026-06-08

Data resilience and cart UX — sync columns, backup encryption, settings hierarchy, and button animations

### Highlights

- **Sync Columns** — Schema v11→v12; all 6 tables carry `updatedAt`, `deletedAt`, `version`, `deviceId`.
- **Backup Encryption** — AES-256-GCM with PIN-derived PBKDF2 key; toggle in Settings → Backup.
- **Crash Recovery** — Immediate draft save on critical events; debounce 1500ms → 500ms.
- **Cart UX Polish** — Full-screen drag, pinned summary, larger touch targets, ultra-compact items, Normal↔Ultra toggle.
- **Settings Hierarchy** — 3-level navigation: topic groups → sub-topics → individual pages + cross-sub-topic search.

### Added

- `BackupEncryptionService` (AES-256-GCM, PBKDF2) + setting + UI toggle.
- `AppTextDialog` reusable widget with auto-managed `TextEditingController`.
- Sync columns on `SaleItem`, `DailyClose`, `InventoryLog`, `DraftCart` + schema v11→v12 migrations.
- `AppSplashScreen` + `AppSplashWrapper` animated loading with shimmer skeletons.
- 3-level Settings hierarchy (Root → SubTopic → Page) with flattened search.
- `PopScope` double-tap back-to-exit on `_MainShell`.
- `searchSettings`, `appTagline`, `loading` l10n keys.

### Changed

- `SaleBloc` — `_immediateSave()` on cart clear/restore/close; debounce 500ms.
- `SaleBloc._scheduleSave` / `_immediateSave` — `await` + `try-catch` + `debugPrint` (was fire-and-forget).
- Settings hierarchy — Flat 12 tiles → 3-level groups (General, Store, Payment, System).
- Onboarding `_skip()`/`_finish()` — Uses `SettingsCubit.updateField()` instead of direct `repo.save()`.
- `CartBottomSheet` — `CustomScrollView` → `Column` + `ListView.builder` with sheet `scrollController`; drag-to-expand now works.
- `CartBottomSheet` summary — Moved out of scroll into pinned bottom `Container` with `bottomInset` padding.
- `CartItemRow` redesign — Single-row 3-zone layout (info | stepper | price), `surfaceContainerLow` card, inline discount chip, removed top-right delete button & drag handle.
- `CartQtyStepper` — Height 48→36px, button 32×32px, font titleMedium, tighter container.
- `CartPanel` — Removed search/filter system (search field, query state, filter method).
- CartHeader toggle — `cubit.update()` → `cubit.updateField()`; cycles Normal↔Ultra only.
- `_CompactCartFab` — Added `onLongPress` to exit compact mode; bounce animation on count change, badge pulse, total cross-fade, press scale.
- `CartQtyStepper` — `_StepperButton`: press scale animation (0.85×), haptic feedback, `primaryContainer` background.
- `CartBottomSheet` — Background `surface`; summary background `surface` + shadow (matches `CartTotalBar`); discount button `TextButton.icon` (matches normal cart); checkout haptic; delete `IconButton.filledTonal` with `errorContainer`.
- `CheckoutBody` confirm — haptic feedback on press.
- `CartReviewPage._QtyButton` — press scale animation + haptic.
- Theme migration — hardcoded `Colors.xxx` → `AppColors` tokens in Settings module (5 files).
- All list pages use `AppEmptyState` consistently.

### Fixed

- N+1 queries → batch `IN` in `listDrafts`, `insertSaleWithItems`, `voidSale`.
- Dialog `TextEditingController` disposal crash — reverted `.whenComplete(() => ctrl.dispose())` (17 files).
- Silent failures → `debugPrint` in `HistoryBloc`, `DailyCloseCubit`, `AppDatabase`, `ReportCubit`, etc.
- `DailyCloseRepositoryImpl._toData` — `DateTime?` fallback for `updatedAt`.
- Unsafe parse crash → `double.tryParse`/`int.tryParse` in `ProductFormPage` and `AdjustStockDialog`.
- `DraftCart` getters — manual `double.parse` → `MoneyUtils.round()`.
- `CartBottomSheet` checkout — `ProviderNotFoundException` via `BlocProvider.value` wrapping.
- Schema v12 — v11 added DateTime as TEXT ISO8601; v12 converts to millisecondsSinceEpoch via `strftime('%s') * 1000`.
- Locale change — Pops back to `SettingsRootPage` to prevent stale language on sub-pages.

### Tests

- `BackupEncryptionService` — 7 tests (encrypt, decrypt, verify, error cases).

`flutter analyze` → **0 issues** · `flutter test` → **286/286 passing**

---

## [0.7.1] - 2026-06-05

Business operations — daily close, onboarding, DB health, and compact POS layout

### Highlights

- **Daily Close** — End-of-day cash reconciliation with sales summary, payment breakdown, and reopen support.
- **Onboarding Wizard** — First-launch setup flow for shop profile, locale, tax, and PromptPay with vertical card layout.
- **DB Health Dashboard** — File size, per-table row counts, and one-tap VACUUM in Settings.
- **Compact Cart Mode** — Floating cart icon with bottom sheet for compact POS layout (toggle in Settings → General).
- **Global Theme Unification** — Premium green/dark palette (`#00C853`) across the entire app.

### Added

- `DailyClose` domain entity, repository, use case, cubit, and DI wiring (full Clean Architecture stack).
- `DailyCloseListPage` / `DailyClosePage` with local `sl<T>()` + `BlocProvider.value` injection.
- `OnboardingPage` — 6-step first-launch flow generating `deviceId` (UUIDv4) and `devicePrefix` (3-char); skippable.
- `DbHealthPage` — Settings → Database Health with file size, row counts, large-DB warnings (>50MB), and VACUUM action.
- `CartBottomSheet` — Floating cart bottom sheet for Compact Cart Mode with +/- qty, delete, and checkout.
- 6 new `AppSettings` fields — `deviceId`, `devicePrefix`, `onboardingCompleted`, `dailyCloseLock`, `lastClosedDate`, `compactCartMode`.
- Schema migration v8→v10; `daily_closes` table gains `payment_breakdown` (JSON), `vat_amount`, `discount_amount`, nullable `closed_at`.
- Sales lock — `dailyCloseLock` blocks checkout when the current day is closed.
- l10n parity — All Daily Close, Onboarding, DB Health, and Compact Cart strings in Thai + English.
- Phase 4 Readiness Audit — Documented in `CODEBASE.md`; 4 of 9 tables sync-ready.

### Changed

- `OnboardingPage` UX — Vertical-scroll single-page layout with 4 card sections, theme-aware background, and consolidated language/theme bottom sheet. Shop name now optional. All colors now read from `Theme.of(context).colorScheme`.
- Settings dashboard quick toggles — Tap language badge to toggle TH/EN, tap theme badge to cycle light → dark → system.
- `SettingsPage` index numbering — Shifted to accommodate Daily Close and DB Health tiles in System & Data group.
- **Global theme unification** — `AppColors.primary` → `#00C853`, dark background `#0D1117`; card radius → 16px, button/input radius → 12px. `SettingsThemeExtension.softAccent` → `#00C853`/`#00E676`.
- Settings readability — Dashboard card gradient raised (0.18→0.35), badge backgrounds (0.12→0.20); icon container dark background → `#0D2B1A`.
- Cart panel — Empty state icon color → `onSurfaceVariant`; replaced `Card` wrapper with `Container` + border.
- Cart header — Reduced vertical padding (6px → 4px).
- `CODEBASE.md` — Updated to schema v10; added Daily Close, Onboarding, DB Health, and CartBottomSheet modules.

### Fixed

- `accessibilityMode` persistence — Present in `AppSettings` entity but never saved/loaded by `SettingsRepositoryImpl`; now persisted correctly.
- `DropdownButtonFormField` deprecation — Replaced deprecated `value` with `initialValue` in Onboarding locale step.
- `DailyCloseData` const analyzer info — Added `const` to test constructors.
- `DailyClose.copyWith` — Fixed nullable field clearing (`closedAt`, `note`, `deviceId`) when explicitly passed as `null`.
- Hardcoded colors — Removed all hardcoded `Color(0xFF...)` outside `lib/core/theme/`; `Colors.red/orange/green` replaced with `colorScheme.error/primaryContainer`.

### Tests

- `DailyClose` entity equality, repository data mapping, cubit state transitions.
- `CloseDay` and `ReopenDay` use cases.

`flutter analyze` → **0 issues** · `flutter test` → **279/279 passing**

---

## [0.7.0] - 2026-06-04

Full Settings UX overhaul — dashboard cards, visual pickers, validation, and grouped sections across all pages

### Highlights

- **Elderly-Friendly Settings Redesign** — Single soft-accent palette replaces 10 garish colors. Larger touch targets (48dp icons, 64dp tiles), bigger fonts (16px titles, 14px subtitles), and real-time search on root page.
- **Dashboard Cards on Every Page** — Gradient preview cards with status badges for Backup (Safe/Warning/Overdue), PromptPay (Active/Not set), and General (language, theme, accessibility).
- **Visual Dialog Pickers & Validation** — Language and theme selection moved from inline `ChoiceChip`s to icon-based dialog cards. PromptPay ID validated (phone 10 digits / citizen ID 13 digits). Shop Info inline form with phone auto-format.
- **Settings Root Dashboard** — At-a-glance dashboard with 5 summary badges; categories grouped into `Store & Business`, `Payments`, `System & Data`; colored status chips on every tile.

### Added

- `SettingsThemeExtension` — Single `softAccent` palette with accessibility sizing tokens (`tileMinHeight`, `iconSize`, `tilePadding`).
- `ShopPreviewCard` — Live receipt preview; `ShopInfoForm` — inline form with dirty-state tracking, counters, and phone auto-format.
- `SettingsCategoryTile` — Tap scale feedback, `InkWell` ripple, value preview below subtitle; `SettingsSectionCard` — softer borders, larger titles.
- `accessibilityMode` field — Added to `AppSettings` (bool, default false).
- Settings search — Real-time category filtering by title/subtitle on root page.
- Dashboard cards — Gradient status cards for Backup (Safe/Warning/Overdue), PromptPay (Active/Not set), General (language/theme/badges), and root page (5-summary dashboard).
- Info cards — `_BackupInfoCard`, `_PromptpayInfoCard`, `_GeneralInfoCard` explaining feature usage.
- Visual dialog pickers — `_DialogOptionTile` for language/theme selection with icon, label, and selected highlight. PromptPay ID validation dialog (phone 10 digits / citizen ID 13 digits).
- Backup reminder Switch + frequency picker — `SwitchListTile` with dialog of preset `ChoiceChip` options (3/7/14/30 days) + custom input. "Backup Now" action tile.
- "Reset to Defaults" tile — Confirmation dialog restoring `locale: th`, `themeMode: system`, `accessibilityMode: false`.
- `_StatusChip` — Reusable colored badge; `SettingsCategoryTile.statusChip` parameter. Category grouping into `Store & Business`, `Payments`, `System & Data` sections.
- 32 new l10n keys — Backup, PromptPay, General, and Settings Root labels.

### Changed

- **Palette & touch targets** — 10 saturated category colors replaced by single `softAccent`. Titles 14→16px, subtitles 12→14px; icons 40→48dp, tile minHeight 64dp.
- **Settings pages rewritten** — Shop Info (inline form + preview), Backup (`SwitchListTile` + dialog picker), PromptPay (preview card + validation dialog), General (dialog pickers + reset tile), Root (dashboard + grouped sections + status chips).
- **Dropdown tiles** — Selected value shown as `subtitle` instead of trailing chip.
- **Receipt size** — Moved from PromptPay settings to Shop Info settings.
- `AppSettings.props` — 33 → 34 (accessibilityMode).
- `SettingsValuePreview` — Removed chip background; now plain bold `softAccent` text.

### Fixed

- `app_settings_test.dart` — `props.length` updated 33 → 34.
- `settings_page_test.dart` — Category tile count adjusted for new layout.

### Tests

- Settings root page renders with search and category tiles.
- Settings root page shows ≥7 `SettingsCategoryTile` widgets.
- Shop Info form validation, dirty state, and save flow.
- Existing Cubit/repo/datasource tests unchanged (27 settings tests passing).

`flutter analyze` → **0 issues** · `flutter test` → **258/258 passing**

---

[0.7.6]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.5...v0.7.6
[0.7.5]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.4...v0.7.5
[0.7.4]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.3...v0.7.4
[0.7.3]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.2...v0.7.3
[0.7.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.6.3...v0.7.0
