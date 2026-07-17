import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late ProductOptionDatasourceImpl ds;
  late String productId;

  setUp(() async {
    db = createInMemoryDatabase();
    ds = ProductOptionDatasourceImpl(db);
    productId = IdGenerator.newId();
    await db
        .into(db.products)
        .insert(
          ProductsCompanion.insert(
            id: productId,
            name: 'Test Product',
            price: 100.0,
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
  });

  tearDown(() => db.close());

  group('ProductOptionDatasource', () {
    test('getOptionGroupsForProduct returns empty when no groups', () async {
      final groups = await ds.getOptionGroupsForProduct(productId);
      expect(groups, isEmpty);
    });

    test('insert and retrieve option group with options', () async {
      final groupId = IdGenerator.newId();
      final now = DateTime.now();
      await ds.insertOptionGroup(
        ProductOptionGroupsCompanion.insert(
          id: groupId,
          productId: productId,
          name: 'Size',
          selectionType: const Value('single'),
          isRequired: const Value(true),
          sortOrder: const Value(0),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final optionId = IdGenerator.newId();
      await ds.insertOption(
        ProductOptionsCompanion.insert(
          id: optionId,
          groupId: groupId,
          name: 'Large',
          priceDelta: const Value(10.0),
          sortOrder: const Value(0),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final groups = await ds.getOptionGroupsForProduct(productId);
      expect(groups.length, 1);
      expect(groups[0].name, 'Size');
      expect(groups[0].selectionType, OptionSelectionType.single);
      expect(groups[0].isRequired, true);
      expect(groups[0].options.length, 1);
      expect(groups[0].options[0].name, 'Large');
      expect(groups[0].options[0].priceDelta, Money.fromDouble(10.0));
    });

    test('deleteOptionGroup soft-deletes group', () async {
      final groupId = IdGenerator.newId();
      final now = DateTime.now();
      await ds.insertOptionGroup(
        ProductOptionGroupsCompanion.insert(
          id: groupId,
          productId: productId,
          name: 'Size',
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await ds.deleteOptionGroup(groupId);
      final groups = await ds.getOptionGroupsForProduct(productId);
      expect(groups, isEmpty);
    });

    test('deleteOptionsByGroupId soft-deletes options', () async {
      final groupId = IdGenerator.newId();
      final now = DateTime.now();
      await ds.insertOptionGroup(
        ProductOptionGroupsCompanion.insert(
          id: groupId,
          productId: productId,
          name: 'Size',
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await ds.insertOption(
        ProductOptionsCompanion.insert(
          id: IdGenerator.newId(),
          groupId: groupId,
          name: 'Small',
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await ds.deleteOptionsByGroupId(groupId);
      final groups = await ds.getOptionGroupsForProduct(productId);
      expect(groups.length, 1);
      expect(groups[0].options, isEmpty);
    });
  });
}
