# Query Patterns — Promsell POS CE v0.8.6

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

## Watch recent sales (stream with limit)

```dart
Stream<List<Sale>> watchRecentSales({int limit = 20}) {
  final query = select(sales)
    ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
    ..limit(limit);
  return query.watch().asyncMap((rows) async {
    // fetch items for each sale
  });
}
```

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

---

<sub>Promsell POS CE · v0.8.6 · Query Patterns</sub>
