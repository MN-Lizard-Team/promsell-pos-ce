import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img_lib;
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/mocks.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late ProductImageServiceImpl service;
  late MockSettingsRepository mockSettingsRepo;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('promsell_test_');
    mockSettingsRepo = MockSettingsRepository();
    when(
      () => mockSettingsRepo.load(),
    ).thenAnswer((_) async => const Settings());
    service = ProductImageServiceImpl(mockSettingsRepo);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('deleteImage', () {
    test('deletes existing file', () async {
      final file = File('${tempDir.path}/test.jpg');
      await file.writeAsBytes([1, 2, 3]);
      expect(await file.exists(), isTrue);

      await service.deleteImage(file.path);

      expect(await file.exists(), isFalse);
    });

    test('no-op for null path', () async {
      await expectLater(service.deleteImage(null), completes);
    });

    test('no-op for empty path', () async {
      await expectLater(service.deleteImage(''), completes);
    });
  });

  group('deleteImages', () {
    test('deletes both full and thumbnail', () async {
      final full = File('${tempDir.path}/full.jpg');
      final thumb = File('${tempDir.path}/thumb.jpg');
      await full.writeAsBytes([1, 2, 3]);
      await thumb.writeAsBytes([1, 2, 3]);

      await service.deleteImages(full.path, thumb.path);

      expect(await full.exists(), isFalse);
      expect(await thumb.exists(), isFalse);
    });

    test('no-op when both paths are null', () async {
      await expectLater(service.deleteImages(null, null), completes);
    });

    test('deletes only existing file when one is null', () async {
      final full = File('${tempDir.path}/full.jpg');
      await full.writeAsBytes([1, 2, 3]);

      await service.deleteImages(full.path, null);

      expect(await full.exists(), isFalse);
    });
  });

  group('generateThumbnail', () {
    test('creates 200px thumbnail from image', () async {
      final image = img_lib.Image(width: 400, height: 400);
      final jpg = img_lib.encodeJpg(image);
      final fullPath = '${tempDir.path}/test.jpg';
      await File(fullPath).writeAsBytes(jpg);

      final thumbPath = await service.generateThumbnail(fullPath);

      expect(thumbPath, isNotNull);
      expect(thumbPath, endsWith('_thumb.jpg'));
      final thumbFile = File(thumbPath!);
      expect(await thumbFile.exists(), isTrue);

      final thumbBytes = await thumbFile.readAsBytes();
      final thumb = img_lib.decodeImage(thumbBytes);
      expect(thumb, isNotNull);
      expect(thumb!.width, 200);
    });

    test('returns existing thumbnail without recreating', () async {
      final fullPath = p.join(tempDir.path, 'test2.jpg');
      final thumbPath = p.join(tempDir.path, 'test2_thumb.jpg');
      await File(fullPath).writeAsBytes([1, 2, 3]);
      await File(thumbPath).writeAsBytes([4, 5, 6]);

      final result = await service.generateThumbnail(fullPath);

      expect(result, thumbPath);
    });

    test('returns null for empty path', () async {
      final result = await service.generateThumbnail('');
      expect(result, isNull);
    });

    test('returns null when source file does not exist', () async {
      final result = await service.generateThumbnail(
        '${tempDir.path}/missing.jpg',
      );
      expect(result, isNull);
    });
  });

  group('pickFromGallery', () {
    late MockImagePicker mockPicker;

    setUp(() {
      mockPicker = MockImagePicker();
      service = ProductImageServiceImpl(mockSettingsRepo, picker: mockPicker);
    });

    test('returns null when user cancels picker', () async {
      when(
        () => mockPicker.pickImage(source: ImageSource.gallery),
      ).thenAnswer((_) async => null);

      final result = await service.pickFromGallery('test-id');

      expect(result, isNull);
    });
  });
}
