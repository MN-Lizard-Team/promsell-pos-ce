# Migration & Operations — Promsell POS CE (v0.9.2)

Migration guide, backup **export**, performance notes, and database testing.

> **Main reference:** [`docs/DATABASE.md`](../DATABASE.md) — overview, ERD, sync columns, SQLCipher encryption

**Current schema: v32** (16 tables including `sale_payments` and `product_audits`; 32 INTEGER `*_satang` money columns added in Phase M). **Same-device in-app restore** is shipped (Settings → Backup). Cross-device / key recovery is **not** (Phase 2b).

---

## Migration Guide

### Current strategy

**SSOT for `onUpgrade` is** [`lib/core/database/app_database.dart`](../../lib/core/database/app_database.dart). Do not copy snippets from this page into a new migration.

- Migrations are additive. There is **no** down migration.
- Unique indexes belong in `onUpgrade` **after a dedupe pass**. `_createIndexes()` runs on `onCreate` and `from < 2` only and does **not** create `idx_products_sku_lower_unique`.
- **v30** adds `sku_lower`, backfills `LOWER(sku)`, then `CREATE UNIQUE` — **no SKU dedupe**. Mixed-case duplicate SKUs can fail the upgrade (repair: [V092-C.2](../plan/UN-COMPLETE/V092-INTEGRITY/WS-V092-C-STOCK.md)).
- In source, `from < 27` (receipt unique) runs **after** `from < 30`.
- **v31** repairs DBs that already ran v30 without dedupe (drop unique index, dedupe, recreate).
- **v32** (Phase M) adds nullable INTEGER `*_satang` columns to all money tables and backfills from REAL baht via `ROUND(baht * 100)`. Writers dual-write; readers prefer satang with REAL fallback. See [WS-C-PHASE-M-MONEY](../plan/UN-COMPLETE/POST-090-MANAGE/WS-C-PHASE-M-MONEY.md).

### Latest steps (v0.9.2)

| Version | Changes (match `onUpgrade`) |
|---------|------------------------------|
| **v25** | Products: `brand`, `unit`, `supplier`, `is_recommended` |
| **v26** | Dedupe `daily_closes` by `close_date`, unique index on `close_date` |
| **v27** | Dedupe non-null `sales.receipt_number`, unique partial index (runs after v30 in source) |
| **v28** | Create `sale_payments` + `idx_sale_payments_sale_id` |
| **v29** | `barcode_lower` + `_deduplicateBarcodesLower()` + unique index |
| **v30** | `sku_lower` + backfill + unique — **no SKU dedupe** |
| **v31** | V092-C.2 repair: drop `idx_products_sku_lower_unique`, dedupe mixed-case SKUs, recreate unique index |
| **v32** | Phase M: 32 INTEGER `*_satang` columns across 10 tables, backfilled from REAL baht (`ROUND(baht * 100)`). NaN/Inf rows skipped (satang stays NULL → REAL fallback). Conditional backfill for `discount_value` / `value` / `cart_discount_value` (AMOUNT type only) |

### Incremental migrations (v2 → v24, historical)

Schema versions 2 through 24 use incremental migration:

