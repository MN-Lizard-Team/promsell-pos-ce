# Database Handbook — Promsell POS CE (v0.9.2)

Complete reference for the Promsell database: schema, relationships, indexes, migration, query patterns, backup export, and performance.

---

## Overview

| Property | Value |
|----------|-------|
| **Engine** | SQLite via [Drift](https://drift.simonbinder.eu/) (type-safe ORM) |
| **Encryption** | SQLCipher AES-256 (full-database encryption, Phase 2a) |
| **File** | `promsell_pos.db` (platform default app directory, encrypted at rest) |
| **Schema version** | **32** (v26 unique `daily_closes.close_date`; **v27** unique `sales.receipt_number`; **v28** `sale_payments` multi-tender; **v29** `products.barcode_lower` + unique index; **v30** `products.sku_lower` + unique index; **v31** V092-C.2 SKU dedupe + V092-C.3 idempotent indexes; **v32** Phase M — 32 nullable INTEGER `*_satang` dual-write columns on 10 money tables, backfilled from REAL baht, NaN/Inf-safe) |
| **Tables** | **16** |
| **ID strategy** | UUIDv4 TEXT on all tables (`IdGenerator.newId()`) |
| **Journal mode** | WAL (`PRAGMA journal_mode=WAL`) |
| **Foreign keys** | Enabled (`PRAGMA foreign_keys=ON`) |
| **Code location** | `lib/core/database/` |
| **Generated file** | `app_database.g.dart` — **do not edit** (not committed to git; run `build_runner build` to generate) |
| **Encryption key** | Mobile: platform secure storage (Keystore/Keychain). Debug desktop may use a fixed dev key — not for production. |
| **Money on disk** | Amount columns retain legacy SQLite **REAL** baht for rollback compatibility, alongside active nullable INTEGER `*_satang` columns on 10 money tables (32 columns). Drift uses `NullableMoneySatangConverter`; writers dual-write `Money` satang + REAL baht, readers prefer satang and fall back to REAL for pre-v32 rows. v32 backfill uses `ROUND(baht * 100)` and leaves non-finite legacy values with `*_satang = NULL`. |

---

## Entity-Relationship Diagram

```mermaid
erDiagram
    Categories ||--o{ Products : "categoryId"
    Sales ||--|{ SaleItems : "saleId (CASCADE)"
    Sales ||--|{ SalePayments : "saleId (CASCADE)"
    Products ||--o{ SaleItems : "productId (logical)"
    Products ||--o{ InventoryLogs : "productId (logical)"
    Products ||--o{ ProductAudits : "productId (logical)"
    Sales ||--o{ InventoryLogs : "refSaleId (logical)"
    DraftCarts ||--|{ DraftCartItems : "cartId (CASCADE)"
    Products ||--o{ DraftCartItems : "productId (logical)"
    Products ||--o{ ProductOptionGroups : "productId (CASCADE)"
    ProductOptionGroups ||--|{ ProductOptions : "groupId (CASCADE)"
    Customers ||--o{ Sales : "customerId (logical)"
    Promotions ||--o{ Sales : "promotionId (logical)"
    RestaurantTables ||--o{ Sales : "tableId (logical)"
```

### Table groupings

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Transactional (FK-enforced CASCADE)                                         │
│  ┌──────────┐   1:N  ┌─────────────┐    1:N  ┌────────────────┐              │
│  │  Sales   │ ──────▶│  SaleItems  │ ◀──────│   Products     │              │
│  └────┬─────┘        └─────────────┘         └───────┬────────┘              │
│       │ logical                               logical│                       │
│       ▼                                              ▼                       │
│  ┌──────────────┐                            ┌────────────────┐              │
│  │ InventoryLogs│                            │  Categories    │              │
│  └──────────────┘                            └────────────────┘              │
│  ┌──────────┐   1:N  ┌──────────────┐                                        │
│  │  Sales   │ ──────▶│ SalePayments │                                        │
│  └──────────┘        └──────────────┘                                        │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│  Draft (FK-enforced CASCADE)                                                 │
│  ┌────────────┐   1:N  ┌────────────────┐                                    │
│  │ DraftCarts │ ──────▶│ DraftCartItems │ ◀── logical ── Products           │
│  └────────────┘        └────────────────┘                                    │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│  Key-Value / Audit (no FK)                                                   │
│  ┌──────────────┐  1:1   ┌────────────────┐  ┌────────────────┐             │
│  │  AppSettings │        │  DailyCloses   │  │ ProductAudits  │             │
│  └──────────────┘        └────────────────┘  └────────────────┘             │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│  Restaurant & CRM (v0.8.9+)                                                  │
│  ┌──────────────────┐  1:N  ┌─────────────────────┐                          │
│  │ ProductOptionGrp │ ────▶│   ProductOptions    │                          │
│  └──────────────────┘       └─────────────────────┘                          │
│  ┌──────────────────┐       ┌─────────────────────┐                          │
│  │    Customers     │       │    Promotions       │                          │
│  └──────────────────┘       └─────────────────────┘                          │
│  ┌──────────────────┐       ┌─────────────────────┐                          │
│  │ RestaurantTables │       │                     │                          │
│  └──────────────────┘       └─────────────────────┘                          │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Relationship notes

| Relationship | FK enforced? | Why |
|-------------|-------------|-----|
| `sale_items.saleId → sales.id` | **Yes** (CASCADE) | Deleting a sale must cascade to its items |
| `draft_cart_items.cartId → draft_carts.id` | **Yes** (CASCADE) | Deleting a draft must cascade to its items |
| `sale_items.productId → products.id` | **No** (logical) | Sale history must survive product deletion |
| `inventory_logs.productId → products.id` | **No** (logical) | Audit trail must survive product deletion |
| `inventory_logs.refSaleId → sales.id` | **No** (logical) | Log must survive even if sale is hard-deleted |
| `products.categoryId → categories.id` | **Yes** (Drift FK, `onDelete: KeyAction.setNull`) | Code uses `references(Categories, #id, onDelete: KeyAction.setNull)`; deleting a category nulls `categoryId` on its products |
| `sale_payments.saleId → sales.id` | **Yes** (CASCADE) | Multi-tender lines (schema **v28**) |
| `product_audits.productId → products.id` | **No** (logical) | Audit trail must survive product deletion |

> Full ERD with all columns: [`docs/database/schema-reference.md`](database/schema-reference.md)

---

## Sync metadata columns (not a sync engine)

These columns exist on **most** tables (schema v11+). They are **metadata only** — CE has **no** sync engine, outbox, or multi-device protocol (ADR-028). `deviceId` was backfilled on six tables in schema v13. `ProductAudits` has no `deletedAt`. As of V092-C.1 (schema v31), sale / void / `adjustStock` all bump `version` alongside the atomic stock update, so a stale product form cannot overwrite the count.

| Column | Type | Purpose |
|--------|------|---------|
| `version` | INTEGER (default 1) | Optimistic concurrency — increment on each update |
| `deviceId` | TEXT (nullable) | Identifies which device created/modified the row |
| `updatedAt` | DATETIME | Last modification timestamp for conflict resolution |
| `deletedAt` | DATETIME (nullable) | **Soft delete** — row is hidden but not physically removed |

### Soft delete pattern

When a record is "deleted":
1. Set `deletedAt = DateTime.now()` instead of `DELETE FROM`
2. All queries filter `WHERE deleted_at IS NULL` (or use `isActive` for products)
3. Sync can detect deletions by comparing `deletedAt` timestamps

> Products use `isActive` for soft deactivation in the UI layer. The `deletedAt` column enables true soft-delete + sync in Phase 4.

### Sync column flow

```
              Local Write (insert/update/delete)
                              │
                              ▼
              ┌───────────────────────────────┐
              │  version++                    │
              │  updatedAt = now()            │
              │  deviceId = this.device       │
              │  deletedAt = now()? (soft)    │
              └───────────────┬───────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │  Local SQLite (WAL)           │
              │  16 tables; metadata columns  │
              │  (not a sync engine)          │
              └───────────────┬───────────────┘
                              │
             Not in CE v1     │
              ┌───────────────▼───────────────┐
              │  No sync engine               │
              │  (ADR-028 non-goal)           │
              └───────────────────────────────┘
```

---

## Migration timeline

```
v1          v2          v5          v7          v8          v10
│           │           │           │           │           │
▼           ▼           ▼           ▼           ▼           ▼
Initial     Draft      Image       is_archived Daily       Rebuild
	schema      discounts  settings    on drafts    Closes      daily_closes

v11         v12         v13         v14         v15         v16      v17       v18       v19
│           │           │           │           │           │        │         │         │
▼           ▼           ▼           ▼           ▼           ▼        ▼         ▼         ▼
Sync        Timestamp   Backfill    Category    Category    Unique   Auto-     Barcode  CartItem
columns     INT ms      deviceId    FK + UUID   color/icon  barcode  dedup     images   note
(6 tables)  conversion  (all rows)  backfill    presets     index    barcodes

v20                                           v21                                v22
│                                             │                                  │
▼                                             ▼                                  ▼
Restaurant tables + Product options           Customer + Promotion tables        Product
+ order type/channel/service charge           + customer/promotion refs          description

v23                                           v24
	│                                             │
	▼                                             ▼
	Runtime validations: barcode uniqueness       Partial unique barcode index
	barcode length constraints                    (WHERE barcode NOT NULL / not empty)
	
	v25                                           v26
	│                                             │
	▼                                             ▼
	Products brand / unit / supplier              Dedupe daily_closes by close_date
	+ is_recommended                              Unique index on close_date

	v27                                           v28
	│                                             │
	▼                                             ▼
	Dedupe sales.receipt_number                   sale_payments multi-tender table
	Unique partial index on receipt_number        + index on sale_id

	v29                                           v30
	│                                             │
	▼                                             ▼
	products.barcode_lower + unique index         products.sku_lower + unique index
	(case-insensitive barcode lookups)            (case-insensitive SKU lookups)
	```
	
	---
	
	## Security & Encryption (Phase 2a)
	
	Promsell POS CE uses **SQLCipher** for full-database encryption at rest.
	
	| Feature | Implementation (app code) |
	|---------|---------------------------|
	| **Open path** | `EncryptedDatabaseOpener` + `DbKeyStore` (`lib/core/database/`) |
	| **Key PRAGMA** | `PRAGMA key="x'<hex>'"` only (library defaults for other cipher settings) |
	| **Key storage** | Mobile secure storage; debug desktop may use a fixed dev key |
	| **Plain → encrypted** | One-time migrate via `sqlcipher_export` when opening a legacy plain file |
	| **Dependencies** | `sqlcipher_flutter_libs: ^0.6.0`, `sqlite3`, `flutter_secure_storage` |
	
	### Key management flow
	
	```
	First launch (mobile)
	    ↓
	Generate secure random key → store in secure storage
	    ↓
	Open NativeDatabase + PRAGMA key
	    ↓
	If plain legacy DB exists → encrypt migrate → ready
	```
	
### Backup export & same-device restore

- **CSV exports**: Plaintext (user-controlled)
- **Full DB export**: WAL checkpoint → copy → optional **AES-256-GCM** package with PIN (≥ 6) via Settings → Backup (default encrypt **on**)
- **In-app restore**: **Yes — same-device only** (Settings → Backup). Restores `.enc` or SQLCipher `.db`; rejects plain SQLite. Needs this device’s SQLCipher key in secure storage. Cross-device / after uninstall = **not** supported (Phase 2b)
- **Cloud sync**: not in CE 0.9

> **Note**: Losing the SQLCipher key (uninstall / keystore wipe) without an export means **permanent data loss**. Key recovery is not available in v0.9.2; Phase 2b recovery-kit work remains deferred.

---

## Reference documents

| Document | Content |
|----------|---------|
| [`docs/database/schema-reference.md`](database/schema-reference.md) | All **16** tables with column details, indexes, seed data, enum values |
| [`docs/database/query-patterns.md`](database/query-patterns.md) | Drift query patterns: watch products, insert sale, void sale, date range, draft upsert |
| [`docs/database/migration-and-ops.md`](database/migration-and-ops.md) | Migration guide (v2→**v32**), backup export/restore, encrypted backups, performance notes, DB testing |

---

### Schema v25–v30

| Version | Changes |
|---------|---------|
| **v25** | Products: nullable `brand`, `unit`, `supplier`; `is_recommended` |
| **v26** | Unique index on `daily_closes(close_date)` after dedupe (one close per business day) |
| **v27** | Unique partial index on `sales(receipt_number)` after dedupe; receipt sequence reseeds from max on disk |
| **v28** | `sale_payments` multi-tender table + index on `sale_id` |
| **v29** | `products.barcode_lower` column + unique partial index for case-insensitive barcode lookups |
| **v30** | `products.sku_lower` column + unique partial index for case-insensitive SKU lookups |
| **v31** | V092-C.2: SKU dedupe before unique index (same pattern as barcode v29); V092-C.3: idempotent index/trigger set at end of every `onUpgrade`; `sku_lower` unique index added to `_createIndexes` for fresh installs |
| **v32** | **Phase M (C1–C3):** 32 nullable INTEGER `*_satang` dual-write columns added to 10 money tables (`products`, `product_options`, `sales`, `sale_items`, `sale_payments`, `daily_closes`, `customers`, `promotions`, `draft_carts`, `draft_cart_items`). Backfilled from REAL baht via `CAST(ROUND(baht * 100) AS INTEGER)`. NaN/Inf-safe: `baht = baht` excludes NaN (NULL in SQLite), `abs(baht) < 1e15` excludes ±Inf. Idempotent (`AND satang IS NULL`). Drift `NullableMoneySatangConverter` is wired; writers dual-write and readers are satang-first with REAL fallback. Legacy REAL columns remain until a later deprecation release. **Also within v32 (not a new schema version):** two cursor-pagination indexes added — `idx_products_created_at_id_cursor` (`products: created_at DESC, id`) and `idx_sales_created_at_id_cursor` (`sales: created_at DESC, id`) for cursor-based pagination. |

**Money on disk:** Domain code uses the `Money` value object (integer satang). v32 stores satang as the active exact representation while retaining REAL baht for rollback compatibility. Report/tender aggregation now accumulates integer satang and converts to display doubles only at the presentation boundary. Dropping legacy REAL columns and the encrypted pre-M backup-restore fixture remain deferred.

### Barcode / SKU uniqueness policy after soft-delete (V092-C.4)

**Decision: Not reusable after delete.**

The unique indexes on `barcode`, `barcode_lower`, `sku`, and `sku_lower` cover the **entire table**, including rows with `deleted_at IS NOT NULL`. This means a soft-deleted product's barcode/SKU cannot be reused by a new product until the old row is hard-deleted (or its barcode/SKU is cleared).

Rationale:
- Prevents accidental shadowing of historical sales/audit records that reference the old barcode/SKU.
- Simplifies sync conflict resolution in Phase 4 — no need to merge two products with the same barcode.
- The trade-off is that a shop deleting and re-adding a product with the same barcode must clear the old barcode first (or use a different one). The `deleteProduct` path could optionally null out barcode/SKU on soft-delete in a future enhancement if reuse is needed.

> If reuse-after-delete is needed later: change the unique indexes to partial `WHERE deleted_at IS NULL AND barcode IS NOT NULL AND barcode != ''`. This requires a migration to drop + recreate the indexes.

**Backup:** Export + AES-GCM (PIN ≥ 6; default **on** when setting missing). **Same-device in-app restore** is shipped; cross-device is not. SQLCipher key lives in platform secure storage; **key loss = data loss** without a backup. Recovery-kit export/import is **code complete, device validation pending** ([Unreleased]) — unit tests cover wrap/unwrap logic only; on-device cross-device restore (D2) is not yet tested. Full cross-device device smoke (Phase 2b D2) remains pending.

---

## Database Health & Lifecycle Services

The following P1 services provide migration safety, WAL checkpoint management, health reporting, backup metadata, and key recovery. All live under `lib/core/database/` (except `BackupExportService`).

### MigrationSafetyService

**File:** `lib/core/database/migration_safety_service.dart`

- **Free-space preflight:** checks available storage before running migrations (requires 2× DB size or a 50 MB floor, whichever is larger).
- **Migration status tracking:** file-based status tracking with states `idle`, `running`, `succeeded`, `failed`.
- **Interrupted-migration detection:** detects if a previous migration was interrupted (status left as `running`) and surfaces it for recovery.
- **Schema version query:** exposes the current on-disk schema version without opening a full database connection.

### WalCheckpointService

**File:** `lib/core/database/wal_checkpoint_service.dart`

- **PASSIVE mode:** safe background checkpoints via `PRAGMA wal_checkpoint(PASSIVE)`. Triggered when WAL size exceeds the 10 MB passive threshold.
- **TRUNCATE mode:** full checkpoint + WAL file truncation via `PRAGMA wal_checkpoint(TRUNCATE)`. Used for backup and day-close operations.
- **Hard limit:** 50 MB hard limit — forces a checkpoint if WAL exceeds this regardless of mode.
- **APIs:** `checkpointIfNeeded()` (passive, threshold-based) and `forceTruncate()` (unconditional TRUNCATE).

### DatabaseHealthService

**File:** `lib/core/database/database_health_service.dart`

- **`generateReport()`** returns a `DatabaseHealthReport` containing:
  - `mainDbSize`, `walSize`, `shmSize`, `totalSize` (bytes)
  - `schemaVersion` (int)
  - `integrityOk` (bool — result of `PRAGMA integrity_check`)
  - `freeStorageBytes` (available storage on device)
  - `walNeedsCheckpoint` (bool — WAL exceeds passive threshold)
  - `walNeedsTruncate` (bool — WAL exceeds hard limit)
  - `generatedAt` (DateTime)
- **512 MB guardrail:** `exceedsGuardrail` flag on the report indicates when `totalSize` surpasses the 512 MB guardrail.

### BackupExportService (enhancements)

**File:** `lib/features/settings/data/services/backup_export_service.dart`

- **`BackupMetadata` class:** captures `schemaVersion`, `appVersion`, `createdAt` (ISO-8601 string), `dbSizeBytes`, `checksumSha256`, and `encrypted` flag for each export. Written as a `.meta.json` sidecar alongside the `.db`/`.enc` file.
- **`exportToFiles()` / `exportWithMetadata()` / `exportAndShare()`:** performs a size preflight (512 MB max via `maxBackupBytes`), WAL checkpoint via `WalCheckpointService.forceTruncate()`, SHA-256 checksum, optional AES-256-GCM encryption, and share via `share_plus`. Reports progress via `BackupProgress` callback with states: `.idle`, `.checkpointing`, `.copying`, `.checksumming`, `.encrypting`, `.sharing`, `.done`.
- **`BackupMetadata.tryDecode()`:** parses a `.meta.json` sidecar for restore-side validation (checksum, schema version, encrypted flag).

### RecoveryKitService

**File:** `lib/core/database/recovery_kit_service.dart`

- **`exportKit({required String secret, String? outputPath})`:** wraps the SQLCipher key with AES-256-GCM using a PBKDF2-HMAC-SHA256 key derived from the user secret (100,000 iterations, 16-byte salt, 12-byte nonce). PBKDF2 runs in a background isolate. Writes a `.promkey` file. Minimum secret length is 8 characters. Returns `RecoveryKitExportResult` with `filePath` and `RecoveryKitMetadata` (version, createdAt, kdfIterations). Throws `SECRET_TOO_SHORT` or `NO_DB_KEY`.
- **`importKit({required String filePath, required String secret, bool replaceExisting = false})`:** unwraps the SQLCipher key from a `.promkey` file using the same PBKDF2 derivation. Installs the key into platform secure storage. Throws `SECRET_TOO_SHORT`, `KIT_FILE_NOT_FOUND`, `KIT_CORRUPT`, `KIT_VERSION_UNSUPPORTED`, `WRONG_SECRET` (GCM auth tag fail), or `KEY_ALREADY_EXISTS` (if a key exists and `replaceExisting` is false).
- **`hasKey()` / `removeKey()`:** check whether a DB key is installed, or remove it (use with caution — the database becomes unreadable until a new key is imported).
- **File format:** `[uint32 headerLength][JSON header][salt(16)][nonce(12)][ciphertext+GCM tag]`

### BackupRestoreService (enhancement)

**File:** `lib/features/settings/data/services/backup_restore_service.dart`

- **`restoreFromPath({required String sourcePath, String? pin})`:** validates the candidate (schema tables, `PRAGMA integrity_check`, `PRAGMA foreign_key_check`), stages the file, closes the live DB, atomically swaps (live → old, staged → live, delete WAL+SHM), and returns the pre-restore backup path. If the swap fails, rolls back by renaming `old` back to `live`. Throws `SOURCE_MISSING`, `BACKUP_TOO_LARGE`, `PIN_REQUIRED`, `PIN_TOO_SHORT`, `PLAIN_SQLITE_UNSUPPORTED`, `INVALID_BACKUP`, `INVALID_BACKUP_SCHEMA`, or `INVALID_BACKUP_INTEGRITY`.
- **`cleanupPreRestoreBackups()`:** deletes leftover `promsell_pos.pre_restore_*.db` files after a successful DB open on next launch.
- **`skipSqlCipherHeaderCheck` param:** test-only parameter to bypass the SQLCipher header check during restore.
- **`@ignoreParam`** annotation on `candidateValidator` and `skipSqlCipherHeaderCheck` for injectable compatibility.

---

<sub>Promsell POS CE · Schema v32 · 16 tables · UUIDv4 · SQLCipher AES-256</sub>