import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockCreateSale mockCreateSale;
  late MockDraftCartRepository mockDraftRepo;
  late MockSettingsRepository mockSettingsRepo;
  late MockProductRepository mockProductRepo;

  setUp(() {
    mockCreateSale = MockCreateSale();
    mockDraftRepo = MockDraftCartRepository();
    mockSettingsRepo = MockSettingsRepository();
    mockProductRepo = MockProductRepository();
    when(
      () => mockDraftRepo.createDraft(name: any(named: 'name')),
    ).thenAnswer((_) async => 'draft-id-1');
    when(
      () => mockDraftRepo.createDraft(),
    ).thenAnswer((_) async => 'draft-id-1');
    when(
      () => mockDraftRepo.saveDraft(any(), any(), name: any(named: 'name')),
    ).thenAnswer((_) async {});
    when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
    when(() => mockDraftRepo.deleteDraft(any())).thenAnswer((_) async {});
    when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 0);
    when(
      () => mockDraftRepo.archiveOldDrafts(any()),
    ).thenAnswer((_) async => 0);
    when(
      () => mockSettingsRepo.load(),
    ).thenAnswer((_) async => const Settings());
  });

  setUpAll(() {
    registerFallbackValue(<CartItem>[]);
    registerFallbackValue(const SaleState());
  });

  SaleBloc buildBloc() => SaleBloc(
    createSale: mockCreateSale,
    draftRepo: mockDraftRepo,
    settingsRepo: mockSettingsRepo,
    productRepo: mockProductRepo,
  );

  group('SaleBloc — barcode scan', () {
    blocTest<SaleBloc, SaleState>(
      'SaleBarcodeScanned adds product to cart when found',
      setUp: () {
        when(
          () => mockProductRepo.getProductByBarcode('123'),
        ).thenAnswer((_) async => tProductWithBarcode);
      },
      build: buildBloc,
      act: (b) => b.add(const SaleBarcodeScanned('123')),
      wait: const Duration(milliseconds: 50),
      expect: () => [
        SaleState(
          items: [CartItem(product: tProductWithBarcode, qty: 1)],
          status: SaleStatus.idle,
        ),
      ],
    );

    blocTest<SaleBloc, SaleState>(
      'SaleBarcodeScanned emits barcodeNotFound error when not found',
      setUp: () {
        when(
          () => mockProductRepo.getProductByBarcode('999'),
        ).thenAnswer((_) async => null);
      },
      build: buildBloc,
      act: (b) => b.add(const SaleBarcodeScanned('999')),
      expect: () => [
        const SaleState(
          status: SaleStatus.idle,
          errorMessage: 'barcodeNotFound',
        ),
      ],
    );
  });
}
