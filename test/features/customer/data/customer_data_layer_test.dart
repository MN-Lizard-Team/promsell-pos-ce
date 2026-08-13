import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/customer/data/datasources/customer_datasource.dart';
import 'package:promsell_pos_ce/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';

import '../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late CustomerRepositoryImpl repo;

  setUp(() {
    db = createInMemoryDatabase();
    repo = CustomerRepositoryImpl(CustomerDatasourceImpl(db));
  });

  tearDown(() => db.close());

  test('add + getAll + getById', () async {
    final id = await repo.addCustomer(
      name: 'Ann',
      phone: '081',
      email: 'a@b.c',
      note: 'vip',
    );
    final all = await repo.getAllCustomers();
    expect(all.single.name, 'Ann');
    expect(all.single.phone, '081');

    final one = await repo.getCustomerById(id);
    expect(one?.email, 'a@b.c');
    expect(one?.note, 'vip');
  });

  test('updateCustomer and deleteCustomer soft-hides', () async {
    final id = await repo.addCustomer(name: 'Bob');
    final loaded = (await repo.getCustomerById(id))!;
    await repo.updateCustomer(loaded.copyWith(name: 'Bobby', phone: '099'));
    expect((await repo.getCustomerById(id))!.name, 'Bobby');
    expect((await repo.getCustomerById(id))!.phone, '099');

    await repo.deleteCustomer(id);
    expect(await repo.getCustomerById(id), isNull);
    expect(await repo.getAllCustomers(), isEmpty);
  });

  test('updateSpentStats increments spent and visits', () async {
    final id = await repo.addCustomer(name: 'Cara');
    await repo.updateSpentStats(id, 50.5);
    await repo.updateSpentStats(id, 10);
    final c = (await repo.getCustomerById(id))!;
    expect(c.totalSpent, Money.fromDouble(60.5));
    expect(c.visitCount, 2);
  });

  test('updateSpentStats no-ops for missing id', () async {
    await repo.updateSpentStats('missing', 99);
    expect(await repo.getAllCustomers(), isEmpty);
  });

  test('watchAllCustomers emits', () async {
    final stream = repo.watchAllCustomers();
    await repo.addCustomer(name: 'Dee');
    await expectLater(
      stream,
      emitsThrough(
        predicate<List<Customer>>((list) => list.any((c) => c.name == 'Dee')),
      ),
    );
  });
}
