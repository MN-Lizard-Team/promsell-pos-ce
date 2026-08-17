# Technical Deep-Dive — Promsell POS CE (v0.9.3)

State management patterns, dependency injection graph, transaction boundaries, error handling strategy, and performance characteristics.

> **Main reference:** [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md) — index + TOC
> **C4 diagrams:** [`docs/architecture/c4-diagrams.md`](c4-diagrams.md) — system context, container, component, data flows
> **ADRs:** [`docs/architecture/adr/index.md`](adr/index.md) — all architecture decision records

---

## State Management Deep-Dive

### Pattern selection rationale

| Pattern | Used by | Why chosen |
|---------|---------|------------|
| **BLoC** (event-driven) | `CartBloc`, `DraftBloc`, `CheckoutBloc`, `ProductBloc`, `CategoryBloc`, `HistoryBloc` | Multiple event types, complex async flows, stream subscriptions |
| **Cubit** (method-driven) | `SettingsCubit`, `ReportCubit`, `InventoryLogCubit`, `ProductFormCubit` | Simple state or stream-based data, no event classes needed, direct method calls |

### BlocListener ordering caution

Multiple `BlocListener`s subscribed to the same BLoC receive emissions in **subscription order**. When a modal (via `showModalBottomSheet`) and its parent page both listen to the same BLoC, the parent listener fires first because it was registered earlier. If the parent listener pushes a new route while the modal listener tries to pop, the pop removes the newly pushed route instead of the modal, leaving the modal open. The fix is to defer any push from the parent listener using `WidgetsBinding.instance.addPostFrameCallback`, giving the modal's pop time to execute in the current frame first.

### Singleton vs Factory BLoCs

| Registration | Instance | Reason |
|-------------|----------|--------|
| `@LazySingleton` | `ProductBloc` | Shared across Sale + Product tabs — same product list everywhere |
| `@LazySingleton` | `CategoryBloc` | Shared across Product + Category Management — same category list everywhere |
| `@LazySingleton` | `CartBloc`, `DraftBloc`, `CheckoutBloc` | Shared single instances across SalePage, cart sheet/review, CheckoutPage/PaymentPage — prevents split-brain state |
| `@LazySingleton` | `SettingsCubit` | Global app state (locale, theme) — must persist across navigation |
| `@LazySingleton` | `ReportCubit` | Persistent singleton — date range preserved across tab navigation; `load()` called once in `ReportPage.initState()` |

### State immutability

All state classes extend `Equatable` for:
- **Efficient rebuilds** — `BlocBuilder` only rebuilds when state actually changes
- **Predictable testing** — state comparison via value equality
- **Debug logging** — meaningful `toString()` output

### Stream lifecycle

```
HistoryBloc subscribes → WatchSaleHistory → Drift watchQuery (SQLite trigger)
                                               ↓
                         Auto-emits new state when DB row changes
                                               ↓
                         UI rebuilds (e.g. VOIDED badge appears after void)
```

Drift's `watch()` queries use SQLite update hooks — no polling, no manual refresh needed.

---

## Dependency Injection Graph

Registered in `lib/core/di/injection_container.dart` via `injectable` + `get_it` (generated config in `injection_container.config.dart`).

