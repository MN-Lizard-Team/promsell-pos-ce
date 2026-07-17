// Generates Play Store feature graphic 1024x500 (run: dart run tool/generate_feature_graphic.dart)
import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const w = 1024;
  const h = 500;
  final image = img.Image(width: w, height: h);

  // Teal brand gradient (Promsell primary ~ #0E7C8A → darker)
  for (var y = 0; y < h; y++) {
    final t = y / (h - 1);
    final r = (14 + (8 - 14) * t).round();
    final g = (124 + (60 - 124) * t).round();
    final b = (138 + (90 - 138) * t).round();
    final row = img.ColorRgba8(r, g, b, 255);
    for (var x = 0; x < w; x++) {
      image.setPixel(x, y, row);
    }
  }

  // Soft accent band (orange ~ #FF6B00) at bottom
  for (var y = h - 48; y < h; y++) {
    for (var x = 0; x < w; x++) {
      image.setPixel(x, y, img.ColorRgba8(255, 107, 0, 255));
    }
  }

  // Title block (bitmap font)
  img.drawString(
    image,
    'Promsell',
    font: img.arial48,
    x: 64,
    y: 140,
    color: img.ColorRgba8(255, 255, 255, 255),
  );
  img.drawString(
    image,
    'Offline POS for small shops',
    font: img.arial24,
    x: 64,
    y: 210,
    color: img.ColorRgba8(230, 250, 252, 255),
  );
  img.drawString(
    image,
    'Sell  ·  Stock  ·  Receipts  ·  PromptPay',
    font: img.arial24,
    x: 64,
    y: 270,
    color: img.ColorRgba8(200, 240, 245, 255),
  );
  img.drawString(
    image,
    'No subscription  ·  Data stays on device  ·  AGPL-3.0',
    font: img.arial14,
    x: 64,
    y: 340,
    color: img.ColorRgba8(180, 220, 230, 255),
  );
  img.drawString(
    image,
    'Community Edition',
    font: img.arial24,
    x: 64,
    y: h - 100,
    color: img.ColorRgba8(255, 255, 255, 255),
  );

  final outDirs = [
    'fastlane/metadata/android/en-US/images',
    'fastlane/metadata/android/th/images',
  ];
  final bytes = img.encodePng(image);
  for (final dir in outDirs) {
    Directory(dir).createSync(recursive: true);
    final path = '$dir/featureGraphic.png';
    File(path).writeAsBytesSync(bytes);
    stdout.writeln('Wrote $path (${bytes.length} bytes)');
  }
}
