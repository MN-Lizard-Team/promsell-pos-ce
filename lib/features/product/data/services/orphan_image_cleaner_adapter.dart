import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/services/orphan_image_cleaner.dart';

@LazySingleton(as: OrphanImageCleaner)
class OrphanImageCleanerAdapter implements OrphanImageCleaner {
  const OrphanImageCleanerAdapter(this._imageService);

  final ProductImageService _imageService;

  @override
  Future<int> clearOrphanedImages(List<String> validPaths) =>
      _imageService.clearOrphanedImages(validPaths);
}
