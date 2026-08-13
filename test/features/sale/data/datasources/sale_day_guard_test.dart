import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_day_guard.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createInMemoryDatabase();
  });

  tearDown(() => db.close());

  Future<void> setDailyCloseSettings({
    required bool enabled,
    String? lastClosedDate,
  }) async {
    await db.batch((batch) {
      batch.insertAll(db.appSettings, [
        AppSettingsCompanion.insert(
          key: 'dailyCloseLock',
          value: enabled.toString(),
        ),
        AppSettingsCompanion.insert(
          key: 'lastClosedDate',
          value: lastClosedDate ?? '',
        ),
      ], mode: InsertMode.insertOrReplace);
    });
  }

  test('allows a sale when daily close lock is disabled', () async {
    await setDailyCloseSettings(enabled: false, lastClosedDate: '2026-08-04');

    await expectLater(
      SaleDayGuard.assertCreateAllowed(db, now: DateTime(2026, 8, 4, 12)),
      completes,
    );
  });

  test('blocks create when settings close today', () async {
    await setDailyCloseSettings(enabled: true, lastClosedDate: '2026-08-04');

    await expectLater(
      SaleDayGuard.assertCreateAllowed(db, now: DateTime(2026, 8, 4, 12)),
      throwsA(
        isA<BusinessRuleError>().having(
          (error) => error.rule,
          'rule',
          SalesDayLock.ruleDayClosed,
        ),
      ),
    );
  });

  test('blocks void when a closed row exists for the sale day', () async {
    await setDailyCloseSettings(enabled: true);
    await db
        .into(db.dailyCloses)
        .insert(
          DailyClosesCompanion.insert(
            id: 'close-1',
            closeDate: '2026-08-04',
            closedAt: const Value.absent(),
          ),
        );
    await db
        .update(db.dailyCloses)
        .write(DailyClosesCompanion(closedAt: Value(DateTime(2026, 8, 4, 18))));

    await expectLater(
      SaleDayGuard.assertVoidAllowed(db, DateTime(2026, 8, 4, 10)),
      throwsA(isA<BusinessRuleError>()),
    );
  });

  test('allows a void when the close row is open', () async {
    await setDailyCloseSettings(enabled: true);
    await db
        .into(db.dailyCloses)
        .insert(
          DailyClosesCompanion.insert(id: 'close-2', closeDate: '2026-08-04'),
        );

    await expectLater(
      SaleDayGuard.assertVoidAllowed(db, DateTime(2026, 8, 4, 10)),
      completes,
    );
  });
}
