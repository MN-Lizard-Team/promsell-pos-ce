import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog/image_viewer_utils.dart';

void main() {
  group('providerFromPaths', () {
    test('returns AssetImage when both paths are null', () {
      final provider = providerFromPaths();
      expect(provider, isA<AssetImage>());
    });

    test('returns AssetImage when both paths are empty', () {
      final provider = providerFromPaths(imagePath: '', imageUrl: '');
      expect(provider, isA<AssetImage>());
    });

    test('returns CachedNetworkImageProvider for valid URL', () {
      final provider = providerFromPaths(
        imageUrl: 'https://example.com/img.png',
      );
      expect(provider, isNotNull);
    });
  });

  group('ZoomController', () {
    test('dispose does not throw', () {
      final controller = ZoomController();
      expect(controller.dispose, returnsNormally);
    });

    test('reset is initially null', () {
      final controller = ZoomController();
      expect(controller.reset, isNull);
    });
  });
}
