import 'package:flutter/material.dart';

const Map<String, IconData> categoryIconMap = <String, IconData>{
  'folder_outlined': Icons.folder_outlined,
  'restaurant_outlined': Icons.restaurant_outlined,
  'shopping_basket_outlined': Icons.shopping_basket_outlined,
  'local_drink_outlined': Icons.local_drink_outlined,
  'cake_outlined': Icons.cake_outlined,
  'local_cafe_outlined': Icons.local_cafe_outlined,
  'fastfood_outlined': Icons.fastfood_outlined,
  'local_pizza_outlined': Icons.local_pizza_outlined,
  'icecream_outlined': Icons.icecream_outlined,
  'kitchen_outlined': Icons.kitchen_outlined,
  'checkroom_outlined': Icons.checkroom_outlined,
  'smartphone_outlined': Icons.smartphone_outlined,
  'computer_outlined': Icons.computer_outlined,
  'chair_outlined': Icons.chair_outlined,
  'pets_outlined': Icons.pets_outlined,
  'sports_soccer_outlined': Icons.sports_soccer_outlined,
  'brush_outlined': Icons.brush_outlined,
  'local_hospital_outlined': Icons.local_hospital_outlined,
  'school_outlined': Icons.school_outlined,
  'build_outlined': Icons.build_outlined,
  'more_horiz_outlined': Icons.more_horiz_outlined,
};

IconData parseCategoryIcon(String? name) {
  return categoryIconMap[name] ?? Icons.folder_outlined;
}
