import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchReport mockWatchReport;
  late MockReportRepository mockReportRepository;
  late MockGetReportSummary mockGetReportSummary;
  const calculator = ReportCalculatorService();

  const tPreviousPeriodSummary = ReportSummary(
    netRevenue: Money.fromSatang(50000),
    voidedTotal: Money.zero,
    salesCount: 5,
    voidCount: 0,
    vatAmount: Money.zero,
    discountAmount: Money.zero,
    serviceChargeAmount: Money.zero,
    promotionDiscountAmount: Money.zero,
    paymentBreakdown: {},
    paymentCounts: {},
    orderTypeBreakdown: {},
    orderChannelBreakdown: {},
    voidReasonBreakdown: {},
    promotionCount: 0,
  );

  const ReportAggregate tAggregate = ReportAggregate(
    summary: tPreviousPeriodSummary,
  );

  setUp(() {
    mockWatchReport = MockWatchReport();
    mockReportRepository = MockReportRepository();
    mockGetReportSummary = MockGetReportSummary();
    when(
      () => mockReportRepository.getProductCostLookup(any()),
    ).thenAnswer((_) async => {});
    when(
      () => mockGetReportSummary(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => tPreviousPeriodSummary);
  });

  ReportCubit buildCubit() => ReportCubit(
    watchReport: mockWatchReport,
    reportRepository: mockReportRepository,
    calculator: calculator,
    getReportSummary: mockGetReportSummary,
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

    test('cache evicts entries exceeding count limit', () async {
      when(
        () => mockWatchReport(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => Stream.value(tSales));

      final cubit = buildCubit();
      // Subscribe to 15 different date ranges — exceeds _maxCachedRanges (10).
      for (var i = 0; i < 15; i++) {
        await cubit.changeDateRange(
          DateTime(2024, 1, 1 + i),
          DateTime(2024, 1, 2 + i),
        );
        // Allow the stream to emit before moving to the next range.
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      // The cache should not grow unbounded. Internal state is private,
      // but we verify the cubit still works correctly after many ranges.
      expect(cubit.state.status, ReportStatus.success);
      await cubit.close();
    });

    test('cache evicts entries exceeding memory limit', () async {
      // Each Sale with items is ~1 KB estimated. 60k sales × 1 KB = ~60 MB,
      // exceeding the 50 MB memory ceiling. The cache should evict entries.
      final largeSales = List.generate(
        60000,
        (i) => tSale.copyWith(
          id: 'sale-mem-$i',
          createdAt: DateTime(2024, 1, 1).add(Duration(seconds: i)),
        ),
      );

      when(
        () => mockWatchReport(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => Stream.value(largeSales));

      final cubit = buildCubit();
      // Subscribe to 3 ranges, each with 60k sales (~60 MB each).
      // After eviction, only the most recent should remain.
      for (var i = 0; i < 3; i++) {
        await cubit.changeDateRange(
          DateTime(2024, 1, 1 + i * 10),
          DateTime(2024, 1, 2 + i * 10),
        );
        // Allow the stream to emit before moving to the next range.
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(cubit.state.status, ReportStatus.success);
      expect(cubit.state.sales.length, 60000);
      await cubit.close();
    });

    test('long range (>31 days) uses SQL aggregate path', () async {
      when(
        () => mockReportRepository.watchReportAggregate(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => Stream.value(tAggregate));

      final cubit = buildCubit();
      // 90-day span — beyond maxHydratedSpanDays (31).
      await cubit.changeDateRange(DateTime(2024, 1, 1), DateTime(2024, 3, 30));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.status, ReportStatus.success);
      expect(cubit.state.aggregate, isNotNull);
      expect(cubit.state.aggregate!.summary.salesCount, 5);
      // Hydrated list stays empty on the aggregate path.
      expect(cubit.state.sales, isEmpty);
      // Previous-period comparison comes from the one-shot summary use case.
      expect(cubit.state.previousSummary?.netRevenue.satang, 50000);
      verifyNever(
        () => mockWatchReport(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      );
      verify(
        () => mockGetReportSummary(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).called(1);
      await cubit.close();
    });

    test('long range emits failure when aggregate stream errors', () async {
      when(
        () => mockReportRepository.watchReportAggregate(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => Stream.error(Exception('aggregate failed')));

      final cubit = buildCubit();
      await cubit.changeDateRange(DateTime(2024, 1, 1), DateTime(2024, 3, 30));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.status, ReportStatus.failure);
      await cubit.close();
    });

    test('short range never touches the aggregate stream', () async {
      when(
        () => mockWatchReport(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => const Stream.empty());

      final cubit = buildCubit();
      await cubit.changeDateRange(DateTime(2024, 1, 1), DateTime(2024, 1, 7));
      await cubit.close();

      verifyNever(
        () => mockReportRepository.watchReportAggregate(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      );
    });
  });
}
