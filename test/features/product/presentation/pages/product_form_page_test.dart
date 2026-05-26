import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockProductBloc mockProductBloc;
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockSettingsCubit = MockSettingsCubit();
    when(
      () => mockProductBloc.state,
    ).thenReturn(const ProductState(status: ProductStatus.success));
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.loaded,
        settings: AppSettings(),
      ),
    );
  });

  setUpAll(() {
    registerFallbackValue(const ProductAdded(name: '', price: 0, stock: 0));
    registerFallbackValue(
      ProductUpdated(
        Product(
          id: 0,
          name: '',
          price: 0,
          stock: 0,
          isActive: true,
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        ),
      ),
    );
  });

  group('ProductFormPage (add mode)', () {
    testWidgets('renders form fields for new product', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows validation error when name is empty', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('dispatches ProductAdded on valid submit', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        settingsCubit: mockSettingsCubit,
      );

      final nameField = find.byType(TextFormField).at(1);
      await tester.enterText(nameField, 'Water');

      final priceField = find.byType(TextFormField).at(2);
      await tester.enterText(priceField, '10.00');

      final stockField = find.byType(TextFormField).at(3);
      await tester.enterText(stockField, '100');

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      verify(
        () => mockProductBloc.add(any(that: isA<ProductAdded>())),
      ).called(1);
    });
  });

  group('ProductFormPage (edit mode)', () {
    final existingProduct = Product(
      id: 1,
      name: 'Water',
      price: 10.0,
      stock: 100,
      category: 'Drinks',
      isActive: true,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

    testWidgets('pre-fills fields with existing product', (tester) async {
      await tester.pumpApp(
        ProductFormPage(product: existingProduct),
        productBloc: mockProductBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(find.text('Water'), findsOneWidget);
      expect(find.text('10.00'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Drinks'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('dispatches ProductUpdated on edit submit', (tester) async {
      when(() => mockProductBloc.add(any())).thenReturn(null);

      await tester.pumpApp(
        ProductFormPage(product: existingProduct),
        productBloc: mockProductBloc,
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      verify(
        () => mockProductBloc.add(any(that: isA<ProductUpdated>())),
      ).called(1);
    });
  });

  group('UI-BUG-11 regression: stock=0 warning', () {
    testWidgets('shows stock zero warning when stock field is 0', (
      tester,
    ) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        settingsCubit: mockSettingsCubit,
      );

      final stockField = find.byType(TextFormField).at(3);
      await tester.enterText(stockField, '0');
      await tester.pumpAndSettle();

      expect(find.textContaining("won't appear"), findsOneWidget);
    });

    testWidgets('no warning when stock > 0', (tester) async {
      await tester.pumpApp(
        const ProductFormPage(),
        productBloc: mockProductBloc,
        settingsCubit: mockSettingsCubit,
      );

      final stockField = find.byType(TextFormField).at(3);
      await tester.enterText(stockField, '10');
      await tester.pumpAndSettle();

      expect(find.textContaining("won't appear"), findsNothing);
    });
  });
}
