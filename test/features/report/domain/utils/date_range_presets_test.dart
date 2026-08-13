import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';

void main() {
  final now = DateTime(2026, 7, 22, 15, 30);

  group('DateRangePresets', () {
    test('startOfDay / endOfDay bounds', () {
      final s = DateRangePresets.startOfDay(now);
      final e = DateRangePresets.endOfDay(now);
      expect(s, DateTime(2026, 7, 22));
      expect(e.hour, 23);
      expect(e.minute, 59);
      expect(e.second, 59);
      expect(e.millisecond, 999);
    });

    test('today', () {
      final (from, to) = DateRangePresets.today(now);
      expect(from, DateTime(2026, 7, 22));
      expect(to.day, 22);
      expect(to.hour, 23);
    });

    test('yesterday', () {
      final (from, to) = DateRangePresets.yesterday(now);
      expect(from, DateTime(2026, 7, 21));
      expect(to.day, 21);
    });

    test('last7Days spans 7 calendar days inclusive', () {
      final (from, to) = DateRangePresets.last7Days(now);
      expect(from, DateTime(2026, 7, 16));
      expect(to.day, 22);
    });

    test('thisMonth from first of month', () {
      final (from, to) = DateRangePresets.thisMonth(now);
      expect(from, DateTime(2026, 7, 1));
      expect(to.day, 22);
    });

    test('match returns preset kinds', () {
      final t = DateRangePresets.today(now);
      expect(
        DateRangePresets.match(t.$1, t.$2, now),
        DateRangePresetKind.today,
      );

      final y = DateRangePresets.yesterday(now);
      expect(
        DateRangePresets.match(y.$1, y.$2, now),
        DateRangePresetKind.yesterday,
      );

      final w = DateRangePresets.last7Days(now);
      expect(
        DateRangePresets.match(w.$1, w.$2, now),
        DateRangePresetKind.last7Days,
      );

      final m = DateRangePresets.thisMonth(now);
      expect(
        DateRangePresets.match(m.$1, m.$2, now),
        DateRangePresetKind.thisMonth,
      );

      expect(
        DateRangePresets.match(DateTime(2020, 1, 1), DateTime(2020, 1, 2), now),
        isNull,
      );
    });
  });
}
