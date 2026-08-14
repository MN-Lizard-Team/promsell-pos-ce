/// Domain port for cleaning up image files no longer referenced by any
/// active product.
///
/// Implemented in the data layer (`OrphanImageCleanerAdapter` wrapping
/// `ProductImageService`) so the product domain never imports
/// `product/data`.
abstract class OrphanImageCleaner {
  /// Deletes image files whose path is not in [validPaths].
  /// Returns the number of files deleted.
  Future<int> clearOrphanedImages(List<String> validPaths);
}
