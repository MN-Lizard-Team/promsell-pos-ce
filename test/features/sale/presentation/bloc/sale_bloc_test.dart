import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockCreateSale mockCreateSale;

  setUp(() {
    mockCreateSale = MockCreateSale();
  });

  setUpAll(() {
    registerFallbackValue(<CartItem>[]);
  });

  SaleBloc buildBloc() => SaleBloc(createSale: mockCreateSale);

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
        SaleState(status: SaleStatus.success, lastSale: tSale),
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
  });
}