```
┌─────────────────── BLoCs / Cubits ────────────────────────┐
│                                                           │
│  ProductBloc ──→ GetProducts, AddProduct,                 │
│                  UpdateProduct, DeleteProduct             │
│  CategoryBloc ──→ WatchCategories, AddCategory,           │
│                  UpdateCategory, DeleteCategory,          │
│                  ReorderCategories                        │
│  CartBloc ──→ (cart state, product add/remove/qty)        │
│  DraftBloc ──→ DraftCartRepository (persist/load drafts)  │
│  CheckoutBloc ──→ CreateSale only                         │
│  HistoryBloc ──→ VoidSale                                 │
│  SettingsCubit ──→ SettingsRepository, Ean13Generator     │
│  ReportCubit (lazySingleton) ──→ WatchReport              │
│  InventoryLogCubit ──→ WatchInventoryLogs                 │
│                                                           │
└──────────┬────────────────────────────────────────────────┘
           │
           │
┌──────────▼──────── Use Cases ────────────────────────────────────────────────┐
│                                                                              │
│  CreateSale ──→ SaleRepository                                               │
│  VoidSale ──→ SaleRepository                                                 │
│  AdjustStock ──→ InventoryRepository + AppLockService                        │
│  GetProducts / Add / Update / Delete ──→ ProductRepository                   │
│  GetProductsPage ──→ ProductRepository (cursor pagination)                   │
│  SearchProductsPage ──→ ProductRepository (DB search + in-memory rank)       │
│  GenerateBarcode ──→ ProductRepository + SettingsRepository + Ean13Generator │
│  BatchGenerateBarcodes ──→ ProductRepository + SettingsRepository +          │
│                           Ean13Generator                                     │
│  WatchCategories / Add / Update / Delete / Reorder ──→ CategoryRepository    │
│  GetSales / GetSaleById ──→ SaleRepository                                   │
│  GetSalesPage ──→ SaleRepository (cursor-paginated history)                  │
│  GetSalesCount ──→ SaleRepository (total count, optional date range)         │
│  GetReportSummary ──→ SaleRepository (SQL aggregate, no hydration)           │
│  WatchSaleHistory ──→ HistoryRepository                                      │
│  WatchSales / WatchRecentSales ──→ SaleRepository                            │
│  WatchReport ──→ ReportRepository                                            │
│  WatchInventoryLogs ──→ InventoryLogRepository                               │
│                                                                              │
└──────────┬───────────────────────────────────────────────────────────────────┘
           │
           │
┌──────────▼──────── Repositories ────────────────────────────┐
│                                                             │
│  SaleRepository ──→ SaleLocalDatasource                     │
│  ProductRepository ──→ ProductLocalDatasource               │
│                       ──→ ProductImageService               │
│                       ──→ BarcodeImageService               │
│  CategoryRepository ──→ CategoryLocalDatasource             │
│  HistoryRepository ──→ SaleLocalDatasource                  │
│  InventoryLogRepository ──→ InventoryLogLocalDatasource     │
│  SettingsRepository ──→ SettingsMapper                      │
│                        ──→ SettingsLocalDatasource          │
│                                                             │
└──────────┬──────────────────────────────────────────────────┘
           │
           │
┌──────────▼──────── Datasources & Services ──────────────────┐
│                                                             │
│  SaleLocalDatasource ──→ AppDatabase                        │
│       ├──→ ReceiptNumberService ──→ AppDatabase             │
│       └──→ InventoryLogService ──→ AppDatabase              │
│  SaleQueryLocalDatasource ──→ AppDatabase                   │
│       (querySalesPage, querySalesCount, queryReportSummary) │
│  ProductLocalDatasource ──→ AppDatabase                     │
│       (getProductsPage, searchProductsPage — cursor)        │
│  InventoryLogLocalDatasource ──→ AppDatabase                │
│  Ean13Generator (@injectable)                               │
│  ProductImageService ──→ SettingsRepository (image config)  │
│  BarcodeImageService ──→ BarcodeWidget off-screen render    │
│                       ──→ barcodes directory (PNG/JPEG)     │
│  ImageCacheService ──→ image directory (size tracking)      │
│  SettingsLocalDatasource ──→ AppDatabase                    │
│  ReceiptPdfService (stateless)                              │
│  PromptPayQrCode (stateless)                                │
│  SlipVerifier (stateless)                                   │
│  ReportExportService ──→ AppLockService                     │
│       (exportPdf, exportCsv, exportCsvStream — streaming)   │
│                                                             │
│  ── DB Lifecycle Services (@LazySingleton) ──               │
│  MigrationSafetyService ──→ AppDatabase + File System       │
│       (free-space preflight, migration status tracking)     │
│  WalCheckpointService ──→ AppDatabase + File System         │
│       (PASSIVE/TRUNCATE checkpoint, WAL size monitoring)    │
│  DatabaseHealthService ──→ AppDatabase + WalCheckpointSvc   │
│       (generateReport — sizes, integrity, guardrails)       │
│  BackupExportService ──→ AppDatabase + WalCheckpointSvc +   │
│       BackupEncryptionService + AppLockService              │
│       (size preflight, checkpoint, copy, SHA-256, encrypt)  │
│  BackupRestoreService ──→ AppDatabase + BackupEncryptionSvc │
│       + AppLockService + DbKeyStore                         │
│       (candidate validation, atomic stage + swap + rollback)│
│  RecoveryKitService ──→ DbKeyStore + Secure Storage         │
│       (AES-256-GCM key wrap, PBKDF2 100K in isolate)        │
│  BackupEncryptionService ──→ encrypt package (AES-256-GCM)  │
│                                                             │
└──────────┬──────────────────────────────────────────────────┘
           │
           │
┌──────────▼─────────────── Database ─────────────────────────┐
│                  AppDatabase (singleton)                    │
│                SQLite • Drift ORM • 16 tables               │
│             • schema v32 • WAL • FK ON • SQLCipher          │
└─────────────────────────────────────────────────────────────┘
```

