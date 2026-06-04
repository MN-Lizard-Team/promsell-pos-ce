import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
      'HistoryDateRangeChanged restarts subscription with dates',
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
        final to = DateTime(2025, 1, 31);
        b.add(HistoryDateRangeChanged(from: from, to: to));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<HistoryState>().having(
          (s) => s.status,
          'status',
          HistoryStatus.loading,
        ),
        isA<HistoryState>().having(
          (s) => s.status,
          'status',
          HistoryStatus.success,
        ),
      ],
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
        totalAmount: 100,
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
