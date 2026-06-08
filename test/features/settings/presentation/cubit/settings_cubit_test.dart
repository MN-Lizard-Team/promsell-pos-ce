import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/services/settings_persistence_service.dart';

import '../../../../helpers/mocks.dart';

class MockSettingsPersistenceService extends Mock
    implements SettingsPersistenceService {}

void main() {
  late MockSettingsRepository mockRepo;
  late MockSettingsPersistenceService mockPersistence;

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockPersistence = MockSettingsPersistenceService();
  });

  setUpAll(() {
    registerFallbackValue(const Settings());
    registerFallbackValue(AppSettings());
  });

  SettingsCubit buildCubit() => SettingsCubit(mockRepo, mockPersistence);

  group('SettingsCubit', () {
    test('initial state is SettingsState()', () {
      expect(buildCubit().state, SettingsState());
    });

    blocTest<SettingsCubit, SettingsState>(
      'load emits loading then loaded',
      setUp: () {
        when(() => mockRepo.load()).thenAnswer((_) async => const Settings());
      },
      build: buildCubit,
      act: (c) => c.load(),
      expect: () => [
        SettingsState(status: SettingsStatus.loading),
        SettingsState(status: SettingsStatus.loaded, settings: AppSettings()),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'load emits failure on error',
      setUp: () {
        when(() => mockRepo.load()).thenThrow(Exception('fail'));
      },
      build: buildCubit,
      act: (c) => c.load(),
      expect: () => [
        SettingsState(status: SettingsStatus.loading, errorMessage: null),
        SettingsState(
          status: SettingsStatus.failure,
          errorMessage: 'Exception: fail',
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'update emits saving then saved',
      setUp: () {
        when(
          () => mockPersistence.saveImmediately(any()),
        ).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (c) => c.update(AppSettings(shopName: 'New')),
      expect: () => [
        SettingsState(
          status: SettingsStatus.saving,
          settings: AppSettings(shopName: 'New'),
          errorMessage: null,
        ),
        SettingsState(
          status: SettingsStatus.saved,
          settings: AppSettings(shopName: 'New'),
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'update emits failure and restores previous settings on error',
      setUp: () {
        when(
          () => mockPersistence.saveImmediately(any()),
        ).thenThrow(Exception('fail'));
      },
      build: buildCubit,
      seed: () => SettingsState(
        status: SettingsStatus.loaded,
        settings: AppSettings(shopName: 'Old'),
      ),
      act: (c) => c.update(AppSettings(shopName: 'New')),
      expect: () => [
        SettingsState(
          status: SettingsStatus.saving,
          settings: AppSettings(shopName: 'New'),
          errorMessage: null,
        ),
        SettingsState(
          status: SettingsStatus.failure,
          settings: AppSettings(shopName: 'Old'),
          errorMessage: 'Exception: fail',
        ),
      ],
    );
  });
}
