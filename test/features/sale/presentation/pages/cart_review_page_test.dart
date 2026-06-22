import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/cart_review_page.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;
  late MockSettingsCubit mockSettingsCubit;

  final testProduct = Product(
    id: 'p1',
    name: 'Water',
    price: 10.0,
    stock: 100,
    imageThumbnailPath: null,
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  final testProduct2 = Product(
    id: 'p2',
    name: 'Coffee',
    price: 25.0,
    stock: 50,
    imageThumbnailPath: null,
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockCartBloc = MockCartBloc();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
  });

  Widget buildSubject() {
    return const CartReviewPage();
  }

  group('CartReviewPage', () {
    testWidgets('renders empty cart state', (tester) async {
      when(() => mockCartBloc.state).thenReturn(const CartState(items: []));

      await tester.pumpApp(
        buildSubject(),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(CartReviewPage), findsOneWidget);
    });

    testWidgets('renders cart items with product names', (tester) async {
      final items = [
        CartItem(product: testProduct, qty: 2),
        CartItem(product: testProduct2, qty: 1),
      ];
      when(() => mockCartBloc.state).thenReturn(CartState(items: items));

      await tester.pumpApp(
        buildSubject(),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.textContaining('2 x'), findsOneWidget);
      expect(find.textContaining('1 x'), findsOneWidget);
    });

    testWidgets('displays total and back button', (tester) async {
      final items = [CartItem(product: testProduct, qty: 1)];
      when(() => mockCartBloc.state).thenReturn(CartState(items: items));

      await tester.pumpApp(
        buildSubject(),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Water'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Back to Payment'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back button pops navigator', (tester) async {
      final items = [CartItem(product: testProduct, qty: 1)];
      when(() => mockCartBloc.state).thenReturn(CartState(items: items));

      await tester.pumpApp(
        buildSubject(),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Back to Payment'));
      await tester.pumpAndSettle();

      expect(find.byType(CartReviewPage), findsNothing);
    });

    testWidgets('calculates correct subtotals', (tester) async {
      final items = [CartItem(product: testProduct, qty: 3)];
      when(() => mockCartBloc.state).thenReturn(CartState(items: items));

      await tester.pumpApp(
        buildSubject(),
        cartBloc: mockCartBloc,
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Water'), findsOneWidget);
      expect(find.textContaining('3 x'), findsOneWidget);
    });
  });
}
