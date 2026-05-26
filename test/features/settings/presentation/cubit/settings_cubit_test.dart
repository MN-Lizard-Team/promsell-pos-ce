import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockSettingsRepository mockRepo;

  setUp(() {
    mockRepo = MockSettingsRepository();
  });

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  SettingsCubit buildCubit() => SettingsCubit(mockRepo);

  group('SettingsCubit', () {
    test('initial state is SettingsState()', () {
      expect(buildCubit().state, const SettingsState());
    });

    blocTest<SettingsCubit, SettingsState>(
      'load emits loading then loaded',
      setUp: () {
        when(
          () => mockRepo.load(),
        ).thenAnswer((_) async => const AppSettings(shopName: 'My Shop'));
      },
      build: buildCubit,
      act: (c) => c.load(),
      expect: () => [
        const SettingsState(status: SettingsStatus.loading),
        const SettingsState(
          status: SettingsStatus.loaded,
          settings: AppSettings(shopName: 'My Shop'),
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'load falls back to loaded defaults on error',
      setUp: () {
        when(() => mockRepo.load()).thenThrow(Exception('fail'));
      },
      build: buildCubit,
      act: (c) => c.load(),
      expect: () => [
        const SettingsState(status: SettingsStatus.loading),
        const SettingsState(status: SettingsStatus.loaded),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'update emits saving then saved',
      setUp: () {
        when(() => mockRepo.save(any())).thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (c) => c.update(const AppSettings(shopName: 'New')),
      expect: () => [
        const SettingsState(
          status: SettingsStatus.saving,
          settings: AppSettings(shopName: 'New'),
        ),
        const SettingsState(
          status: SettingsStatus.saved,
          settings: AppSettings(shopName: 'New'),
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'update emits failure and restores previous settings on error',
      setUp: () {
        when(() => mockRepo.save(any())).thenThrow(Exception('fail'));
      },
      build: buildCubit,
      seed: () => const SettingsState(
        status: SettingsStatus.loaded,
        settings: AppSettings(shopName: 'Old'),
      ),
      act: (c) => c.update(const AppSettings(shopName: 'New')),
      expect: () => [
        const SettingsState(
          status: SettingsStatus.saving,
          settings: AppSettings(shopName: 'New'),
        ),
        const SettingsState(
          status: SettingsStatus.failure,
          settings: AppSettings(shopName: 'Old'),
        ),
      ],
    );
  });
}
