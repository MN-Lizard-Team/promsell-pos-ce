import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/inventory/data/datasources/inventory_log_local_datasource.dart';

import '../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late InventoryLogLocalDatasource ds;

  setUp(() {
    db = createInMemoryDatabase();
    ds = InventoryLogLocalDatasource(db);
  });

  tearDown(() => db.close());

  Future<void> seedLog({
    required String productId,
    required DateTime createdAt,
    String type = 'SALE',
    int qtyChange = -1,
  }) async {
    await ds.insertLog(
      InventoryLogsCompanion.insert(
        id: IdGenerator.newId(),
        productId: productId,
        type: type,
        qtyChange: qtyChange,
        balanceAfter: 10,
        createdAt: Value(createdAt),
      ),
    );
  }

  test('watchLogsByProduct filters and orders desc', () async {
    final p1 = 'prod-a';
    final p2 = 'prod-b';
    await seedLog(productId: p1, createdAt: DateTime(2026, 1, 1), type: 'SALE');
    await seedLog(
      productId: p1,
      createdAt: DateTime(2026, 1, 3),
      type: 'ADJUSTMENT_IN',
      qtyChange: 5,
    );
    await seedLog(productId: p2, createdAt: DateTime(2026, 1, 2));

    await expectLater(
      ds.watchLogsByProduct(p1),
      emitsThrough(
        predicate((list) {
          final logs = list as List;
          return logs.length == 2 &&
              logs.first.type == 'ADJUSTMENT_IN' &&
              logs.last.type == 'SALE';
        }),
      ),
    );
  });

  test('getLogsByDateRange filters by start/end', () async {
    await seedLog(productId: 'p', createdAt: DateTime(2026, 6, 1, 12));
    await seedLog(productId: 'p', createdAt: DateTime(2026, 6, 15, 12));
    await seedLog(productId: 'p', createdAt: DateTime(2026, 7, 1, 12));

    final mid = await ds.getLogsByDateRange(
      startDate: DateTime(2026, 6, 10),
      endDate: DateTime(2026, 6, 20),
    );
    expect(mid.length, 1);
    expect(mid.single.createdAt.day, 15);

    final all = await ds.getLogsByDateRange();
    expect(all.length, 3);
  });

  test('legacy watchLogs with productId limit', () async {
    final pid = 'prod-x';
    for (var i = 0; i < 3; i++) {
      await seedLog(productId: pid, createdAt: DateTime(2026, 1, i + 1));
    }
    await expectLater(
      ds.watchLogs(productId: pid),
      emitsThrough(predicate((rows) => (rows as List).length == 3)),
    );
  });
}
