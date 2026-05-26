import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_cubit.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockWatchReport mockWatchReport;

  setUp(() {
    mockWatchReport = MockWatchReport();
  });

  ReportCubit buildCubit() =>
      ReportCubit(watchReport: mockWatchReport);

  group('ReportCubit', () {
    const tSales = <Sale>[];

    test('initial state has correct defaults', () {
      when(() => mockWatchReport(from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) => const Stream.empty());
      final cubit = buildCubit();
      expect(cubit.state.status, ReportStatus.initial);
      expect(cubit.state.sales, isEmpty);
      cubit.close();
    });

    blocTest<ReportCubit, ReportState>(
      'load emits [loading, success] on data',
      build: buildCubit,
      setUp: () {
        when(() => mockWatchReport(from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) => Stream.value(tSales));
      },
      act: (c) => c.load(),
      expect: () => [
        isA<ReportState>().having((s) => s.status, 'status', ReportStatus.loading),
        isA<ReportState>().having((s) => s.status, 'status', ReportStatus.success),
      ],
    );

    blocTest<ReportCubit, ReportState>(
      'load emits [loading, failure] on error',
      build: buildCubit,
      setUp: () {
        when(() => mockWatchReport(from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) => Stream.error(Exception('db error')));
      },
      act: (c) => c.load(),
      expect: () => [
        isA<ReportState>().having((s) => s.status, 'status', ReportStatus.loading),
        isA<ReportState>().having((s) => s.status, 'status', ReportStatus.failure),
      ],
    );

    blocTest<ReportCubit, ReportState>(
      'changeDateRange updates from/to and re-subscribes',
      build: buildCubit,
      setUp: () {
        when(() => mockWatchReport(from: any(named: 'from'), to: any(named: 'to')))
            .thenAnswer((_) => Stream.value(tSales));
      },
      act: (c) => c.changeDateRange(
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 31),
      ),
      expect: () => [
        isA<ReportState>()
            .having((s) => s.status, 'status', ReportStatus.loading)
            .having((s) => s.from, 'from', DateTime(2024, 1, 1)),
        isA<ReportState>().having((s) => s.status, 'status', ReportStatus.success),
      ],
    );
  });
}
