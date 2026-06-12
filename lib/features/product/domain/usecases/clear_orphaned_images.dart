import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';

@injectable
class ClearOrphanedImages {
  ClearOrphanedImages(this._repository, this._imageService);

  final ProductRepository _repository;
  final ProductImageService _imageService;

  /// Returns the number of orphaned image files deleted.
  Future<int> call() async {
    final products = await _repository.getActiveProducts();
    final validPaths = <String>{};
    for (final p in products) {
      if (p.imagePath != null && p.imagePath!.isNotEmpty) {
        validPaths.add(p.imagePath!);
      }
      if (p.imageThumbnailPath != null && p.imageThumbnailPath!.isNotEmpty) {
        validPaths.add(p.imageThumbnailPath!);
      }
    }
    return _imageService.clearOrphanedImages(validPaths.toList());
  }
}
