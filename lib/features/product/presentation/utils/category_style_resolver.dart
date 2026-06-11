import 'package:flutter/material.dart';

class CategoryStyle {
  const CategoryStyle({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

class CategoryStyleResolver {
  static CategoryStyle resolve(String name) {
    final lower = name.toLowerCase();

    for (final entry in _entries) {
      for (final keyword in entry.keywords) {
        if (lower.contains(keyword.toLowerCase())) {
          return CategoryStyle(icon: entry.icon, color: entry.color);
        }
      }
    }

    return const CategoryStyle(icon: Icons.folder, color: Colors.transparent);
  }
}

class _Entry {
  const _Entry({
    required this.keywords,
    required this.icon,
    required this.color,
  });

  final List<String> keywords;
  final IconData icon;
  final Color color;
}

const _entries = <_Entry>[
  _Entry(
    keywords: [
      // English
      'drink', 'coffee', 'tea', 'beverage',
      // Thai
      'เครื่องดื่ม', 'กาแฟ', 'ชา', 'น้ำ',
    ],
    icon: Icons.local_cafe,
    color: Colors.brown,
  ),
  _Entry(
    keywords: [
      // English
      'food', 'meal', 'rice', 'dish',
      // Thai
      'อาหาร', 'ข้าว', 'จาน',
    ],
    icon: Icons.restaurant,
    color: Colors.orange,
  ),
  _Entry(
    keywords: [
      // English
      'dessert', 'cake', 'sweet', 'pastry',
      // Thai
      'ขนม', 'เค้ก', 'หวาน', 'ขนมหวาน',
    ],
    icon: Icons.cake,
    color: Colors.pink,
  ),
  _Entry(
    keywords: [
      // English
      'snack', 'chip', 'cracker',
      // Thai
      'ขนมขบเคี้ยว', 'แครกเกอร์',
    ],
    icon: Icons.fastfood,
    color: Colors.amber,
  ),
  _Entry(
    keywords: [
      // English
      'fruit', 'vegetable', 'salad',
      // Thai
      'ผัก', 'ผลไม้', 'สลัด',
    ],
    icon: Icons.spa,
    color: Colors.green,
  ),
  _Entry(
    keywords: [
      // English
      'bread', 'bakery', 'toast',
      // Thai
      'ขนมปัง', 'เบเกอรี่', 'ปัง',
    ],
    icon: Icons.bakery_dining,
    color: Colors.deepOrange,
  ),
  _Entry(
    keywords: [
      // English
      'alcohol', 'beer', 'wine', 'liquor',
      // Thai
      'เหล้า', 'เบียร์', 'ไวน์', 'แอลกอฮอล์',
    ],
    icon: Icons.local_bar,
    color: Colors.purple,
  ),
  _Entry(
    keywords: [
      // English
      'ice', 'frozen', 'cold',
      // Thai
      'น้ำแข็ง', 'แช่แข็ง', 'เย็น',
    ],
    icon: Icons.ac_unit,
    color: Colors.cyan,
  ),
];
