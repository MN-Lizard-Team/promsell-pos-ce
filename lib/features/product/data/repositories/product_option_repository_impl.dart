import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_option_repository.dart';

@LazySingleton(as: ProductOptionRepository)
class ProductOptionRepositoryImpl implements ProductOptionRepository {
  const ProductOptionRepositoryImpl(this._datasource);
  final ProductOptionDatasource _datasource;

  @override
  Future<List<ProductOptionGroup>> getOptionGroupsForProduct(
    String productId,
  ) => _datasource.getOptionGroupsForProduct(productId);

  @override
  Future<String> addOptionGroup({
    required String productId,
    required String name,
    OptionSelectionType selectionType = OptionSelectionType.single,
    bool isRequired = false,
    int sortOrder = 0,
  }) async {
    final id = IdGenerator.newId();
    final now = DateTime.now();
    await _datasource.insertOptionGroup(
      ProductOptionGroupsCompanion.insert(
        id: id,
        productId: productId,
        name: name,
        selectionType: Value(
          selectionType == OptionSelectionType.multiple ? 'multiple' : 'single',
        ),
        isRequired: Value(isRequired),
        sortOrder: Value(sortOrder),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return id;
  }

  @override
  Future<void> updateOptionGroup(ProductOptionGroup group) async {
    final now = DateTime.now();
    await _datasource.updateOptionGroup(
      ProductOptionGroupsCompanion(
        id: Value(group.id),
        name: Value(group.name),
        selectionType: Value(
          group.selectionType == OptionSelectionType.multiple
              ? 'multiple'
              : 'single',
        ),
        isRequired: Value(group.isRequired),
        sortOrder: Value(group.sortOrder),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteOptionGroup(String id) async {
    await _datasource.deleteOptionsByGroupId(id);
    await _datasource.deleteOptionGroup(id);
  }

  @override
  Future<String> addOption({
    required String groupId,
    required String name,
    double priceDelta = 0.0,
    int sortOrder = 0,
  }) async {
    final id = IdGenerator.newId();
    final now = DateTime.now();
    await _datasource.insertOption(
      ProductOptionsCompanion.insert(
        id: id,
        groupId: groupId,
        name: name,
        priceDelta: Value(priceDelta),
        sortOrder: Value(sortOrder),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return id;
  }

  @override
  Future<void> updateOption(ProductOption option) async {
    final now = DateTime.now();
    await _datasource.updateOption(
      ProductOptionsCompanion(
        id: Value(option.id),
        name: Value(option.name),
        priceDelta: Value(option.priceDelta),
        sortOrder: Value(option.sortOrder),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteOption(String id) => _datasource.deleteOption(id);

  @override
  Future<void> saveOptionGroupsForProduct(
    String productId,
    List<ProductOptionGroup> groups,
  ) async {
    final existing = await _datasource.getOptionGroupsForProduct(productId);
    final existingGroupIds = existing.map((g) => g.id).toSet();
    final newGroupIds = groups.map((g) => g.id).toSet();

    for (final oldId in existingGroupIds.difference(newGroupIds)) {
      await deleteOptionGroup(oldId);
    }

    for (final group in groups) {
      if (existingGroupIds.contains(group.id)) {
        await updateOptionGroup(group);
        final existingOptions = existing
            .firstWhere((g) => g.id == group.id)
            .options;
        final existingOptionIds = existingOptions.map((o) => o.id).toSet();
        final newOptionIds = group.options.map((o) => o.id).toSet();

        for (final oldOptId in existingOptionIds.difference(newOptionIds)) {
          await deleteOption(oldOptId);
        }
        for (final opt in group.options) {
          if (existingOptionIds.contains(opt.id)) {
            await updateOption(opt);
          } else {
            await _datasource.insertOption(
              ProductOptionsCompanion.insert(
                id: opt.id,
                groupId: group.id,
                name: opt.name,
                priceDelta: Value(opt.priceDelta),
                sortOrder: Value(opt.sortOrder),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
          }
        }
      } else {
        final groupId = await addOptionGroup(
          productId: productId,
          name: group.name,
          selectionType: group.selectionType,
          isRequired: group.isRequired,
          sortOrder: group.sortOrder,
        );
        for (final opt in group.options) {
          await _datasource.insertOption(
            ProductOptionsCompanion.insert(
              id: opt.id,
              groupId: groupId,
              name: opt.name,
              priceDelta: Value(opt.priceDelta),
              sortOrder: Value(opt.sortOrder),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    }
  }
}
