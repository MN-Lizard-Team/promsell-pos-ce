import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';

void main() {
  group('SalesDayLock.dateIso', () {
    test('formats local calendar date', () {
      expect(SalesDayLock.dateIso(DateTime(2026, 7, 15, 23, 30)), '2026-07-15');
    });
  });

  group('SalesDayLock.isCreateBlocked', () {
    final today = DateTime(2026, 7, 15, 10);

    test('false when lock off', () {
      expect(
        SalesDayLock.isCreateBlocked(
          dailyCloseLock: false,
          lastClosedDate: '2026-07-15',
          now: today,
        ),
        isFalse,
      );
    });

    test('true when lock on and lastClosed is today', () {
      expect(
        SalesDayLock.isCreateBlocked(
          dailyCloseLock: true,
          lastClosedDate: '2026-07-15',
          now: today,
        ),
        isTrue,
      );
    });

    test('false when lastClosed is other day', () {
      expect(
        SalesDayLock.isCreateBlocked(
          dailyCloseLock: true,
          lastClosedDate: '2026-07-14',
          now: today,
        ),
        isFalse,
      );
    });

    test('false when lastClosed empty', () {
      expect(
        SalesDayLock.isCreateBlocked(
          dailyCloseLock: true,
          lastClosedDate: '',
          now: today,
        ),
        isFalse,
      );
    });
  });

  group('SalesDayLock.isVoidBlocked', () {
    test('false when lock off even if row closed', () {
      expect(
        SalesDayLock.isVoidBlocked(
          dailyCloseLock: false,
          lastClosedDate: '2026-07-15',
          saleCreatedAt: DateTime(2026, 7, 15, 12),
          dayRowClosed: true,
        ),
        isFalse,
      );
    });

    test('true when lastClosed matches sale day', () {
      expect(
        SalesDayLock.isVoidBlocked(
          dailyCloseLock: true,
          lastClosedDate: '2026-07-15',
          saleCreatedAt: DateTime(2026, 7, 15, 12),
        ),
        isTrue,
      );
    });

    test('true when dayRowClosed even if lastClosed other', () {
      expect(
        SalesDayLock.isVoidBlocked(
          dailyCloseLock: true,
          lastClosedDate: '2026-07-14',
          saleCreatedAt: DateTime(2026, 7, 15, 12),
          dayRowClosed: true,
        ),
        isTrue,
      );
    });

    test('false when open day', () {
      expect(
        SalesDayLock.isVoidBlocked(
          dailyCloseLock: true,
          lastClosedDate: '2026-07-14',
          saleCreatedAt: DateTime(2026, 7, 15, 12),
          dayRowClosed: false,
        ),
        isFalse,
      );
    });
  });
}
