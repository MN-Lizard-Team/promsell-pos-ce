import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/promotion/data/datasources/promotion_datasource.dart';
import 'package:promsell_pos_ce/features/promotion/data/repositories/promotion_repository_impl.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';

import '../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late PromotionDatasourceImpl ds;
  late PromotionRepositoryImpl repo;

  setUp(() {
    db = createInMemoryDatabase();
    ds = PromotionDatasourceImpl(db);
    repo = PromotionRepositoryImpl(ds);
  });

  tearDown(() => db.close());

  // Datasource getActive() filters with DateTime.now() — use wall clock.
  DateTime wallNow() => DateTime.now();

  test('insert + getAll + getById round-trip percent promo', () async {
    final t = wallNow();
    final id = await repo.addPromotion(
      Promotion(
        id: 'tmp',
        name: '10% off',
        type: PromotionType.percent,
        value: 10,
        minPurchaseAmount: Money.fromDouble(100),
        startDate: t.subtract(const Duration(days: 1)),
        endDate: t.add(const Duration(days: 30)),
        isActive: true,
        createdAt: t,
        updatedAt: t,
      ),
    );

    final all = await repo.getAllPromotions();
    expect(all.length, 1);
    expect(all.first.id, id);
    expect(all.first.name, '10% off');
    expect(all.first.type, PromotionType.percent);
    expect(all.first.value, 10);

    final one = await repo.getPromotionById(id);
    expect(one, isNotNull);
    expect(one!.minPurchaseAmount, Money.fromDouble(100));
    final stored = await (db.select(
      db.promotions,
    )..where((p) => p.id.equals(id))).getSingle();
    expect(stored.valueSatang, isNull);
    expect(stored.minPurchaseAmountSatang, const Money.fromSatang(10000));
  });

  test('getActive excludes inactive, future, and expired', () async {
    final t = wallNow();
    await repo.addPromotion(
      Promotion(
        id: 'a',
        name: 'Active',
        type: PromotionType.amount,
        value: 20,
        startDate: t.subtract(const Duration(days: 2)),
        endDate: t.add(const Duration(days: 2)),
        isActive: true,
        createdAt: t,
        updatedAt: t,
      ),
    );
    await repo.addPromotion(
      Promotion(
        id: 'b',
        name: 'Off',
        startDate: t.subtract(const Duration(days: 2)),
        endDate: t.add(const Duration(days: 2)),
        isActive: false,
        createdAt: t,
        updatedAt: t,
      ),
    );
    await repo.addPromotion(
      Promotion(
        id: 'c',
        name: 'Future',
        startDate: t.add(const Duration(days: 5)),
        isActive: true,
        createdAt: t,
        updatedAt: t,
      ),
    );
    await repo.addPromotion(
      Promotion(
        id: 'd',
        name: 'Expired',
        startDate: t.subtract(const Duration(days: 10)),
        endDate: t.subtract(const Duration(days: 1)),
        isActive: true,
        createdAt: t,
        updatedAt: t,
      ),
    );

    final active = await repo.getActivePromotions();
    final activeRow = await (db.select(
      db.promotions,
    )..where((p) => p.name.equals('Active'))).getSingle();
    expect(activeRow.valueSatang, const Money.fromSatang(2000));
    expect(active.map((p) => p.name), contains('Active'));
    expect(active.any((p) => p.name == 'Off'), isFalse);
    expect(active.any((p) => p.name == 'Future'), isFalse);
    expect(active.any((p) => p.name == 'Expired'), isFalse);
  });

  test('updatePromotion and softDelete', () async {
    final t = wallNow();
    final id = await repo.addPromotion(
      Promotion(id: 'x', name: 'Old', startDate: t, createdAt: t, updatedAt: t),
    );

    await repo.updatePromotion(
      Promotion(
        id: id,
        name: 'New',
        type: PromotionType.amount,
        value: 5,
        startDate: t,
        isActive: true,
        createdAt: t,
        updatedAt: t,
      ),
    );
    expect((await repo.getPromotionById(id))!.name, 'New');

    await repo.deletePromotion(id);
    expect(await repo.getPromotionById(id), isNull);
    expect(await repo.getAllPromotions(), isEmpty);
  });

  test('watchAll emits list', () async {
    final stream = repo.watchAllPromotions();
    final id = IdGenerator.newId();
    final t = wallNow();
    await ds.insert(
      PromotionsCompanion.insert(
        id: id,
        name: 'Watch me',
        startDate: Value(t),
        createdAt: Value(t),
        updatedAt: Value(t),
      ),
    );
    await expectLater(
      stream,
      emitsThrough(
        predicate<List<Promotion>>(
          (list) => list.any((p) => p.name == 'Watch me'),
        ),
      ),
    );
  });
}
