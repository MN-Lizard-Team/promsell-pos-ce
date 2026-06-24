import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/failures/settings_failure.dart';
import 'package:promsell_pos_ce/features/settings/domain/usecases/get_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/usecases/update_setting_group.dart';
import 'package:promsell_pos_ce/features/settings/domain/usecases/update_settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockSettingsRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const Settings());
  });

  setUp(() {
    mockRepo = MockSettingsRepository();
  });

  group('SettingsFailure', () {
    test('SettingsLoadFailure has correct props', () {
      const a = SettingsLoadFailure('err1');
      const b = SettingsLoadFailure('err1');
      const c = SettingsLoadFailure('err2');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.props, ['err1']);
      expect(a.message, 'err1');
    });

    test('SettingsSaveFailure has correct props', () {
      const a = SettingsSaveFailure('save-err');
      const b = SettingsSaveFailure('save-err');
      const c = SettingsSaveFailure('other');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.props, ['save-err']);
      expect(a.message, 'save-err');
    });

    test('InvalidSettingsFailure has correct props', () {
      const a = InvalidSettingsFailure('currency');
      const b = InvalidSettingsFailure('currency');
      const c = InvalidSettingsFailure('locale');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.props, ['currency']);
      expect(a.field, 'currency');
    });
  });

  group('GetSettings', () {
    late GetSettings useCase;

    setUp(() => useCase = GetSettings(mockRepo));

    test('returns settings on success', () async {
      const settings = Settings();
      when(() => mockRepo.load()).thenAnswer((_) async => settings);

      final (result, failure) = await useCase();

      expect(result, settings);
      expect(failure, isNull);
      verify(() => mockRepo.load()).called(1);
    });

    test('returns failure on error', () async {
      when(() => mockRepo.load()).thenThrow(Exception('db error'));

      final (result, failure) = await useCase();

      expect(result, isNull);
      expect(failure, isA<SettingsLoadFailure>());
      verify(() => mockRepo.load()).called(1);
    });
  });

  group('UpdateSettings', () {
    late UpdateSettings useCase;

    setUp(() => useCase = UpdateSettings(mockRepo));

    test('returns null on success', () async {
      const settings = Settings();
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final failure = await useCase(settings);

      expect(failure, isNull);
      verify(() => mockRepo.save(settings)).called(1);
    });

    test('returns SettingsSaveFailure on error', () async {
      const settings = Settings();
      when(() => mockRepo.save(any())).thenThrow(Exception('write error'));

      final failure = await useCase(settings);

      expect(failure, isA<SettingsSaveFailure>());
      verify(() => mockRepo.save(settings)).called(1);
    });
  });

  group('UpdateSettingGroup', () {
    late UpdateSettingGroup useCase;

    setUp(() => useCase = UpdateSettingGroup(mockRepo));

    test('applies mapper and saves', () async {
      const current = Settings();
      final updated = current.copyWith(currency: 'THB');
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final (result, failure) = await useCase(
        current,
        (s) => s.copyWith(currency: 'THB'),
      );

      expect(result, updated);
      expect(failure, isNull);
      verify(() => mockRepo.save(updated)).called(1);
    });

    test('returns current and failure on error', () async {
      const current = Settings();
      when(() => mockRepo.save(any())).thenThrow(Exception('fail'));

      final (result, failure) = await useCase(
        current,
        (s) => s.copyWith(currency: 'THB'),
      );

      expect(result, current);
      expect(failure, isA<SettingsSaveFailure>());
    });
  });
}
