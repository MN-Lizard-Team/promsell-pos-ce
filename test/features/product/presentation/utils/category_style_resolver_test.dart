import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/category_style_resolver.dart';

void main() {
  group('CategoryStyleResolver', () {
    test('returns cafe icon for drink keywords', () {
      final style = CategoryStyleResolver.resolve('Coffee');
      expect(style.icon, Icons.local_cafe);
      expect(style.color, Colors.brown);
    });

    test('returns restaurant icon for food keywords', () {
      final style = CategoryStyleResolver.resolve('Food');
      expect(style.icon, Icons.restaurant);
      expect(style.color, Colors.orange);
    });

    test('returns cake icon for dessert keywords', () {
      final style = CategoryStyleResolver.resolve('Dessert');
      expect(style.icon, Icons.cake);
      expect(style.color, Colors.pink);
    });

    test('returns fastfood icon for snack keywords', () {
      final style = CategoryStyleResolver.resolve('Snack');
      expect(style.icon, Icons.fastfood);
      expect(style.color, Colors.amber);
    });

    test('returns spa icon for fruit keywords', () {
      final style = CategoryStyleResolver.resolve('Fruit');
      expect(style.icon, Icons.spa);
      expect(style.color, Colors.green);
    });

    test('returns bakery icon for bread keywords', () {
      final style = CategoryStyleResolver.resolve('Bakery');
      expect(style.icon, Icons.bakery_dining);
      expect(style.color, Colors.deepOrange);
    });

    test('returns bar icon for alcohol keywords', () {
      final style = CategoryStyleResolver.resolve('Beer');
      expect(style.icon, Icons.local_bar);
      expect(style.color, Colors.purple);
    });

    test('returns ac_unit icon for ice keywords', () {
      final style = CategoryStyleResolver.resolve('Ice Cream');
      expect(style.icon, Icons.ac_unit);
      expect(style.color, Colors.cyan);
    });

    test('returns default folder icon for unknown', () {
      final style = CategoryStyleResolver.resolve('Misc');
      expect(style.icon, Icons.folder);
      expect(style.color, Colors.transparent);
    });

    test('matches Thai keywords', () {
      final style = CategoryStyleResolver.resolve('เครื่องดื่ม');
      expect(style.icon, Icons.local_cafe);
    });

    test('matches case-insensitively', () {
      final style = CategoryStyleResolver.resolve('COFFEE SHOP');
      expect(style.icon, Icons.local_cafe);
    });
  });
}
