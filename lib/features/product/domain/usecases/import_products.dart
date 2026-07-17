import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/category_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_category.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/csv_product_parser.dart';

class ProductImportResult {
  const ProductImportResult({
    required this.importedCount,
    this.createdCategoryCount = 0,
    this.rowErrors = const [],
  });

  final int importedCount;
  final int createdCategoryCount;
  final List<CsvImportRowError> rowErrors;
}

@injectable
class ImportProducts {
  const ImportProducts(
    this._productRepository,
    this._categoryRepository,
    this._addCategory,
  );

  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;
  final AddCategory _addCategory;

  Future<ProductImportResult> call(List<CsvProductRow> rows) async {
    final categories = await _categoryRepository.watchCategories().first;
    final categoryIds = <String, String>{
      for (final category in categories)
        category.name.trim().toLowerCase(): category.id,
    };
    var importedCount = 0;
    var createdCategoryCount = 0;
    final rowErrors = <CsvImportRowError>[];

    for (final row in rows) {
      try {
        String? categoryId;
        final categoryName = row.categoryName?.trim();
        if (categoryName != null && categoryName.isNotEmpty) {
          final key = categoryName.toLowerCase();
          categoryId = categoryIds[key];
          if (categoryId == null) {
            // Shared create path: uniqueness + max+1 sortOrder.
            categoryId = await _addCategory(name: categoryName);
            categoryIds[key] = categoryId;
            createdCategoryCount++;
          }
        }
        await _productRepository.addProduct(
          name: row.name,
          sku: row.sku,
          barcode: row.barcode,
          price: row.price,
          cost: row.cost,
          stock: row.stock,
          categoryId: categoryId,
          trackStock: row.trackStock,
        );
        importedCount++;
      } catch (error) {
        rowErrors.add(
          CsvImportRowError(
            sourceRow: row.sourceRow,
            message: error.toString(),
          ),
        );
      }
    }

    return ProductImportResult(
      importedCount: importedCount,
      createdCategoryCount: createdCategoryCount,
      rowErrors: rowErrors,
    );
  }
}
