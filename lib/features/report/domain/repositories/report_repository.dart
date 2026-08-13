import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

/// Abstraction for report data access.
///
/// Wraps [SaleRepository] and [ProductRepository] so the Report feature
/// depends only on its own contract. The cost-lookup method accepts a
/// filtered set of product ids so the full catalog is not loaded when
/// only a handful of products appear in the selected period.
abstract class ReportRepository {
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});
  Future<List<Sale>> getSales({DateTime? from, DateTime? to});

  /// Returns a productId → [Product] map for the supplied ids.
  ///
  /// Used by profit analytics so cost data is fetched only for products
  /// that appear in the current period instead of the entire catalog.
  Future<Map<String, Product>> getProductCostLookup(List<String> productIds);
}
