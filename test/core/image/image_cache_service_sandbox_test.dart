import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/image/image_cache_service.dart';

/// POST-090 B5: image delete path sandbox under app `images/`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late ImageCacheService service;

  void mockPathProvider(Directory root) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            if (call.method == 'getApplicationDocumentsDirectory') {
              return root.path;
            }
            return null;
          },
        );
  }

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('promsell_img_sandbox');
    mockPathProvider(temp);
    service = ImageCacheService();
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('deleteImage removes files under images/ only', () async {
    final images = Directory(p.join(temp.path, 'images'));
    await images.create(recursive: true);
    final safe = File(p.join(images.path, 'ok.jpg'));
    await safe.writeAsBytes([1, 2, 3]);
    final thumb = File(p.join(images.path, 'ok_thumb.jpg'));
    await thumb.writeAsBytes([4, 5]);

    final outside = File(p.join(temp.path, 'secret.db'));
    await outside.writeAsBytes([9, 9, 9]);
    final traversal = File(p.join(temp.path, 'escape.jpg'));
    await traversal.writeAsBytes([8, 8]);

    await service.deleteImage(safe.path, thumb.path);
    expect(await safe.exists(), isFalse);
    expect(await thumb.exists(), isFalse);

    // Path outside images/ must not be deleted (sandbox).
    await service.deleteImage(outside.path, traversal.path);
    expect(await outside.exists(), isTrue);
    expect(await traversal.exists(), isTrue);

    // Relative escape attempt via parent of images.
    final sneaky = File(p.join(images.path, '..', 'escape2.bin'));
    await sneaky.writeAsBytes([7]);
    await service.deleteImage(sneaky.path, null);
    expect(await File(p.normalize(sneaky.absolute.path)).exists(), isTrue);
  });

  test('deleteImage no-ops on null/empty paths', () async {
    await service.deleteImage(null, '');
  });
}
