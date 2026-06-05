import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/close_day.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_by_date.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/reopen_day.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/cubit/daily_close_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

class MockCloseDay extends Mock implements CloseDay {}

class MockReopenDay extends Mock implements ReopenDay {}

class MockGetDailyCloseByDate extends Mock implements GetDailyCloseByDate {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class FakeAppSettings extends Fake implements AppSettings {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAppSettings());
  });
  group('DailyCloseCubit', () {
    late MockCloseDay mockCloseDay;
    late MockReopenDay mockReopenDay;
    late MockGetDailyCloseByDate mockGetByDate;
    late MockSettingsRepository mockSettingsRepo;
    late DailyCloseCubit cubit;

    setUp(() {
      mockCloseDay = MockCloseDay();
      mockReopenDay = MockReopenDay();
      mockGetByDate = MockGetDailyCloseByDate();
      mockSettingsRepo = MockSettingsRepository();
      when(() => mockGetByDate(any())).thenAnswer((_) async => null);
      when(
        () => mockSettingsRepo.load(),
      ).thenAnswer((_) async => const AppSettings());
      when(() => mockSettingsRepo.save(any())).thenAnswer((_) async {});
      cubit = DailyCloseCubit(
        mockCloseDay,
        mockReopenDay,
        mockGetByDate,
        mockSettingsRepo,
      );
    });

    test('initial state is correct', () {
      expect(cubit.state.status, DailyCloseStatus.initial);
      expect(cubit.state.countedCash, 0);
      expect(cubit.state.openingCash, 0);
    });

    blocTest<DailyCloseCubit, DailyCloseState>(
      'loadDate emits ready when no existing close',
      build: () => cubit,
      act: (c) => c.loadDate('2026-06-05'),
      expect: () => [
        isA<DailyCloseState>().having(
          (s) => s.status,
          'status',
          DailyCloseStatus.loading,
        ),
        isA<DailyCloseState>().having(
          (s) => s.status,
          'status',
          DailyCloseStatus.ready,
        ),
      ],
    );

    blocTest<DailyCloseCubit, DailyCloseState>(
      'loadDate emits closed when day is already closed',
      build: () {
        when(() => mockGetByDate('2026-06-05')).thenAnswer(
          (_) async => const DailyClose(
            id: '1',
            closeDate: '2026-06-05',
            closedAt: null,
          ),
        );
        return cubit;
      },
      act: (c) => c.loadDate('2026-06-05'),
      expect: () => [
        isA<DailyCloseState>().having(
          (s) => s.status,
          'status',
          DailyCloseStatus.loading,
        ),
        isA<DailyCloseState>().having(
          (s) => s.status,
          'status',
          DailyCloseStatus.ready,
        ),
      ],
    );

    blocTest<DailyCloseCubit, DailyCloseState>(
      'closeDay emits closing then closed on success',
      build: () {
        when(
          () => mockCloseDay(
            date: any(named: 'date'),
            openingCash: any(named: 'openingCash'),
            countedCash: any(named: 'countedCash'),
            note: any(named: 'note'),
            deviceId: any(named: 'deviceId'),
          ),
        ).thenAnswer(
          (_) async => const DailyClose(id: '1', closeDate: '2026-06-05'),
        );
        return cubit;
      },
      seed: () => const DailyCloseState(
        status: DailyCloseStatus.ready,
        date: '2026-06-05',
        countedCash: 500,
        openingCash: 100,
      ),
      act: (c) => c.closeDay(deviceId: 'dev1'),
      expect: () => [
        isA<DailyCloseState>().having(
          (s) => s.status,
          'status',
          DailyCloseStatus.closing,
        ),
        isA<DailyCloseState>().having(
          (s) => s.status,
          'status',
          DailyCloseStatus.closed,
        ),
      ],
    );

    blocTest<DailyCloseCubit, DailyCloseState>(
      'setCountedCash updates state',
      build: () => cubit,
      act: (c) => c.setCountedCash(500),
      expect: () => [
        isA<DailyCloseState>().having((s) => s.countedCash, 'countedCash', 500),
      ],
    );
  });
}
