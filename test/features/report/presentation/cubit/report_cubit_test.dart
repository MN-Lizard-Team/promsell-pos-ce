import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchReport mockWatchReport;
  late MockReportRepository mockReportRepository;
  const calculator = ReportCalculatorService();

  setUp(() {
    mockWatchReport = MockWatchReport();
    mockReportRepository = MockReportRepository();
    when(
      () => mockReportRepository.getProductCostLookup(any()),
    ).thenAnswer((_) async => {});
  });

  ReportCubit buildCubit() => ReportCubit(
    watchReport: mockWatchReport,
    reportRepository: mockReportRepository,
    calculator: calculator,
  );

  group('ReportCubit', () {
    const tSales = <Sale>[];

    test('initial state defaults range to today', () {
      when(
        () => mockWatchReport(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => const Stream.empty());
      final cubit = buildCubit();
      final now = DateTime.now();
      expect(cubit.state.status, ReportStatus.initial);
      expect(cubit.state.sales, isEmpty);
      expect(cubit.state.from?.year, now.year);
      expect(cubit.state.from?.month, now.month);
      expect(cubit.state.from?.day, now.day);
      expect(cubit.state.to?.day, now.day);
      cubit.close();
    });

    blocTest<ReportCubit, ReportState>(
      'load emits [loading, success] on data',
      build: buildCubit,
      setUp: () {
        when(
          () => mockWatchReport(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) => Stream.value(tSales));
      },
      act: (c) => c.load(),
      expect: () => [
        isA<ReportState>().having(
          (s) => s.status,
          'status',
          ReportStatus.loading,
        ),
        isA<ReportState>().having(
          (s) => s.status,
          'status',
          ReportStatus.success,
        ),
      ],
    );

    blocTest<ReportCubit, ReportState>(
      'load emits [loading, failure] on error',
      build: buildCubit,
      setUp: () {
        when(
          () => mockWatchReport(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) => Stream.error(Exception('db error')));
      },
      act: (c) => c.load(),
      expect: () => [
        isA<ReportState>().having(
          (s) => s.status,
          'status',
          ReportStatus.loading,
        ),
        isA<ReportState>().having(
          (s) => s.status,
          'status',
          ReportStatus.failure,
        ),
      ],
    );

    blocTest<ReportCubit, ReportState>(
      'changeDateRange clears sales then succeeds (no stale totals)',
      build: buildCubit,
      seed: () => ReportState(
        status: ReportStatus.success,
        sales: [tSale],
        from: DateTime(2024, 1, 1),
        to: DateTime(2024, 1, 2),
      ),
      setUp: () {
        when(
          () => mockWatchReport(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) => Stream.value(tSales));
      },
      act: (c) =>
          c.changeDateRange(DateTime(2024, 2, 1), DateTime(2024, 2, 28)),
      expect: () => [
        isA<ReportState>()
            .having((s) => s.status, 'status', ReportStatus.loading)
            .having((s) => s.from, 'from', DateTime(2024, 2, 1))
            .having((s) => s.sales, 'sales', isEmpty),
        isA<ReportState>().having(
          (s) => s.status,
          'status',
          ReportStatus.success,
        ),
      ],
    );

    blocTest<ReportCubit, ReportState>(
      'Wave R1: revisiting range re-subscribes (watch called again)',
      build: buildCubit,
      setUp: () {
        when(
          () => mockWatchReport(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) => Stream.value(tSales));
      },
      act: (c) async {
        final a = DateTime(2024, 3, 1);
        final b = DateTime(2024, 3, 7);
        await c.changeDateRange(a, b);
        await c.changeDateRange(DateTime(2024, 3, 8), DateTime(2024, 3, 9));
        await c.changeDateRange(a, b); // cache hit path — still re-watch
      },
      verify: (_) {
        verify(
          () => mockWatchReport(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).called(6);
      },
    );

    test('Wave R1: load forceRefresh still calls watch', () async {
      when(
        () => mockWatchReport(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => Stream.value(tSales));
      final cubit = buildCubit();
      await cubit.changeDateRange(DateTime(2024, 4, 1), DateTime(2024, 4, 2));
      await cubit.load(); // forceRefresh: true
      verify(
        () => mockWatchReport(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).called(greaterThanOrEqualTo(2));
      await cubit.close();
    });

    test(
      'Wave R1: late stream from old range does not overwrite new range',
      () async {
        final older = StreamController<List<Sale>>.broadcast();
        final newer = StreamController<List<Sale>>.broadcast();
        var call = 0;
        when(
          () => mockWatchReport(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) {
          call++;
          return call == 1 ? older.stream : newer.stream;
        });

        final cubit = buildCubit();
        await cubit.changeDateRange(DateTime(2024, 5, 1), DateTime(2024, 5, 2));
        await cubit.changeDateRange(DateTime(2024, 6, 1), DateTime(2024, 6, 2));

        // Late emission from first subscription must be ignored.
        older.add([tSale]);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(cubit.state.from, DateTime(2024, 6, 1));
        expect(cubit.state.sales, isEmpty);

        newer.add(const <Sale>[]);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(cubit.state.status, ReportStatus.success);

        await older.close();
        await newer.close();
        await cubit.close();
      },
    );
  });
}
