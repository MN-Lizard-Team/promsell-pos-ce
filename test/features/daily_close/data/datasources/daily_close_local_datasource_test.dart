import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/daily_close/data/datasources/daily_close_local_datasource.dart';

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late DailyCloseLocalDatasourceImpl ds;

  setUp(() {
    db = createInMemoryDatabase();
    ds = DailyCloseLocalDatasourceImpl(db);
  });

  tearDown(() => db.close());

  group('DailyCloseLocalDatasourceImpl', () {
    test('getByDate returns null when not found', () async {
      final result = await ds.getByDate('2025-01-15');
      expect(result, isNull);
    });

    test('save and getByDate round-trip', () async {
      final companion = DailyClosesCompanion.insert(
        id: 'dc-001',
        closeDate: '2025-01-15',
        totalRevenue: const Value(5000.0),
        salesCount: const Value(10),
      );
      await db.into(db.dailyCloses).insert(companion);

      final result = await ds.getByDate('2025-01-15');
      expect(result, isNotNull);
      expect(result!.closeDate, '2025-01-15');
      expect(result.totalRevenue, 5000.0);
      expect(result.salesCount, 10);
    });

    test('getAll returns empty when no records', () async {
      final result = await ds.getAll();
      expect(result, isEmpty);
    });

    test('getAll returns all records ordered by date desc', () async {
      await db
          .into(db.dailyCloses)
          .insert(
            DailyClosesCompanion.insert(id: 'dc-001', closeDate: '2025-01-15'),
          );
      await db
          .into(db.dailyCloses)
          .insert(
            DailyClosesCompanion.insert(id: 'dc-002', closeDate: '2025-01-16'),
          );

      final result = await ds.getAll();
      expect(result, hasLength(2));
      expect(result.first.closeDate, '2025-01-16');
      expect(result.last.closeDate, '2025-01-15');
    });

    test('delete removes the record', () async {
      await db
          .into(db.dailyCloses)
          .insert(
            DailyClosesCompanion.insert(id: 'dc-001', closeDate: '2025-01-15'),
          );

      await ds.delete('dc-001');

      final result = await ds.getAll();
      expect(result, isEmpty);
    });

    test('save inserts new record', () async {
      final data = DailyClosesCompanion.insert(
        id: 'dc-001',
        closeDate: '2025-01-15',
        totalRevenue: const Value(1000.0),
      );
      await db.into(db.dailyCloses).insert(data);
      final saved = await (db.select(
        db.dailyCloses,
      )..where((c) => c.id.equals('dc-001'))).getSingle();

      expect(saved.id, 'dc-001');
      expect(saved.closeDate, '2025-01-15');
      expect(saved.totalRevenue, 1000.0);
    });
  });
}
