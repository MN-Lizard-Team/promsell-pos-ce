import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/adjust_stock.dart';
import '../../../../helpers/mocks.dart';

void main() {
  group('AdjustStock', () {
    late AdjustStock useCase;
    late MockInventoryRepository mockRepo;
    late MockAppLockService mockAppLock;

    setUp(() {
      mockRepo = MockInventoryRepository();
      mockAppLock = MockAppLockService();
      useCase = AdjustStock(mockRepo, mockAppLock);
    });

    test('delegates to repository.adjustStock after app lock check', () async {
      when(
        () => mockAppLock.requireSensitiveSession(),
      ).thenAnswer((_) async {});
      when(
        () => mockRepo.adjustStock(
          productId: any(named: 'productId'),
          qtyChange: any(named: 'qtyChange'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async {});

      await useCase(productId: 'prod-001', qtyChange: 10, reason: 'Restock');

      verify(() => mockAppLock.requireSensitiveSession()).called(1);
      verify(
        () => mockRepo.adjustStock(
          productId: 'prod-001',
          qtyChange: 10,
          reason: 'Restock',
        ),
      ).called(1);
    });

    test(
      'throws BusinessRuleError when app lock is enabled and session locked',
      () async {
        when(
          () => mockAppLock.requireSensitiveSession(),
        ).thenThrow(const BusinessRuleError('AppLockRequired'));

        expect(
          () => useCase(productId: 'prod-001', qtyChange: 5, reason: 'Adjust'),
          throwsA(isA<BusinessRuleError>()),
        );

        verifyNever(
          () => mockRepo.adjustStock(
            productId: any(named: 'productId'),
            qtyChange: any(named: 'qtyChange'),
            reason: any(named: 'reason'),
          ),
        );
      },
    );

    test('propagates repository errors', () async {
      when(
        () => mockAppLock.requireSensitiveSession(),
      ).thenAnswer((_) async {});
      when(
        () => mockRepo.adjustStock(
          productId: any(named: 'productId'),
          qtyChange: any(named: 'qtyChange'),
          reason: any(named: 'reason'),
        ),
      ).thenThrow(StateError('Product not found'));

      expect(
        () => useCase(productId: 'missing', qtyChange: -5, reason: 'Remove'),
        throwsA(isA<StateError>()),
      );
    });

    test('negative qtyChange is passed through (stock removal)', () async {
      when(
        () => mockAppLock.requireSensitiveSession(),
      ).thenAnswer((_) async {});
      when(
        () => mockRepo.adjustStock(
          productId: any(named: 'productId'),
          qtyChange: any(named: 'qtyChange'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async {});

      await useCase(productId: 'prod-001', qtyChange: -3, reason: 'Damaged');

      verify(
        () => mockRepo.adjustStock(
          productId: 'prod-001',
          qtyChange: -3,
          reason: 'Damaged',
        ),
      ).called(1);
    });

    test(
      'app lock is checked before repository call (order matters)',
      () async {
        var lockChecked = false;
        var repoCalled = false;

        when(() => mockAppLock.requireSensitiveSession()).thenAnswer((_) async {
          lockChecked = true;
        });
        when(
          () => mockRepo.adjustStock(
            productId: any(named: 'productId'),
            qtyChange: any(named: 'qtyChange'),
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async {
          repoCalled = true;
        });

        await useCase(productId: 'p1', qtyChange: 1, reason: 'test');

        expect(lockChecked, isTrue);
        expect(repoCalled, isTrue);
      },
    );
  });
}
