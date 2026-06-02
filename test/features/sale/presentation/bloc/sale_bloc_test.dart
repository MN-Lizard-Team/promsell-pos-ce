import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

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
    ).thenAnswer((_) async => 'draft-id-1');
    when(
      () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
    ).thenAnswer((_) async {});
    when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
    when(() => mockDraftRepo.deleteDraft(any())).thenAnswer((_) async {});
    when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 0);
    when(() => mockDraftRepo.archiveOldDrafts(any())).thenAnswer((_) async => 0);
    when(
      () => mockSettingsRepo.load(),
    ).thenAnswer((_) async => const AppSettings(maxDrafts: 30));
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

  group('SaleBloc', () {
    test('initial state is SaleState()', () {
      expect(buildBloc().state, const SaleState());
    });

    blocTest<SaleBloc, SaleState>(
      'SaleProductAdded adds product to cart',
      build: buildBloc,
      act: (b) => b.add(SaleProductAdded(tProduct)),
      expect: () => [
        SaleState(items: [CartItem(product: tProduct, qty: 1)]),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleProductAdded increments qty for existing product',
      build: buildBloc,
      seed: () => SaleState(items: [CartItem(product: tProduct, qty: 1)]),
      act: (b) => b.add(SaleProductAdded(tProduct)),
      expect: () => [
        SaleState(items: [CartItem(product: tProduct, qty: 2)]),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleProductRemoved removes product from cart',
      build: buildBloc,
      seed: () => SaleState(items: [tCartItem]),
      act: (b) => b.add(SaleProductRemoved(tProduct.id)),
      expect: () => [const SaleState()],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleItemQtyChanged updates qty',
      build: buildBloc,
      seed: () => SaleState(items: [CartItem(product: tProduct, qty: 1)]),
      act: (b) => b.add(SaleItemQtyChanged(productId: tProduct.id, qty: 5)),
      expect: () => [
        SaleState(items: [CartItem(product: tProduct, qty: 5)]),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleCartCleared resets state',
      build: buildBloc,
      seed: () => SaleState(items: [tCartItem]),
      act: (b) => b.add(const SaleCartCleared()),
      expect: () => [const SaleState()],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleNoteChanged updates note',
      build: buildBloc,
      act: (b) => b.add(const SaleNoteChanged('test note')),
      expect: () => [const SaleState(note: 'test note')],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleConfirmed emits processing then success',
      setUp: () {
        when(
          () => mockCreateSale(
            items: any(named: 'items'),
            paymentMethod: any(named: 'paymentMethod'),
            vatMode: any(named: 'vatMode'),
            vatRate: any(named: 'vatRate'),
            amountReceived: any(named: 'amountReceived'),
            changeAmount: any(named: 'changeAmount'),
            note: any(named: 'note'),
          ),
        ).thenAnswer((_) async => tSale);
      },
      build: buildBloc,
      seed: () => SaleState(items: [tCartItem]),
      act: (b) => b.add(
        const SaleConfirmed(
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: 500,
          changeAmount: 300,
        ),
      ),
      expect: () => [
        SaleState(items: [tCartItem], status: SaleStatus.processing),
        SaleState(
          status: SaleStatus.success,
          lastSale: tSale,
          activeDraftId: 'draft-id-1',
          activeDraftName: 'Bill #1',
        ),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleConfirmed emits failure on error',
      setUp: () {
        when(
          () => mockCreateSale(
            items: any(named: 'items'),
            paymentMethod: any(named: 'paymentMethod'),
            vatMode: any(named: 'vatMode'),
            vatRate: any(named: 'vatRate'),
            amountReceived: any(named: 'amountReceived'),
            changeAmount: any(named: 'changeAmount'),
            note: any(named: 'note'),
          ),
        ).thenThrow(Exception('db error'));
      },
      build: buildBloc,
      seed: () => SaleState(items: [tCartItem]),
      act: (b) => b.add(
        const SaleConfirmed(paymentMethod: 'cash', vatMode: 'NONE', vatRate: 0),
      ),
      expect: () => [
        SaleState(items: [tCartItem], status: SaleStatus.processing),
        isA<SaleState>()
            .having((s) => s.status, 'status', SaleStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleConfirmed does nothing when cart is empty',
      build: buildBloc,
      act: (b) => b.add(
        const SaleConfirmed(paymentMethod: 'cash', vatMode: 'NONE', vatRate: 0),
      ),
      expect: () => [],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleReset preserves cart discount and clears success status',
      build: buildBloc,
      seed: () => SaleState(
        status: SaleStatus.success,
        lastSale: tSale,
        items: [tCartItem],
        note: 'note',
        activeDraftId: 'draft-1',
        activeDraftName: 'Test Draft',
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10.0,
      ),
      act: (b) => b.add(const SaleReset()),
      expect: () => [
        SaleState(
          items: [tCartItem],
          note: 'note',
          activeDraftId: 'draft-1',
          activeDraftName: 'Test Draft',
          cartDiscountType: 'PERCENT',
          cartDiscountValue: 10.0,
        ),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleDraftSwitched restores cart discount',
      build: buildBloc,
      seed: () => SaleState(
        items: [tCartItem],
        activeDraftId: 'draft-1',
        activeDraftName: 'Old',
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10.0,
      ),
      setUp: () {
        when(() => mockDraftRepo.loadDraft('draft-2')).thenAnswer(
          (_) async => DraftCart(
            id: 'draft-2',
            name: 'New Draft',
            items: [tCartItem],
            cartDiscountType: 'AMOUNT',
            cartDiscountValue: 20.0,
            updatedAt: DateTime(2024),
          ),
        );
      },
      act: (b) => b.add(const SaleDraftSwitched('draft-2')),
      expect: () => [
        SaleState(
          items: [tCartItem],
          activeDraftId: 'draft-2',
          activeDraftName: 'New Draft',
          cartDiscountType: 'AMOUNT',
          cartDiscountValue: 20.0,
        ),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleDraftInitialized restores cart discount from existing draft',
      build: buildBloc,
      setUp: () {
        when(() => mockDraftRepo.listDrafts()).thenAnswer(
          (_) async => [
            DraftCart(
              id: 'draft-1',
              name: 'Saved Draft',
              items: [tCartItem],
              cartDiscountType: 'PERCENT',
              cartDiscountValue: 15.0,
              updatedAt: DateTime(2024),
            ),
          ],
        );
      },
      act: (b) => b.add(const SaleDraftInitialized()),
      expect: () => [
        SaleState(
          items: [tCartItem],
          activeDraftId: 'draft-1',
          activeDraftName: 'Saved Draft',
          cartDiscountType: 'PERCENT',
          cartDiscountValue: 15.0,
        ),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleBulkItemsRemoved removes multiple items from cart',
      build: buildBloc,
      seed: () => SaleState(items: [tCartItem, tCartItem2]),
      act: (b) => b.add(SaleBulkItemsRemoved([tProduct.id, tProduct2.id])),
      expect: () => [
        const SaleState(items: []),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleBulkItemDiscountsCleared clears discounts on specified items',
      build: buildBloc,
      seed: () => SaleState(
        items: [
          tCartItem.copyWith(discountType: 'PERCENT', discountValue: 10.0),
          tCartItem2.copyWith(discountType: 'AMOUNT', discountValue: 5.0),
        ],
      ),
      act: (b) => b.add(SaleBulkItemDiscountsCleared([tProduct.id, tProduct2.id])),
      expect: () => [
        SaleState(
          items: [
            tCartItem.clearDiscount(),
            tCartItem2.clearDiscount(),
          ],
        ),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleCartItemsReordered reorders items',
      build: buildBloc,
      seed: () => SaleState(items: [tCartItem, tCartItem2]),
      act: (b) => b.add(SaleCartItemsReordered([tProduct2.id, tProduct.id])),
      expect: () => [
        SaleState(items: [tCartItem2, tCartItem]),
      ],
    );
  });
}
