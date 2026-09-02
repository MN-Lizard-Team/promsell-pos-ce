import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/kitchen_ticket.dart';

void main() {
  const line = KitchenTicketLine(
    lineId: 'line-1',
    productId: 'prod-1',
    productName: 'Pad Thai',
    qty: 2,
    note: 'no peanuts',
    optionsJson: '[{"id":"opt-1"}]',
  );

  group('KitchenTicketLine', () {
    test('equal lines with identical fields are equal', () {
      const other = KitchenTicketLine(
        lineId: 'line-1',
        productId: 'prod-1',
        productName: 'Pad Thai',
        qty: 2,
        note: 'no peanuts',
        optionsJson: '[{"id":"opt-1"}]',
      );

      expect(line, equals(other));
      expect(line.hashCode, other.hashCode);
    });

    test('different qty means inequality', () {
      const other = KitchenTicketLine(
        lineId: 'line-1',
        productId: 'prod-1',
        productName: 'Pad Thai',
        qty: 3,
      );

      expect(line, isNot(equals(other)));
    });

    test('different note means inequality', () {
      const other = KitchenTicketLine(
        lineId: 'line-1',
        productId: 'prod-1',
        productName: 'Pad Thai',
        qty: 2,
        note: 'extra spicy',
      );

      expect(line, isNot(equals(other)));
    });
  });

  group('KitchenTicket', () {
    test('equal tickets with identical fields are equal', () {
      final firedAt = DateTime(2026, 9, 1, 10);
      final a = KitchenTicket(
        cartId: 'cart-1',
        firedAt: firedAt,
        lines: const [line],
        tableId: 'table-1',
        tableName: 'A1',
      );
      final b = KitchenTicket(
        cartId: 'cart-1',
        firedAt: firedAt,
        lines: const [line],
        tableId: 'table-1',
        tableName: 'A1',
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different tableId means inequality', () {
      final firedAt = DateTime(2026, 9, 1, 10);
      final a = KitchenTicket(
        cartId: 'cart-1',
        firedAt: firedAt,
        lines: const [line],
        tableId: 'table-1',
      );
      final b = KitchenTicket(
        cartId: 'cart-1',
        firedAt: firedAt,
        lines: const [line],
        tableId: 'table-2',
      );

      expect(a, isNot(equals(b)));
    });

    test('different lines mean inequality', () {
      final firedAt = DateTime(2026, 9, 1, 10);
      const otherLine = KitchenTicketLine(
        lineId: 'line-2',
        productId: 'prod-2',
        productName: 'Fried Rice',
        qty: 1,
      );
      final a = KitchenTicket(
        cartId: 'cart-1',
        firedAt: firedAt,
        lines: const [line],
      );
      final b = KitchenTicket(
        cartId: 'cart-1',
        firedAt: firedAt,
        lines: const [otherLine],
      );

      expect(a, isNot(equals(b)));
    });

    test('nullable fields default to null', () {
      final ticket = KitchenTicket(
        cartId: 'cart-1',
        firedAt: DateTime(2026, 9, 1, 10),
        lines: const [],
      );

      expect(ticket.tableId, isNull);
      expect(ticket.tableName, isNull);
      expect(ticket.lines, isEmpty);
    });
  });
}
