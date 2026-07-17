import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockProductRepository mockProductRepo;
  late MockSettingsRepository mockSettingsRepo;
  late MockPromotionRepository mockPromotionRepo;
  late CartBloc cartBloc;

  setUp(() {
    mockProductRepo = MockProductRepository();
    mockSettingsRepo = MockSettingsRepository();
    mockPromotionRepo = MockPromotionRepository();
    cartBloc = CartBloc(
      productRepo: mockProductRepo,
      settingsRepo: mockSettingsRepo,
      promotionRepo: mockPromotionRepo,
    );
    registerFallbackValue(CartProductAdded(_dummyProduct));
  });

  tearDown(() => cartBloc.close());

  final now = DateTime(2025, 1, 1);

  Product testProduct({List<ProductOptionGroup> optionGroups = const []}) =>
      Product(
        id: 'p1',
        name: 'Coffee',
        price: Money.fromDouble(50),
        stock: 10,
        isActive: true,
        trackStock: false,
        optionGroups: optionGroups,
        createdAt: now,
        updatedAt: now,
      );

  test(
    'adding product with selectedOptions creates separate line item',
    () async {
      final product = testProduct();
      final options = [
        SelectedProductOption(
          optionId: 'opt1',
          optionName: 'Large',
          groupId: 'g1',
          groupName: 'Size',
          priceDelta: Money.fromDouble(10),
        ),
      ];

      cartBloc.add(CartProductAdded(product, selectedOptions: options));
      await expectLater(
        cartBloc.stream,
        emitsInOrder([
          predicate<CartState>(
            (s) =>
                s.items.length == 1 &&
                s.items[0].selectedOptions.length == 1 &&
                s.items[0].selectedOptions[0].optionName == 'Large',
          ),
        ]),
      );
    },
  );

  test(
    'adding same product with different options creates separate items',
    () async {
      final product = testProduct();
      final opts1 = [
        SelectedProductOption(
          optionId: 'opt1',
          optionName: 'Large',
          groupId: 'g1',
          groupName: 'Size',
          priceDelta: Money.fromDouble(10),
        ),
      ];
      final opts2 = [
        const SelectedProductOption(
          optionId: 'opt2',
          optionName: 'Small',
          groupId: 'g1',
          groupName: 'Size',
          priceDelta: Money.zero,
        ),
      ];

      cartBloc.add(CartProductAdded(product, selectedOptions: opts1));
      cartBloc.add(CartProductAdded(product, selectedOptions: opts2));

      final states = <CartState>[];
      cartBloc.stream.listen(states.add);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.last.items.length, 2);
      expect(states.last.items[0].selectedOptions[0].optionName, 'Large');
      expect(states.last.items[1].selectedOptions[0].optionName, 'Small');
    },
  );

  test(
    'adding product without options merges with existing no-option item',
    () async {
      final product = testProduct();

      cartBloc.add(CartProductAdded(product));
      cartBloc.add(CartProductAdded(product));

      final states = <CartState>[];
      cartBloc.stream.listen(states.add);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.last.items.length, 1);
      expect(states.last.items[0].qty, 2);
    },
  );

  test('selectedOptions price delta is included in subtotal', () async {
    final product = testProduct();
    final options = [
      SelectedProductOption(
        optionId: 'opt1',
        optionName: 'Large',
        groupId: 'g1',
        groupName: 'Size',
        priceDelta: Money.fromDouble(10),
      ),
    ];

    cartBloc.add(CartProductAdded(product, selectedOptions: options));
    final states = <CartState>[];
    cartBloc.stream.listen(states.add);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(states.last.items[0].rawSubtotal, Money.fromDouble(60));
    expect(states.last.items[0].subtotal, Money.fromDouble(60));
  });
}

final _dummyProduct = Product(
  id: 'fallback',
  name: '',
  price: Money.zero,
  stock: 0,
  isActive: true,
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);
