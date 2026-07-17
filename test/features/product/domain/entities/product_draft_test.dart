import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_draft.dart';

void main() {
  group('ProductDraft', () {
    test('description defaults to empty string', () {
      const draft = ProductDraft();
      expect(draft.description, '');
    });

    test('isEmpty is true when all fields including description are empty', () {
      const draft = ProductDraft();
      expect(draft.isEmpty, isTrue);
    });

    test('isEmpty is false when description has content', () {
      const draft = ProductDraft(description: 'Some description');
      expect(draft.isEmpty, isFalse);
    });

    test('toJson includes description', () {
      const draft = ProductDraft(description: 'Test desc');
      final json = draft.toJson();
      expect(json['description'], 'Test desc');
    });

    test('fromJson reads description', () {
      final draft = ProductDraft.fromJson(const {
        'name': 'Test',
        'price': '10',
        'stock': '5',
        'sku': '',
        'barcode': '',
        'cost': '',
        'description': 'From JSON',
      });
      expect(draft.description, 'From JSON');
    });

    test('fromJson defaults description to empty when missing', () {
      final draft = ProductDraft.fromJson(const {
        'name': 'Test',
        'price': '10',
        'stock': '5',
        'sku': '',
        'barcode': '',
        'cost': '',
      });
      expect(draft.description, '');
    });

    test('copyWith updates description', () {
      const draft = ProductDraft();
      final updated = draft.copyWith(description: 'New desc');
      expect(updated.description, 'New desc');
    });
  });
}
