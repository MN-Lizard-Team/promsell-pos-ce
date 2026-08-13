import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';
import 'package:promsell_pos_ce/features/customer/domain/repositories/customer_repository.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_event.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_state.dart';

class _MockCustomerRepo extends Mock implements CustomerRepository {}

void main() {
  late _MockCustomerRepo repo;
  final now = DateTime(2026, 1, 1);
  final customer = Customer(
    id: 'c1',
    name: 'Ann',
    phone: '081',
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    repo = _MockCustomerRepo();
    registerFallbackValue(customer);
  });

  CustomerBloc build() => CustomerBloc(repo);

  blocTest<CustomerBloc, CustomerState>(
    'subscribe loads customers from watch stream',
    build: build,
    setUp: () {
      when(
        () => repo.watchAllCustomers(),
      ).thenAnswer((_) => Stream.value([customer]));
    },
    act: (b) => b.add(const CustomersSubscribed()),
    wait: const Duration(milliseconds: 20),
    expect: () => [
      isA<CustomerState>().having(
        (s) => s.status,
        'status',
        CustomerStatus.loading,
      ),
      isA<CustomerState>()
          .having((s) => s.status, 'status', CustomerStatus.success)
          .having((s) => s.customers, 'customers', [customer]),
    ],
  );

  blocTest<CustomerBloc, CustomerState>(
    'add success sets saveStatus saved',
    build: build,
    setUp: () {
      when(
        () => repo.addCustomer(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async => 'new-id');
    },
    act: (b) => b.add(const CustomerAdded(name: 'Bob', phone: '09')),
    expect: () => [
      isA<CustomerState>().having(
        (s) => s.saveStatus,
        'save',
        CustomerSaveStatus.saving,
      ),
      isA<CustomerState>().having(
        (s) => s.saveStatus,
        'save',
        CustomerSaveStatus.saved,
      ),
    ],
  );

  blocTest<CustomerBloc, CustomerState>(
    'add failure sets error',
    build: build,
    setUp: () {
      when(
        () => repo.addCustomer(
          name: any(named: 'name'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          note: any(named: 'note'),
        ),
      ).thenThrow(Exception('boom'));
    },
    act: (b) => b.add(const CustomerAdded(name: 'X')),
    expect: () => [
      isA<CustomerState>().having(
        (s) => s.saveStatus,
        'save',
        CustomerSaveStatus.saving,
      ),
      isA<CustomerState>()
          .having((s) => s.saveStatus, 'save', CustomerSaveStatus.error)
          .having((s) => s.errorMessage, 'err', contains('boom')),
    ],
  );

  blocTest<CustomerBloc, CustomerState>(
    'update and delete success',
    build: build,
    setUp: () {
      when(() => repo.updateCustomer(any())).thenAnswer((_) async {});
      when(() => repo.deleteCustomer(any())).thenAnswer((_) async {});
    },
    act: (b) async {
      b.add(CustomerUpdated(customer));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      b.add(const CustomerDeleted('c1'));
    },
    expect: () => [
      isA<CustomerState>().having(
        (s) => s.saveStatus,
        'save',
        CustomerSaveStatus.saving,
      ),
      isA<CustomerState>().having(
        (s) => s.saveStatus,
        'save',
        CustomerSaveStatus.saved,
      ),
      isA<CustomerState>().having(
        (s) => s.saveStatus,
        'save',
        CustomerSaveStatus.saving,
      ),
      isA<CustomerState>().having(
        (s) => s.saveStatus,
        'save',
        CustomerSaveStatus.saved,
      ),
    ],
  );

  blocTest<CustomerBloc, CustomerState>(
    'search filters list via state.filtered',
    build: build,
    seed: () => CustomerState(
      status: CustomerStatus.success,
      customers: [
        customer,
        Customer(
          id: 'c2',
          name: 'Zed',
          email: 'z@z.com',
          totalSpent: Money.zero,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    ),
    act: (b) => b.add(const CustomerSearchChanged('zed')),
    verify: (b) {
      expect(b.state.filtered.map((c) => c.name), ['Zed']);
    },
  );
}
