# Database API Reference

> Current release: **v0.9.4** · schema: **v32** · package version: `0.9.4+2`

Complete guide to Drift database access patterns, repository implementations, and query techniques.

---

## Table of Contents

1. [Database Setup](#database-setup)
2. [Query Patterns](#query-patterns)
3. [Transaction Patterns](#transaction-patterns)
4. [Repository Pattern](#repository-pattern)
5. [Drift Type Converters](#drift-type-converters)
6. [Stream Patterns](#stream-patterns)
7. [Migration Strategy](#migration-strategy)

---

## Database Setup

### AppDatabase Class

**Location:** `lib/core/database/app_database.dart`

```dart
@DriftDatabase(tables: [
  Products,
  Sales,
  SaleItems,
  SalePayments,
  Categories,
  InventoryLogs,
  ProductAudits,
  AppSettings,
  DraftCarts,
  DraftCartItems,
  DailyCloses,
  RestaurantTables,
  ProductOptionGroups,
  ProductOptions,
  Customers,
  Promotions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openDatabase());

  @override
  int get schemaVersion => 32;  // Current schema version (v0.9.2)

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createIndexes();
      await _seedDefaultSettings();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Incremental steps — see app_database_migrations.dart (+ helpers + v32_satang part files) for full history
      if (from < 24) { /* partial unique barcode + indexes */ }
      if (from < 25) { /* products brand/unit/supplier/is_recommended */ }
      if (from < 26) { /* daily_closes unique close_date + dedupe */ }
    },
  );
}
```

### Connection Setup (production · SQLCipher)

Production does **not** open a plain `NativeDatabase` without a key. Use the encrypted opener:

```dart
// lib/core/database/database_opener.dart (conceptual)
// 1) DbKeyStore loads/creates key (secure storage on mobile)
// 2) EncryptedDatabaseOpener.open(file) → NativeDatabase + PRAGMA key
// 3) Optional one-time plain → encrypted migrate via sqlcipher_export

// Tests may use:
// AppDatabase.forTesting(NativeDatabase.memory());
```

See `lib/core/database/database_opener.dart` and `db_key_store.dart` for the real implementation.

### Configuration

```dart
// After open, migration beforeOpen (and app setup) enables:
// PRAGMA journal_mode=WAL
// PRAGMA foreign_keys=ON
// (SQLCipher: only PRAGMA key is set by the app; other cipher defaults are library-side)

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final db = await EncryptedDatabaseOpener.open(/* path + key */);
    
    // Enable foreign keys
    await db.customStatement('PRAGMA foreign_keys=ON');
    
    return db;
  });
}
```

---

## Query Patterns

### Basic Queries

#### Select All

```dart
// Get all products
Future<List<ProductData>> getAllProducts() {
  return select(products).get();
}

// With condition
Future<List<ProductData>> getActiveProducts() {
  return (select(products)
    ..where((p) => p.isActive.equals(true))
  ).get();
}

// With ordering
Future<List<ProductData>> getProductsByPrice() {
  return (select(products)
    ..orderBy([(p) => OrderingTerm(expression: p.price, mode: OrderingMode.desc)])
  ).get();
}
```

#### Select Single

```dart
// By primary key
Future<ProductData?> getProductById(String id) {
  return (select(products)
    ..where((p) => p.id.equals(id))
  ).getSingleOrNull();
}

// With multiple conditions
Future<ProductData?> getProductByBarcode(String barcode) {
  return (select(products)
    ..where((p) => p.barcode.lower().equals(barcode.toLowerCase()))
    ..where((p) => p.isActive.equals(true))
  ).getSingleOrNull();
}
```

### Watch Queries (Streams)

```dart
// Watch all products (reactive)
Stream<List<ProductData>> watchAllProducts() {
  return select(products).watch();
}

// Watch with condition
Stream<List<ProductData>> watchActiveProducts() {
  return (select(products)
    ..where((p) => p.isActive.equals(true))
    ..orderBy([(p) => OrderingTerm.asc(p.name)])
  ).watch();
}

// Watch single entity
Stream<ProductData?> watchProductById(String id) {
  return (select(products)
    ..where((p) => p.id.equals(id))
  ).watchSingleOrNull();
}
```

### Joins

#### One-to-Many

```dart
// Products with their categories
Stream<List<ProductWithCategory>> watchProductsWithCategories() {
  final query = select(products).join([
    leftOuterJoin(
      categories,
      categories.id.equalsExp(products.categoryId),
    ),
  ]);
  
  return query.watch().map((rows) {
    return rows.map((row) {
      final product = row.readTable(products);
      final category = row.readTableOrNull(categories);
      return ProductWithCategory(product, category);
    }).toList();
  });
}
```

#### With asyncMap for Related Data

```dart
// Products with option groups loaded separately
Stream<List<ProductData>> watchAllProductsWithOptions() {
  return select(products).watch().asyncMap((products) async {
    // Load option groups for each product
    for (final product in products) {
      final groups = await (select(productOptionGroups)
        ..where((g) => g.productId.equals(product.id))
      ).get();
      
      // Store in product (if Product has optionGroups field)
      // or handle separately
    }
    return products;
  });
}
```

### Aggregations

```dart
// Count products
Future<int> countProducts() async {
  final query = selectOnly(products)
    ..addColumns([products.id.count()]);
  
  final result = await query.getSingle();
  return result.read(products.id.count()) ?? 0;
}

// Sum of inventory value
Future<double> getTotalInventoryValue() async {
  final query = selectOnly(products)
    ..addColumns([
      (products.price * products.stock).sum(),
    ]);
  
  final result = await query.getSingle();
  return result.read((products.price * products.stock).sum()) ?? 0.0;
}

// Group by category
Future<Map<String, int>> getProductCountByCategory() async {
  final query = selectOnly(products)
    ..addColumns([
      products.categoryId,
      products.id.count(),
    ])
    ..groupBy([products.categoryId]);
  
  final results = await query.get();
  return {
    for (final row in results)
      row.read(products.categoryId) ?? 'uncategorized':
        row.read(products.id.count()) ?? 0,
  };
}
```

### Date Range Queries

```dart
// Sales in date range
Future<List<SaleData>> getSalesByDateRange(
  DateTime start,
  DateTime end,
) {
  return (select(sales)
    ..where((s) => s.createdAt.isBiggerOrEqualValue(start))
    ..where((s) => s.createdAt.isSmallerOrEqualValue(end))
    ..where((s) => s.voidedAt.isNull())  // Exclude voided sales
    ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
  ).get();
}
```

### Cursor-Based Pagination

Cursor-based pagination avoids `OFFSET` performance degradation on large tables by using a composite cursor on `(createdAt DESC, id)`. Two dedicated indexes support this: `idx_products_created_at_id_cursor` and `idx_sales_created_at_id_cursor` (added within schema **v32**, not a new schema version).

#### Product list pagination

```dart
// ProductLocalDatasource
Future<ProductPage> getProductsPage({
  ProductCursor? cursor,    // from previous page's nextCursor; null for first page
  int pageSize = 50,
  bool activeOnly = false,
});

// ProductRepository
Future<ProductPage> getProductsPage({
  ProductCursor? cursor,
  int pageSize = 50,
  bool activeOnly = false,
});

// Use case
@injectable
class GetProductsPage {
  Future<ProductPage> call({
    ProductCursor? cursor,
    int pageSize = 50,
    bool activeOnly = false,
  });
}
```

`ProductPage` is an entity containing `products` (list of `Product`), `nextCursor` (`ProductCursor?`, null when no more rows), and `totalCount` (total non-deleted count, independent of pagination).

#### Product search pagination

```dart
// ProductLocalDatasource
Future<ProductPage> searchProductsPage({
  required String query,
  ProductCursor? cursor,
  int pageSize = 50,
  bool activeOnly = false,
});

// Use case
@injectable
class SearchProductsPage {
  Future<ProductPage> call({
    required String query,
    ProductCursor? cursor,
    int pageSize = 50,
    bool activeOnly = false,
  });
}
```

DB-side `LIKE` filter on name / `sku_lower` / `barcode_lower` with in-memory ranking on the result page.

#### Paged sale history

```dart
// SaleQueryLocalDatasource
Future<SalePage> querySalesPage({
  DateTime? from,
  DateTime? to,
  SaleCursor? cursor,
  int pageSize = 50,
});

Future<int> querySalesCount({DateTime? from, DateTime? to});

// SaleRepository
Future<SalePage> getSalesPage({
  DateTime? from,
  DateTime? to,
  SaleCursor? cursor,
  int pageSize = 50,
});

// Use cases
@injectable
class GetSalesPage {
  Future<SalePage> call({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
  });
}

@injectable
class GetSalesCount {
  Future<int> call({DateTime? from, DateTime? to});
}
```

`SalePage` is an entity containing `sales` (list of `Sale`), `nextCursor` (`SaleCursor?`, null when no more rows), and `totalCount`. Items and payments are hydrated **only for the current page** (batched, not N+1).

### Report Summary Aggregate

```dart
// SaleQueryLocalDatasource
Future<ReportSummary> queryReportSummary({DateTime? from, DateTime? to});

// SaleRepository
Future<ReportSummary> getReportSummary({DateTime? from, DateTime? to});

// Use case
@injectable
class GetReportSummary {
  Future<ReportSummary> call({DateTime? from, DateTime? to});
}
```

`ReportSummary` is an entity with aggregated totals computed in SQL. The aggregation uses the Satang-SSOT strategy: INTEGER `*_satang` columns are preferred, with REAL baht fallback for pre-v32 rows. Payment method lookup is chunked to 500 rows at a time to avoid SQLite variable limits.

### Bounded Streaming CSV Export

```dart
const int kExportMaxRows = 10000;

class CsvExportResult {
  final int rowsWritten;
  final bool truncated;   // true when kExportMaxRows cap was hit
}

// ReportExportService
Future<CsvExportResult> exportCsvStream({
  required SaleRepository saleRepository,
  required void Function(String chunk) sink,
  DateTime? from,
  DateTime? to,
  int maxRows = kExportMaxRows,
  int pageSize = 500,
  Future<void> Function()? startSignal,
});
```

Pages through sales via `SaleRepository.getSalesPage()`, writing CSV chunks incrementally to the provided `sink` callback. Memory is bounded by `pageSize`, not by the total row count. The `startSignal` callback is invoked just before the first data row is written, allowing the caller to dismiss a "preparing" indicator without waiting for the full export.

---

## Transaction Patterns

### Single Insert

```dart
Future<void> insertProduct(ProductsCompanion product) {
  return into(products).insert(product);
}
```

### Batch Insert

```dart
Future<void> insertProducts(List<ProductsCompanion> productList) {
  return batch((batch) {
    batch.insertAll(products, productList);
  });
}
```

### Update

```dart
// Update entire row
Future<void> updateProduct(ProductData product) {
  return update(products).replace(product);
}

// Update specific columns
Future<void> updateProductStock(String productId, double newStock) {
  return (update(products)
    ..where((p) => p.id.equals(productId))
  ).write(ProductsCompanion(
    stock: Value(newStock),
    updatedAt: Value(DateTime.now()),
    version: Value(currentVersion + 1),  // Optimistic locking
  ));
}
```

### Delete

```dart
// Hard delete
Future<void> deleteProduct(String id) {
  return (delete(products)
    ..where((p) => p.id.equals(id))
  ).go();
}

// Soft delete
Future<void> softDeleteProduct(String id) {
  return (update(products)
    ..where((p) => p.id.equals(id))
  ).write(ProductsCompanion(
    deletedAt: Value(DateTime.now()),
    updatedAt: Value(DateTime.now()),
  ));
}
```

### Complex Transactions

```dart
Future<void> createSaleWithInventoryDecrement(
  SalesCompanion sale,
  List<SaleItemsCompanion> items,
) async {
  await transaction(() async {
    // 1. Insert sale
    await into(sales).insert(sale);
    
    // 2. Insert sale items
    await batch((batch) {
      batch.insertAll(saleItems, items);
    });
    
    // 3. Decrement inventory for each item
    for (final item in items) {
      final productId = item.productId.value;
      final qty = item.quantity.value;
      
      // Read current stock
      final product = await (select(products)
        ..where((p) => p.id.equals(productId))
      ).getSingle();
      
      // Update stock
      await (update(products)
        ..where((p) => p.id.equals(productId))
      ).write(ProductsCompanion(
        stock: Value(product.stock - qty),
        updatedAt: Value(DateTime.now()),
      ));
      
      // Insert inventory log
      await into(inventoryLogs).insert(InventoryLogsCompanion.insert(
        id: IdGenerator.newId(),
        productId: productId,
        type: 'out',
        quantity: -qty,
        reason: 'sale',
        refSaleId: Value(sale.id.value),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  });
}
```

### Void Sale Transaction

```dart
Future<void> voidSaleWithInventoryReversal(String saleId) async {
  await transaction(() async {
    // 1. Get sale items
    final items = await (select(saleItems)
      ..where((i) => i.saleId.equals(saleId))
    ).get();
    
    // 2. Mark sale as voided
    await (update(sales)
      ..where((s) => s.id.equals(saleId))
    ).write(SalesCompanion(
      voidedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
    
    // 3. Restore inventory for each item
    for (final item in items) {
      final product = await (select(products)
        ..where((p) => p.id.equals(item.productId))
      ).getSingle();
      
      await (update(products)
        ..where((p) => p.id.equals(item.productId))
      ).write(ProductsCompanion(
        stock: Value(product.stock + item.quantity),
        updatedAt: Value(DateTime.now()),
      ));
      
      // Log reversal
      await into(inventoryLogs).insert(InventoryLogsCompanion.insert(
        id: IdGenerator.newId(),
        productId: item.productId,
        type: 'in',
        quantity: item.quantity.toDouble(),
        reason: 'void_sale',
        refSaleId: Value(saleId),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  });
}
```

---

## Repository Pattern

### Datasource Layer

**Path:** `lib/features/product/data/datasources/product_local_datasource.dart`

```dart
abstract class ProductLocalDatasource {
  Stream<List<ProductData>> watchAllProducts();
  Future<ProductData?> getProductById(String id);
  Future<void> insertProduct(ProductsCompanion product);
  Future<void> updateProduct(ProductData product);
  Future<void> deleteProduct(String id);
}

@LazySingleton(as: ProductLocalDatasource)
class ProductLocalDatasourceImpl implements ProductLocalDatasource {
  ProductLocalDatasourceImpl(this._db);
  
  final AppDatabase _db;
  
  @override
  Stream<List<ProductData>> watchAllProducts() {
    return (_db.select(_db.products)
      ..where((p) => p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.asc(p.name)])
    ).watch();
  }
  
  @override
  Future<ProductData?> getProductById(String id) {
    return (_db.select(_db.products)
      ..where((p) => p.id.equals(id))
      ..where((p) => p.deletedAt.isNull())
    ).getSingleOrNull();
  }
  
  @override
  Future<void> insertProduct(ProductsCompanion product) {
    return _db.into(_db.products).insert(product);
  }
  
  @override
  Future<void> updateProduct(ProductData product) {
    return _db.update(_db.products).replace(product);
  }
  
  @override
  Future<void> deleteProduct(String id) {
    return (_db.update(_db.products)
      ..where((p) => p.id.equals(id))
    ).write(ProductsCompanion(
      deletedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
```

### Repository Implementation

**Path:** `lib/features/product/data/repositories/product_repository_impl.dart`

```dart
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._localDatasource);
  
  final ProductLocalDatasource _localDatasource;
  
  @override
  Stream<List<Product>> watchAllProducts() {
    return _localDatasource.watchAllProducts().map((dataList) {
      return dataList.map((data) => _mapToEntity(data)).toList();
    });
  }
  
  @override
  Future<Product?> getById(String id) async {
    final data = await _localDatasource.getProductById(id);
    return data != null ? _mapToEntity(data) : null;
  }
  
  @override
  Future<void> insertProduct(Product product) async {
    final companion = _mapToCompanion(product);
    await _localDatasource.insertProduct(companion);
  }
  
  // Map database model to domain entity
  Product _mapToEntity(ProductData data) {
    return Product(
      id: data.id,
      name: data.name,
      price: moneyFromSatangOrBaht(data.priceSatang, data.price),
      // ... other fields
    );
  }
  
  // Map domain entity to Drift companion: keep REAL compatibility dual-write.
  ProductsCompanion _mapToCompanion(Product entity) {
    return ProductsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      price: Value(entity.price.value),
      priceSatang: Value(entity.price),
      // ... other fields
    );
  }
}
```

---

## Drift Type Converters

### MoneyConverter

**Location:** `lib/core/database/money_converter.dart`

**v0.9.2 reality:** Legacy REAL baht columns remain for compatibility, while
nullable INTEGER satang columns are active through Drift converters. Writers
must dual-write both representations; readers prefer satang and fall back to
REAL for pre-v32 rows.

```dart
class Products extends Table {
  RealColumn get price => real()();
  RealColumn get cost => real().nullable()();
  IntColumn get priceSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get costSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
}

final price = moneyFromSatangOrBaht(row.priceSatang, row.price);
```
```

### DateTimeConverter (if custom format needed)

```dart
class MillisecondsDateConverter extends TypeConverter<DateTime, int> {
  const MillisecondsDateConverter();
  
  @override
  DateTime fromSql(int fromDb) {
    return DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);
  }
  
  @override
  int toSql(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}
```

---

## Stream Patterns

### BLoC Integration

```dart
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc(this._repository) : super(ProductState.initial()) {
    // Watch products stream
    _productsSubscription = _repository.watchAllProducts().listen(
      (products) => add(ProductsLoaded(products)),
    );
  }
  
  final ProductRepository _repository;
  StreamSubscription<List<Product>>? _productsSubscription;
  
  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}
```

### Multiple Stream Sources

```dart
Stream<CartState> _mapLoadedToState() async* {
  // Combine multiple streams
  await for (final products in _productRepository.watchAllProducts()) {
    final activeProducts = products.where((p) => p.isActive).toList();
    
    // Get current cart items and validate stock
    final validatedItems = _validateStock(state.items, activeProducts);
    
    yield state.copyWith(
      items: validatedItems,
      availableProducts: activeProducts,
    );
  }
}
```

---

## Migration Strategy

### Schema Version Tracking

```dart
@override
int get schemaVersion => 32;  // Increment on each schema change
```

### `beforeOpen` repairs (every open)

`beforeOpen` runs on every database open (not just upgrades) and performs idempotent repairs:

- `PRAGMA journal_mode=WAL` and `PRAGMA foreign_keys=ON`.
- **`ensureProductAuditsTable()`** — creates `product_audits` if missing (legacy v32 DBs created before the table existed), repairs the legacy `changed_at` default from `strftime('%s','now') * 1000` to `strftime('%s','now')`, and migrates existing rows whose `changed_at > 100000000000` by dividing by 1000. Also called from `onUpgrade` so upgraded DBs are repaired in the same pass.

Source: `lib/core/database/app_database_migrations.dart` (`ensureProductAuditsTable`).

### Migration Pattern

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
    await _seedDefaults();
  },
  
  onUpgrade: (Migrator m, int from, int to) async {
    // Migration #17: Add barcode unique index
    if (from < 17) {
      await customStatement('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_unique
        ON products(barcode)
        WHERE barcode IS NOT NULL AND barcode != ''
      ''');
    }
    
    // Migration #22: Add product description
    if (from < 22) {
      await m.addColumn(products, products.description);
    }
    
    // Migration #24: Add barcode indexes
    if (from < 24) {
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_sale_items_product_id
        ON sale_items(product_id)
      ''');
      await customStatement('''
        CREATE INDEX IF NOT EXISTS idx_sales_created_at
        ON sales(created_at DESC)
      ''');
    }
  },
);
```

### v32 Phase M migration

The v32 migration adds 32 nullable `*_satang` columns across 10 money tables and
backfills finite REAL baht values with `CAST(ROUND(baht * 100) AS INTEGER)`.
Conditional amount-or-percent fields are backfilled only when their type is
`AMOUNT`; percentage values remain REAL. The update is idempotent and excludes
NaN/Infinity. Add a file-backed legacy-fixture test for each future schema change.

### Safe Column Addition

```dart
Future<void> _addColumnIfNotExists(
  Migrator m,
  String tableName,
  String columnName,
  String columnDef,
) async {
  // Check if column exists
  final result = await customSelect(
    'PRAGMA table_info($tableName)',
  ).get();
  
  final columnExists = result.any((row) => row.data['name'] == columnName);
  
  if (!columnExists) {
    await customStatement(
      'ALTER TABLE $tableName ADD COLUMN $columnName $columnDef',
    );
  }
}
```

### Data Backfill Migration

```dart
// Example: Backfill deviceId on existing rows
if (from < 13) {
  final deviceId = await _settingsRepository.getDeviceId();
  
  await customStatement('''
    UPDATE products
    SET device_id = ?
    WHERE device_id IS NULL
  ''', [deviceId]);
  
  // Repeat for other tables...
}
```

### Migration Safety & Database Health

The following P1 services provide migration safety, WAL checkpoint management, health reporting, backup metadata, and key recovery. All are `@LazySingleton()` registered via injectable.

#### MigrationSafetyService

**Location:** `lib/core/database/migration_safety_service.dart`

```dart
@LazySingleton()
class MigrationSafetyService {
  MigrationSafetyService(this._db);
  final AppDatabase _db;

  // Free-space preflight — requires ≥ 2× DB size (or 50 MB floor, whichever is larger).
  // Returns MigrationPreflightResult { freeBytes, requiredBytes, canProceed, reason }.
  // reason: 'INSUFFICIENT_FREE_SPACE' | 'FREE_SPACE_UNKNOWN' | null
  Future<MigrationPreflightResult> checkFreeSpace();

  // Current schema version (PRAGMA user_version)
  Future<int> getSchemaVersion();

  // File-based migration status tracking (writes migration_status.json to app docs dir)
  Future<void> markMigrationStart({required int fromVersion, required int toVersion});
  Future<void> markMigrationSuccess({required int fromVersion, required int toVersion});
  Future<void> markMigrationFailure({required int fromVersion, required int toVersion, required String error});
  Future<MigrationStatus> readMigrationStatus();  // returns idle if no status file
  Future<void> clearMigrationStatus();
}

enum MigrationStatus { idle, running, succeeded, failed }
```

#### WalCheckpointService

**Location:** `lib/core/database/wal_checkpoint_service.dart`

```dart
@LazySingleton()
class WalCheckpointService {
  WalCheckpointService(this._db);
  final AppDatabase _db;

  Future<int> getWalSize();        // WAL file size in bytes (0 if absent)
  Future<int> getShmSize();        // SHM file size in bytes
  Future<bool> shouldCheckpoint(); // WAL ≥ 10 MB threshold
  Future<bool> needsTruncate();    // WAL ≥ 50 MB hard limit

  // PASSIVE mode — safe during active money transactions. Returns null if no checkpoint needed.
  Future<CheckpointResult?> checkpointIfNeeded();

  // TRUNCATE mode — requires exclusive lock (backup / day-close).
  Future<CheckpointResult> forceTruncate();

  // General checkpoint with selectable mode.
  Future<CheckpointResult> checkpoint({CheckpointMode mode = CheckpointMode.passive});
}

enum CheckpointMode { passive, full, restart, truncate }

class CheckpointResult {
  final CheckpointMode mode;
  final int busy;               // 1 if a reader was active
  final int logFrames;
  final int checkpointedFrames;
  final int walSizeBefore;
  final int walSizeAfter;
  final int elapsedMs;
  bool get wasBusy => busy == 1;
  bool get walTruncated => walSizeAfter == 0;
}
```

Constants: `walCheckpointThreshold = 10 MB`, `walHardLimit = 50 MB`.

#### DatabaseHealthService

**Location:** `lib/core/database/database_health_service.dart`

```dart
@LazySingleton()
class DatabaseHealthService {
  DatabaseHealthService(this._db, this._walService);
  final AppDatabase _db;
  final WalCheckpointService _walService;

  // checkIntegrity defaults to false — PRAGMA integrity_check can be slow on large DBs.
  Future<DatabaseHealthReport> generateReport({bool checkIntegrity = false});
}

class DatabaseHealthReport {
  final int mainDbSize;
  final int walSize;
  final int shmSize;
  final int totalSize;          // main + WAL + SHM
  final int schemaVersion;      // PRAGMA user_version
  final bool integrityOk;       // PRAGMA integrity_check == 'ok'
  final int freeStorageBytes;   // -1 if unknown
  final bool walNeedsCheckpoint;
  final bool walNeedsTruncate;
  final DateTime generatedAt;

  double get totalSizeMb;
  double get walPercent;
  bool get approachingGuardrail => totalSize > 400 MB;
  bool get exceedsGuardrail => totalSize > 512 MB;
}
```

#### BackupExportService (enhancements)

**Location:** `lib/features/settings/data/services/backup_export_service.dart`

```dart
@LazySingleton()
class BackupExportService {
  BackupExportService(this._db, this._encryption, this._appLock);
  static const minPinLength = 6;
  static const maxBackupBytes = 512 MB;
  static const metadataExtension = '.meta.json';

  // Full export with checksum, metadata, size preflight, progress, and share.
  // Throws StateError('BACKUP_TOO_LARGE') if DB > 512 MB.
  Future<BackupExportResult> exportWithMetadata({
    required bool encrypt,
    String? pin,
    required String shareSubject,
    String appVersion = 'unknown',
    void Function(BackupProgress stage)? onProgress,
  });

  // Export to files without sharing — testable without Flutter bindings.
  Future<BackupExportResult> exportToFiles({
    required bool encrypt,
    String? pin,
    String appVersion = 'unknown',
    void Function(BackupProgress stage)? onProgress,
  });

  // Convenience — returns just the shared file path.
  Future<String> exportAndShare({required bool encrypt, String? pin, required String shareSubject});
}

class BackupMetadata {
  final int schemaVersion;
  final String appVersion;
  final String createdAt;       // ISO-8601 string
  final int dbSizeBytes;
  final String checksumSha256;
  final bool encrypted;

  Map<String, dynamic> toJson();
  factory BackupMetadata.fromJson(Map<String, dynamic> json);
  String encode();
  static BackupMetadata? tryDecode(String? content);
}

class BackupExportResult {
  final String filePath;
  final BackupMetadata metadata;
  final String? metadataPath;
}

enum BackupProgress { idle, checkpointing, copying, checksumming, encrypting, sharing, done }
```

#### RecoveryKitService

**Location:** `lib/core/database/recovery_kit_service.dart`

```dart
@LazySingleton()
class RecoveryKitService {
  RecoveryKitService();

  // Exports SQLCipher key as a password-wrapped .promkey file.
  // Throws: SECRET_TOO_SHORT, NO_DB_KEY.
  Future<RecoveryKitExportResult> exportKit({required String secret, String? outputPath});

  // Imports a .promkey file and installs the key into secure storage.
  // Throws: SECRET_TOO_SHORT, KIT_FILE_NOT_FOUND, KIT_CORRUPT,
  //         KIT_VERSION_UNSUPPORTED, WRONG_SECRET, KEY_ALREADY_EXISTS.
  Future<String> importKit({required String filePath, required String secret, bool replaceExisting = false});

  Future<bool> hasKey();
  Future<void> removeKey();
}

class RecoveryKitExportResult {
  final String filePath;
  final RecoveryKitMetadata metadata;
}

class RecoveryKitMetadata {
  final int version;
  final String createdAt;
  final int kdfIterations;
}
```

File format: `[uint32 headerLength][JSON header][salt(16)][nonce(12)][ciphertext+GCM tag]`. Constants: `kRecoveryKitVersion = 1`, `kRecoveryKitExtension = '.promkey'`, `kRecoveryKitMinSecretLength = 8`, PBKDF2 iterations: 100,000 (HMAC-SHA256).

#### BackupRestoreService (enhancement)

**Location:** `lib/features/settings/data/services/backup_restore_service.dart`

```dart
typedef CandidateValidator = Future<void> Function(String path);

@LazySingleton()
class BackupRestoreService {
  BackupRestoreService(
    this._db,
    this._encryption,
    this._appLock, {
    @ignoreParam CandidateValidator? candidateValidator,
    @ignoreParam this.skipSqlCipherHeaderCheck = false,
  });

  // Restores sourcePath (.enc or .db). Returns the pre-restore backup path.
  // Caller must restart the app process so Drift/GetIt reopen the DB cleanly.
  // Throws: SOURCE_MISSING, BACKUP_TOO_LARGE, PIN_REQUIRED, PIN_TOO_SHORT,
  //         PLAIN_SQLITE_UNSUPPORTED, INVALID_BACKUP, INVALID_BACKUP_SCHEMA,
  //         INVALID_BACKUP_INTEGRITY.
  Future<String> restoreFromPath({required String sourcePath, String? pin});

  // Deletes leftover promsell_pos.pre_restore_*.db files after a successful DB open.
  Future<int> cleanupPreRestoreBackups();
}
```

Constants: `minPinLength = 6` (aligned with `BackupExportService.minPinLength`), `maxBackupBytes = 512 MB`. The `@ignoreParam` annotation on `candidateValidator` and `skipSqlCipherHeaderCheck` keeps them out of the injectable-generated factory.

---

## Performance Tips

### 1. Use Indexes

```dart
// Add index for frequently queried columns
await customStatement('''
  CREATE INDEX IF NOT EXISTS idx_sales_created_at
  ON sales(created_at DESC)
''');
```

### 2. Batch Operations

```dart
// GOOD: Single batch
await batch((batch) {
  for (final product in products) {
    batch.insert(db.products, product);
  }
});

// BAD: Multiple transactions
for (final product in products) {
  await into(db.products).insert(product);  // N transactions
}
```

### 3. Limit Joined Queries

```dart
// Avoid N+1 queries
// BAD:
final products = await select(db.products).get();
for (final product in products) {
  final category = await _getCategory(product.categoryId);  // N queries
}

// GOOD: Use join or asyncMap
final query = select(db.products).join([
  leftOuterJoin(categories, categories.id.equalsExp(products.categoryId)),
]);
```

### 4. Use WAL Mode

```dart
await customStatement('PRAGMA journal_mode=WAL');
```

Benefits:
- Better concurrency (readers don't block writers)
- Faster writes
- No rollback journal overhead

---

<sub>Promsell POS CE · v0.9.4 · Database API Reference</sub>