### Registration order

1. **Database** (singleton — created once, shared)
2. **Datasources** (lazy — depends on DB)
3. **Services** (lazy — depends on DB)
4. **Repositories** (lazy — depends on datasources)
5. **Use Cases** (lazy — depends on repositories)
6. **BLoCs/Cubits** (singleton or factory)

---

## Transaction Boundaries

Every stock-mutating operation runs inside a **single Drift transaction** to guarantee atomicity.

| Operation | Transaction scope | Tables touched |
|-----------|------------------|----------------|
| **Create Sale** | 1 sale + N items + N stock updates + N logs + 1 receipt seq | `sales`, `sale_items`, `products`, `inventory_logs`, `app_settings` |
| **Void Sale** | 1 sale update + N stock restores + N reversal logs | `sales`, `products`, `inventory_logs` |
| **Adjust Stock** | 1 product update + 1 log | `products`, `inventory_logs` |
| **Backup Restore** | Atomic file swap (not a DB transaction) | File system: live DB → old, staged → live, WAL+SHM deleted |

### Design rules

1. **Services never open their own transactions** — they participate in the caller's ambient transaction
2. **Stock pre-validation happens before any writes** — prevents partial deductions
3. **Every stock change has a matching log** — enforced by service API design (no raw UPDATE allowed)
4. **Idempotency guard for void** — check `status != VOIDED` before proceeding
5. **Backup restore uses atomic file swap** — candidate is validated (schema, integrity, FK) before the live DB is touched; a pre-restore backup is kept for rollback if the swap fails
6. **WAL checkpoint before backup** — `forceTruncate()` acquires an exclusive lock so the backup copy is consistent

---

## Error Handling Strategy

### AppError value object (domain layer)

All domain-layer errors use the `AppError` sealed class for type-safe error handling:

```dart
sealed class AppError extends Equatable {
  const AppError();
}

// Domain Errors
final class ValidationError extends AppError { ... }      // message + field
final class NotFoundError extends AppError { ... }         // resource + id
final class BusinessRuleError extends AppError { ... }     // rule + details

// Infrastructure Errors
final class DatabaseError extends AppError { ... }         // message + operation
final class NetworkError extends AppError { ... }          // statusCode + message
final class FileSystemError extends AppError { ... }       // message + path

// Permission + Unknown
final class PermissionDeniedError extends AppError { ... } // permission
final class UnknownError extends AppError { ... }          // message + stackTrace
```

Benefits:
- **Exhaustive pattern matching** — compiler enforces all error types are handled
- **Type-safe error context** — each error carries specific typed fields
- **Localization-ready** — error messages constructed at UI layer using `context.l10n`
- **Testable** — errors are pure value objects

### Money value object (domain layer)

