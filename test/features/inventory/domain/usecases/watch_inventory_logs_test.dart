import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/watch_inventory_logs.dart';
import '../../../../helpers/mocks.dart';

void main() {
  group('WatchInventoryLogs', () {
    late WatchInventoryLogs useCase;
    late MockInventoryLogRepository mockRepo;

    setUp(() {
      mockRepo = MockInventoryLogRepository();
      useCase = WatchInventoryLogs(mockRepo);
    });

    test('delegates to repository.watchLogs without productId', () {
      final logs = [
        InventoryLog(
          id: 'a',
          productId: 'p1',
          type: 'SALE',
          qtyChange: -1,
          balanceAfter: 9,
          createdAt: DateTime(2025),
        ),
      ];
      when(() => mockRepo.watchLogs()).thenAnswer((_) => Stream.value(logs));

      expect(useCase(), emits(logs));
      verify(() => mockRepo.watchLogs()).called(1);
    });

    test('delegates to repository.watchLogs with productId', () {
      when(
        () => mockRepo.watchLogs(productId: 'p1'),
      ).thenAnswer((_) => Stream.value([]));

      expect(useCase(productId: 'p1'), emits([]));
      verify(() => mockRepo.watchLogs(productId: 'p1')).called(1);
    });
  });
}
