// ignore_for_file: avoid_print

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

/// Capacity-contract baseline fixture sizes (see ce-scaling-management-plan.md).
///
/// These match the "Supported baseline" column. Tests that exercise the
/// "Upper-bound watch list" should override the parameters.
const int kBaselineProductCount = 2000;
const int kBaselineSaleCount = 50000;
const int kBaselineSaleItemCount = 250000;
const int kBaselineInventoryLogCount = 150000;

/// Default page size used by cursor-paginated queries (capacity contract).
const int kProductPageSize = 50;
const int kSaleHistoryPageSize = 50;

/// Creates a file-backed [AppDatabase] in a unique temp directory.
///
/// Uses plain [NativeDatabase] over a temp file (not SQLCipher) so it runs
/// on the desktop `flutter test` runner without a native crypto library.
/// The schema, migrations, indexes, and query plans are identical to
/// production — only the encryption layer is bypassed. The plan's
/// "file-backed SQLCipher" requirement is satisfied on-device via the
/// integration_test suite; this desktop fixture is the CI-fast analogue.
AppDatabase createFileBackedDatabase(
  Directory dir, {
  String name = 'scaling.db',
}) {
  final file = File(p.join(dir.path, name));
  if (file.existsSync()) file.deleteSync();
  return AppDatabase.forTesting(NativeDatabase(file));
}

/// Snapshot of seeded counts returned by [seedScalingFixture].
class ScalingFixtureCounts {
  const ScalingFixtureCounts({
    required this.products,
    required this.sales,
    required this.saleItems,
    required this.inventoryLogs,
  });

  final int products;
  final int sales;
  final int saleItems;
  final int inventoryLogs;

  @override
  String toString() =>
      'products=$products, sales=$sales, items=$saleItems, logs=$inventoryLogs';
}

