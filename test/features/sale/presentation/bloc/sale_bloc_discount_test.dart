import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockCreateSale mockCreateSale;
  late MockDraftCartRepository mockDraftRepo;
  late MockSettingsRepository mockSettingsRepo;

  setUp(() {
    mockCreateSale = MockCreateSale();
    mockDraftRepo = MockDraftCartRepository();
    mockSettingsRepo = MockSettingsRepository();
    when(
      () => mockDraftRepo.createDraft(name: any(named: 'name')),
    ).thenAnswer((_) async => 'draft-1');
    when(
      () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
    ).thenAnswer((_) async {});
    when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
    when(() => mockDraftRepo.deleteDraft(any())).thenAnswer((_) async {});
    when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 0);
    when(
      () => mockSettingsRepo.load(),
    ).thenAnswer((_) async => const Settings());
  });

  setUpAll(() {
    registerFallbackValue(<CartItem>[]);
    registerFallbackValue(const SaleState());
  });

  SaleBloc buildBloc() => SaleBloc(
    createSale: mockCreateSale,
    draftRepo: mockDraftRepo,
    settingsRepo: mockSettingsRepo,
  );

  group('SaleBloc — item discount', () {
    blocTest<SaleBloc, SaleState>(
      'SaleItemDiscountChanged updates item discount',
      build: buildBloc,
      seed: () => SaleState(items: [CartItem(product: tProduct, qty: 2)]),
      act: (b) => b.add(
        SaleItemDiscountChanged(
          productId: tProduct.id,
          discountType: 'PERCENT',
          discountValue: 10,
        ),
      ),
      expect: () => [
        SaleState(
          items: [
            CartItem(
              product: tProduct,
              qty: 2,
              discountType: 'PERCENT',
              discountValue: 10,
            ),
          ],
        ),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleItemDiscountCleared removes item discount',
      build: buildBloc,
      seed: () => SaleState(
        items: [
          CartItem(
            product: tProduct,
            qty: 2,
            discountType: 'PERCENT',
            discountValue: 10,
          ),
        ],
      ),
      act: (b) => b.add(SaleItemDiscountCleared(tProduct.id)),
      expect: () => [
        SaleState(items: [CartItem(product: tProduct, qty: 2)]),
      ],
    );
  });

  group('SaleBloc — cart discount', () {
    blocTest<SaleBloc, SaleState>(
      'SaleCartDiscountChanged sets cart discount',
      build: buildBloc,
      act: (b) => b.add(
        const SaleCartDiscountChanged(
          discountType: 'AMOUNT',
          discountValue: 50,
        ),
      ),
      expect: () => [
        const SaleState(cartDiscountType: 'AMOUNT', cartDiscountValue: 50),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleCartDiscountCleared removes cart discount',
      build: buildBloc,
      seed: () =>
          const SaleState(cartDiscountType: 'AMOUNT', cartDiscountValue: 50),
      act: (b) => b.add(const SaleCartDiscountCleared()),
      expect: () => [const SaleState()],
    );

    test('SaleState.total = itemsSubtotal - cartDiscountAmount', () {
      final state = SaleState(
        items: [CartItem(product: tProduct, qty: 2)],
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10,
      );
      expect(state.itemsSubtotal, 200.0);
      expect(state.cartDiscountAmount, 20.0);
      expect(state.total, 180.0);
    });

    test('SaleState.hasCartDiscount is true when cart discount set', () {
      const state = SaleState(
        cartDiscountType: 'AMOUNT',
        cartDiscountValue: 30,
      );
      expect(state.hasCartDiscount, isTrue);
    });

    test('SaleState.hasCartDiscount is false when no discount', () {
      expect(const SaleState().hasCartDiscount, isFalse);
    });
  });

  group('SaleBloc — trackStock + allowOversell', () {
    test('trackStock=false: isInStock is true regardless of stock', () {
      expect(tServiceProduct.isInStock, isTrue);
      expect(tServiceProduct.trackStock, isFalse);
    });

    blocTest<SaleBloc, SaleState>(
      'allowOversell=false: cannot add beyond stock',
      build: buildBloc,
      seed: () => SaleState(
        items: [CartItem(product: tProduct, qty: tProduct.stock)],
      ),
      act: (b) => b.add(SaleProductAdded(tProduct, allowOversell: false)),
      expect: () => [],
    );

    blocTest<SaleBloc, SaleState>(
      'allowOversell=true: can add beyond stock',
      build: buildBloc,
      seed: () => SaleState(
        items: [CartItem(product: tProduct, qty: tProduct.stock)],
      ),
      act: (b) => b.add(SaleProductAdded(tProduct, allowOversell: true)),
      expect: () => [
        SaleState(
          items: [CartItem(product: tProduct, qty: tProduct.stock + 1)],
        ),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'trackStock=false: can always add regardless of stock=0',
      build: buildBloc,
      act: (b) =>
          b.add(SaleProductAdded(tServiceProduct, allowOversell: false)),
      expect: () => [
        SaleState(items: [CartItem(product: tServiceProduct, qty: 1)]),
      ],
    );
  });
}