All **domain** currency math uses the `Money` value object (`lib/core/domain/money.dart`):
- **Precision**: Integer **satang** (1 ฿ = 100 satang) — avoids binary float error on add/sub/mul
- **No currency field on the VO** — shop currency symbol comes from settings / formatters
- **Safe arithmetic**: `+`, `-`, `*` with half-up rounding; clamp-safe subtraction
- **Persistence (v0.9.2)**: schema v32 stores active INTEGER satang columns through `NullableMoneySatangConverter`; writers dual-write legacy REAL baht for rollback compatibility, and readers prefer satang with REAL fallback
- **Aggregation**: tender and report totals accumulate integer satang before converting to display doubles
- **Formatting**: `MoneyText` / `CurrencyFormatter` respect locale and settings symbol
- **Payable SSOT**: cart display, checkout charge, and sale insert share `SalePayableCalculator`

### Layer-specific patterns

| Layer | Strategy |
|-------|----------|
| **Datasource** | Throw `AppError` subtypes on constraint violations (e.g. `BusinessRuleError('InsufficientStock')` for low stock) |
| **Repository** | Catches DB exceptions, wraps in `AppError` types |
| **Use Case** | Propagates `AppError` — no silent swallowing |
| **BLoC/Cubit** | Catches in event handler, emits error state with `AppError` |
| **UI** | Pattern-match on `AppError` type → shows localized `AppSnackBar.error()` |

### Transaction failure recovery

```dart
try {
  await _db.transaction(() async { ... });
} catch (e) {
  // Transaction auto-rolled back by Drift
  // No partial state possible
  rethrow; // Let BLoC handle error state
}
```

### Specific error scenarios

| Error | Source | Handling |
|-------|--------|----------|
| Insufficient stock | `SaleInsertWriter` | Throw `BusinessRuleError('InsufficientStock')` before writes; BLoC shows localized snackbar |
| Double void | `SaleVoidWriter` | `BusinessRuleError('SaleAlreadyVoided')` → UI error snackbar |
| Product not found | `SaleInsertWriter` | `NotFoundError('Product', id: ...)` → BLoC shows localized snackbar |
| Duplicate barcode | Use Case (AddProduct/UpdateProduct) | `DuplicateBarcodeException` → BLoC catches, emits `BusinessRuleError('DuplicateBarcode')` → UI shows error |
| DB corruption | SQLite | Drift WAL recovery; worst case: app reinstall |
| Encryption key loss | SQLCipher | **Permanent data loss** — requires backup restore or fresh start |
| Backup too large | `BackupExportService` / `BackupRestoreService` | `StateError('BACKUP_TOO_LARGE')` — DB > 512 MB; UI shows size warning |
| PIN required / too short | `BackupExportService` / `BackupRestoreService` | `StateError('PIN_REQUIRED')` / `StateError('PIN_TOO_SHORT')` — encrypt enabled but no/short PIN |
| Plain SQLite backup | `BackupRestoreService` | `StateError('PLAIN_SQLITE_UNSUPPORTED')` — same-device restore requires SQLCipher header |
| Invalid backup schema | `BackupRestoreService` | `StateError('INVALID_BACKUP_SCHEMA')` — candidate missing required tables |
| Invalid backup integrity | `BackupRestoreService` | `StateError('INVALID_BACKUP_INTEGRITY')` — `PRAGMA integrity_check` or `foreign_key_check` failed |
| Recovery kit corrupt | `RecoveryKitService` | `StateError('KIT_CORRUPT')` — file too short or malformed header |
| Wrong recovery passphrase | `RecoveryKitService` | `StateError('WRONG_SECRET')` — GCM auth tag verification failed |
| Key already installed | `RecoveryKitService` | `StateError('KEY_ALREADY_EXISTS')` — call with `replaceExisting: true` to overwrite |
| Insufficient free space | `MigrationSafetyService` | `MigrationPreflightResult(canProceed: false, reason: 'INSUFFICIENT_FREE_SPACE')` — caller aborts migration |

---

## Performance & Scaling

### Read performance