/// Seeds [db] with [productCount] products, [saleCount] sales (each with
/// ~[kBaselineSaleItemCount / kBaselineSaleCount] items), and
/// [inventoryLogCount] inventory logs.
///
/// Dates are spread across a 2-year window starting at [baseDate] so
/// year-range report queries have data in both years.
///
/// Returns the actual inserted counts. Seeding is batched to keep memory
/// bounded — each batch writes at most [batchSize] rows then clears.
Future<ScalingFixtureCounts> seedScalingFixture(
  AppDatabase db, {
  int productCount = kBaselineProductCount,
  int saleCount = kBaselineSaleCount,
  int saleItemCount = kBaselineSaleItemCount,
  int inventoryLogCount = kBaselineInventoryLogCount,
  DateTime? baseDate,
  int batchSize = 1000,
}) async {
  final start = baseDate ?? DateTime(2024, 1, 1);
  // 2-year window so year-range reports have data in both years.
  final window = const Duration(days: 730);

  // Categories (5).
  final categoryIds = <String>[];
  await db.batch((b) {
    for (var i = 0; i < 5; i++) {
      final id = 'cat-scale-$i';
      categoryIds.add(id);
      b.insert(
        db.categories,
        CategoriesCompanion.insert(
          id: id,
          name: 'Category $i',
          sortOrder: Value(i),
        ),
      );
    }
  });

  // Products.
  final productIds = <String>[];
  for (var offset = 0; offset < productCount; offset += batchSize) {
    final end = (offset + batchSize).clamp(0, productCount);
    await db.batch((b) {
      for (var i = offset; i < end; i++) {
        final id = 'prod-scale-$i';
        productIds.add(id);
        final created = start.add(
          Duration(microseconds: (window.inMicroseconds * i) ~/ productCount),
        );
        final price = Money.fromDouble(((i % 1000) + 1) / 10.0);
        final cost = Money.fromDouble(((i % 500) + 1) / 10.0);
        b.insert(
          db.products,
          ProductsCompanion.insert(
            id: id,
            name: 'Product $i',
            sku: Value('SKU$i'),
            skuLower: Value('sku$i'),
            barcode: Value('BC$i'),
            barcodeLower: Value('bc$i'),
            price: price.value,
            cost: Value(cost.value),
            stock: const Value(100),
            categoryId: Value(categoryIds[i % 5]),
            isActive: const Value(true),
            createdAt: Value(created),
            updatedAt: Value(created),
            priceSatang: Value(price),
            costSatang: Value(cost),
          ),
        );
      }
    });
  }

  // Sales + sale items. Each sale has itemsPerSale lines.
  final itemsPerSale = (saleItemCount / saleCount).round();
  var actualItems = 0;
  for (var offset = 0; offset < saleCount; offset += batchSize) {
    final end = (offset + batchSize).clamp(0, saleCount);
    await db.batch((b) {
      for (var s = offset; s < end; s++) {
        final saleId = 'sale-scale-$s';
        final saleDate = start.add(
          Duration(microseconds: (window.inMicroseconds * s) ~/ saleCount),
        );
        var lineTotal = 0.0;
        final itemRows = <SaleItemsCompanion>[];
        for (var j = 0; j < itemsPerSale; j++) {
          final pIdx = (s * 7 + j * 13) % productCount;
          final price = ((pIdx % 1000) + 1) / 10.0;
          final qty = (s % 3) + 1;
          final subtotal = price * qty;
          lineTotal += subtotal;
          final itemSubtotal = Money.fromDouble(subtotal);
          itemRows.add(
            SaleItemsCompanion.insert(
              id: 'si-$s-$j',
              saleId: saleId,
              productId: productIds[pIdx],
              productName: 'Product $pIdx',
              price: price,
              qty: qty,
              subtotal: subtotal,
              updatedAt: Value(saleDate),
              subtotalSatang: Value(itemSubtotal),
              priceSatang: Value(Money.fromDouble(price)),
            ),
          );
        }
        final total = Money.fromDouble(lineTotal);
        b.insert(
          db.sales,
          SalesCompanion.insert(
            id: saleId,
            receiptNumber: Value('R$s'),
            status: const Value('COMPLETED'),
            subtotalAmount: Value(lineTotal),
            totalAmount: lineTotal,
            paymentMethod: 'cash',
            amountReceived: Value(lineTotal),
            createdAt: Value(saleDate),
            updatedAt: Value(saleDate),
            subtotalAmountSatang: Value(total),
            totalAmountSatang: Value(total),
            amountReceivedSatang: Value(total),
          ),
        );
        for (final row in itemRows) {
          b.insert(db.saleItems, row);
        }
        actualItems += itemsPerSale;
      }
    });
  }

  // Inventory logs.
  for (var offset = 0; offset < inventoryLogCount; offset += batchSize) {
    final end = (offset + batchSize).clamp(0, inventoryLogCount);
    await db.batch((b) {
      for (var i = offset; i < end; i++) {
        final pIdx = i % productCount;
        final created = start.add(
          Duration(
            microseconds: (window.inMicroseconds * i) ~/ inventoryLogCount,
          ),
        );
        b.insert(
          db.inventoryLogs,
          InventoryLogsCompanion.insert(
            id: 'log-scale-$i',
            productId: productIds[pIdx],
            type: 'adjustment',
            reason: const Value('adjustment'),
            qtyChange: (i % 5) - 2,
            balanceAfter: 100 + ((i % 5) - 2),
            createdAt: Value(created),
          ),
        );
      }
    });
  }

  return ScalingFixtureCounts(
    products: productIds.length,
    sales: saleCount,
    saleItems: actualItems,
    inventoryLogs: inventoryLogCount,
  );
}

/// Provides a fake [PathProviderPlatform] so [getTemporaryDirectory] works
/// in desktop `flutter_test`. Call once before creating any file-backed DB.
void registerFakePathProvider(Directory root) {
  PathProviderPlatform.instance = _FakePathProvider(root);
}

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);
  final Directory root;

  @override
  Future<String?> getTemporaryPath() async => root.path;

  @override
  Future<String?> getApplicationSupportPath() async => root.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => root.path;

  @override
  Future<String?> getLibraryPath() async => root.path;

  @override
  Future<String?> getDownloadsPath() async => root.path;
}
