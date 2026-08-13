import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/home/domain/entities/home_data.dart';
import 'package:promsell_pos_ce/features/home/domain/repositories/home_repository.dart';
import 'package:promsell_pos_ce/features/home/domain/usecases/load_home_data.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockRepo;
  late LoadHomeData usecase;

  setUp(() {
    mockRepo = MockHomeRepository();
    usecase = LoadHomeData(mockRepo);
  });

  group('LoadHomeData', () {
    test('returns HomeData from repository', () async {
      final expected = HomeData(
        todayRevenue: Money.fromDouble(1500),
        trendData: const [100, 200, 300, 400, 500, 600, 700],
        todaySales: const [],
        todaySalesCount: 10,
        todayCost: Money.fromDouble(500),
        costReady: true,
      );

      when(() => mockRepo.loadHomeData()).thenAnswer((_) async => expected);

      final result = await usecase();

      expect(result, expected);
      expect(result.todayRevenue, Money.fromDouble(1500));
      expect(result.todaySalesCount, 10);
      expect(result.costReady, isTrue);
      verify(() => mockRepo.loadHomeData()).called(1);
    });

    test('propagates error from repository', () async {
      when(() => mockRepo.loadHomeData()).thenThrow(Exception('DB error'));

      expect(() => usecase(), throwsA(isA<Exception>()));
    });
  });
}
