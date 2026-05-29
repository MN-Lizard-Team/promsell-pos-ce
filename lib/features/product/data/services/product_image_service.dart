import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

abstract class ProductImageService {
  Future<String?> pickFromGallery(String productId);
  Future<String?> pickFromCamera(String productId);
  Future<void> deleteImage(String? imagePath);
}

@LazySingleton(as: ProductImageService)
class ProductImageServiceImpl implements ProductImageService {
  static const _maxWidth = 800;
  static const _quality = 80;

  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickFromGallery(String productId) async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxWidth.toDouble(),
      imageQuality: _quality,
    );
    if (xFile == null) return null;
    return _compressAndSave(xFile.path, productId);
  }

  @override
  Future<String?> pickFromCamera(String productId) async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _maxWidth.toDouble(),
      imageQuality: _quality,
    );
    if (xFile == null) return null;
    return _compressAndSave(xFile.path, productId);
  }

  @override
  Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<String> _compressAndSave(String sourcePath, String productId) async {
    final dir = await _imageDirectory;
    final targetPath = '${dir.path}/$productId.jpg';

    await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: _quality,
      minWidth: _maxWidth,
      format: CompressFormat.jpeg,
    );

    return targetPath;
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
