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

  setUp(() {
    mockWatchSaleHistory = MockWatchSaleHistory();
  });

  HistoryBloc buildBloc() =>
      HistoryBloc(watchSaleHistory: mockWatchSaleHistory);

  group('HistoryBloc', () {
    test('initial state is HistoryState()', () {
      when(() => mockWatchSaleHistory(
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) => const Stream.empty());
      expect(buildBloc().state, const HistoryState());
    });

    blocTest<HistoryBloc, HistoryState>(
      'HistorySubscribed emits loading then success',
      setUp: () {
        when(() => mockWatchSaleHistory(
              from: any(named: 'from'),
              to: any(named: 'to'),
            )).thenAnswer((_) => Stream.value([tSale]));
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
        when(() => mockWatchSaleHistory(
              from: any(named: 'from'),
              to: any(named: 'to'),
            )).thenAnswer((_) => Stream.value([]));
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
            (s) => s.status, 'status', HistoryStatus.loading),
        isA<HistoryState>().having(
            (s) => s.status, 'status', HistoryStatus.success),
      ],
    );

    blocTest<HistoryBloc, HistoryState>(
      'stream error emits failure',
      setUp: () {
        when(() => mockWatchSaleHistory(
              from: any(named: 'from'),
              to: any(named: 'to'),
            )).thenAnswer((_) => Stream<List<Sale>>.error('db error'));
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
  });
}
