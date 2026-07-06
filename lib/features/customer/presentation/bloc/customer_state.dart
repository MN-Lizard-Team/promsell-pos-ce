import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';

enum CustomerStatus { initial, loading, success, failure }

enum CustomerSaveStatus { idle, saving, saved, error }

class CustomerState extends Equatable {
  const CustomerState({
    this.status = CustomerStatus.initial,
    this.customers = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.saveStatus = CustomerSaveStatus.idle,
  });

  final CustomerStatus status;
  final List<Customer> customers;
  final String searchQuery;
  final String? errorMessage;
  final CustomerSaveStatus saveStatus;

  List<Customer> get filtered {
    if (searchQuery.isEmpty) return customers;
    final q = searchQuery.toLowerCase();
    return customers
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              (c.phone?.toLowerCase().contains(q) ?? false) ||
              (c.email?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  CustomerState copyWith({
    CustomerStatus? status,
    List<Customer>? customers,
    String? searchQuery,
    String? errorMessage,
    CustomerSaveStatus? saveStatus,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  @override
  List<Object?> get props => [
    status,
    customers,
    searchQuery,
    errorMessage,
    saveStatus,
  ];
}
