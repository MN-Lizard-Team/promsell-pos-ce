import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/restaurant_table/data/repositories/restaurant_table_repository_impl.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';

import '../../../helpers/fake_database.dart';
import '../../../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late RestaurantTableRepositoryImpl repo;

  setUp(() {
    db = createInMemoryDatabase();
    repo = RestaurantTableRepositoryImpl(
      db,
      settingsRepo: FakeSettingsRepository(),
    );
  });

  tearDown(() => db.close());

  Future<String> seedTable({String name = 'T1'}) => repo.addTable(name: name);

  /// Inserts a draft cart row directly.
  Future<String> seedCart(
    String tableId, {
    bool archived = false,
    DateTime? deletedAt,
  }) async {
    final id =
        'cart-$tableId-${archived
            ? 'a'
            : deletedAt != null
            ? 'd'
            : 'x'}';
    await db
        .into(db.draftCarts)
        .insert(
          DraftCartsCompanion.insert(
            id: id,
            tableId: Value(tableId),
            isArchived: Value(archived),
            deletedAt: Value(deletedAt),
            updatedAt: Value(DateTime(2026, 1, 1)),
          ),
        );
    return id;
  }

  test('addTable + getAllTables + getTableById', () async {
    final id = await repo.addTable(
      name: 'T1',
      zone: 'A',
      seats: 4,
      sortOrder: 1,
    );
    final all = await repo.getAllTables();
    expect(all.single.name, 'T1');
    expect(all.single.zone, 'A');
    expect(all.single.seats, 4);
    expect(all.single.status, TableStatus.available);
    expect(all.single.manualStatus, TableStatus.available);

    final one = await repo.getTableById(id);
    expect(one?.id, id);
  });

  test('updateTable persists manual fields but never occupancy', () async {
    final id = await seedTable(name: 'T2');
    final t = (await repo.getTableById(id))!;
    // Effective occupied must not round-trip into the stored column.
    await repo.updateTable(
      t.copyWith(name: 'T2b', zone: 'Patio', seats: 2, sortOrder: 9),
    );
    final loaded = (await repo.getTableById(id))!;
    expect(loaded.name, 'T2b');
    expect(loaded.zone, 'Patio');
    expect(loaded.seats, 2);
    expect(loaded.sortOrder, 9);
    expect(loaded.manualStatus, TableStatus.available);
  });

  test('updateTableStatus persists ONLY available/reserved', () async {
    final id = await seedTable();
    await repo.updateTableStatus(id, TableStatus.reserved);
    var loaded = (await repo.getTableById(id))!;
    expect(loaded.status, TableStatus.reserved);
    expect(loaded.manualStatus, TableStatus.reserved);

    await repo.updateTableStatus(id, TableStatus.available);
    loaded = (await repo.getTableById(id))!;
    expect(loaded.manualStatus, TableStatus.available);
  });

  test('deleteTable soft-deletes so the table disappears from reads', () async {
    final id = await seedTable();
    await repo.deleteTable(id);
    expect(await repo.getTableById(id), isNull);
    expect(await repo.getAllTables(), isEmpty);
  });

  group('derived occupancy (active draft cart bound to table)', () {
    test('active cart makes the effective status occupied', () async {
      final tableId = await seedTable();
      await seedCart(tableId);

      final t = (await repo.getTableById(tableId))!;
      expect(t.status, TableStatus.occupied);
      // Manual choice untouched underneath.
      expect(t.manualStatus, TableStatus.available);
    });

    test(
      'paying frees the table: hard-deleted cart no longer occupies',
      () async {
        final tableId = await seedTable();
        final cartId = await seedCart(tableId);
        expect(
          (await repo.getTableById(tableId))!.status,
          TableStatus.occupied,
        );

        // What SaleInsertWriter does inside the sale transaction: hard-delete
        // the originating cart row (items cascade via FK).
        final deleted = await (db.delete(
          db.draftCarts,
        )..where((c) => c.id.equals(cartId))).go();
        expect(deleted, 1);

        final t = (await repo.getTableById(tableId))!;
        expect(t.status, TableStatus.available);
      },
    );

    test('archived or soft-deleted carts do NOT occupy', () async {
      final tableId = await seedTable();
      await seedCart(tableId, archived: true);
      expect((await repo.getTableById(tableId))!.status, TableStatus.available);

      final tableId2 = await seedTable(name: 'T3');
      await seedCart(tableId2, deletedAt: DateTime(2026, 1, 2));
      expect(
        (await repo.getTableById(tableId2))!.status,
        TableStatus.available,
      );
    });

    test(
      'occupied overrides a reserved manual status; freeing restores it',
      () async {
        final tableId = await seedTable();
        await repo.updateTableStatus(tableId, TableStatus.reserved);
        await seedCart(tableId);

        var t = (await repo.getTableById(tableId))!;
        expect(t.status, TableStatus.occupied);
        expect(t.manualStatus, TableStatus.reserved);

        // Paying deletes the binding — manual reserved value comes back.
        await (db.delete(
          db.draftCarts,
        )..where((c) => c.tableId.equals(tableId))).go();
        t = (await repo.getTableById(tableId))!;
        expect(t.status, TableStatus.reserved);
      },
    );

    test(
      'watchTables re-emits when a cart binds/unbinds (live floor plan)',
      () async {
        final tableId = await seedTable();

        final statuses = <TableStatus>[];
        final sub = repo.watchTables().listen(
          (tables) =>
              statuses.add(tables.firstWhere((t) => t.id == tableId).status),
        );
        addTearDown(sub.cancel);
        await Future<void>.delayed(Duration.zero);
        expect(statuses, [TableStatus.available]);

        // Cart opened on the table → next emission is occupied.
        await seedCart(tableId);
        while (statuses.length < 2) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        expect(statuses[1], TableStatus.occupied);

        // Cart paid/deleted → freed again without any explicit write.
        await db.draftCarts.delete().go();
        while (statuses.length < 3) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        expect(statuses[2], TableStatus.available);
      },
    );
  });
}
