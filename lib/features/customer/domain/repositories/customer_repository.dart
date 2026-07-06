import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAllCustomers();
  Stream<List<Customer>> watchAllCustomers();
  Future<Customer?> getCustomerById(String id);
  Future<String> addCustomer({
    required String name,
    String? phone,
    String? email,
    String? note,
  });
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
  Future<void> updateSpentStats(String customerId, double amount);
}
