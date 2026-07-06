import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/repositories/product_option_repository_impl.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late ProductOptionDatasourceImpl ds;
  late ProductOptionRepositoryImpl repo;
  late String productId;

  setUp(() async {
    db = createInMemoryDatabase();
    ds = ProductOptionDatasourceImpl(db);
    repo = ProductOptionRepositoryImpl(ds);
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

  group('ProductOptionRepositoryImpl', () {
    test('addOptionGroup and getOptionGroupsForProduct', () async {
      final id = await repo.addOptionGroup(
        productId: productId,
        name: 'Size',
        selectionType: OptionSelectionType.single,
        isRequired: true,
      );
      expect(id, isNotEmpty);

      final groups = await repo.getOptionGroupsForProduct(productId);
      expect(groups.length, 1);
      expect(groups[0].name, 'Size');
      expect(groups[0].isRequired, true);
    });

    test('addOption and retrieve via group', () async {
      final groupId = await repo.addOptionGroup(
        productId: productId,
        name: 'Toppings',
      );
      final optId = await repo.addOption(
        groupId: groupId,
        name: 'Extra Cheese',
        priceDelta: 5.0,
      );
      expect(optId, isNotEmpty);

      final groups = await repo.getOptionGroupsForProduct(productId);
      expect(groups[0].options.length, 1);
      expect(groups[0].options[0].name, 'Extra Cheese');
      expect(groups[0].options[0].priceDelta, 5.0);
    });

    test('updateOptionGroup updates name and selectionType', () async {
      await repo.addOptionGroup(productId: productId, name: 'Size');

      final groups = await repo.getOptionGroupsForProduct(productId);
      await repo.updateOptionGroup(
        groups[0].copyWith(
          name: 'Drink Size',
          selectionType: OptionSelectionType.multiple,
        ),
      );

      final updated = await repo.getOptionGroupsForProduct(productId);
      expect(updated[0].name, 'Drink Size');
      expect(updated[0].selectionType, OptionSelectionType.multiple);
    });

    test('deleteOptionGroup removes group and its options', () async {
      final groupId = await repo.addOptionGroup(
        productId: productId,
        name: 'Size',
      );
      await repo.addOption(groupId: groupId, name: 'Large');

      await repo.deleteOptionGroup(groupId);

      final groups = await repo.getOptionGroupsForProduct(productId);
      expect(groups, isEmpty);
    });

    test('saveOptionGroupsForProduct creates new groups', () async {
      final optId = IdGenerator.newId();
      final groupId = IdGenerator.newId();
      final groups = [
        ProductOptionGroup(
          id: groupId,
          productId: productId,
          name: 'Spice Level',
          selectionType: OptionSelectionType.single,
          isRequired: true,
          options: [
            ProductOption(
              id: optId,
              groupId: groupId,
              name: 'Hot',
              priceDelta: 0.0,
            ),
          ],
        ),
      ];

      await repo.saveOptionGroupsForProduct(productId, groups);

      final result = await repo.getOptionGroupsForProduct(productId);
      expect(result.length, 1);
      expect(result[0].name, 'Spice Level');
      expect(result[0].options.length, 1);
      expect(result[0].options[0].name, 'Hot');
    });

    test(
      'saveOptionGroupsForProduct updates existing and deletes removed',
      () async {
        final groupId = await repo.addOptionGroup(
          productId: productId,
          name: 'Size',
        );
        await repo.addOption(groupId: groupId, name: 'Small');
        await repo.addOption(groupId: groupId, name: 'Large');

        final existing = await repo.getOptionGroupsForProduct(productId);
        final smallOpt = existing[0].options.firstWhere(
          (o) => o.name == 'Small',
        );

        await repo.saveOptionGroupsForProduct(productId, [
          existing[0].copyWith(
            name: 'Drink Size',
            options: [smallOpt.copyWith(name: 'Small Size')],
          ),
        ]);

        final result = await repo.getOptionGroupsForProduct(productId);
        expect(result.length, 1);
        expect(result[0].name, 'Drink Size');
        expect(result[0].options.length, 1);
        expect(result[0].options[0].name, 'Small Size');
      },
    );
  });
}
