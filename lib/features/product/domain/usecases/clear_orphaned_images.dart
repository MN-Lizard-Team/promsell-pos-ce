import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/services/orphan_image_cleaner.dart';

@injectable
class ClearOrphanedImages {
  ClearOrphanedImages(this._repository, this._imageCleaner);

  final ProductRepository _repository;
  final OrphanImageCleaner _imageCleaner;

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
    return _imageCleaner.clearOrphanedImages(validPaths.toList());
  }
}
