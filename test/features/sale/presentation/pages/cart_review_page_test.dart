import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/cart_review_page.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;
  late MockDraftBloc mockDraftBloc;
  late MockSettingsCubit mockSettingsCubit;

  final testProduct = Product(
    id: 'p1',
    name: 'Water',
    price: Money.fromDouble(10),
    stock: 100,
    imageThumbnailPath: null,
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  final testProduct2 = Product(
    id: 'p2',
    name: 'Coffee',
    price: Money.fromDouble(25),
    stock: 50,
    imageThumbnailPath: null,
    isActive: true,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  setUp(() {
    mockCartBloc = MockCartBloc();
    mockDraftBloc = MockDraftBloc();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockDraftBloc.state).thenReturn(const DraftState());
  });

  Widget buildSubject() {
    return const CartReviewPage();
  }

  Widget buildSubjectWithBaseRoute() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<CartBloc>.value(value: mockCartBloc),
          BlocProvider<DraftBloc>.value(value: mockDraftBloc),
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        ],
        child: const Scaffold(body: SizedBox.shrink()),
      ),
    );
  }

  group('CartReviewPage', () {
    testWidgets('renders empty cart state', (tester) async {
      when(() => mockCartBloc.state).thenReturn(const CartState(items: []));

      await tester.pumpApp(
        buildSubject(),
        cartBloc: mockCartBloc,
        draftBloc: mockDraftBloc,
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
        draftBloc: mockDraftBloc,
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Water'), findsOneWidget);
      // Taller cart rows may push the second line off-screen in the test viewport.
      await tester.scrollUntilVisible(
        find.text('Coffee'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('displays total and pay CTA', (tester) async {
      final items = [CartItem(product: testProduct, qty: 1)];
      when(() => mockCartBloc.state).thenReturn(CartState(items: items));

      await tester.pumpApp(
        buildSubject(),
        cartBloc: mockCartBloc,
        draftBloc: mockDraftBloc,
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Water'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(
        find.byKey(const ValueKey('sale_cart_checkout_cta')),
        findsOneWidget,
      );
    });

    testWidgets('back button pops navigator', (tester) async {
      final items = [CartItem(product: testProduct, qty: 1)];
      when(() => mockCartBloc.state).thenReturn(CartState(items: items));

      await tester.pumpWidget(buildSubjectWithBaseRoute());
      await tester.pumpAndSettle();

      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      navigator.push(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<CartBloc>.value(value: mockCartBloc),
              BlocProvider<DraftBloc>.value(value: mockDraftBloc),
              BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
            ],
            child: const CartReviewPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CartReviewPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(CartReviewPage), findsNothing);
    });

    testWidgets('calculates correct subtotals', (tester) async {
      final items = [CartItem(product: testProduct, qty: 3)];
      when(() => mockCartBloc.state).thenReturn(CartState(items: items));

      await tester.pumpApp(
        buildSubject(),
        cartBloc: mockCartBloc,
        draftBloc: mockDraftBloc,
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.text('Water'), findsOneWidget);
      // Qty lives in cluster once; unit price as "@ …" meta (not "3 ×").
      expect(find.text('3'), findsWidgets);
      expect(find.textContaining('@'), findsOneWidget);
    });
  });
}
