import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/inventory/data/datasources/inventory_log_local_datasource.dart';
import 'package:promsell_pos_ce/features/inventory/data/repositories/inventory_log_repository_impl.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';

import '../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late InventoryLogLocalDatasource ds;
  late InventoryLogRepositoryImpl repo;
  late ProductLocalDatasourceImpl productDs;

  setUp(() {
    db = createInMemoryDatabase();
    ds = InventoryLogLocalDatasource(db);
    repo = InventoryLogRepositoryImpl(ds);
    productDs = ProductLocalDatasourceImpl(db);
  });

  tearDown(() => db.close());

  Future<void> seedInventoryLog({
    required String id,
    required String productId,
    required String type,
    required int qtyChange,
    required int balanceAfter,
  }) async {
    await db
        .into(db.inventoryLogs)
        .insert(
          InventoryLogsCompanion.insert(
            id: id,
            productId: productId,
            type: type,
            qtyChange: qtyChange,
            balanceAfter: balanceAfter,
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  group('InventoryLogLocalDatasource', () {
    test('watchLogs returns empty stream when no logs', () async {
      final logs = await ds.watchLogs().first;
      expect(logs, isEmpty);
    });

    test('watchLogs returns all logs ordered by createdAt desc', () async {
      await productDs.insertProduct(
        ProductsCompanion.insert(
          id: 'p1',
          name: 'P1',
          price: 10,
          stock: const Value(10),
        ),
      );
      await seedInventoryLog(
        id: 'log-1',
        productId: 'p1',
        type: 'ADJUSTMENT_IN',
        qtyChange: 5,
        balanceAfter: 15,
      );
      await seedInventoryLog(
        id: 'log-2',
        productId: 'p1',
        type: 'SALE',
        qtyChange: -2,
        balanceAfter: 13,
      );

      final logs = await ds.watchLogs().first;
      expect(logs, hasLength(2));
    });

    test('watchLogs filters by productId', () async {
      await productDs.insertProduct(
        ProductsCompanion.insert(
          id: 'p1',
          name: 'P1',
          price: 10,
          stock: const Value(10),
        ),
      );
      await productDs.insertProduct(
        ProductsCompanion.insert(
          id: 'p2',
          name: 'P2',
          price: 20,
          stock: const Value(5),
        ),
      );
      await seedInventoryLog(
        id: 'log-1',
        productId: 'p1',
        type: 'ADJUSTMENT_IN',
        qtyChange: 5,
        balanceAfter: 15,
      );
      await seedInventoryLog(
        id: 'log-2',
        productId: 'p2',
        type: 'SALE',
        qtyChange: -1,
        balanceAfter: 4,
      );

      final logs = await ds.watchLogs(productId: 'p1').first;
      expect(logs, hasLength(1));
      expect(logs.first.productId, 'p1');
    });
  });

  group('InventoryLogRepositoryImpl', () {
    test('watchLogs maps data to entity correctly', () async {
      await productDs.insertProduct(
        ProductsCompanion.insert(
          id: 'p1',
          name: 'P1',
          price: 10,
          stock: const Value(10),
        ),
      );
      await seedInventoryLog(
        id: 'log-1',
        productId: 'p1',
        type: 'ADJUSTMENT_IN',
        qtyChange: 5,
        balanceAfter: 15,
      );

      final logs = await repo.watchLogs().first;
      expect(logs, hasLength(1));
      expect(logs.first.id, 'log-1');
      expect(logs.first.productId, 'p1');
      expect(logs.first.type, 'ADJUSTMENT_IN');
      expect(logs.first.qtyChange, 5);
      expect(logs.first.balanceAfter, 15);
    });

    test('watchLogs with productId filter', () async {
      await productDs.insertProduct(
        ProductsCompanion.insert(
          id: 'p1',
          name: 'P1',
          price: 10,
          stock: const Value(10),
        ),
      );
      await productDs.insertProduct(
        ProductsCompanion.insert(
          id: 'p2',
          name: 'P2',
          price: 20,
          stock: const Value(5),
        ),
      );
      await seedInventoryLog(
        id: 'log-1',
        productId: 'p1',
        type: 'ADJUSTMENT_IN',
        qtyChange: 5,
        balanceAfter: 15,
      );
      await seedInventoryLog(
        id: 'log-2',
        productId: 'p2',
        type: 'SALE',
        qtyChange: -1,
        balanceAfter: 4,
      );

      final logs = await repo.watchLogs(productId: 'p2').first;
      expect(logs, hasLength(1));
      expect(logs.first.productId, 'p2');
    });
  });
}
