import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_by_date.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_list.dart';

class MockDailyCloseRepository extends Mock implements DailyCloseRepository {}

void main() {
  late MockDailyCloseRepository mockRepo;

  setUp(() {
    mockRepo = MockDailyCloseRepository();
  });

  const tDailyClose = DailyClose(
    id: 'dc-0001',
    closeDate: '2025-01-15',
    totalRevenue: 5000.0,
    salesCount: 10,
  );

  group('GetDailyCloseList', () {
    late GetDailyCloseList useCase;

    setUp(() => useCase = GetDailyCloseList(mockRepo));

    test('delegates to repository.getAll', () async {
      when(() => mockRepo.getAll()).thenAnswer((_) async => [tDailyClose]);

      final result = await useCase();

      expect(result, [tDailyClose]);
      verify(() => mockRepo.getAll()).called(1);
    });
  });

  group('GetDailyCloseByDate', () {
    late GetDailyCloseByDate useCase;

    setUp(() => useCase = GetDailyCloseByDate(mockRepo));

    test('delegates to repository.getByDate', () async {
      when(
        () => mockRepo.getByDate('2025-01-15'),
      ).thenAnswer((_) async => tDailyClose);

      final result = await useCase('2025-01-15');

      expect(result, tDailyClose);
      verify(() => mockRepo.getByDate('2025-01-15')).called(1);
    });

    test('returns null when not found', () async {
      when(
        () => mockRepo.getByDate('2025-01-16'),
      ).thenAnswer((_) async => null);

      final result = await useCase('2025-01-16');

      expect(result, isNull);
    });
  });
}
