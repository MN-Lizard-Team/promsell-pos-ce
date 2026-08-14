import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

abstract class ProductOptionDatasource {
  Future<List<ProductOptionGroup>> getOptionGroupsForProduct(String productId);
  Future<Map<String, List<ProductOptionGroup>>> getOptionGroupsForProducts(
    List<String> productIds,
  );
  Future<void> insertOptionGroup(ProductOptionGroupsCompanion companion);
  Future<void> updateOptionGroup(ProductOptionGroupsCompanion companion);
  Future<void> deleteOptionGroup(String id);
  Future<void> insertOption(ProductOptionsCompanion companion);
  Future<void> updateOption(ProductOptionsCompanion companion);
  Future<void> deleteOption(String id);
  Future<void> deleteOptionsByGroupId(String groupId);
}

@LazySingleton(as: ProductOptionDatasource)
class ProductOptionDatasourceImpl implements ProductOptionDatasource {
  const ProductOptionDatasourceImpl(this._db);
  final AppDatabase _db;

  ProductOption _optionFromData(ProductOptionData d) => ProductOption(
    id: d.id,
    groupId: d.groupId,
    name: d.name,
    priceDelta: moneyFromSatangOrBaht(d.priceDeltaSatang, d.priceDelta),
    sortOrder: d.sortOrder,
  );

  ProductOptionGroup _groupFromData(
    ProductOptionGroupData g,
    List<ProductOption> options,
  ) => ProductOptionGroup(
    id: g.id,
    productId: g.productId,
    name: g.name,
    selectionType: g.selectionType == 'multiple'
        ? OptionSelectionType.multiple
        : OptionSelectionType.single,
    isRequired: g.isRequired,
    sortOrder: g.sortOrder,
    options: options..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
  );

  @override
  Future<List<ProductOptionGroup>> getOptionGroupsForProduct(
    String productId,
  ) async {
    final groups =
        await (_db.select(_db.productOptionGroups)
              ..where((g) => g.productId.equals(productId))
              ..where((g) => g.deletedAt.isNull())
              ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]))
            .get();

    if (groups.isEmpty) return [];

    final groupIds = groups.map((g) => g.id).toList();
    final options =
        await (_db.select(_db.productOptions)
              ..where((o) => o.groupId.isIn(groupIds))
              ..where((o) => o.deletedAt.isNull())
              ..orderBy([(o) => OrderingTerm.asc(o.sortOrder)]))
            .get();

    final optionsByGroup = <String, List<ProductOption>>{};
    for (final opt in options) {
      optionsByGroup
          .putIfAbsent(opt.groupId, () => [])
          .add(_optionFromData(opt));
    }

    return groups
        .map((g) => _groupFromData(g, optionsByGroup[g.id] ?? []))
        .toList();
  }

  @override
  Future<Map<String, List<ProductOptionGroup>>> getOptionGroupsForProducts(
    List<String> productIds,
  ) async {
    if (productIds.isEmpty) return {};

    final groups =
        await (_db.select(_db.productOptionGroups)
              ..where((g) => g.productId.isIn(productIds))
              ..where((g) => g.deletedAt.isNull())
              ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]))
            .get();

    if (groups.isEmpty) {
      return {for (final id in productIds) id: []};
    }

    final groupIds = groups.map((g) => g.id).toList();
    final options =
        await (_db.select(_db.productOptions)
              ..where((o) => o.groupId.isIn(groupIds))
              ..where((o) => o.deletedAt.isNull())
              ..orderBy([(o) => OrderingTerm.asc(o.sortOrder)]))
            .get();

    final optionsByGroup = <String, List<ProductOption>>{};
    for (final opt in options) {
      optionsByGroup
          .putIfAbsent(opt.groupId, () => [])
          .add(_optionFromData(opt));
    }

    final result = <String, List<ProductOptionGroup>>{};
    for (final id in productIds) {
      result[id] = [];
    }
    for (final g in groups) {
      result[g.productId]!.add(_groupFromData(g, optionsByGroup[g.id] ?? []));
    }

    return result;
  }

  @override
  Future<void> insertOptionGroup(ProductOptionGroupsCompanion companion) =>
      _db.into(_db.productOptionGroups).insert(companion);

  @override
  Future<void> updateOptionGroup(ProductOptionGroupsCompanion companion) =>
      (_db.update(
        _db.productOptionGroups,
      )..where((g) => g.id.equals(companion.id.value))).write(companion);

  @override
  Future<void> deleteOptionGroup(String id) =>
      (_db.update(
        _db.productOptionGroups,
      )..where((g) => g.id.equals(id))).write(
        ProductOptionGroupsCompanion(deletedAt: Value(DateTime.now())),
      );

  @override
  Future<void> insertOption(ProductOptionsCompanion companion) =>
      _db.into(_db.productOptions).insert(companion);

  @override
  Future<void> updateOption(ProductOptionsCompanion companion) => (_db.update(
    _db.productOptions,
  )..where((o) => o.id.equals(companion.id.value))).write(companion);

  @override
  Future<void> deleteOption(String id) =>
      (_db.update(_db.productOptions)..where((o) => o.id.equals(id))).write(
        ProductOptionsCompanion(deletedAt: Value(DateTime.now())),
      );

  @override
  Future<void> deleteOptionsByGroupId(String groupId) =>
      (_db.update(_db.productOptions)..where((o) => o.groupId.equals(groupId)))
          .write(ProductOptionsCompanion(deletedAt: Value(DateTime.now())));
}
