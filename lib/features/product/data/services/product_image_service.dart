import 'dart:io';

import 'package:image/image.dart' as img_lib;
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

abstract class ProductImageService {
  Future<String?> pickFromGallery(String productId);
  Future<String?> pickFromCamera(String productId);
  Future<void> deleteImage(String? imagePath);
  Future<void> deleteImages(String? imagePath, String? thumbnailPath);
  Future<String?> generateThumbnail(String imagePath);
  Future<ImagePaths?> renameImages(String? oldPath, String newProductId);
}

class ImagePaths {
  const ImagePaths({required this.fullPath, required this.thumbnailPath});
  final String fullPath;
  final String thumbnailPath;
}

@LazySingleton(as: ProductImageService)
class ProductImageServiceImpl implements ProductImageService {
  static const _thumbWidth = 200;
  static const _thumbQuality = 70;

  final ImagePicker _picker;
  final SettingsRepository _settingsRepository;

  ProductImageServiceImpl(this._settingsRepository, {ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  @override
  Future<String?> pickFromGallery(String productId) async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return null;
    final effectiveId = _resolveProductId(productId);
    return _compressAndSave(xFile.path, effectiveId);
  }

  @override
  Future<String?> pickFromCamera(String productId) async {
    final xFile = await _picker.pickImage(source: ImageSource.camera);
    if (xFile == null) return null;
    final effectiveId = _resolveProductId(productId);
    return _compressAndSave(xFile.path, effectiveId);
  }

  @override
  Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> deleteImages(String? imagePath, String? thumbnailPath) async {
    await deleteImage(imagePath);
    await deleteImage(thumbnailPath);
  }

  @override
  Future<String?> generateThumbnail(String imagePath) async {
    if (imagePath.isEmpty) return null;
    final file = File(imagePath);
    if (!await file.exists()) return null;

    final thumbPath = _thumbPathFromFull(imagePath);
    final thumbFile = File(thumbPath);
    if (await thumbFile.exists()) return thumbPath;

    final bytes = await file.readAsBytes();
    final image = img_lib.decodeImage(bytes);
    if (image == null) return null;

    final thumb = img_lib.copyResize(image, width: _thumbWidth);
    final jpg = img_lib.encodeJpg(thumb, quality: _thumbQuality);
    await thumbFile.writeAsBytes(jpg);
    return thumbPath;
  }

  String _resolveProductId(String productId) {
    if (productId == 'new' || productId.isEmpty) {
      return IdGenerator.newId();
    }
    return productId;
  }

  Future<String> _compressAndSave(String sourcePath, String productId) async {
    final settings = await _settingsRepository.load();
    final maxWidth = settings.imageMaxWidth;
    final quality = settings.imageQuality;

    final dir = await _imageDirectory;
    final bytes = await File(sourcePath).readAsBytes();
    final image = img_lib.decodeImage(bytes);
    if (image == null) {
      throw StateError('Failed to decode image: $sourcePath');
    }

    final resized = img_lib.copyResize(image, width: maxWidth);
    final jpg = img_lib.encodeJpg(resized, quality: quality);

    final targetPath = '${dir.path}/$productId.jpg';
    await File(targetPath).writeAsBytes(jpg);

    final thumb = img_lib.copyResize(image, width: _thumbWidth);
    final thumbJpg = img_lib.encodeJpg(thumb, quality: _thumbQuality);
    final thumbPath = '${dir.path}/${productId}_thumb.jpg';
    await File(thumbPath).writeAsBytes(thumbJpg);

    return targetPath;
  }

  @override
  Future<ImagePaths?> renameImages(String? oldPath, String newProductId) async {
    if (oldPath == null || oldPath.isEmpty) return null;
    final oldFile = File(oldPath);
    if (!await oldFile.exists()) return null;

    final dir = await _imageDirectory;
    final newPath = '${dir.path}/$newProductId.jpg';
    final newThumbPath = '${dir.path}/${newProductId}_thumb.jpg';

    await oldFile.rename(newPath);

    final oldThumbPath = _thumbPathFromFull(oldPath);
    final oldThumbFile = File(oldThumbPath);
    if (await oldThumbFile.exists()) {
      await oldThumbFile.rename(newThumbPath);
    }

    return ImagePaths(fullPath: newPath, thumbnailPath: newThumbPath);
  }

  String _thumbPathFromFull(String fullPath) {
    final dir = fullPath.substring(0, fullPath.lastIndexOf('/'));
    final fileName = fullPath.substring(fullPath.lastIndexOf('/') + 1);
    final thumbName = fileName.replaceAll('.jpg', '_thumb.jpg');
    return '$dir/$thumbName';
  }

  Future<Directory> get _imageDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }
}
