import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image_settings_labels.dart';

void main() {
  group('image_settings_labels', () {
    group('qualityLabel', () {
      test('returns Draft quality for <= 50', () {
        expect(qualityLabel(40), 'Draft quality');
        expect(qualityLabel(50), 'Draft quality');
      });

      test('returns Standard quality for 51-70', () {
        expect(qualityLabel(60), 'Standard quality');
        expect(qualityLabel(70), 'Standard quality');
      });

      test('returns High quality for 71-80', () {
        expect(qualityLabel(75), 'High quality');
        expect(qualityLabel(80), 'High quality');
      });

      test('returns Best quality for 81-90', () {
        expect(qualityLabel(85), 'Best quality');
        expect(qualityLabel(90), 'Best quality');
      });

      test('returns Original quality for > 90', () {
        expect(qualityLabel(95), 'Original quality');
        expect(qualityLabel(100), 'Original quality');
      });
    });

    group('widthLabel', () {
      test('returns Small size for <= 400', () {
        expect(widthLabel(300), 'Small size');
        expect(widthLabel(400), 'Small size');
      });

      test('returns Medium size for 401-600', () {
        expect(widthLabel(500), 'Medium size');
        expect(widthLabel(600), 'Medium size');
      });

      test('returns Large size for 601-800', () {
        expect(widthLabel(700), 'Large size');
        expect(widthLabel(800), 'Large size');
      });

      test('returns Extra large size for 801-1200', () {
        expect(widthLabel(1000), 'Extra large size');
        expect(widthLabel(1200), 'Extra large size');
      });

      test('returns Full HD size for > 1200', () {
        expect(widthLabel(1600), 'Full HD size');
      });
    });
  });
}
