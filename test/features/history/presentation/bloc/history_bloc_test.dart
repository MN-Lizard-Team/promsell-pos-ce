import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_event.dart';
import 'package:promsell_pos_ce/features/history/presentation/bloc/history_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchSaleHistory mockWatchSaleHistory;
  late MockVoidSale mockVoidSale;

  setUp(() {
    mockWatchSaleHistory = MockWatchSaleHistory();
    mockVoidSale = MockVoidSale();
  });

  HistoryBloc buildBloc() => HistoryBloc(
    watchSaleHistory: mockWatchSaleHistory,
    voidSale: mockVoidSale,
  );

  group('HistoryBloc', () {
    test('initial state is HistoryState()', () {
      when(
        () => mockWatchSaleHistory(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => const Stream.empty());
      expect(buildBloc().state, const HistoryState());
    });

    blocTest<HistoryBloc, HistoryState>(
      'HistorySubscribed emits loading then success',
      setUp: () {
        when(
          () => mockWatchSaleHistory(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) => Stream.value([tSale]));
      },
      build: buildBloc,
      act: (b) => b.add(const HistorySubscribed()),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const HistoryState(status: HistoryStatus.loading),
        HistoryState(status: HistoryStatus.success, sales: [tSale]),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'HistoryDateRangeChanged sets from/to and watches with those bounds',
      setUp: () {
        when(
          () => mockWatchSaleHistory(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) => Stream.value([]));
      },
      build: buildBloc,
      act: (b) {
        final from = DateTime(2025, 1, 1);
        final to = DateTime(2025, 1, 31, 23, 59, 59, 999);
        b.add(HistoryDateRangeChanged(from: from, to: to));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<HistoryState>()
            .having((s) => s.status, 'status', HistoryStatus.loading)
            .having((s) => s.from, 'from', DateTime(2025, 1, 1))
            .having((s) => s.to, 'to', DateTime(2025, 1, 31, 23, 59, 59, 999)),
        isA<HistoryState>().having(
          (s) => s.status,
          'status',
          HistoryStatus.success,
        ),
      ],
      verify: (_) {
        verify(
          () => mockWatchSaleHistory(
            from: DateTime(2025, 1, 1),
            to: DateTime(2025, 1, 31, 23, 59, 59, 999),
          ),
        ).called(1);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'stream error emits failure',
      setUp: () {
        when(
          () => mockWatchSaleHistory(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) => Stream<List<Sale>>.error('db error'));
      },
      build: buildBloc,
      act: (b) => b.add(const HistorySubscribed()),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const HistoryState(status: HistoryStatus.loading),
        isA<HistoryState>()
            .having((s) => s.status, 'status', HistoryStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'HistorySearchChanged updates searchQuery',
      build: buildBloc,
      act: (b) => b.add(const HistorySearchChanged('cash')),
      expect: () => [const HistoryState(searchQuery: 'cash')],
    );

    blocTest<HistoryBloc, HistoryState>(
      'SaleVoidRequested sets voidingSaleId then clears on success',
      setUp: () {
        when(
          () => mockVoidSale(any(), reason: any(named: 'reason')),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      seed: () => HistoryState(status: HistoryStatus.success, sales: [tSale]),
      act: (b) =>
          b.add(SaleVoidRequested(saleId: tSale.id, reason: 'Customer return')),
      expect: () => [
        isA<HistoryState>().having((s) => s.voidingSaleId, 'voiding', tSale.id),
        isA<HistoryState>()
            .having((s) => s.voidingSaleId, 'voiding', isNull)
            .having((s) => s.status, 'status', HistoryStatus.success),
      ],
      verify: (_) {
        verify(
          () => mockVoidSale(tSale.id, reason: 'Customer return'),
        ).called(1);
      },
    );

    blocTest<HistoryBloc, HistoryState>(
      'SaleVoidRequested maps already-voided to stable error key',
      setUp: () {
        when(
          () => mockVoidSale(any(), reason: any(named: 'reason')),
        ).thenThrow(const BusinessRuleError('SaleAlreadyVoided'));
      },
      build: buildBloc,
      seed: () => HistoryState(status: HistoryStatus.success, sales: [tSale]),
      act: (b) => b.add(SaleVoidRequested(saleId: tSale.id, reason: 'dup')),
      expect: () => [
        isA<HistoryState>().having((s) => s.voidingSaleId, 'voiding', tSale.id),
        isA<HistoryState>()
            .having((s) => s.voidingSaleId, 'voiding', isNull)
            .having(
              (s) => s.errorMessage,
              'err',
              HistoryErrorKeys.saleAlreadyVoided,
            )
            .having((s) => s.sales, 'sales', isNotEmpty),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'SaleVoidRequested maps NotFoundError to saleNotFound key',
      setUp: () {
        when(
          () => mockVoidSale(any(), reason: any(named: 'reason')),
        ).thenThrow(const NotFoundError('Sale'));
      },
      build: buildBloc,
      seed: () => HistoryState(status: HistoryStatus.success, sales: [tSale]),
      act: (b) => b.add(SaleVoidRequested(saleId: tSale.id, reason: 'gone')),
      expect: () => [
        isA<HistoryState>().having((s) => s.voidingSaleId, 'voiding', tSale.id),
        isA<HistoryState>()
            .having((s) => s.voidingSaleId, 'voiding', isNull)
            .having((s) => s.errorMessage, 'err', HistoryErrorKeys.saleNotFound)
            .having((s) => s.sales, 'sales', isNotEmpty),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'SaleVoidRequested maps generic error to generic key',
      setUp: () {
        when(
          () => mockVoidSale(any(), reason: any(named: 'reason')),
        ).thenThrow(Exception('boom'));
      },
      build: buildBloc,
      seed: () => HistoryState(status: HistoryStatus.success, sales: [tSale]),
      act: (b) => b.add(SaleVoidRequested(saleId: tSale.id, reason: 'x')),
      expect: () => [
        isA<HistoryState>().having((s) => s.voidingSaleId, 'voiding', tSale.id),
        isA<HistoryState>()
            .having((s) => s.voidingSaleId, 'voiding', isNull)
            .having((s) => s.errorMessage, 'err', HistoryErrorKeys.generic)
            .having((s) => s.sales, 'sales', isNotEmpty),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'SaleVoidRequested ignored while another void is in flight',
      setUp: () {
        when(
          () => mockVoidSale(any(), reason: any(named: 'reason')),
        ).thenAnswer((_) async {});
      },
      build: buildBloc,
      seed: () => HistoryState(
        status: HistoryStatus.success,
        sales: [tSale],
        voidingSaleId: 'other-sale',
      ),
      act: (b) =>
          b.add(SaleVoidRequested(saleId: tSale.id, reason: 'should-not-run')),
      expect: () => <HistoryState>[],
      verify: (_) {
        verifyNever(() => mockVoidSale(any(), reason: any(named: 'reason')));
      },
    );
  });

  group('mapHistoryVoidErrorKey', () {
    test('maps already voided and not found', () {
      expect(
        mapHistoryVoidErrorKey(const BusinessRuleError('SaleAlreadyVoided')),
        HistoryErrorKeys.saleAlreadyVoided,
      );
      expect(
        mapHistoryVoidErrorKey(const NotFoundError('Sale')),
        HistoryErrorKeys.saleNotFound,
      );
      expect(mapHistoryVoidErrorKey(Exception('x')), HistoryErrorKeys.generic);
    });
  });

  group('HistoryState.filteredSales', () {
    test('returns all sales when searchQuery is empty', () {
      final state = HistoryState(sales: [tSale]);
      expect(state.filteredSales, [tSale]);
    });

    test('filters by payment method', () {
      final state = HistoryState(sales: [tSale], searchQuery: 'cash');
      expect(state.filteredSales, [tSale]);
    });

    test('filters by receipt number', () {
      final sale = Sale(
        id: 's1',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'cash',
        receiptNumber: 'RCP-260527',
        createdAt: tNow,
      );
      final state = HistoryState(sales: [sale], searchQuery: '260527');
      expect(state.filteredSales, [sale]);
    });

    test('returns empty when no match', () {
      final state = HistoryState(sales: [tSale], searchQuery: 'promptpay');
      expect(state.filteredSales, isEmpty);
    });
  });
}
