import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/services/free_disk_space.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('promsell/secure_screen');
  const service = FreeDiskSpaceService();

  void mockChannel(Future<Object?>? Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('FreeDiskSpaceService', () {
    test('passes through the value produced by the platform channel', () async {
      mockChannel((call) async {
        expect(call.method, 'getFreeDiskSpace');
        expect(call.arguments, {'path': '/data'});
        return 42;
      });
      expect(await service.getFreeDiskSpace('/data'), 42);
    });

    test('null channel result maps to -1 (unknown)', () async {
      mockChannel((call) async => null);
      expect(await service.getFreeDiskSpace('/data'), -1);
    });

    test('PlatformException degrades to -1', () async {
      mockChannel(
        (call) async => throw PlatformException(code: 'INVALID_ARGUMENT'),
      );
      expect(await service.getFreeDiskSpace('/bad'), -1);
    });

    test('MissingPluginException degrades to -1', () async {
      // No mock registered on desktop/web-like environments →
      // MissingPluginException from the messenger.
      expect(await service.getFreeDiskSpace('/any'), -1);
    });
  });
}
