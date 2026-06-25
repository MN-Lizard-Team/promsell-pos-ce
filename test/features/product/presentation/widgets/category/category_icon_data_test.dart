import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';

void main() {
  group('categoryIconMap', () {
    test('contains all expected category icons', () {
      expect(categoryIconMap.length, greaterThanOrEqualTo(21));
      expect(categoryIconMap['folder_outlined'], Icons.folder_outlined);
      expect(categoryIconMap['restaurant_outlined'], Icons.restaurant_outlined);
      expect(categoryIconMap['more_horiz_outlined'], Icons.more_horiz_outlined);
    });
  });

  group('parseCategoryIcon', () {
    test('returns folder icon for null', () {
      expect(parseCategoryIcon(null), Icons.folder_outlined);
    });

    test('returns folder icon for unknown name', () {
      expect(parseCategoryIcon('unknown'), Icons.folder_outlined);
    });

    test('returns correct icon for known name', () {
      expect(
        parseCategoryIcon('restaurant_outlined'),
        Icons.restaurant_outlined,
      );
    });
  });
}
