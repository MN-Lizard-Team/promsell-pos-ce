import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;
  late MockDraftBloc mockDraftBloc;
  late MockSettingsCubit mockSettingsCubit;
  late MockDraftCartRepository mockDraftRepo;

  setUp(() async {
    await GetIt.I.reset();
    mockCartBloc = MockCartBloc();
    mockDraftBloc = MockDraftBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockDraftRepo = MockDraftCartRepository();

    when(() => mockCartBloc.state).thenReturn(const CartState());
    when(
      () => mockDraftBloc.state,
    ).thenReturn(const DraftState(activeDraftId: 'd1', draftCount: 1));
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);

    GetIt.I.registerSingleton<DraftCartRepository>(mockDraftRepo);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('shows app bar title and empty state', (tester) async {
    await tester.pumpApp(
      const SavedBillsPage(),
      cartBloc: mockCartBloc,
      draftBloc: mockDraftBloc,
      settingsCubit: mockSettingsCubit,
    );
    await tester.pumpAndSettle();

    expect(find.text('Open bills'), findsWidgets);
    expect(find.text('No saved bills yet'), findsOneWidget);
  });

  testWidgets('lists draft tiles when repo returns drafts', (tester) async {
    final product = Product(
      id: 'p1',
      name: 'Coffee',
      price: Money.fromDouble(50),
      stock: 10,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    when(() => mockDraftRepo.listDrafts()).thenAnswer(
      (_) async => [
        DraftCart(
          id: 'd1',
          name: 'Table 3',
          items: [CartItem(product: product, qty: 1)],
          updatedAt: DateTime(2026, 7, 1),
        ),
        DraftCart(
          id: 'd2',
          name: 'Walk-in',
          items: [CartItem(product: product, qty: 2)],
          updatedAt: DateTime(2026, 7, 2),
        ),
      ],
    );
    when(
      () => mockDraftBloc.state,
    ).thenReturn(const DraftState(activeDraftId: 'd1', draftCount: 2));

    await tester.pumpApp(
      const SavedBillsPage(),
      cartBloc: mockCartBloc,
      draftBloc: mockDraftBloc,
      settingsCubit: mockSettingsCubit,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Table 3'), findsOneWidget);
    expect(find.textContaining('Walk-in'), findsOneWidget);
  });
}
