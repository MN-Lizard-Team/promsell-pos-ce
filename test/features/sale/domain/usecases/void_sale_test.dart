import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_by_date.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

class MockGetDailyCloseByDate extends Mock implements GetDailyCloseByDate {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late VoidSale useCase;
  late MockSaleRepository mockRepo;
  late MockSettingsRepository mockSettings;
  late MockGetDailyCloseByDate mockGetClose;
  late AppLockService appLock;
  late Map<String, String> lockMap;

  setUp(() {
    mockRepo = MockSaleRepository();
    mockSettings = MockSettingsRepository();
    mockGetClose = MockGetDailyCloseByDate();
    lockMap = {};
    final storage = _MockStorage();
    when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async {
      return lockMap[inv.namedArguments[#key] as String];
    });
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((inv) async {
      lockMap[inv.namedArguments[#key] as String] =
          inv.namedArguments[#value] as String;
    });
    when(() => storage.delete(key: any(named: 'key'))).thenAnswer((inv) async {
      lockMap.remove(inv.namedArguments[#key] as String);
    });
    appLock = AppLockService(storage: storage);
    useCase = VoidSale(mockRepo, mockSettings, mockGetClose, appLock);
    when(() => mockSettings.load()).thenAnswer((_) async => const Settings());
    when(() => mockGetClose(any())).thenAnswer((_) async => null);
    when(() => mockRepo.getSaleById(any())).thenAnswer((_) async => tSale);
    when(
      () => mockRepo.voidSale(any(), reason: any(named: 'reason')),
    ).thenAnswer((_) async {});
  });

  test('voids when day open', () async {
    await useCase(tSale.id, reason: 'test');
    verify(() => mockRepo.voidSale(tSale.id, reason: 'test')).called(1);
  });

  test('blocks when lastClosedDate matches sale day', () async {
    final saleDate = SalesDayLock.dateIso(tSale.createdAt);
    when(() => mockSettings.load()).thenAnswer(
      (_) async => const Settings().copyWith(
        dailyCloseLock: true,
        lastClosedDate: saleDate,
      ),
    );

    await expectLater(
      () => useCase(tSale.id, reason: 'x'),
      throwsA(
        isA<BusinessRuleError>().having(
          (e) => e.rule,
          'rule',
          SalesDayLock.ruleDayClosed,
        ),
      ),
    );
    verifyNever(() => mockRepo.voidSale(any(), reason: any(named: 'reason')));
  });

  test('blocks when daily close row is closed', () async {
    final saleDate = SalesDayLock.dateIso(tSale.createdAt);
    when(
      () => mockSettings.load(),
    ).thenAnswer((_) async => const Settings().copyWith(dailyCloseLock: true));
    when(() => mockGetClose(saleDate)).thenAnswer(
      (_) async => DailyClose(
        id: 'dc1',
        closeDate: saleDate,
        closedAt: DateTime(2026, 7, 15),
      ),
    );

    await expectLater(
      () => useCase(tSale.id, reason: 'x'),
      throwsA(isA<BusinessRuleError>()),
    );
  });

  test('blocks when store PIN enabled and session locked', () async {
    await appLock.setPin('147258');
    appLock.lockSession();

    await expectLater(
      () => useCase(tSale.id, reason: 'x'),
      throwsA(
        isA<BusinessRuleError>().having(
          (e) => e.rule,
          'rule',
          AppLockService.ruleAppLockRequired,
        ),
      ),
    );
    verifyNever(() => mockRepo.voidSale(any(), reason: any(named: 'reason')));
  });

  test('voids when store PIN enabled and session unlocked', () async {
    await appLock.setPin('147258');
    // setPin unlocks session
    await useCase(tSale.id, reason: 'ok');
    verify(() => mockRepo.voidSale(tSale.id, reason: 'ok')).called(1);
  });
}
