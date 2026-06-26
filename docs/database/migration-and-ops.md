# Migration & Operations — Promsell POS CE v0.8.7

Migration guide, backup & restore procedures, performance notes, and database testing.

> **Main reference:** [`docs/DATABASE.md`](../DATABASE.md) — overview, ERD, sync columns

---

## Migration Guide

### Current strategy (v0.6.3+)

All migrations are **non-destructive**. Pre-v2 schemas safely migrate via table creation + guarded column adds.

```dart
onUpgrade: (m, from, to) async {
  // Safe migration for pre-v2 schemas
  if (from < 2) {
    await m.createAll(); // creates tables at current schema
    await _createIndexes();
    await _seedDefaultSettings();
    // Add columns that may not exist in old schemas
    await _addColumnIfNotExists(m, products, products.imagePath);
    await _addColumnIfNotExists(m, products, products.imageThumbnailPath);
    await _addColumnIfNotExists(m, draftCarts, draftCarts.cartDiscountType);
    await _addColumnIfNotExists(m, draftCarts, draftCarts.cartDiscountValue);
  }
  if (from < 3) { ... }
  if (from < 4) { ... }
  if (from < 5) { ... }
  if (from < 6) { ... }
},
```

### Incremental migrations (v2 → v18)

Schema versions 2 through 18 use incremental migration:

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
    await m.addColumn(sales, sales.vatAmount);
    await m.addColumn(sales, sales.vatRate);
  }
  if (from < 8) {
    // daily_closes table added
  }
  if (from < 9) {
    // payment_breakdown, vat_amount, discount_amount on daily_closes
  }
  if (from < 10) {
    // deviceId, devicePrefix, onboardingCompleted, dailyCloseLock, lastClosedDate, compactCartMode settings
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
    // Add UNIQUE INDEX on products.barcode
    // Duplicate-safe: logs warning and skips if legacy data has duplicates
    // Prevents migration crash while enforcing uniqueness going forward
  }
  if (from < 17) {
    // Auto-deduplicate barcodes before unique index creation
    // Clears duplicate barcode rows (keeps most recently updated) so v16 unique index can be enforced
  }
  if (from < 18) {
    // Add barcodeImagePath column to products table
    // Stores a generated PNG barcode image for each product that has a barcode
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
| Android | `/data/data/com.mnlizard.promsell/databases/promsell_pos.db` |
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

### Restore

1. Close the database connection
2. Replace `promsell_pos.db` with the backup file
3. If encrypted: decrypt first using `BackupEncryptionService`
4. Delete any stale `-wal` and `-shm` files
5. Restart the app

### Cautions

- **Version mismatch:** Restoring a pre-v2 backup on v18+ app triggers `onUpgrade` with safe non-destructive migration (`_addColumnIfNotExists` guard). No data loss.
- **Encrypted backups:** Restoring an encrypted backup without the PIN is impossible.
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

Requires `sqlite3_flutter_libs` in `dev_dependencies` for FFI on desktop test runners.

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

<sub>Promsell POS CE · v0.8.7 · Migration & Operations</sub>
