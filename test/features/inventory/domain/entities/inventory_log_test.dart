import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';

void main() {
  group('InventoryLog', () {
    test('supports value equality', () {
      final log1 = InventoryLog(
        id: 'a',
        productId: 'p1',
        type: 'SALE',
        qtyChange: -1,
        balanceAfter: 9,
        createdAt: DateTime(2025),
      );
      final log2 = InventoryLog(
        id: 'a',
        productId: 'p1',
        type: 'SALE',
        qtyChange: -1,
        balanceAfter: 9,
        createdAt: DateTime(2025),
      );
      expect(log1, equals(log2));
    });

    test('isPositive returns true for non-negative qtyChange', () {
      final log = InventoryLog(
        id: 'a',
        productId: 'p1',
        type: 'ADJUSTMENT_IN',
        qtyChange: 5,
        balanceAfter: 15,
        createdAt: DateTime(2025),
      );
      expect(log.isPositive, isTrue);
    });

    test('isPositive returns false for negative qtyChange', () {
      final log = InventoryLog(
        id: 'a',
        productId: 'p1',
        type: 'SALE',
        qtyChange: -3,
        balanceAfter: 7,
        createdAt: DateTime(2025),
      );
      expect(log.isPositive, isFalse);
    });

    test('props contains all fields', () {
      final log = InventoryLog(
        id: 'a',
        productId: 'p1',
        type: 'SALE',
        qtyChange: -1,
        balanceAfter: 9,
        reason: 'test',
        refSaleId: 's1',
        createdAt: DateTime(2025),
      );
      expect(log.props.length, 8);
    });
  });
}
