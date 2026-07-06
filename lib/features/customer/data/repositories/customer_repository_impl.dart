import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/customer/data/datasources/customer_datasource.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';
import 'package:promsell_pos_ce/features/customer/domain/repositories/customer_repository.dart';

@LazySingleton(as: CustomerRepository)
class CustomerRepositoryImpl implements CustomerRepository {
  const CustomerRepositoryImpl(this._datasource);
  final CustomerDatasource _datasource;

  @override
  Future<List<Customer>> getAllCustomers() => _datasource.getAll();

  @override
  Stream<List<Customer>> watchAllCustomers() => _datasource.watchAll();

  @override
  Future<Customer?> getCustomerById(String id) => _datasource.getById(id);

  @override
  Future<String> addCustomer({
    required String name,
    String? phone,
    String? email,
    String? note,
  }) async {
    final id = IdGenerator.newId();
    final now = DateTime.now();
    await _datasource.insert(
      CustomersCompanion.insert(
        id: id,
        name: name,
        phone: Value(phone),
        email: Value(email),
        note: Value(note),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return id;
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _datasource.update(
      CustomersCompanion(
        id: Value(customer.id),
        name: Value(customer.name),
        phone: Value(customer.phone),
        email: Value(customer.email),
        note: Value(customer.note),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteCustomer(String id) => _datasource.softDelete(id);

  @override
  Future<void> updateSpentStats(String customerId, double amount) async {
    final customer = await _datasource.getById(customerId);
    if (customer == null) return;
    await _datasource.updateSpent(
      customerId,
      customer.totalSpent + amount,
      customer.visitCount + 1,
    );
  }
}