```dart
onUpgrade: (m, from, to) async {
  if (from < 3) {
    await m.addColumn(draftCarts, draftCarts.cartDiscountType);
    await m.addColumn(draftCarts, draftCarts.cartDiscountValue);
  }
  if (from < 4) {
    await m.addColumn(products, products.imagePath);
  }
  if (from < 5) {
    await _seedR4Settings(); // promptpayId, receiptSize, backupReminderDays
  }
  if (from < 6) {
    await m.addColumn(products, products.imageThumbnailPath);
    await _seedR45Settings(); // imageMaxWidth, imageQuality
  }
  if (from < 7) {
    // CODE: draft_carts.is_archived — NOT sales.vat*
    await m.addColumn(draftCarts, draftCarts.isArchived);
  }
  if (from < 8) {
    // CODE: _seedR5Settings (deviceId, devicePrefix, onboarding, dailyCloseLock, lastClosedDate)
  }
  if (from < 9) {
    // payment_breakdown, vat_amount, discount_amount on daily_closes
  }
  if (from < 10) {
    // CODE: rebuild daily_closes so closed_at is nullable (NOT device settings)
  }
  if (from < 11) {
    // sync columns v1: updatedAt, deletedAt, version, deviceId on 6 core tables (TEXT ISO8601)
  }
  if (from < 12) {
    // sync columns v2: convert DateTime from TEXT ISO8601 to millisecondsSinceEpoch
  }
  if (from < 13) {
    // Backfill deviceId on all sync-enabled tables for existing rows
    // Tables: sales, sale_items, draft_carts, draft_cart_items, inventory_logs, daily_closes
  }
  if (from < 14) {
    // Add categoryId FK constraint to products table (products.category_id → categories.id)
    // Backfill: convert existing category name strings to UUID references
  }
  if (from < 15) {
    // Add color and iconName columns to categories table
    // Preset colors: 10 choices; preset icons: 21 Material icons
  }
  if (from < 16) {
    // CODE: _deduplicateBarcodes() then unique index.
    // Leftover duplicates THROW StateError — do not document as skip/warn.
  }
  if (from < 17) {
    // Auto-deduplicate barcodes before unique index creation
    // Clears duplicate barcode rows (keeps most recently updated) so v16 unique index can be enforced
  }
  if (from < 18) {
    // Add barcodeImagePath column to products table
    // Stores a generated PNG barcode image for each product that has a barcode
  }
  if (from < 19) {
    // Add note column to sale_items and draft_cart_items tables
    // Allows per-item notes (e.g. "No ice", "Extra spicy")
  }
  if (from < 20) {
    // Restaurant mode: orderType, orderChannel, externalOrderRef, tableId, serviceChargeRate, serviceChargeAmount
    // Add columns to sales and draft_carts tables
    // Add productOptionsJson to sale_items and draft_cart_items
    // Create restaurant_tables, product_option_groups, product_options tables
    // Create indexes: idx_product_option_groups_product_id, idx_product_options_group_id, idx_restaurant_tables_status
    // Seed businessType and defaultServiceChargeRate settings
  }
  if (from < 21) {
    // Customer & promotion management
    // Create customers and promotions tables
    // Add customerId, promotionId, promotionDiscountAmount to sales and draft_carts
    // Create indexes: idx_customers_name, idx_customers_phone, idx_promotions_active, idx_sales_customer_id
  }
  if (from < 22) {
    // Add description column to products table for long-form product descriptions
  }
  if (from < 23) {
    // CODE: no-op (runtime validation only). UNIQUE was NOT dropped.
  }
  if (from < 24) {
    // CODE: re-dedupe + DROP/CREATE partial unique on barcode WHERE non-null/non-empty
    // + idx_sale_items_product_id + idx_sales_created_at.
    // There is NO idx_products_barcode_deletedAt.
  }
  if (from < 25) {
    // Add brand, unit, supplier, is_recommended columns to products table
  }
  if (from < 26) {
    // Dedupe daily_closes by close_date; add unique index idx_daily_closes_close_date_unique
  }
  if (from < 27) {
    // Dedupe non-null sales.receipt_number; add unique partial index idx_sales_receipt_number_unique
    // Reseed receipt sequence from highest existing receipt number
  }
  if (from < 28) {
    // Create sale_payments table (multi-tender) + index idx_sale_payments_sale_id
  }
  if (from < 29) {
    // Add barcode_lower shadow column to products; dedupe case-insensitive barcodes
    // Create unique partial index idx_products_barcode_lower_unique
  }
  if (from < 30) {
    // Add sku_lower shadow column to products
    // Create unique partial index idx_products_sku_lower_unique
  }
  if (from < 31) {
    // V092-C.2 repair: drop idx_products_sku_lower_unique, dedupe mixed-case SKUs, recreate
  }
  if (from < 32) {
    // Phase M: add nullable INTEGER *_satang columns to all money tables
    // Backfill from REAL baht via ROUND(baht * 100) AS INTEGER
    // NaN/Inf rows skipped (satang stays NULL → REAL fallback at read time)
    // 32 columns across 10 tables; conditional backfill for AMOUNT-type discount/value fields
  }
},
```

### How to add a new table

1. Create `lib/core/database/tables/my_new_table.dart`
2. Define the table class with `@DataClassName`
3. Add to `@DriftDatabase(tables: [..., MyNewTable])` in `app_database.dart`
4. Bump `schemaVersion`
5. Add migration step in `onUpgrade`
6. Add indexes if needed in `_createIndexes()`
7. Run codegen:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### How to add a column to an existing table

1. Add the column getter in the table class (use `.nullable()` or `.withDefault()` for existing rows)
2. Bump `schemaVersion`
3. Add `await m.addColumn(tableName, tableName.newColumn)` in `onUpgrade`
4. Run codegen

### How to add an index

Add a `customStatement` in `_createIndexes()`:

```dart
await customStatement(
  'CREATE INDEX IF NOT EXISTS idx_my_table_column ON my_table (column_name)',
);
```

---

## Backup & Restore

### Database file location

| Platform | Path |
|----------|------|
| Android | `/data/data/com.promsell.promsell_pos_ce/databases/promsell_pos.db` |
| iOS | `<app_sandbox>/Documents/promsell_pos.db` |
| Desktop (dev) | Working directory or platform default |

### Export (backup)

1. **WAL checkpoint first** — ensure all WAL data is flushed to the main DB file:

```sql
PRAGMA wal_checkpoint(TRUNCATE);
```

2. Copy the `promsell_pos.db` file to user-accessible storage

3. Share via system share sheet or save to selected directory

> **Important:** Also copy `promsell_pos.db-wal` and `promsell_pos.db-shm` if WAL checkpoint was not performed.

### Encrypted backups (v0.7.2+)

Backups can be encrypted with AES-256-GCM using a PIN-derived PBKDF2-HMAC-SHA256 key (100,000 iterations since v0.7.5):

