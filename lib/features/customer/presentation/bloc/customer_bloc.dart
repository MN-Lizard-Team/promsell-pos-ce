import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';
import 'package:promsell_pos_ce/features/customer/domain/repositories/customer_repository.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_event.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_state.dart';

class _CustomersUpdated extends CustomerEvent {
  const _CustomersUpdated(this.customers);
  final List<Customer> customers;
  @override
  List<Object?> get props => [customers];
}

@injectable
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerBloc(this._repository) : super(const CustomerState()) {
    on<CustomersSubscribed>(_onSubscribed);
    on<_CustomersUpdated>(_onCustomersUpdated);
    on<CustomerAdded>(_onAdded);
    on<CustomerUpdated>(_onUpdated);
    on<CustomerDeleted>(_onDeleted);
    on<CustomerSearchChanged>(_onSearchChanged);
  }

  final CustomerRepository _repository;
  StreamSubscription<List<Customer>>? _sub;

  Future<void> _onSubscribed(
    CustomersSubscribed event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(status: CustomerStatus.loading));
    await _sub?.cancel();
    _sub = _repository.watchAllCustomers().listen(
      (customers) => add(_CustomersUpdated(customers)),
    );
  }

  void _onCustomersUpdated(
    _CustomersUpdated event,
    Emitter<CustomerState> emit,
  ) {
    emit(
      state.copyWith(
        status: CustomerStatus.success,
        customers: event.customers,
        errorMessage: null,
        saveStatus: CustomerSaveStatus.idle,
      ),
    );
  }

  Future<void> _onAdded(
    CustomerAdded event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(saveStatus: CustomerSaveStatus.saving));
    try {
      await _repository.addCustomer(
        name: event.name,
        phone: event.phone,
        email: event.email,
        note: event.note,
      );
      emit(state.copyWith(saveStatus: CustomerSaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: CustomerSaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdated(
    CustomerUpdated event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(saveStatus: CustomerSaveStatus.saving));
    try {
      await _repository.updateCustomer(event.customer);
      emit(state.copyWith(saveStatus: CustomerSaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: CustomerSaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleted(
    CustomerDeleted event,
    Emitter<CustomerState> emit,
  ) async {
    emit(state.copyWith(saveStatus: CustomerSaveStatus.saving));
    try {
      await _repository.deleteCustomer(event.id);
      emit(state.copyWith(saveStatus: CustomerSaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: CustomerSaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSearchChanged(
    CustomerSearchChanged event,
    Emitter<CustomerState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
