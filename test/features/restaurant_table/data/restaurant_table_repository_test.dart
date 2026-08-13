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

    final one = await repo.getTableById(id);
    expect(one?.id, id);
  });

  test('updateTable, updateTableStatus, deleteTable', () async {
    final id = await repo.addTable(name: 'T2');
    final t = (await repo.getTableById(id))!;
    await repo.updateTable(
      t.copyWith(name: 'T2b', zone: 'Patio', seats: 2, sortOrder: 9),
    );
    var loaded = (await repo.getTableById(id))!;
    expect(loaded.name, 'T2b');
    expect(loaded.zone, 'Patio');
    expect(loaded.seats, 2);
    expect(loaded.sortOrder, 9);

    await repo.updateTableStatus(id, TableStatus.occupied);
    loaded = (await repo.getTableById(id))!;
    expect(loaded.status, TableStatus.occupied);

    await repo.deleteTable(id);
    expect(await repo.getTableById(id), isNull);
    expect(await repo.getAllTables(), isEmpty);
  });

  test('getTableById returns null for missing', () async {
    expect(await repo.getTableById('nope'), isNull);
  });
}
