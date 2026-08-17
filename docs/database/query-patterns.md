# Query Patterns — Promsell POS CE (v0.9.3)

Common Drift query patterns used in the datasource layer.

> **Main reference:** [`docs/DATABASE.md`](../DATABASE.md) — overview, ERD, sync columns

---

## Watch active products (stream)

```dart
// ProductLocalDatasourceImpl
Stream<List<Product>> watchActiveProducts() {
  final query = select(products)
    ..where((p) => p.isActive.equals(true))
    ..orderBy([(p) => OrderingTerm.asc(p.name)]);
  return query.watch().map((rows) => rows.map(_fromData).toList());
}
```

## Get product by ID

```dart
Future<Product?> getProductById(String id) async {
  final query = select(products)..where((p) => p.id.equals(id));
  final row = await query.getSingleOrNull();
  return row == null ? null : _fromData(row);
}
```

## Insert sale with items (atomic transaction)

```dart
Future<Sale> insertSaleWithItems({
  required List<CartItem> items,
  required String paymentMethod,
  required String vatMode,   // 'NONE' | 'INCLUSIVE' | 'EXCLUSIVE'
  required double vatRate,   // e.g. 7.0
  double? amountReceived,
  double? changeAmount,
  String? note,
}) async {
  // Calculate VAT breakdown from vatMode + vatRate
  final subtotal = ...; final vatAmount = ...; final finalTotal = ...;

  await _db.transaction(() async {
    // 1. Generate receipt number via ReceiptNumberService
    final receipt = await _receiptService.next();

    // 2. Insert sale row with sale-time VAT snapshot
    final saleId = IdGenerator.newId();
    await _db.into(_db.sales).insert(
      SalesCompanion.insert(
        id: saleId, receiptNumber: Value(receipt),
        subtotalAmount: Value(subtotal),
        vatMode: Value(vatMode), vatRate: Value(vatRate), vatAmount: Value(vatAmount),
        totalAmount: finalTotal, ...
      ),
    );

    for (final item in items) {
      // 3. Insert sale item
      await _db.into(_db.saleItems).insert(...);

      // 4. Deduct stock
      await (_db.update(_db.products)..where((p) => p.id.equals(item.product.id)))
        .write(ProductsCompanion(stock: Value(newStock)));

      // 5. Log inventory change
      await _inventoryLogService.log(
        productId: item.product.id,
        type: 'SALE',
        qtyChange: -item.qty,
        balanceAfter: newStock,
        refSaleId: saleId,
      );
    }
  });
}
```

## Void sale (atomic transaction)

```dart
Future<void> voidSale(String saleId, {String? reason}) async {
  await _db.transaction(() async {
    // 1. Mark sale as VOIDED
    await (_db.update(_db.sales)..where((s) => s.id.equals(saleId)))
      .write(SalesCompanion(
        status: const Value('VOIDED'),
        voidedAt: Value(DateTime.now()),
        voidReason: Value(reason),
      ));

    // 2. Restore stock + log VOID_REVERSAL per item
    for (final item in saleItems) {
      final newStock = currentStock + item.qty;
      await (_db.update(_db.products)..where(...))
        .write(ProductsCompanion(stock: Value(newStock)));
      await _inventoryLogService.log(
        type: 'VOID_REVERSAL', qtyChange: item.qty, ...
      );
    }
  });
}
```

## Query sales by date range

```dart
Future<List<Sale>> querySalesByDateRange(DateTime from, DateTime to) async {
  final query = select(sales)
    ..where((s) => s.createdAt.isBetweenValues(from, to))
    ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
  // ...fetch + build with items
}
```

## Watch / hydrate recent sales (batched — not N+1)

SSOT: `SaleQueryLocalDatasource.hydrateSales` in
`lib/features/sale/data/datasources/sale_query_local_datasource.dart`.

```dart
// After selecting sale rows:
// 1) one query: sale_items WHERE saleId.isIn(ids)
// 2) one query: sale_payments WHERE saleId.isIn(ids)
// 3) map into Sale aggregates
```

Do **not** loop `get items for each sale`.

## Upsert draft cart (debounced auto-save)

```dart
// DraftCartLocalDatasourceImpl
Future<void> upsertDraft(String cartId, SaleState state) async {
  await _db.transaction(() async {
    // 1. Update cart header (name, note, updatedAt)
    await (_db.update(_db.draftCarts)..where((t) => t.id.equals(cartId)))
        .write(DraftCartsCompanion(updatedAt: Value(DateTime.now())));

    // 2. Delete old items
    await (_db.delete(_db.draftCartItems)..where((t) => t.cartId.equals(cartId))).go();

    // 3. Re-insert current items (with per-item discounts)
    for (final item in state.items) {
      await _db.into(_db.draftCartItems).insert(
        DraftCartItemsCompanion.insert(
          id: IdGenerator.newId(), cartId: cartId,
          productId: item.product.id, productName: item.product.name,
          price: item.product.price, qty: item.qty,
          discountType: Value(item.discountType),
          discountValue: Value(item.discountValue),
        ),
      );
    }
  });
}
```

## Cursor-based product pagination

SSOT: `ProductLocalDatasource.getProductsPage()` in
`lib/features/product/data/datasources/product_local_datasource.dart`.

Uses a composite `(created_at DESC, id)` cursor backed by `idx_products_created_at_id_cursor` (added within schema **v32**, not a new schema version). Avoids `OFFSET` performance degradation on large product tables.

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

## Cursor-based product search

SSOT: `ProductLocalDatasource.searchProductsPage()` in
`lib/features/product/data/datasources/product_local_datasource.dart`.

Same cursor mechanism as `getProductsPage`, with an additional `query` filter (name / `sku_lower` / `barcode_lower` `LIKE` match). Ranking is applied in memory on the DB result page.

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

## Paged sale history

SSOT: `SaleQueryLocalDatasource.querySalesPage()` / `querySalesCount()` in
`lib/features/sale/data/datasources/sale_query_local_datasource.dart`.

Uses `idx_sales_created_at_id_cursor` (added within schema **v32**, not a new schema version) for cursor-based pagination. Items and payments are hydrated **only for the current page** (batched, not N+1).

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

`SalePage` is an entity containing `sales` (list of `Sale`), `nextCursor` (`SaleCursor?`, null when no more rows), and `totalCount`.

## Report summary aggregate

SSOT: `SaleQueryLocalDatasource.queryReportSummary()` in
`lib/features/sale/data/datasources/sale_query_local_datasource.dart`.

SQL-level aggregation returning a `ReportSummary` entity. Uses the Satang-SSOT strategy: INTEGER `*_satang` columns are preferred, with REAL baht fallback for pre-v32 rows. Payment method lookup is chunked to 500 rows at a time to avoid SQLite variable limits.

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

## Bounded streaming CSV export

SSOT: `ReportExportService.exportCsvStream()` in
`lib/features/report/data/services/report_export_service.dart`.

Pages through sales via `SaleRepository.getSalesPage()`, writing CSV chunks incrementally to a `sink` callback. Memory is bounded by `pageSize`, not by the total row count. Enforces a hard cap of `kExportMaxRows = 10000` rows; `CsvExportResult.truncated` is true when the cap was hit. The `startSignal` callback is invoked just before the first data row is written, allowing the caller to dismiss a "preparing" indicator without waiting for the full export.

```dart
const int kExportMaxRows = 10000;

class CsvExportResult {
  final int rowsWritten;
  final bool truncated;
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

---

<sub>Promsell POS CE · v0.9.3 · Query Patterns</sub>
