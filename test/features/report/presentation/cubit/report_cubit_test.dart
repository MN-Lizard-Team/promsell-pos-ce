import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchReport mockWatchReport;

  setUp(() {
    mockWatchReport = MockWatchReport();
  });

  ReportCubit buildCubit() => ReportCubit(watchReport: mockWatchReport);

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
  });
}
