/// Client-side window paging for the product catalog list.
///
/// All products stay in [ProductBloc] memory; the UI only paints
/// [initialPageSize], then grows by [pageSize] as the user scrolls.
class ProductListPaging {
  ProductListPaging._();

  /// First paint / after filter reset.
  static const int initialPageSize = 20;

  /// Extra rows loaded each time the user nears the bottom.
  static const int pageSize = 20;

  /// Distance from the bottom (px) that triggers load-more.
  static const double loadMoreExtent = 240;
}
