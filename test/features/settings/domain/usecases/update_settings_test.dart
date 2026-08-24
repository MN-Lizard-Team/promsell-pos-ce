import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/failures/settings_failure.dart';
import 'package:promsell_pos_ce/features/settings/domain/usecases/update_settings.dart';
import '../../../../helpers/mocks.dart';

void main() {
  group('UpdateSettings', () {
    late UpdateSettings useCase;
    late MockSettingsRepository mockRepo;
    late MockAppLockService mockAppLock;

    setUp(() {
      mockRepo = MockSettingsRepository();
      mockAppLock = MockAppLockService();
      useCase = UpdateSettings(mockRepo, mockAppLock);

      when(() => mockRepo.load()).thenAnswer((_) async => const Settings());
      when(() => mockRepo.save(any())).thenAnswer((_) async {});
    });

    setUpAll(() {
      registerFallbackValue(const Settings());
    });

    test(
      'saves settings and returns null when no sensitive fields changed',
      () async {
        final newSettings = const Settings().copyWith(
          shopName: 'New Shop Name',
        );

        final result = await useCase(newSettings);

        expect(result, isNull);
        verify(() => mockRepo.save(newSettings)).called(1);
        verifyNever(() => mockAppLock.requireSensitiveSession());
      },
    );

    test('requires sensitive session when PromptPay ID changes', () async {
      when(
        () => mockAppLock.requireSensitiveSession(),
      ).thenAnswer((_) async {});

      final current = const Settings().copyWith(promptpayId: 'old-id');
      final updated = const Settings().copyWith(promptpayId: 'new-id');

      when(() => mockRepo.load()).thenAnswer((_) async => current);

      final result = await useCase(updated);

      expect(result, isNull);
      verify(() => mockAppLock.requireSensitiveSession()).called(1);
      verify(() => mockRepo.save(updated)).called(1);
    });

    test('requires sensitive session when biller ID changes', () async {
      when(
        () => mockAppLock.requireSensitiveSession(),
      ).thenAnswer((_) async {});

      final current = const Settings().copyWith(billerId: 'old-biller');
      final updated = const Settings().copyWith(billerId: 'new-biller');

      when(() => mockRepo.load()).thenAnswer((_) async => current);

      await useCase(updated);

      verify(() => mockAppLock.requireSensitiveSession()).called(1);
    });

    test('requires sensitive session when discount policy changes', () async {
      when(
        () => mockAppLock.requireSensitiveSession(),
      ).thenAnswer((_) async {});

      final current = const Settings().copyWith(enableCartDiscount: false);
      final updated = const Settings().copyWith(enableCartDiscount: true);

      when(() => mockRepo.load()).thenAnswer((_) async => current);

      await useCase(updated);

      verify(() => mockAppLock.requireSensitiveSession()).called(1);
    });

    test('requires sensitive session when oversell setting changes', () async {
      when(
        () => mockAppLock.requireSensitiveSession(),
      ).thenAnswer((_) async {});

      final current = const Settings().copyWith(allowOversell: false);
      final updated = const Settings().copyWith(allowOversell: true);

      when(() => mockRepo.load()).thenAnswer((_) async => current);

      await useCase(updated);

      verify(() => mockAppLock.requireSensitiveSession()).called(1);
    });

    test('requires sensitive session when dailyCloseLock changes', () async {
      when(
        () => mockAppLock.requireSensitiveSession(),
      ).thenAnswer((_) async {});

      final current = const Settings().copyWith(dailyCloseLock: false);
      final updated = const Settings().copyWith(dailyCloseLock: true);

      when(() => mockRepo.load()).thenAnswer((_) async => current);

      await useCase(updated);

      verify(() => mockAppLock.requireSensitiveSession()).called(1);
    });

    test('requires sensitive session when backup encryption changes', () async {
      when(
        () => mockAppLock.requireSensitiveSession(),
      ).thenAnswer((_) async {});

      final current = const Settings().copyWith(backupEncryptionEnabled: false);
      final updated = const Settings().copyWith(backupEncryptionEnabled: true);

      when(() => mockRepo.load()).thenAnswer((_) async => current);

      await useCase(updated);

      verify(() => mockAppLock.requireSensitiveSession()).called(1);
    });

    test(
      'throws BusinessRuleError when app lock is enabled and session locked',
      () async {
        when(
          () => mockAppLock.requireSensitiveSession(),
        ).thenThrow(const BusinessRuleError('AppLockRequired'));

        final current = const Settings().copyWith(promptpayId: 'old');
        final updated = const Settings().copyWith(promptpayId: 'new');

        when(() => mockRepo.load()).thenAnswer((_) async => current);

        expect(() => useCase(updated), throwsA(isA<BusinessRuleError>()));

        verifyNever(() => mockRepo.save(any()));
      },
    );

    test('returns SettingsSaveFailure when repository throws', () async {
      when(() => mockRepo.save(any())).thenThrow(Exception('DB write failed'));

      final result = await useCase(const Settings());

      expect(result, isA<SettingsSaveFailure>());
      expect(
        (result as SettingsSaveFailure).message,
        contains('DB write failed'),
      );
    });

    test('returns SettingsSaveFailure when load throws', () async {
      when(() => mockRepo.load()).thenThrow(Exception('DB read failed'));

      final result = await useCase(const Settings());

      expect(result, isA<SettingsSaveFailure>());
      expect(
        (result as SettingsSaveFailure).message,
        contains('DB read failed'),
      );
    });

    test(
      'does not require lock when maxDiscountAmount changes with same value',
      () async {
        final current = const Settings().copyWith(
          maxDiscountAmount: Money.fromDouble(100),
        );
        final updated = const Settings().copyWith(
          maxDiscountAmount: Money.fromDouble(100), // same value
        );

        when(() => mockRepo.load()).thenAnswer((_) async => current);

        await useCase(updated);

        verifyNever(() => mockAppLock.requireSensitiveSession());
      },
    );
  });
}
