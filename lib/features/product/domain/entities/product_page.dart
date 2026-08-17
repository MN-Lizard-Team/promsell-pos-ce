import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

/// A single page of products from a cursor-paginated query.
///
/// Cursor = `(createdAt, id)` ordered DESC. Pass [cursor] to fetch the next
/// page; null on the first page. [nextCursor] is null when there are no more
/// rows. [totalCount] is the total non-deleted product count (independent of
/// pagination) so the UI can show "Showing X of Y".
@immutable
class ProductPage extends Equatable {
  const ProductPage({
    required this.products,
    required this.nextCursor,
    required this.totalCount,
  });

  final List<Product> products;

  /// Pass this to the next call to fetch the following page. Null when the
  /// last row of this page is the last row overall.
  final ProductCursor? nextCursor;

  final int totalCount;

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [products, nextCursor, totalCount];
}

/// Cursor position for product pagination (createdAt DESC, id DESC).
@immutable
class ProductCursor extends Equatable {
  const ProductCursor({required this.createdAt, required this.id});

  final DateTime createdAt;
  final String id;

  @override
  List<Object?> get props => [createdAt, id];
}