| Query | Index used | Expected latency |
|-------|-----------|-----------------|
| Active products list | `idx_products_is_active` | ~1–3 ms |
| Product page (cursor, 50 rows) | `idx_products_created_at_id_cursor` | ~1–2 ms (stable at any depth) |
| Product search page (LIKE + rank) | `idx_products_created_at_id_cursor` + `sku_lower` / `barcode_lower` | ~2–5 ms |
| Sale history (30 days) | `idx_sales_created_at` | ~2–5 ms |
| Sale page (cursor, 50 rows + hydrate) | `idx_sales_created_at_id_cursor` + batched item/payment hydration | ~3–8 ms |
| Sale count (date range) | `idx_sales_created_at` | ~1–3 ms |
| Report summary (SQL aggregate, 50k sales) | `idx_sales_created_at` + `*_satang` columns | ~1.2 s (no hydration) |
| Sale items for 1 sale | `idx_sale_items_sale_id` | <1 ms |
| Inventory logs for product | `idx_inventory_logs_product_id` | ~1–2 ms |
| Filter by status | `idx_sales_status` | ~1–2 ms |
| WAL size check | File system (`File.length()`) | <1 ms |
| Database health report | File system + `PRAGMA user_version` | ~2–5 ms (integrity off) / ~50–200 ms (integrity on) |

### Write performance

| Operation | Expected latency | Bottleneck |
|-----------|-----------------|------------|
| Create sale (5 items) | ~5–10 ms | N inserts + N updates in single tx |
| Void sale (5 items) | ~3–8 ms | N updates + N inserts |
| Stock adjustment | ~1–2 ms | 1 update + 1 insert |
| Receipt number generation | ~0.5 ms | 1 read + 1 write (app_settings) |
| WAL passive checkpoint | ~5–20 ms | `PRAGMA wal_checkpoint(PASSIVE)` |
| WAL truncate checkpoint | ~10–50 ms | `PRAGMA wal_checkpoint(TRUNCATE)` (exclusive lock) |
| Backup export (50 MB DB) | ~500–800 ms | WAL truncate + copy + SHA-256 + optional encrypt |
| Backup restore (50 MB DB) | ~300–600 ms | decrypt + validate + stage + atomic swap |

### Export performance

| Operation | Expected latency | Memory |
|-----------|-----------------|--------|
| `exportCsv` (in-memory, 1k sales) | ~50–100 ms | O(n) — full `ReportData` in memory |
| `exportCsvStream` (10k sales, pageSize=500) | ~860 ms | O(pageSize) — only 500 sales hydrated at a time |
| `exportPdf` (100 sales) | ~200–400 ms | O(n) — PDF document in memory |

### Scaling characteristics

- **Cursor pagination** — O(pageSize) scan cost regardless of page depth; no OFFSET scan-and-discard degradation
- **SQL report summary** — O(1) memory, single aggregation pass; no `List<Sale>` hydration for sale-table-derived metrics
- **Streaming CSV export** — O(pageSize) memory regardless of export size; hard cap at 10k rows prevents unbounded exports
- **WAL mode** — concurrent reads during writes (no reader blocking)
- **WAL checkpoint policy** — passive at 10 MB (safe during transactions), truncate at 50 MB (exclusive lock, backup/day-close only)
- **Lazy-loaded tabs** — only active tab is built; visited tabs kept alive via `_cachedPages` map
- **Stream-based queries** — Drift watch() uses SQLite update hooks, zero polling
- **Lazy DI registration** — services only instantiated on first access
- **UUID generation** — pure Dart, ~1μs per call, no I/O
- **PBKDF2 in isolate** — recovery kit key derivation (100K iterations) runs off the UI thread

### Memory considerations

- `ProductBloc` singleton — shared product list, single subscription
- `ReportCubit` lazySingleton — date range persists across tab navigation; `load()` guarded to `initState()` only
- Drift query streams — auto-disposed when BLoC is closed
- **Cursor pagination** — `ProductPage` / `SalePage` hold at most `pageSize` (default 50) entities; `totalCount` is a single int
- **SQL report summary** — `ReportSummary` is a fixed-size value object; no `List<Sale>` allocation regardless of date range
- **Streaming CSV export** — only `pageSize` (default 500) sales hydrated at any time; CSV chunks written to sink immediately
- **Backup export** — snapshot copy is a file operation, not an in-memory buffer; SHA-256 streams the file
- **Recovery kit** — PBKDF2 runs in a background isolate; the `.promkey` file is written directly to disk

---

<sub>Promsell POS CE · v0.9.3 · Technical Deep-Dive</sub>
