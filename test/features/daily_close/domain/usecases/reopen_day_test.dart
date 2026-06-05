import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/reopen_day.dart';

class MockDailyCloseRepository extends Mock implements DailyCloseRepository {}

class FakeDailyClose extends Fake implements DailyClose {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDailyClose());
  });
  group('ReopenDay', () {
    late MockDailyCloseRepository mockRepo;
    late ReopenDay usecase;

    setUp(() {
      mockRepo = MockDailyCloseRepository();
      usecase = ReopenDay(mockRepo);
    });

    test('clears closedAt and resets cash fields', () async {
      final existing = DailyClose(
        id: '1',
        closeDate: '2026-06-05',
        closedAt: DateTime(2026, 6, 5, 22),
        countedCash: 500,
        overShortAmount: 20,
        note: 'All good',
      );

      when(
        () => mockRepo.getByDate('2026-06-05'),
      ).thenAnswer((_) async => existing);
      when(() => mockRepo.save(any())).thenAnswer((inv) async {
        return inv.positionalArguments.first as DailyClose;
      });

      final result = await usecase('2026-06-05');

      expect(result.isClosed, isFalse);
      expect(result.countedCash, 0);
      expect(result.overShortAmount, 0);
      expect(result.note, isNull);
    });

    test('throws when no record exists', () async {
      when(
        () => mockRepo.getByDate('2026-06-05'),
      ).thenAnswer((_) async => null);

      expect(() => usecase('2026-06-05'), throwsA(isA<StateError>()));
    });

    test('throws when day is not closed', () async {
      final existing = const DailyClose(
        id: '1',
        closeDate: '2026-06-05',
        closedAt: null,
      );

      when(
        () => mockRepo.getByDate('2026-06-05'),
      ).thenAnswer((_) async => existing);

      expect(() => usecase('2026-06-05'), throwsA(isA<StateError>()));
    });
  });
}
