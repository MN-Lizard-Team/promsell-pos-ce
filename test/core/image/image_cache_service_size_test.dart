import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/image/image_cache_service.dart';

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
    temp = await Directory.systemTemp.createTemp('promsell_img_size');
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

  test('getCacheSize sums file lengths', () async {
    final images = Directory(p.join(temp.path, 'images'));
    await images.create(recursive: true);
    await File(p.join(images.path, 'a.bin')).writeAsBytes(List.filled(10, 1));
    await File(p.join(images.path, 'b.bin')).writeAsBytes(List.filled(5, 2));
    expect(await service.getCacheSize(), 15);
  });

  test('clearCache removes files', () async {
    final images = Directory(p.join(temp.path, 'images'));
    await images.create(recursive: true);
    final f = File(p.join(images.path, 'x.jpg'));
    await f.writeAsBytes([1, 2, 3]);
    await service.clearCache();
    expect(await f.exists(), isFalse);
    expect(await service.getCacheSize(), 0);
  });

  test('evictIfNeeded deletes oldest until under limit', () async {
    final images = Directory(p.join(temp.path, 'images'));
    await images.create(recursive: true);
    // 3 files × 1 byte; max 0 MB → must evict all (maxBytes = 0)
    for (var i = 0; i < 3; i++) {
      final f = File(p.join(images.path, 'f$i.bin'));
      await f.writeAsBytes([i]);
      // Stagger mtime so sort is deterministic
      await Future<void>.delayed(const Duration(milliseconds: 15));
    }
    await service.evictIfNeeded(maxSizeMB: 0);
    expect(await service.getCacheSize(), 0);
  });
}
