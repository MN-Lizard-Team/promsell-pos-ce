import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_bloc.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_event.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_state.dart';

class _MockPromoRepo extends Mock implements PromotionRepository {}

void main() {
  late _MockPromoRepo repo;
  final now = DateTime(2026, 1, 1);
  final promo = Promotion(
    id: 'p1',
    name: '10%',
    startDate: now,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    repo = _MockPromoRepo();
    registerFallbackValue(promo);
  });

  PromotionBloc build() => PromotionBloc(repo);

  blocTest<PromotionBloc, PromotionState>(
    'subscribe loads promotions',
    build: build,
    setUp: () {
      when(
        () => repo.watchAllPromotions(),
      ).thenAnswer((_) => Stream.value([promo]));
    },
    act: (b) => b.add(const PromotionsSubscribed()),
    wait: const Duration(milliseconds: 20),
    expect: () => [
      isA<PromotionState>().having(
        (s) => s.status,
        'status',
        PromotionStatus.loading,
      ),
      isA<PromotionState>()
          .having((s) => s.status, 'status', PromotionStatus.success)
          .having((s) => s.promotions, 'list', [promo]),
    ],
  );

  blocTest<PromotionBloc, PromotionState>(
    'add / update / delete success paths',
    build: build,
    setUp: () {
      when(() => repo.addPromotion(any())).thenAnswer((_) async => 'id');
      when(() => repo.updatePromotion(any())).thenAnswer((_) async {});
      when(() => repo.deletePromotion(any())).thenAnswer((_) async {});
    },
    act: (b) async {
      b.add(PromotionAdded(promo));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      b.add(PromotionUpdated(promo));
      await Future<void>.delayed(const Duration(milliseconds: 5));
      b.add(const PromotionDeleted('p1'));
    },
    expect: () => [
      isA<PromotionState>().having(
        (s) => s.saveStatus,
        's',
        PromotionSaveStatus.saving,
      ),
      isA<PromotionState>().having(
        (s) => s.saveStatus,
        's',
        PromotionSaveStatus.saved,
      ),
      isA<PromotionState>().having(
        (s) => s.saveStatus,
        's',
        PromotionSaveStatus.saving,
      ),
      isA<PromotionState>().having(
        (s) => s.saveStatus,
        's',
        PromotionSaveStatus.saved,
      ),
      isA<PromotionState>().having(
        (s) => s.saveStatus,
        's',
        PromotionSaveStatus.saving,
      ),
      isA<PromotionState>().having(
        (s) => s.saveStatus,
        's',
        PromotionSaveStatus.saved,
      ),
    ],
  );

  blocTest<PromotionBloc, PromotionState>(
    'add failure',
    build: build,
    setUp: () {
      when(() => repo.addPromotion(any())).thenThrow(Exception('nope'));
    },
    act: (b) => b.add(PromotionAdded(promo)),
    expect: () => [
      isA<PromotionState>().having(
        (s) => s.saveStatus,
        's',
        PromotionSaveStatus.saving,
      ),
      isA<PromotionState>()
          .having((s) => s.saveStatus, 's', PromotionSaveStatus.error)
          .having((s) => s.errorMessage, 'e', contains('nope')),
    ],
  );

  blocTest<PromotionBloc, PromotionState>(
    'search changes query',
    build: build,
    act: (b) => b.add(const PromotionSearchChanged('sale')),
    expect: () => [
      isA<PromotionState>().having((s) => s.searchQuery, 'q', 'sale'),
    ],
  );
}
