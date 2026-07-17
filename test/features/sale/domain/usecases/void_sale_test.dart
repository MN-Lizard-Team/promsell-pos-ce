import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_by_date.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

class MockGetDailyCloseByDate extends Mock implements GetDailyCloseByDate {}

void main() {
  late VoidSale useCase;
  late MockSaleRepository mockRepo;
  late MockSettingsRepository mockSettings;
  late MockGetDailyCloseByDate mockGetClose;

  setUp(() {
    mockRepo = MockSaleRepository();
    mockSettings = MockSettingsRepository();
    mockGetClose = MockGetDailyCloseByDate();
    useCase = VoidSale(mockRepo, mockSettings, mockGetClose);
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
}
