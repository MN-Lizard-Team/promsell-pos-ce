import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/failures/settings_failure.dart';
import 'package:promsell_pos_ce/features/settings/domain/usecases/get_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/usecases/update_setting_group.dart';
import 'package:promsell_pos_ce/features/settings/domain/usecases/update_settings.dart';

import '../../../../helpers/fake_app_lock.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockSettingsRepository mockRepo;
  late AppLockService appLock;

  setUpAll(() {
    registerFallbackValue(const Settings());
  });

  setUp(() {
    mockRepo = MockSettingsRepository();
    appLock = fakeAppLock();
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

    setUp(() {
      useCase = UpdateSettings(mockRepo, appLock);
      when(() => mockRepo.load()).thenAnswer((_) async => const Settings());
    });

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

    test('blocks PromptPay id change when session locked', () async {
      await appLock.setPin('147258');
      appLock.lockSession();
      when(() => mockRepo.load()).thenAnswer((_) async => const Settings());

      await expectLater(
        () => useCase(const Settings().copyWith(promptpayId: '0812345678')),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            AppLockService.ruleAppLockRequired,
          ),
        ),
      );
      verifyNever(() => mockRepo.save(any()));
    });

    // V092-B.3 regression: oversell toggle is a sensitive money policy.
    test('blocks allowOversell change when session locked', () async {
      await appLock.setPin('147258');
      appLock.lockSession();
      when(() => mockRepo.load()).thenAnswer((_) async => const Settings());

      await expectLater(
        () => useCase(const Settings().copyWith(allowOversell: true)),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            AppLockService.ruleAppLockRequired,
          ),
        ),
      );
      verifyNever(() => mockRepo.save(any()));
    });

    // V092-B.3 regression: discount enable is a sensitive money policy.
    test('blocks enableCartDiscount change when session locked', () async {
      await appLock.setPin('147258');
      appLock.lockSession();
      when(() => mockRepo.load()).thenAnswer((_) async => const Settings());

      await expectLater(
        () => useCase(const Settings().copyWith(enableCartDiscount: false)),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            AppLockService.ruleAppLockRequired,
          ),
        ),
      );
      verifyNever(() => mockRepo.save(any()));
    });

    // V092-B.3 regression: day-lock toggle is a sensitive money policy.
    test('blocks dailyCloseLock change when session locked', () async {
      await appLock.setPin('147258');
      appLock.lockSession();
      when(() => mockRepo.load()).thenAnswer((_) async => const Settings());

      await expectLater(
        () => useCase(const Settings().copyWith(dailyCloseLock: true)),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            AppLockService.ruleAppLockRequired,
          ),
        ),
      );
      verifyNever(() => mockRepo.save(any()));
    });
  });

  group('UpdateSettingGroup', () {
    late UpdateSettingGroup useCase;

    setUp(() => useCase = UpdateSettingGroup(mockRepo, appLock));

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

    test('blocks billerId change when session locked', () async {
      await appLock.setPin('147258');
      appLock.lockSession();
      const current = Settings();

      await expectLater(
        () => useCase(current, (s) => s.copyWith(billerId: '1234567890123')),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            AppLockService.ruleAppLockRequired,
          ),
        ),
      );
      verifyNever(() => mockRepo.save(any()));
    });

    test('allows PromptPay change when session unlocked', () async {
      await appLock.setPin('147258');
      // setPin unlocks session
      const current = Settings();
      when(() => mockRepo.save(any())).thenAnswer((_) async {});

      final (result, failure) = await useCase(
        current,
        (s) => s.copyWith(promptpayId: '0812345678'),
      );

      expect(failure, isNull);
      expect(result!.promptpayId, '0812345678');
      verify(() => mockRepo.save(any())).called(1);
    });
  });
}
