import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
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
    this._appLock,
  );

  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;
  final AddCategory _addCategory;
  final AppLockService _appLock;

  Future<ProductImportResult> call(List<CsvProductRow> rows) async {
    await _appLock.requireSensitiveSession();

    final categories = await _categoryRepository.watchCategories().first;
    final categoryIds = <String, String>{
      for (final category in categories)
        category.name.trim().toLowerCase(): category.id,
    };
    var importedCount = 0;
    var createdCategoryCount = 0;
    final rowErrors = <CsvImportRowError>[];

    // Pre-validate: detect duplicate barcodes within the CSV itself so we
    // can report all conflicts upfront instead of partial-importing.
    final seenBarcodes = <String, int>{};
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final barcode = row.barcode?.trim();
      if (barcode == null || barcode.isEmpty) continue;
      final key = barcode.toLowerCase();
      if (seenBarcodes.containsKey(key)) {
        rowErrors.add(
          CsvImportRowError(
            sourceRow: row.sourceRow,
            message:
                'Duplicate barcode "$barcode" within CSV (also at row ${seenBarcodes[key]! + 1})',
          ),
        );
        // Mark row as skipped by setting a sentinel — we filter below.
        continue;
      }
      seenBarcodes[key] = i;
    }

    // Pre-validate: check DB barcode uniqueness for all valid rows upfront
    // so we can report conflicts before any insert (reduces partial imports).
    final dbBarcodeConflicts = <int, String>{};
    for (final row in rows) {
      final barcode = row.barcode?.trim();
      if (barcode == null || barcode.isEmpty) continue;
      if (rowErrors.any(
        (e) =>
            e.sourceRow == row.sourceRow &&
            e.message.contains('Duplicate barcode'),
      )) {
        continue;
      }
      final exists = await _productRepository.barcodeExists(barcode);
      if (exists) {
        dbBarcodeConflicts[row.sourceRow] = barcode;
        rowErrors.add(
          CsvImportRowError(
            sourceRow: row.sourceRow,
            message: 'Barcode "$barcode" already exists in database',
          ),
        );
      }
    }

    for (final row in rows) {
      // Skip rows already flagged as intra-CSV duplicates or DB conflicts.
      final barcode = row.barcode?.trim();
      if (barcode != null &&
          barcode.isNotEmpty &&
          rowErrors.any(
            (e) =>
                e.sourceRow == row.sourceRow &&
                (e.message.contains('Duplicate barcode') ||
                    e.message.contains('already exists')),
          )) {
        continue;
      }
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
