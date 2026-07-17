import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';

void main() {
  group('DailyClose', () {
    test('equality works for identical values', () {
      final a = DailyClose(
        id: '1',
        closeDate: '2026-06-05',
        totalRevenue: Money.fromDouble(1000),
        salesCount: 5,
      );
      final b = DailyClose(
        id: '1',
        closeDate: '2026-06-05',
        totalRevenue: Money.fromDouble(1000),
        salesCount: 5,
      );
      expect(a, b);
    });

    test('equality fails for different values', () {
      const a = DailyClose(id: '1', closeDate: '2026-06-05');
      const b = DailyClose(id: '2', closeDate: '2026-06-05');
      expect(a, isNot(b));
    });

    test('isClosed returns true when closedAt is set', () {
      const close = DailyClose(
        id: '1',
        closeDate: '2026-06-05',
        closedAt: null,
      );
      expect(close.isClosed, isFalse);
    });

    test('isClosed returns false when closedAt is null', () {
      const close = DailyClose(
        id: '1',
        closeDate: '2026-06-05',
        closedAt: null,
      );
      expect(close.isClosed, isFalse);
    });

    test('copyWith updates values', () {
      const close = DailyClose(id: '1', closeDate: '2026-06-05');
      final updated = close.copyWith(
        countedCash: Money.fromDouble(500),
        salesCount: 3,
      );
      expect(updated.countedCash, Money.fromDouble(500));
      expect(updated.salesCount, 3);
      expect(updated.closeDate, '2026-06-05');
    });
  });
}
