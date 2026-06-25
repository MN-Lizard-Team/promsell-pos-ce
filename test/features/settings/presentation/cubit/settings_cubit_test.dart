import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/services/settings_persistence_service.dart';

import '../../../../helpers/mocks.dart';

class MockSettingsPersistenceService extends Mock
    implements SettingsPersistenceService {}

void main() {
  late MockSettingsRepository mockRepo;
  late MockSettingsPersistenceService mockPersistence;
  late Ean13Generator generator;

  setUp(() {
    mockRepo = MockSettingsRepository();
    mockPersistence = MockSettingsPersistenceService();
    generator = Ean13Generator();
    when(() => mockPersistence.dispose()).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(const Settings());
  });

  SettingsCubit buildCubit() =>
      SettingsCubit(mockRepo, mockPersistence, generator);

  group('SettingsCubit', () {
    test('initial state is SettingsState()', () {
      expect(buildCubit().state, const SettingsState());
    });

    blocTest<SettingsCubit, SettingsState>(
      'load emits loading then loaded',
      setUp: () {
        when(() => mockRepo.load()).thenAnswer((_) async => const Settings());
      },
      build: buildCubit,
      act: (c) => c.load(),
      expect: () => [
        const SettingsState(status: SettingsStatus.loading),
        const SettingsState(
          status: SettingsStatus.loaded,
          settings: Settings(),
        ),
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
        const SettingsState(status: SettingsStatus.loading, errorMessage: null),
        const SettingsState(
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
      act: (c) => c.update(const Settings().copyWith(shopName: 'New')),
      expect: () => [
        SettingsState(
          status: SettingsStatus.saving,
          settings: const Settings().copyWith(shopName: 'New'),
          errorMessage: null,
        ),
        SettingsState(
          status: SettingsStatus.saved,
          settings: const Settings().copyWith(shopName: 'New'),
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
        settings: const Settings().copyWith(shopName: 'Old'),
      ),
      act: (c) => c.update(const Settings().copyWith(shopName: 'New')),
      expect: () => [
        SettingsState(
          status: SettingsStatus.saving,
          settings: const Settings().copyWith(shopName: 'New'),
          errorMessage: null,
        ),
        SettingsState(
          status: SettingsStatus.failure,
          settings: const Settings().copyWith(shopName: 'Old'),
          errorMessage: 'Exception: fail',
        ),
      ],
    );
  });
}
