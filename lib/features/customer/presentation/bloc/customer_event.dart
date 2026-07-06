import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();
  @override
  List<Object?> get props => [];
}

class CustomersSubscribed extends CustomerEvent {
  const CustomersSubscribed();
}

class CustomerAdded extends CustomerEvent {
  const CustomerAdded({required this.name, this.phone, this.email, this.note});
  final String name;
  final String? phone;
  final String? email;
  final String? note;

  @override
  List<Object?> get props => [name, phone, email, note];
}

class CustomerUpdated extends CustomerEvent {
  const CustomerUpdated(this.customer);
  final Customer customer;

  @override
  List<Object?> get props => [customer];
}

class CustomerDeleted extends CustomerEvent {
  const CustomerDeleted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class CustomerSearchChanged extends CustomerEvent {
  const CustomerSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}
