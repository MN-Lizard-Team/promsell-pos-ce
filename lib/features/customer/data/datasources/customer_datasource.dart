import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';

abstract class CustomerDatasource {
  Future<List<Customer>> getAll();
  Stream<List<Customer>> watchAll();
  Future<Customer?> getById(String id);
  Future<void> insert(CustomersCompanion companion);
  Future<void> update(CustomersCompanion companion);
  Future<void> softDelete(String id);
  Future<void> updateSpent(String id, double totalSpent, int visitCount);
}

@LazySingleton(as: CustomerDatasource)
class CustomerDatasourceImpl implements CustomerDatasource {
  const CustomerDatasourceImpl(this._db);
  final AppDatabase _db;

  Customer _fromData(CustomerData d) => Customer(
    id: d.id,
    name: d.name,
    phone: d.phone,
    email: d.email,
    note: d.note,
    totalSpent: d.totalSpent,
    visitCount: d.visitCount,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );

  @override
  Future<List<Customer>> getAll() =>
      (_db.select(_db.customers)
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .get()
          .then((rows) => rows.map(_fromData).toList());

  @override
  Stream<List<Customer>> watchAll() =>
      (_db.select(_db.customers)
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .watch()
          .map((rows) => rows.map(_fromData).toList());

  @override
  Future<Customer?> getById(String id) =>
      (_db.select(_db.customers)
            ..where((c) => c.id.equals(id))
            ..where((c) => c.deletedAt.isNull()))
          .getSingleOrNull()
          .then((d) => d == null ? null : _fromData(d));

  @override
  Future<void> insert(CustomersCompanion companion) =>
      _db.into(_db.customers).insert(companion);

  @override
  Future<void> update(CustomersCompanion companion) => (_db.update(
    _db.customers,
  )..where((c) => c.id.equals(companion.id.value))).write(companion);

  @override
  Future<void> softDelete(String id) =>
      (_db.update(_db.customers)..where((c) => c.id.equals(id))).write(
        CustomersCompanion(deletedAt: Value(DateTime.now())),
      );

  @override
  Future<void> updateSpent(String id, double totalSpent, int visitCount) =>
      (_db.update(_db.customers)..where((c) => c.id.equals(id))).write(
        CustomersCompanion(
          totalSpent: Value(totalSpent),
          visitCount: Value(visitCount),
          updatedAt: Value(DateTime.now()),
        ),
      );
}
