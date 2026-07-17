import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';

void main() {
  final tDateTime = DateTime(2025, 1, 15, 10, 30);

  group('Customer', () {
    test('creates with required fields', () {
      final customer = Customer(
        id: 'c1',
        name: 'John Doe',
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(customer.id, 'c1');
      expect(customer.name, 'John Doe');
      expect(customer.phone, isNull);
      expect(customer.email, isNull);
      expect(customer.note, isNull);
      expect(customer.totalSpent, Money.zero);
      expect(customer.visitCount, 0);
    });

    test('creates with all fields', () {
      final customer = Customer(
        id: 'c1',
        name: 'Jane Smith',
        phone: '0812345678',
        email: 'jane@example.com',
        note: 'VIP customer',
        totalSpent: Money.fromDouble(1500.50),
        visitCount: 12,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(customer.phone, '0812345678');
      expect(customer.email, 'jane@example.com');
      expect(customer.note, 'VIP customer');
      expect(customer.totalSpent, Money.fromDouble(1500.50));
      expect(customer.visitCount, 12);
    });

    test('copyWith updates only specified fields', () {
      final customer = Customer(
        id: 'c1',
        name: 'John',
        phone: '0812345678',
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      final updated = customer.copyWith(name: 'John Doe', visitCount: 5);

      expect(updated.id, 'c1');
      expect(updated.name, 'John Doe');
      expect(updated.phone, '0812345678');
      expect(updated.visitCount, 5);
    });

    test('copyWith can clear nullable phone/email/note', () {
      final customer = Customer(
        id: 'c1',
        name: 'John',
        phone: '0812345678',
        email: 'john@test.com',
        note: 'vip',
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      final cleared = customer.copyWith(phone: null, email: null, note: null);

      expect(cleared.phone, isNull);
      expect(cleared.email, isNull);
      expect(cleared.note, isNull);
      expect(cleared.name, 'John');
    });

    test('props contains all fields', () {
      final customer = Customer(
        id: 'c1',
        name: 'John',
        phone: '081',
        email: 'john@test.com',
        note: 'note',
        totalSpent: Money.fromDouble(100.0),
        visitCount: 3,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(customer.props.length, 9);
    });

    test('equality works correctly', () {
      final c1 = Customer(
        id: 'c1',
        name: 'John',
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );
      final c2 = Customer(
        id: 'c1',
        name: 'John',
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );
      final c3 = Customer(
        id: 'c2',
        name: 'John',
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(c1 == c2, isTrue);
      expect(c1 == c3, isFalse);
    });
  });
}