1. User sets a PIN in Settings → Backup → Encryption
2. On export: `BackupEncryptionService.encrypt(plainBytes, pin)` → encrypted file
3. On import: `BackupEncryptionService.decrypt(encryptedBytes, pin)` → restored DB

> Encrypted backups have `.enc` extension. The PIN is never stored — forgotten PIN = unrecoverable backup.

### SQLCipher database encryption (Phase 2a)

Full-database encryption at rest using SQLCipher:

- **Cipher:** AES-256-CBC with PBKDF2-HMAC-SHA512 (256k iterations)
- **Key storage:** Platform secure storage (iOS Keychain / Android Keystore)
- **First launch:** Auto-generates 256-bit encryption key
- **Backup:** Database file remains encrypted; restore requires same key

> **Important:** SQLCipher encryption is transparent after initial setup. Losing the encryption key means **permanent data loss**. Key recovery mechanisms are planned for Phase 2b.

### Restore

1. Close the database connection
2. Replace `promsell_pos.db` with the backup file
3. If encrypted: decrypt first using `BackupEncryptionService`
4. Delete any stale `-wal` and `-shm` files
5. Restart the app

### Cautions

- **Version mismatch:** Restoring a pre-v2 backup on v32+ app triggers `onUpgrade` with safe non-destructive migration (`_addColumnIfNotExists` guard). No data loss. Phase M satang columns are backfilled from REAL baht automatically.
- **PIN-encrypted backups:** Restoring an encrypted backup without the PIN is impossible.
- **SQLCipher encryption:** Database files are encrypted at rest. Losing the platform-stored key requires data recovery from unencrypted backup.
- **CSV export** (v0.6.0): Export sales and products data as CSV via `csv` + `share_plus`.

---

## Performance Notes

### WAL mode

Write-Ahead Logging allows concurrent reads during writes. Set via `beforeOpen`:

```dart
await customStatement('PRAGMA journal_mode=WAL');
```

Benefits:
- Readers don't block writers
- Faster write transactions
- Better crash recovery

### Index coverage

All hot-path queries are covered by indexes:
- Product list: `idx_products_is_active`
- Sale history by date: `idx_sales_created_at`
- Sale items fetch: `idx_sale_items_sale_id`
- Product by category: `idx_products_category_id`

### Transaction batching

Sale creation inserts 1 sale + N items + N stock updates + N inventory logs + 1 receipt sequence update in a **single transaction**. Void sale similarly updates 1 sale + restores N stocks + N inventory logs atomically. This ensures no partial state on crash or failure.

> **Draft cart saves** are intentionally **outside** the sale transaction — they are debounced writes (500 ms) that run independently. Draft data is ephemeral; losing the last 500 ms of changes is acceptable.

### UUID generation cost

`IdGenerator.newId()` uses `Uuid().v4()` — pure Dart, no I/O, ~1μs per call. Negligible even for batch operations.

### DB file size expectations

| Scale | Estimated size |
|-------|---------------|
| 100 products, 1K sales | ~1–2 MB |
| 500 products, 10K sales | ~10–15 MB |
| 1000 products, 50K sales | ~50–80 MB |

SQLite handles files up to 281 TB. For a POS app, DB size is never a practical concern.

> R5 will add a "DB size" display in Settings as a user-facing health indicator.

---

## Testing

### In-memory database

Tests use a real SQLite database in memory — no disk I/O, full SQL execution:

```dart
import 'package:drift/native.dart';

AppDatabase createInMemoryDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
```

Requires `sqlcipher_flutter_libs` in `dev_dependencies` for FFI on desktop test runners (replaced `sqlite3_flutter_libs` in Phase 2a).

### Test fixtures

Deterministic UUID strings are used in test fixtures for predictable assertions:

```dart
// test/helpers/fixtures.dart
final tProduct = Product(
  id: 'prod-0001-0001-0001-000000000001',
  name: 'Water',
  price: 10.0,
  // ...
);
```

### Datasource tests

Datasource tests (e.g. `product_local_datasource_test.dart`) use the in-memory DB directly:

```dart
late AppDatabase db;
late ProductLocalDatasourceImpl datasource;

setUp(() {
  db = createInMemoryDatabase();
  datasource = ProductLocalDatasourceImpl(db);
});

tearDown(() => db.close());
```

### Integration tests

- `test/integration/checkout_flow_test.dart` — add products → create sale → verify stock deduction → check history
- `test/integration/sale_integrity_test.dart` — atomic sale with receipt number → void sale → stock restored → inventory logs verified → manual stock adjustment → cannot double-void
- `test/integration/onboarding_first_sale_test.dart` — onboarding flow → first sale → settings persistence
- `test/tool/seed_integration_test.dart` — stress test (`@Tags(['stress'])`): seeds 10k products + 50k sales + 150k sale_items, measures query performance (all < 1s)

All run against real in-memory SQLite.

---

<sub>Promsell POS CE · v0.9.2 · Migration & Operations · SQLCipher AES-256</sub>
