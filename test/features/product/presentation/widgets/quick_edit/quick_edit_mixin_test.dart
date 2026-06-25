import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit/quick_edit_mixin.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

import '../../../../../helpers/mocks.dart';

class _FakeProductEvent extends Fake implements ProductEvent {}

class _TestWidget extends StatefulWidget {
  const _TestWidget({required this.product});

  final Product product;

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> with QuickEditMixin {
  @override
  Product get product => widget.product;

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

void main() {
  late MockProductBloc mockProductBloc;
  late MockSettingsCubit mockSettingsCubit;

  final tProduct = Product(
    id: 'p1',
    name: 'Coffee',
    price: 80.0,
    stock: 10,
    isActive: true,
    trackStock: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(_FakeProductEvent());
  });

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockProductBloc.state).thenReturn(
      ProductState(status: ProductStatus.success, products: [tProduct]),
    );
    when(() => mockProductBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpHost(WidgetTester tester, {Product? product}) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>.value(value: mockProductBloc),
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: _TestWidget(product: product ?? tProduct)),
        ),
      ),
    );
    await tester.pump();
  }

  /// Opens the quick-edit sheet and lets its animation finish.
  ///
  /// The action future is not awaited; the sheet is opened synchronously and
  /// callers interact with it before it closes.
  Future<void> openSheet(
    WidgetTester tester,
    Future<void> Function(_TestWidgetState, BuildContext) action,
  ) async {
    final state = tester.state<_TestWidgetState>(find.byType(_TestWidget));
    final context = tester.element(find.byType(_TestWidget));
    action(state, context);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(BottomSheet), findsOneWidget);
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(BottomSheet), findsNothing);
  }

  Future<void> tapCancel(WidgetTester tester) async {
    await tester.tap(find.byType(OutlinedButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(BottomSheet), findsNothing);
  }

  void expectDispatched({required bool expected}) {
    if (expected) {
      verify(
        () => mockProductBloc.add(any(that: isA<ProductUpdated>())),
      ).called(1);
    } else {
      verifyNever(() => mockProductBloc.add(any(that: isA<ProductUpdated>())));
    }
  }

  void expectSnackBar(WidgetTester tester, {required bool expected}) {
    if (expected) {
      expect(find.byType(SnackBar), findsOneWidget);
    } else {
      expect(find.byType(SnackBar), findsNothing);
    }
  }

  group('QuickEditMixin', () {
    group('name', () {
      testWidgets('dispatches ProductUpdated when name changes', (
        tester,
      ) async {
        await pumpHost(tester);
        await openSheet(
          tester,
          (state, context) => state.quickEditName(context),
        );

        await tester.enterText(find.byType(TextField), 'Espresso');
        await tester.pump();
        await tapSave(tester);

        expectDispatched(expected: true);
        expectSnackBar(tester, expected: true);
      });

      testWidgets('no dispatch when cancelled', (tester) async {
        await pumpHost(tester);
        await openSheet(
          tester,
          (state, context) => state.quickEditName(context),
        );

        await tapCancel(tester);

        expectDispatched(expected: false);
        expectSnackBar(tester, expected: false);
      });
    });

    group('price', () {
      testWidgets('dispatches ProductUpdated when price changes', (
        tester,
      ) async {
        await pumpHost(tester);
        await openSheet(
          tester,
          (state, context) => state.quickEditPrice(context),
        );

        await tester.enterText(find.byType(TextField), '99.00');
        await tester.pump();
        await tapSave(tester);

        expectDispatched(expected: true);
        expectSnackBar(tester, expected: true);
      });

      testWidgets('no dispatch when cancelled', (tester) async {
        await pumpHost(tester);
        await openSheet(
          tester,
          (state, context) => state.quickEditPrice(context),
        );

        await tapCancel(tester);

        expectDispatched(expected: false);
        expectSnackBar(tester, expected: false);
      });
    });

    group('stock', () {
      testWidgets('dispatches ProductUpdated when stock changes', (
        tester,
      ) async {
        await pumpHost(tester);
        await openSheet(
          tester,
          (state, context) => state.quickEditStock(context),
        );

        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pump();
        await tapSave(tester);

        expectDispatched(expected: true);
        expectSnackBar(tester, expected: true);
      });

      testWidgets('no dispatch when cancelled', (tester) async {
        await pumpHost(tester);
        await openSheet(
          tester,
          (state, context) => state.quickEditStock(context),
        );

        await tapCancel(tester);

        expectDispatched(expected: false);
        expectSnackBar(tester, expected: false);
      });

      testWidgets('stock Adjust mode — add delta dispatches ProductUpdated', (
        tester,
      ) async {
        await pumpHost(tester);
        await openSheet(
          tester,
          (state, context) => state.quickEditStock(context),
        );

        await tester.tap(find.text('Adjust'));
        await tester.pump();

        await tester.enterText(find.byType(TextField), '5');
        await tester.pump();
        await tapSave(tester);

        expectDispatched(expected: true);
        expectSnackBar(tester, expected: true);
      });

      testWidgets(
        'stock Adjust mode — subtract to negative does not dispatch',
        (tester) async {
          await pumpHost(tester, product: tProduct.copyWith(stock: 3));
          await openSheet(
            tester,
            (state, context) => state.quickEditStock(context),
          );

          await tester.tap(find.text('Adjust'));
          await tester.pump();

          await tester.tap(find.byIcon(Icons.remove).at(0));
          await tester.pump();

          await tester.enterText(find.byType(TextField), '10');
          await tester.pump();

          final saveButton = tester.widget<FilledButton>(
            find.byType(FilledButton),
          );
          expect(saveButton.onPressed, isNull);
        },
      );
    });
  });
}
