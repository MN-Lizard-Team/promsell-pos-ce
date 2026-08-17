import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_page.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class GetProductsPage {
  const GetProductsPage(this._repository);
  final ProductRepository _repository;

  Future<ProductPage> call({
    ProductCursor? cursor,
    int pageSize = 50,
    bool activeOnly = false,
  }) => _repository.getProductsPage(
    cursor: cursor,
    pageSize: pageSize,
    activeOnly: activeOnly,
  );
}

@injectable
class SearchProductsPage {
  const SearchProductsPage(this._repository);
  final ProductRepository _repository;

  Future<ProductPage> call({
    required String query,
    ProductCursor? cursor,
    int pageSize = 50,
    bool activeOnly = false,
  }) => _repository.searchProductsPage(
    query: query,
    cursor: cursor,
    pageSize: pageSize,
    activeOnly: activeOnly,
  );
}
