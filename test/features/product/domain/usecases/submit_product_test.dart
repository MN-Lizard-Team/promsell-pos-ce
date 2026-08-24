import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/submit_product.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  late SubmitProductUseCase useCase;

  setUp(() {
    useCase = SubmitProductUseCase();
  });

  final tCategory = Category(
    id: 'cat-1',
    name: 'Drinks',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  group('SubmitProductUseCase', () {
    group('add (isEditing = false)', () {
      test('returns SubmitProductAdd with parsed fields', () {
        final result = useCase(
          SubmitProductInput(
            isEditing: false,
            name: '  Coffee  ',
            priceText: '120.50',
            stock: 30,
            sku: '  SKU001  ',
            barcode: '  885123  ',
            costText: '80',
            selectedCategory: tCategory,
            categoryWasChanged: true,
            imageUrl: null,
            imagePath: null,
            imageThumbnailPath: null,
            isActive: true,
            trackStock: true,
            description: '  Hot coffee  ',
            brand: '  BrandA  ',
            unit: '  cup  ',
            supplier: '  SupplierX  ',
            isRecommended: true,
            optionGroups: const [],
          ),
        );

        expect(result, isA<SubmitProductAdd>());
        final cmd = (result as SubmitProductAdd).command;
        expect(cmd.name, 'Coffee'); // trimmed
        expect(cmd.price, 120.50);
        expect(cmd.stock, 30);
        expect(cmd.sku, 'SKU001'); // trimmed
        expect(cmd.barcode, '885123');
        expect(cmd.cost, 80.0);
        expect(cmd.categoryId, 'cat-1');
        expect(cmd.isActive, isTrue);
        expect(cmd.trackStock, isTrue);
        expect(cmd.description, 'Hot coffee');
        expect(cmd.brand, 'BrandA');
        expect(cmd.unit, 'cup');
        expect(cmd.supplier, 'SupplierX');
        expect(cmd.isRecommended, isTrue);
      });

      test('returns null when price is invalid', () {
        final result = useCase(
          const SubmitProductInput(
            isEditing: false,
            name: 'Test',
            priceText: 'not-a-number',
            stock: 10,
            sku: null,
            barcode: null,
            costText: '',
            selectedCategory: null,
            categoryWasChanged: false,
            imageUrl: null,
            imagePath: null,
            imageThumbnailPath: null,
            isActive: true,
            trackStock: true,
            description: '',
            brand: '',
            unit: '',
            supplier: '',
            isRecommended: false,
            optionGroups: [],
          ),
        );

        expect(result, isNull);
      });

      test('normalizes empty category id to null', () {
        final result = useCase(
          SubmitProductInput(
            isEditing: false,
            name: 'Test',
            priceText: '50',
            stock: 5,
            sku: null,
            barcode: null,
            costText: '',
            selectedCategory: Category(
              id: '',
              name: 'None',
              createdAt: DateTime(2025, 1, 1),
              updatedAt: DateTime(2025, 1, 1),
            ),
            categoryWasChanged: true,
            imageUrl: null,
            imagePath: null,
            imageThumbnailPath: null,
            isActive: true,
            trackStock: true,
            description: '',
            brand: '',
            unit: '',
            supplier: '',
            isRecommended: false,
            optionGroups: const [],
          ),
        );

        expect(result, isA<SubmitProductAdd>());
        final cmd = (result as SubmitProductAdd).command;
        expect(cmd.categoryId, isNull);
      });

      test('trims empty strings to null for optional fields', () {
        final result = useCase(
          const SubmitProductInput(
            isEditing: false,
            name: 'Test',
            priceText: '10',
            stock: 0,
            sku: '   ',
            barcode: '   ',
            costText: '',
            selectedCategory: null,
            categoryWasChanged: false,
            imageUrl: null,
            imagePath: null,
            imageThumbnailPath: null,
            isActive: true,
            trackStock: false,
            description: '   ',
            brand: '   ',
            unit: '   ',
            supplier: '   ',
            isRecommended: false,
            optionGroups: [],
          ),
        );

        final cmd = (result as SubmitProductAdd).command;
        expect(cmd.sku, isNull);
        expect(cmd.barcode, isNull);
        expect(cmd.cost, isNull);
        expect(cmd.description, isNull);
        expect(cmd.brand, isNull);
        expect(cmd.unit, isNull);
        expect(cmd.supplier, isNull);
      });

      test('passes option groups through', () {
        final groups = [
          const ProductOptionGroup(id: 'g1', productId: 'p1', name: 'Size'),
        ];
        final result = useCase(
          SubmitProductInput(
            isEditing: false,
            name: 'Test',
            priceText: '10',
            stock: 0,
            sku: null,
            barcode: null,
            costText: '',
            selectedCategory: null,
            categoryWasChanged: false,
            imageUrl: null,
            imagePath: null,
            imageThumbnailPath: null,
            isActive: true,
            trackStock: true,
            description: '',
            brand: '',
            unit: '',
            supplier: '',
            isRecommended: false,
            optionGroups: groups,
          ),
        );

        final cmd = (result as SubmitProductAdd).command;
        expect(cmd.optionGroups, groups);
      });
    });

    group('edit (isEditing = true)', () {
      test('returns SubmitProductUpdate with updated fields', () {
        final result = useCase(
          SubmitProductInput(
            isEditing: true,
            name: '  Updated Name  ',
            priceText: '200',
            stock: 999, // should be ignored — stock stays from base
            sku: '  NEW-SKU  ',
            barcode: null,
            costText: '150',
            selectedCategory: Category(
              id: 'cat-2',
              name: 'Food',
              createdAt: DateTime(2025, 1, 1),
              updatedAt: DateTime(2025, 1, 1),
            ),
            categoryWasChanged: true,
            imageUrl: null,
            imagePath: null,
            imageThumbnailPath: null,
            isActive: false,
            trackStock: false,
            description: '  Updated desc  ',
            brand: '  BrandB  ',
            unit: '  bottle  ',
            supplier: '  SupplierY  ',
            isRecommended: true,
            optionGroups: const [],
            latestProduct: tProduct,
          ),
        );

        expect(result, isA<SubmitProductUpdate>());
        final update = result as SubmitProductUpdate;
        expect(update.product.name, 'Updated Name');
        expect(update.product.price, Money.fromDouble(200));
        expect(update.product.stock, tProduct.stock); // preserved from base
        expect(update.product.sku, 'NEW-SKU');
        expect(update.product.cost, Money.fromDouble(150));
        expect(update.product.categoryId, 'cat-2');
        expect(update.product.isActive, isFalse);
        expect(update.product.trackStock, isFalse);
        expect(update.product.description, 'Updated desc');
        expect(update.product.brand, 'BrandB');
        expect(update.product.unit, 'bottle');
        expect(update.product.supplier, 'SupplierY');
        expect(update.product.isRecommended, isTrue);
      });

      test(
        'preserves base stock (V092-C.1: form must not overwrite stock)',
        () {
          final result = useCase(
            SubmitProductInput(
              isEditing: true,
              name: 'Test',
              priceText: '100',
              stock: 0, // form says 0, but base has 50
              sku: null,
              barcode: null,
              costText: '',
              selectedCategory: null,
              categoryWasChanged: false,
              imageUrl: null,
              imagePath: null,
              imageThumbnailPath: null,
              isActive: true,
              trackStock: true,
              description: '',
              brand: '',
              unit: '',
              supplier: '',
              isRecommended: false,
              optionGroups: const [],
              latestProduct: tProduct, // stock = 50
            ),
          );

          final update = result as SubmitProductUpdate;
          expect(update.product.stock, 50); // NOT 0
        },
      );

      test('clears categoryId when user selects "none" (empty id)', () {
        final result = useCase(
          SubmitProductInput(
            isEditing: true,
            name: 'Test',
            priceText: '100',
            stock: 10,
            sku: null,
            barcode: null,
            costText: '',
            selectedCategory: Category(
              id: '',
              name: 'None',
              createdAt: DateTime(2025, 1, 1),
              updatedAt: DateTime(2025, 1, 1),
            ),
            categoryWasChanged: true,
            imageUrl: null,
            imagePath: null,
            imageThumbnailPath: null,
            isActive: true,
            trackStock: true,
            description: '',
            brand: '',
            unit: '',
            supplier: '',
            isRecommended: false,
            optionGroups: const [],
            latestProduct: tProduct, // categoryId = 'Drinks'
          ),
        );

        final update = result as SubmitProductUpdate;
        expect(update.product.categoryId, isNull);
      });

      test('preserves categoryId when categoryWasChanged is false', () {
        final result = useCase(
          SubmitProductInput(
            isEditing: true,
            name: 'Test',
            priceText: '100',
            stock: 10,
            sku: null,
            barcode: null,
            costText: '',
            selectedCategory: Category(
              id: 'cat-99',
              name: 'Other',
              createdAt: DateTime(2025, 1, 1),
              updatedAt: DateTime(2025, 1, 1),
            ),
            categoryWasChanged: false, // user did not change category
            imageUrl: null,
            imagePath: null,
            imageThumbnailPath: null,
            isActive: true,
            trackStock: true,
            description: '',
            brand: '',
            unit: '',
            supplier: '',
            isRecommended: false,
            optionGroups: const [],
            latestProduct: tProduct, // categoryId = 'Drinks'
          ),
        );

        final update = result as SubmitProductUpdate;
        expect(update.product.categoryId, 'Drinks'); // preserved
      });

      test('uses existingProduct when latestProduct is null', () {
        final result = useCase(
          SubmitProductInput(
            isEditing: true,
            name: 'Test',
            priceText: '100',
            stock: 10,
            sku: null,
            barcode: null,
            costText: '',
            selectedCategory: null,
            categoryWasChanged: false,
            imageUrl: null,
            imagePath: null,
            imageThumbnailPath: null,
            isActive: true,
            trackStock: true,
            description: '',
            brand: '',
            unit: '',
            supplier: '',
            isRecommended: false,
            optionGroups: const [],
            existingProduct: tProduct2,
            latestProduct: null,
          ),
        );

        expect(result, isA<SubmitProductUpdate>());
        final update = result as SubmitProductUpdate;
        expect(update.product.id, tProduct2.id);
      });

      test('preserves image paths even when null (no silent destruction)', () {
        final result = useCase(
          SubmitProductInput(
            isEditing: true,
            name: 'Test',
            priceText: '100',
            stock: 10,
            sku: null,
            barcode: null,
            costText: '',
            selectedCategory: null,
            categoryWasChanged: false,
            imageUrl: 'http://example.com/img.jpg',
            imagePath: '/data/images/p1.jpg',
            imageThumbnailPath: '/data/images/p1_thumb.jpg',
            isActive: true,
            trackStock: true,
            description: '',
            brand: '',
            unit: '',
            supplier: '',
            isRecommended: false,
            optionGroups: const [],
            latestProduct: tProduct,
          ),
        );

        final update = result as SubmitProductUpdate;
        expect(update.product.imageUrl, 'http://example.com/img.jpg');
        expect(update.product.imagePath, '/data/images/p1.jpg');
        expect(update.product.imageThumbnailPath, '/data/images/p1_thumb.jpg');
      });
    });
  });
}
