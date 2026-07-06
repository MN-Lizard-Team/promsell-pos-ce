import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';

void main() {
  final tDateTime = DateTime(2025, 1, 15, 10, 30);
  final futureDate = DateTime(2030, 1, 1);
  final pastDate = DateTime(2024, 1, 1);

  group('Promotion', () {
    test('creates with defaults', () {
      final promo = Promotion(
        id: 'p1',
        name: 'Summer Sale',
        startDate: pastDate,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(promo.type, PromotionType.percent);
      expect(promo.value, 0.0);
      expect(promo.minPurchaseAmount, 0.0);
      expect(promo.isActive, isTrue);
      expect(promo.endDate, isNull);
    });

    test(
      'isCurrentlyActive returns true for active promotion in date range',
      () {
        final promo = Promotion(
          id: 'p1',
          name: 'Active Promo',
          startDate: pastDate,
          isActive: true,
          createdAt: tDateTime,
          updatedAt: tDateTime,
        );

        expect(promo.isCurrentlyActive, isTrue);
      },
    );

    test('isCurrentlyActive returns false when inactive', () {
      final promo = Promotion(
        id: 'p1',
        name: 'Inactive Promo',
        startDate: pastDate,
        isActive: false,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(promo.isCurrentlyActive, isFalse);
    });

    test('isCurrentlyActive returns false when start date is in future', () {
      final promo = Promotion(
        id: 'p1',
        name: 'Future Promo',
        startDate: futureDate,
        isActive: true,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(promo.isCurrentlyActive, isFalse);
    });

    test('isCurrentlyActive returns false when end date has passed', () {
      final promo = Promotion(
        id: 'p1',
        name: 'Expired Promo',
        startDate: pastDate,
        endDate: DateTime(2024, 6, 1),
        isActive: true,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(promo.isCurrentlyActive, isFalse);
    });

    test('discountFor percent type calculates correctly', () {
      final promo = Promotion(
        id: 'p1',
        name: '10% Off',
        type: PromotionType.percent,
        value: 10,
        startDate: pastDate,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(promo.discountFor(100), 10);
      expect(promo.discountFor(250), 25);
      expect(promo.discountFor(0), 0);
    });

    test('discountFor amount type clamps to subtotal', () {
      final promo = Promotion(
        id: 'p1',
        name: '50 Off',
        type: PromotionType.amount,
        value: 50,
        startDate: pastDate,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(promo.discountFor(100), 50);
      expect(promo.discountFor(30), 30);
      expect(promo.discountFor(0), 0);
    });

    test('discountFor returns 0 when below minPurchaseAmount', () {
      final promo = Promotion(
        id: 'p1',
        name: 'Min 200',
        type: PromotionType.percent,
        value: 10,
        minPurchaseAmount: 200,
        startDate: pastDate,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(promo.discountFor(100), 0);
      expect(promo.discountFor(200), 20);
    });

    test('discountFor returns 0 when not currently active', () {
      final promo = Promotion(
        id: 'p1',
        name: 'Inactive',
        type: PromotionType.percent,
        value: 10,
        startDate: pastDate,
        isActive: false,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(promo.discountFor(100), 0);
    });

    test('copyWith updates only specified fields', () {
      final promo = Promotion(
        id: 'p1',
        name: 'Original',
        value: 10,
        startDate: pastDate,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      final updated = promo.copyWith(name: 'Updated', value: 20);

      expect(updated.id, 'p1');
      expect(updated.name, 'Updated');
      expect(updated.value, 20);
      expect(updated.startDate, pastDate);
    });

    test('props contains all fields', () {
      final promo = Promotion(
        id: 'p1',
        name: 'Test',
        type: PromotionType.percent,
        value: 10,
        minPurchaseAmount: 100,
        startDate: pastDate,
        endDate: futureDate,
        isActive: true,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(promo.props.length, 10);
    });

    test('equality works correctly', () {
      final p1 = Promotion(
        id: 'p1',
        name: 'Test',
        startDate: pastDate,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );
      final p2 = Promotion(
        id: 'p1',
        name: 'Test',
        startDate: pastDate,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );
      final p3 = Promotion(
        id: 'p2',
        name: 'Test',
        startDate: pastDate,
        createdAt: tDateTime,
        updatedAt: tDateTime,
      );

      expect(p1 == p2, isTrue);
      expect(p1 == p3, isFalse);
    });
  });
}
