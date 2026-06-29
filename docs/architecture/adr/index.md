# Architecture Decision Records (ADRs) — Promsell POS CE v0.8.8

All architecture decision records, ordered by ADR number.

> **Main reference:** [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md) — index + TOC
> **C4 diagrams:** [`docs/architecture/c4-diagrams.md`](../architecture/c4-diagrams.md) — system context, container, component, data flows
> **Technical deep-dive:** [`docs/architecture/technical-deep-dive.md`](../architecture/technical-deep-dive.md) — state management, DI, transactions, error handling, performance

---

## Index

| ADR | Title | Version |
|-----|-------|---------|
| [ADR-001](#adr-001-drift-over-raw-sqlite) | Drift over raw SQLite | — |
| [ADR-002](#adr-002-bloc--cubit-hybrid) | BLoC + Cubit hybrid | — |
| [ADR-003](#adr-003-injectable--get_it-for-di) | injectable + get_it for DI | — |
| [ADR-004](#adr-004-services-run-inside-callers-transaction) | Services run inside caller's transaction | — |
| [ADR-005](#adr-005-receipt-number-generated-inside-transaction) | Receipt number generated inside transaction | — |
| [ADR-006](#adr-006-inventory-logs-are-immutable-append-only) | Inventory logs are immutable append-only | — |
| [ADR-007](#adr-007-soft-voided-sales-not-hard-deleted) | Soft-voided sales, not hard-deleted | — |
| [ADR-008](#adr-008-feature-first-folder-structure) | Feature-first folder structure | — |
| [ADR-009](#adr-009-deferred-route-push-after-modal-pop-addpostframecallback) | Deferred route push after modal pop | — |
| [ADR-010](#adr-010-draft-cart-auto-save-via-timer-debounce-in-bloc) | Draft cart auto-save via Timer debounce | — |
| [ADR-011](#adr-011-discount-applied-before-vat-pretaxtotal) | Discount applied before VAT | — |
| [ADR-012](#adr-012-pure-dart-image-compression-over-native-plugin) | Pure Dart image compression | — |
| [ADR-013](#adr-013-checkoutbody-extraction-with-dynamic-total-from-checkoutbloc) | CheckoutBody extraction with dynamic total | v0.6.1 |
| [ADR-014](#adr-014-productimageservice-coupling-is-not-an-architectural-issue) | ProductImageService coupling is not an issue | — |
| [ADR-015](#adr-015-sync-ready-columns-on-all-core-tables) | Sync-ready columns on all core tables | v0.7.2 |
| [ADR-016](#adr-016-backup-encryption-with-aes-256-gcm) | Backup encryption with AES-256-GCM | — |
| [ADR-017](#adr-017-settings-hierarchy-revised-in-v081) | Settings hierarchy (revised) | v0.8.1 |
| [ADR-018](#adr-018-settings-aggregate-root-with-typed-group-entities) | Settings aggregate root with typed groups | v0.7.3 |
| [ADR-019](#adr-019-widget-decomposition-and-domain-logic-extraction) | Widget decomposition and domain logic extraction | — |
| [ADR-020](#adr-020-generated-code-size-appdatabasegdart) | Generated code size | — |
| [ADR-021](#adr-021-product-preview-page-v084) | Product Preview Page | v0.8.4 |
| [ADR-022](#adr-022-generated-code-untracked-from-git-v085) | Generated code untracked from git | v0.8.5 |
| [ADR-023](#adr-023-dependency-vulnerability-scanning-v085) | Dependency vulnerability scanning | v0.8.5 |
| [ADR-024](#adr-024-widget-folder-standardization-v085) | Widget folder standardization (feature + core) | v0.8.5 |
| [ADR-025](#adr-025-ean13generator-injectable-instance-v086) | Ean13Generator injectable instance | v0.8.6 |
| [ADR-026](#adr-026-barcode-image-rendering-via-repaintboundary-v086) | Barcode image rendering via RenderRepaintBoundary | v0.8.6 |

---

## ADR-001: Drift over raw SQLite

**Context:** Need type-safe database access with code generation.

**Decision:** Use Drift (formerly Moor) as SQLite ORM.

**Consequences:**
- ✅ Type-safe queries, compile-time schema validation
- ✅ Built-in migration support
- ✅ Reactive streams via `watch()` with SQLite update hooks
- ✅ In-memory DB for testing (real SQL execution)
- ⚠️ Requires code generation step (`build_runner`)
- ⚠️ Generated file is large (~290KB)

---

## ADR-002: BLoC + Cubit hybrid

**Context:** Need state management that scales from simple settings to complex sale flows.

**Decision:** Use `flutter_bloc` with BLoC for complex event-driven flows and Cubit for simple state.

**Consequences:**
- ✅ Testable (event→state is deterministic)
- ✅ Separation: UI dispatches events, never calls business logic directly
- ✅ Cubit reduces boilerplate for simple cases
- ⚠️ Learning curve for event/state pattern

---

## ADR-003: injectable + get_it for DI

**Context:** Need dependency injection with compile-time safety.

**Decision:** Use `injectable` annotations + `get_it` service locator with code generation.

**Consequences:**
- ✅ Compile-time dependency graph verification
- ✅ Annotations (`@injectable`, `@LazySingleton`, `@lazySingleton`, `@module`) are self-documenting
- ✅ Generated config in `injection_container.config.dart`
- ✅ Singleton + factory + lazy patterns supported
- ⚠️ Requires `build_runner` code generation step

---

## ADR-004: Services run inside caller's transaction

**Context:** `ReceiptNumberService` and `InventoryLogService` need to participate in atomic transactions.

**Decision:** Services accept the ambient transaction context — they never open their own `_db.transaction()`.

**Consequences:**
- ✅ Atomic: receipt + sale + items + logs all commit or all rollback together
- ✅ No nested transaction issues (SQLite doesn't support savepoints well in all scenarios)
- ✅ Testable: service can be tested with its own transaction in isolation
- ⚠️ Caller must ensure transaction is open before calling service

---

## ADR-005: Receipt number generated inside transaction

**Context:** Need unique receipt numbers without collisions under concurrent access.

**Decision:** Generate receipt number inside the sale transaction by reading/incrementing `app_settings` counter.

**Consequences:**
- ✅ Serialized by transaction lock — impossible to get duplicate numbers
- ✅ Daily reset via date comparison inside same atomic operation
- ✅ Format (`YYMMDD-XX-NNNN`) is human-readable and sortable
- ⚠️ Slight serialization overhead (transactions queue)

---

## ADR-006: Inventory logs are immutable append-only

**Context:** Need audit trail for all stock mutations.

**Decision:** `inventory_logs` table is append-only — no UPDATE or DELETE ever.

**Consequences:**
- ✅ Complete audit history — can reconstruct stock balance at any point in time
- ✅ Tamper-evident — any gap in logs indicates data corruption
- ✅ `balanceAfter` provides running total without aggregation query
- ⚠️ Table grows indefinitely (acceptable for POS scale — see DB size estimates)

---

## ADR-007: Soft-voided sales, not hard-deleted

**Context:** Voided sales must remain in history for audit purposes.

**Decision:** Void sets `status=VOIDED` + `voidedAt` timestamp — never DELETE the sale row.

**Consequences:**
- ✅ Full audit trail preserved
- ✅ Report filtering by status is trivial (`WHERE status = 'COMPLETED'`)
- ✅ UI can show voided sales with visual indicator
- ⚠️ History list grows (mitigated by date-range filtering)

---

## ADR-008: Feature-first folder structure

**Context:** Need clear module boundaries as app grows through R1–R5 phases.

**Decision:** `lib/features/<name>/` with Clean Architecture layers inside each feature.

**Consequences:**
- ✅ Each feature is self-contained (can be understood in isolation)
- ✅ No cross-feature imports enforced by convention
- ✅ Easy to add new features without touching existing ones
- ⚠️ Some code duplication across features (acceptable trade-off for isolation)

---

## ADR-009: Deferred route push after modal pop (addPostFrameCallback)

**Context:** Both a modal bottom sheet (`PaymentSheet`) / full-screen page (`CheckoutPage`) and its parent page (`_CartPanel`) listen to `CheckoutBloc`. On `SaleStatus.success`, the parent listener (subscribed first) pushes a receipt dialog before the modal/page listener can pop. `Navigator.pop()` then removes the dialog, not the modal — leaving it open and `_submitted = true` permanently.

**Decision:** Wrap any `showDialog` call in the parent `BlocListener` with `WidgetsBinding.instance.addPostFrameCallback`. The dialog push is deferred to the next frame, after the modal/page's `Navigator.pop()` has already run. Applies to both `PaymentSheet` (legacy bottom sheet) and `CheckoutPage` (v0.6.1+ full-screen page).

**Consequences:**
- ✅ Modal always closes correctly before the receipt dialog appears
- ✅ No change to the BLoC or event model
- ✅ Single-line fix — zero architectural overhead
- ⚠️ Slight one-frame delay before the dialog is visible (imperceptible at 60+ fps)

---

## ADR-010: Draft cart auto-save via Timer debounce in BLoC

**Context:** Cart state changes rapidly on every tap (add item, change qty, apply discount). Saving to SQLite synchronously on every event would cause write thrashing.

**Decision:** Use a `Timer?` field in `DraftBloc`. Every cart-mutating handler cancels the previous timer and schedules a new 1.5 s save (increased from 500 ms in v0.6.1 to reduce write pressure). The save captures `state.activeDraftId` at schedule time and validates it's still the same draft at fire time.

**Consequences:**
- ✅ Batches rapid edits into a single write
- ✅ No lost state — even a crash within the 1.5 s window only loses the last 1.5 s of changes
- ✅ `Timer` is cancelled in `close()` to prevent post-dispose writes
- ⚠️ `DraftBloc` timer lifecycle is managed by `@lazySingleton` — single shared instance, timer cancelled in `close()`

---

## ADR-011: Discount applied before VAT (preTaxTotal)

**Context:** Merchants expect discounts to reduce the taxable amount, not the final total.

**Decision:** VAT is calculated on `preTaxTotal = itemsSubtotal - cartDiscountAmount`, not on the raw sum of item prices.

```
preTaxTotal = sum(item.subtotal) - cartDiscountAmount
INCLUSIVE: subtotal = preTaxTotal / (1 + vatRate)
EXCLUSIVE: finalTotal = preTaxTotal + (preTaxTotal * vatRate)
```

**Consequences:**
- ✅ Correct tax semantics (discount reduces taxable base)
- ✅ Receipt math is consistent: subtotal + VAT = total
- ✅ Per-item `discountAmount` stored at sale time for accurate historical reprints
- ⚠️ Payment sheet must read `SaleState.total` (preTaxTotal) not the raw `itemsSubtotal`

---

## ADR-012: Pure Dart image compression over native plugin

**Context:** Product image compression previously used `flutter_image_compress` (native platform channels). This added a native dependency, complicated the build, and couldn't be configured at runtime.

**Decision:** Replace with the `image` package (pure Dart). Compression settings (`imageMaxWidth`, `imageQuality`) are stored in `Settings` and read via `SettingsCubit`, allowing merchant configuration without app rebuild.

**Consequences:**
- ✅ No native dependency — simpler build, no platform channel issues
- ✅ Runtime-configurable quality/size via settings
- ✅ Thumbnail generation in same pass (200px + full size)
- ✅ `CachedNetworkImage` replaces `Image.network` for better UX (placeholder, error widget, disk cache)
- ✅ Async file existence check replaces sync `existsSync()` — no frame jank
- ⚠️ Pure Dart decoding is slower than native libyuv for very large images (acceptable for POS photo scale)
- ⚠️ `image` package increases APK size by ~2MB (wasm/JS decoder)

---

## ADR-013: CheckoutBody extraction with dynamic total from CheckoutBloc

**Context:** v0.6.1 introduces a full-screen `CheckoutPage` and interactive `CartReviewPage` where merchants can edit quantities mid-checkout. Previously `CheckoutPage` and `PaymentSheet` received static `preTaxTotal`/`vatInfo` as constructor parameters — these became stale after returning from `CartReviewPage`.

**Decision:** Extract shared payment UI into `CheckoutBody` (stateful widget). Remove static `preTaxTotal`/`vatInfo` parameters from `CheckoutPage`, `PaymentSheet`, and `CheckoutBody`. The effective total is computed dynamically on every build by reading the live `CheckoutBloc` state via `context.read<CheckoutBloc>()`. This ensures:
- `CartReviewPage` quantity changes immediately reflect in `CheckoutPage` upon return
- `CheckoutBody` is reusable by both `CheckoutPage` (full-screen) and `PaymentSheet` (bottom sheet wrapper)
- Quick amount chips, change calculation, and `canConfirm` logic all use the live `_effectiveTotal`

**Consequences:**
- ✅ Total is always fresh — no stale parameters
- ✅ Single source of truth (`CheckoutBloc` state) for all checkout widgets
- ✅ `CheckoutBody` is framework-agnostic to its container (page or sheet)
- ⚠️ `CheckoutBody` must be placed inside a `BlocProvider<CheckoutBloc>` scope (enforced by `BlocBuilder` assertion at runtime)
- ⚠️ Slightly more build-time computation (total recomputed on every frame) — negligible for POS-scale cart sizes

---

## ADR-014: ProductImageService coupling is not an architectural issue

**Context:** During the Phase 4 audit (A6), `ProductImageServiceImpl` was flagged as potentially coupled to `SettingsCubit` because it reads `imageMaxWidth` and `imageQuality` settings. Investigation revealed that the service depends on `SettingsRepository` (injected via `injectable`), **not** `SettingsCubit`. This follows the existing Clean Architecture layer rule: data/services depend on domain repository interfaces, never on presentation-layer cubits.

**Decision:** No code change required. The perceived coupling was a false positive. The dependency graph is correct: `ProductImageServiceImpl` → `SettingsRepository` → `SettingsLocalDatasource`.

**Consequences:** No action needed. Future reviews should verify the actual dependency graph before flagging coupling concerns.

---

## ADR-015: Sync-ready columns on all core tables

**Context:** v0.7.2 prepares for future cloud sync by adding `updatedAt`, `deletedAt`, `version`, and `deviceId` columns to all 6 core tables (`products`, `sales`, `sale_items`, `inventory_logs`, `daily_closes`, `draft_carts`).

**Decision:** Add columns via schema migration v11→v12. Use `DateTime` (TEXT ISO8601 in v11, millisecondsSinceEpoch in v12). All repositories update `updatedAt` and `version` on writes. Soft deletes set `deletedAt` instead of removing rows.

**Consequences:**
- ✅ Tables are sync-ready without future schema changes
- ✅ Immutable audit trail preserved (soft delete)
- ⚠️ Migration complexity: v11→v12 converts DateTime format
- ⚠️ All repository write methods must now update timestamp columns

---

## ADR-016: Backup encryption with AES-256-GCM

**Context:** Merchants requested encryption for SQLite backup exports to protect business data if backup files are shared or stored in cloud storage.

**Decision:** Implement `BackupEncryptionService` using AES-256-GCM with a key derived from a user-supplied PIN via PBKDF2 (100,000 iterations). Encryption is optional — toggle in Settings → Backup.

**Consequences:**
- ✅ Backups are unreadable without the PIN
- ✅ No external key storage needed (PIN is user-managed)
- ⚠️ Forgotten PIN = unrecoverable backup
- ⚠️ Adds `encrypt` / `pointycastle` dependencies

---

## ADR-017: Settings hierarchy (revised in v0.8.1)

**Context:** The Settings page grew from 5 tiles (v0.5.x) to 12 tiles (v0.6.x) to 20+ individual settings (v0.7.0). Flat list became unwieldy. Merchants struggled to find specific settings. Initially solved with 3-level navigation (v0.7.0), but user testing revealed 3 taps to reach any setting was excessive — especially for Payments (1 sub-topic) and General (2 sub-topics).

**Decision (v0.7.0):** Restructure into 3-level navigation: topic groups → sub-topics → individual pages.

**Revision (v0.8.1):** Flattened to 2-level hierarchy: section headers (General, Store & Sales, Discounts, Payments, System & Data, About) → individual pages. Removed `SettingsSubTopicPage` intermediary. Merged Discount Presets into Discount Policy page. Moved Barcode to General section. Added About section with in-app Privacy Policy and License pages.

**Consequences:**
- ✅ Every setting page is 1 tap from root — no intermediary navigation
- ✅ Search finds settings across all sections with grouped results
- ✅ Balanced sections (3-4 tiles each) — no overloaded or single-item groups
- ✅ About page provides version, privacy policy, and license info in-app (offline-first)
- ⚠️ Root page is longer — mitigated by section headers and search
- ⚠️ `SettingsSubTopicPage` and `DiscountPresetsPage` are now dead code (kept in repo for reference)

---

## ADR-018: Settings aggregate root with typed group entities

**Context:** v0.7.3 refactored Settings from a flat 30-field entity (`AppSettings`) to a typed aggregate root. Previously, settings were read/written as individual primitive fields with manual per-field serialization in `SettingsRepositoryImpl`. This made adding new settings tedious and error-prone.

**Decision:** Introduce `Settings` as an aggregate root with 13 typed group entities (`ShopInfo`, `ReceiptConfig`, `TaxConfig`, `DiscountConfig`, `StockConfig`, `ImageConfig`, `BarcodeConfig`, `PaymentConfig`, `DeviceConfig`, `UiConfig`, `DailyCloseConfig`, `BackupConfig`, `DraftConfig`). Centralize serialization in `SettingsMapper` (`Settings` ↔ `Map<String,String>`). Extract debounce persistence logic from `SettingsCubit` into `SettingsPersistenceService`.

**Consequences:**
- ✅ Adding a new setting only requires updating the relevant group entity + mapper key
- ✅ Type safety — no more raw string access for config values
- ✅ `SettingsMapper` normalizes legacy values (e.g., integer `themeMode` → string names)
- ✅ `SettingsPersistenceService` owns debounce Timer — `SettingsCubit` is now pure state management
- ⚠️ `AppSettings` facade removed in v0.8.1 — all consumers now use `Settings` aggregate root directly with flat getters + flat `copyWith`
- ⚠️ All repository tests must mock `getAll()` return values instead of individual getters

---

## ADR-019: Widget decomposition and domain logic extraction

**Context:** 9 presentation pages had grown to 300–900 lines each with deeply nested private widget classes and inline business logic. This made testing, navigation, and hot reload slow.

**Decision:** Extract private `_WidgetName` classes into public widgets in `features/<name>/presentation/widgets/`. Move business logic helper methods (e.g., `_completedSales`, `_netRevenue`, `_topProducts` from `ReportPage`) into domain layer extensions (`ReportCalculator` on `List<Sale>`). Add widget tests for each extracted component.

**Consequences:**
- ✅ Pages shrink by 50–70% (e.g., `report_page.dart`: 316 → 147 lines)
- ✅ Widgets are reusable across pages and testable in isolation
- ✅ Domain extensions are pure Dart — testable without Flutter binding
- ✅ Hot reload is faster (smaller build units)
- ⚠️ Extracted widgets may have different constructor signatures than their private predecessors
- ⚠️ Parent pages need import updates and may require Builder wrappers for context-dependent params

---

## ADR-020: Generated code size (app_database.g.dart)

**Context:** `lib/core/database/app_database.g.dart` is ~195 KB — a large generated file produced by `drift_dev` and `injectable_generator`. This raised concerns about build time, IDE navigation performance, and repository bloat.

**Decision:** Accept the generated code size as inherent to Drift's code-generation approach. No action taken to split the database or reduce generated output. The file is dev-dependency only (not shipped to end users) and has no runtime performance impact. WAL mode + index optimization (already in place) provides the actual runtime performance wins.

**Consequences:**
- ✅ No additional complexity from splitting tables into multiple database files
- ✅ Full type safety and reactive streams from Drift remain intact
- ✅ No regression in build time beyond current `build_runner` baseline
- ⚠️ `app_database.g.dart` continues to be a large file — mitigated in v0.8.5 by removing from git tracking (see ADR-022)
- ⚠️ IDE "go to definition" on generated Drift classes may be slower

---

## ADR-021: Product Preview Page (v0.8.4)

**Context:** Product cards previously navigated directly to the edit form on tap. Merchants wanted a read-only detail view to quickly check product information (price, stock, barcode, margins) without accidentally modifying data. Long-press was already used for quick actions.

**Decision:** Introduce `ProductPreviewPage` as a full-page read-only product detail view. Navigation pattern: tap → Preview, long-press → Edit Form. The preview page displays:
- Hero image with gradient overlay (260px) + product name, category, active status
- Price card: prominent selling price on `primaryContainer`, cost and profit (with margin %) as mini-stats
- Stock card: large stock number with color-coded status, stock value, inline edit button via `showQuickEditSheet`
- Codes card: SKU, barcode text, visual barcode rendering (`barcode_widget` — EAN13/EAN8/UPCA/Code128) with actions (view full image, save as PDF, print)
- System info card: product ID, created/updated timestamps

**Consequences:**
- ✅ Merchants can review product details without risk of accidental edits
- ✅ Visual barcode enables quick verification against physical products
- ✅ Inline stock edit from preview page reduces navigation for common adjustments
- ✅ Barcode PDF export (58mm label format) supports thermal label printers
- ⚠️ `barcode_widget` adds a new dependency
- ⚠️ `ModernProductTile` and `ModernProductGridCard` navigation changed — existing muscle memory may need adjustment

---

## ADR-022: Generated code untracked from git (v0.8.5)

**Context:** Generated files (`*.g.dart`, `*.config.dart`) were committed to git, causing large diffs, merge conflicts, and inflated repository size. `app_database.g.dart` alone was ~195 KB with thousands of lines.

**Decision:** Remove generated files from git tracking. Add `**/*.g.dart` and `**/*.config.dart` to `.gitignore`. Mark them as `linguist-generated=true` in `.gitattributes` to hide from GitHub PR diffs and language statistics. Contributors run `dart run build_runner build` after `flutter pub get` to generate locally.

**Consequences:**
- ✅ Smaller diffs — generated code no longer appears in PRs
- ✅ Fewer merge conflicts on generated files
- ✅ Reduced repository size
- ✅ GitHub language stats no longer skewed by generated Dart
- ⚠️ Contributors must run `build_runner build` after cloning or pulling
- ⚠️ CI must run `build_runner build` before analyze/test (already in place)

---

## ADR-023: Dependency vulnerability scanning (v0.8.5)

**Context:** The project had no automated dependency vulnerability scanning. Dependencies could fall behind by multiple major versions without detection, increasing security risk.

**Decision:** Add `tool/check_outdated.dart` to CI — parses `dart pub outdated --json` and fails if any direct dependency is behind by ≥ 1 major version. Configure Dependabot with `allow: dependency-type: "all"` for security + version updates. Document Dependabot security alert setup in `docs/DEPLOY.md`.

**Consequences:**
- ✅ CI catches stale dependencies before merge
- ✅ Dependabot automatically opens PRs for security vulnerabilities
- ✅ Documented setup process for maintainers
- ⚠️ CI may fail if a dependency is intentionally pinned to an older major version
- ⚠️ Dependabot PRs require review before auto-merge

---

## ADR-024: Widget folder standardization (v0.8.5)

**Context:** Both `features/*/widgets/` and `lib/core/widgets/` had grown to 19–36 flat files per folder with no subfolder organization. This made navigation difficult, obscured logical grouping, and contrasted with the already-organized `product_add/`, `product_form/`, `product_list/`, `product_preview/` subfolders.

**Decision:** Standardize all `widgets/` folders — both feature-level (`features/<name>/presentation/widgets/`) and core-level (`lib/core/widgets/`) — into subfolders grouped by functional domain. Each subfolder contains widgets that serve a shared purpose.

**Naming convention:** `<domain>/` — lowercase, descriptive of the widget group's function.

**Mandatory vs optional folders:**

| Folder type | Rule | When to create |
|-------------|------|----------------|
| **`<domain>/`** | **Mandatory** — always organize widgets into domain subfolders | Every `widgets/` folder (even 1–2 files go in a domain folder) |
| **`<widget>/`** | **Optional** — extracted subcomponents for large widgets (>300 lines) | When a widget file exceeds ~300 lines and contains extractable private widgets or helper logic |
| **`shared/`** | **Optional** — only when a widget is reused across 2+ domain subfolders | When cross-domain reuse exists |
| **`deprecated/`** | **Optional** — only when keeping backward-compat aliases (feature widgets only) | When a widget is replaced but still referenced |

> `deprecated/` is not expected in `core/widgets/` — deprecated core widgets are removed, not aliased.

**Target structure — feature widgets:**

```
features/<name>/presentation/widgets/
├── <domain>/        # MANDATORY — grouped by function (e.g., cart/, checkout/, forms/)
│   ├── <widget>/    # OPTIONAL — extracted subcomponents for large widgets (>300 lines)
│   │   ├── subcomponent_a.dart
│   │   └── subcomponent_b.dart
│   ├── widget_a.dart  # Main widget, composes subcomponents if <widget>/ exists
│   └── widget_b.dart
├── shared/          # OPTIONAL — only if a widget is used by 2+ domain subfolders
│   └── shared_widget.dart
└── deprecated/      # OPTIONAL — only if backward-compat aliases exist
    └── old_widget.dart
```

**Target structure — core widgets:**

```
lib/core/widgets/
├── <domain>/        # MANDATORY — grouped by function (not by feature)
│   ├── <widget>/    # OPTIONAL — extracted subcomponents for large widgets (>300 lines)
│   │   ├── subcomponent_a.dart
│   │   └── subcomponent_b.dart
│   ├── widget_a.dart  # Main widget, composes subcomponents if <widget>/ exists
│   └── widget_b.dart
└── shared/          # OPTIONAL — cross-domain reuse within core
    └── shared_widget.dart
```

**Rules:**
1. Every widget file MUST live inside a subfolder — no flat files in `widgets/` root
2. Domain subfolders are mandatory regardless of file count (even 1 file gets its own domain folder)
3. Widget-level subfolders (`<widget>/`) are optional — create only when a widget exceeds ~300 lines and has extractable private widgets or helper logic. The main widget file stays at `<domain>/<widget>.dart` and imports/composes subcomponents from `<domain>/<widget>/`
4. `shared/` is created only when a widget is imported by 2+ domain subfolders within the same `widgets/` folder
5. `deprecated/` is created only when a legacy class is kept as a thin alias for backward compatibility (feature widgets only)
6. Do NOT create empty `shared/` or `deprecated/` folders "just in case"
7. Core widgets: group by function, not by feature (core widgets are feature-agnostic). Single-file domains are acceptable (e.g., `nav/animated_nav_bar.dart`) — prefer descriptive folder over `misc/`

**Implementation status — feature widgets: ✅ Done**

| Feature | Status | Subfolders | Files moved |
|---------|--------|------------|-------------|
| **product** | ✅ Done | 9 subfolders | 19 files |
| **sale** | ✅ Done | `cart/` (11), `checkout/` (3), `catalog/` (2), `drafts/` (1), `payment/` (1), `shared/` (1) | 19 files |
| **settings** | ✅ Done | `forms/` (6), `cards/` (11), `tiles/` (9), `shared/` (10) | 36 files |
| **daily_close** | ✅ Done | `cards/` (3), `rows/` (2) | 5 files |
| **report** | ✅ Done | `cards/` (5) | 5 files |
| **onboarding** | ✅ Done | `sections/` (4) | 4 files |
| **history** | ✅ Done | `tiles/` (1) | 1 file |
| **inventory** | ✅ Done | `dialogs/` (1) | 1 file |

**Feature total: 71 files moved across 8 features, ~69 import paths updated.**

**Implementation status — core widgets: ✅ Done**

| Subfolder | Files | Count |
|-----------|-------|-------|
| `primitives/` | `app_badge`, `app_empty_state`, `app_loading_overlay`, `app_snack_bar`, `app_text_dialog`, `money_text`, `section_card`, `skeleton_card` | 8 |
| `barcode/` | `barcode_scanner_dialog`, `scan_overlay_painter` | 2 |
| `image/` | `image_source_sheet`, `image_viewer_dialog` | 2 |
| `search/` | `app_search_bar`, `search_empty_state`, `search_highlight_text`, `search_history_cubit`, `search_result_tile` | 5 |
| `layout/` | `adaptive_breakpoints`, `danger_zone_card`, `form_section_card`, `modern_toggle_card`, `sticky_action_bar` | 5 |
| `nav/` | `animated_nav_bar` | 1 |
| `receipt/` | `receipt_preview` | 1 |
| `splash/` | `app_splash_screen`, `app_splash_wrapper` | 2 |
| `stock/` | `stock_stepper` | 1 |

**Core total: 27 files moved, 65 import paths updated.**

**Combined: 98 files moved, 134 import paths updated, 0 analyze issues, 436 tests passing.**

**Consequences:**
- ✅ Consistent structure across all features and core — predictable file locations
- ✅ IDE navigation via folder expansion instead of scrolling flat lists
- ✅ Clear separation of concerns (e.g., `cart/` vs `checkout/` in sale)
- ✅ `deprecated/` folder isolates legacy aliases from active code
- ✅ Widget-level subfolders enable god file decomposition without cluttering domain folders
- ⚠️ All import paths across codebase must be updated (batch script approach)
- ⚠️ Cross-feature imports (e.g., `sale/` importing `product/widgets/product_tile/product_avatar.dart`) require careful path updates
- ⚠️ Core widgets have high blast radius — imported by every feature
- ⚠️ Test files may need import updates if they reference moved widgets

---

## ADR-025: Ean13Generator injectable instance (v0.8.6)

**Context:** `Ean13Generator` used a static mutable `_counter` field shared across all calls. This caused cross-test contamination (test order dependency) and prevented proper dependency injection.

**Decision:** Refactor to `@injectable` instance class. Counter state is now per-instance. `GenerateBarcode`, `BatchGenerateBarcodes`, and `SettingsCubit` receive `Ean13Generator` via constructor injection.

**Consequences:**
- ✅ Eliminates cross-test counter contamination — each test gets a fresh instance
- ✅ Enables mocking in unit tests via `mocktail`
- ✅ Follows existing DI patterns (`@injectable` for factory-scoped services)
- ✅ Counter persistence still works via `initCounter()` / `currentCounter` → Settings
- ⚠️ All call sites and tests must be updated to pass instance via constructor
- ⚠️ `build_runner build` required after annotation change

---

## ADR-026: Barcode image rendering via RenderRepaintBoundary (v0.8.6)

**Context:** `BarcodeImageService` used manual canvas drawing (`PictureRecorder` + `Canvas.drawRect` for each bar + `ParagraphBuilder` for text). This produced small, incomplete barcode images with inconsistent text rendering.

**Decision:** Replace manual canvas drawing with `BarcodeWidget` off-screen rendering via `RenderRepaintBoundary`. The widget tree is built off-screen using `RenderObjectToWidgetAdapter`, laid out via `PipelineOwner`, and captured with `repaintBoundary.toImage(pixelRatio: 3.0)`.

**Consequences:**
- ✅ Consistent rendering — uses same `BarcodeWidget` as on-screen display
- ✅ Higher quality — 600×200 @ 3x pixel ratio (was 400×160 @ 3x)
- ✅ Proper text rendering — `BarcodeWidget.drawText: true` handles font/layout automatically
- ✅ White background via `ColoredBox` wrapper
- ⚠️ Off-screen rendering requires `PipelineOwner` + `BuildOwner` setup — more complex than manual canvas
- ⚠️ Must call `flushLayout` / `flushCompositingBits` / `flushPaint` before `toImage()`
- ⚠️ Not unit-testable without a full Flutter binding (uses rendering infrastructure)

---

<sub>Promsell POS CE · v0.8.8 · Architecture Decision Records</sub>
