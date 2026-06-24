import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_add/add_product_draft_handler.dart';

void main() {
  group('AddProductDraftHandler', () {
    late TextEditingController nameCtrl;
    late TextEditingController priceCtrl;
    late TextEditingController stockCtrl;
    late TextEditingController skuCtrl;
    late TextEditingController barcodeCtrl;
    late TextEditingController costCtrl;
    late AddProductDraftHandler handler;

    setUp(() {
      nameCtrl = TextEditingController(text: 'Coffee');
      priceCtrl = TextEditingController(text: '50');
      stockCtrl = TextEditingController(text: '10');
      skuCtrl = TextEditingController(text: 'SKU001');
      barcodeCtrl = TextEditingController(text: '123456');
      costCtrl = TextEditingController(text: '30');
      handler = AddProductDraftHandler(
        nameCtrl: nameCtrl,
        priceCtrl: priceCtrl,
        stockCtrl: stockCtrl,
        skuCtrl: skuCtrl,
        barcodeCtrl: barcodeCtrl,
        costCtrl: costCtrl,
      );
    });

    tearDown(() {
      nameCtrl.dispose();
      priceCtrl.dispose();
      stockCtrl.dispose();
      skuCtrl.dispose();
      barcodeCtrl.dispose();
      costCtrl.dispose();
    });

    test('collectDraft returns all values', () {
      const category = Category(
        id: 'c1',
        name: 'Drinks',
        createdAt: _dummyDate,
        updatedAt: _dummyDate,
      );
      final draft = handler.collectDraft(
        selectedCategory: category,
        imagePath: '/img.png',
        imageThumbnailPath: '/thumb.png',
        trackStock: true,
      );

      expect(draft['name'], 'Coffee');
      expect(draft['price'], '50');
      expect(draft['categoryId'], 'c1');
      expect(draft['categoryName'], 'Drinks');
      expect(draft['trackStock'], true);
    });

    test('collectDraft handles null category', () {
      final draft = handler.collectDraft(
        selectedCategory: null,
        imagePath: null,
        imageThumbnailPath: null,
        trackStock: false,
      );

      expect(draft['categoryId'], isNull);
      expect(draft['trackStock'], false);
    });
  });
}

const _dummyDate = _FixedDateTime();

class _FixedDateTime implements DateTime {
  const _FixedDateTime();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
