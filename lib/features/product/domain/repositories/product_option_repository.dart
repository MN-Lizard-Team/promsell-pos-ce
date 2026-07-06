import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

abstract class ProductOptionRepository {
  Future<List<ProductOptionGroup>> getOptionGroupsForProduct(String productId);
  Future<String> addOptionGroup({
    required String productId,
    required String name,
    OptionSelectionType selectionType = OptionSelectionType.single,
    bool isRequired = false,
    int sortOrder = 0,
  });
  Future<void> updateOptionGroup(ProductOptionGroup group);
  Future<void> deleteOptionGroup(String id);
  Future<String> addOption({
    required String groupId,
    required String name,
    double priceDelta = 0.0,
    int sortOrder = 0,
  });
  Future<void> updateOption(ProductOption option);
  Future<void> deleteOption(String id);
  Future<void> saveOptionGroupsForProduct(
    String productId,
    List<ProductOptionGroup> groups,
  );
}
