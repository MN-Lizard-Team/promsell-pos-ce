import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/batch_generate_barcodes.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockProductRepository mockProductRepo;
  late MockSettingsRepository mockSettingsRepo;
  late Ean13Generator generator;
  late BatchGenerateBarcodes batchGenerate;

  setUpAll(() {
    registerFallbackValue(tProduct);
    registerFallbackValue(const Settings());
  });

  setUp(() {
    mockProductRepo = MockProductRepository();
    mockSettingsRepo = MockSettingsRepository();
    generator = Ean13Generator();
    when(() => mockSettingsRepo.load()).thenAnswer((_) async => tAppSettings);
    when(
      () => mockSettingsRepo.saveBarcodeLastCounter(any()),
    ).thenAnswer((_) async {});
    batchGenerate = BatchGenerateBarcodes(
      mockProductRepo,
      mockSettingsRepo,
      generator,
    );
  });

  group('BatchGenerateBarcodes', () {
    test('returns 0 when all products have barcodes', () async {
      when(
        () => mockProductRepo.getAllProducts(),
      ).thenAnswer((_) async => [tProductWithBarcode]);

      final count = await batchGenerate(prefix: '200');
      expect(count, 0);
      verifyNever(() => mockProductRepo.bulkUpdateBarcodes(any()));
    });

    test('generates barcodes for products without one', () async {
      when(
        () => mockProductRepo.getAllProducts(),
      ).thenAnswer((_) async => [tProductWithBarcode, tProduct]);
      when(
        () => mockProductRepo.barcodeExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);
      when(
        () => mockProductRepo.bulkUpdateBarcodes(any()),
      ).thenAnswer((_) async {});

      final count = await batchGenerate(prefix: '200');
      expect(count, 1);
      verify(() => mockProductRepo.bulkUpdateBarcodes(any())).called(1);
      verify(() => mockSettingsRepo.saveBarcodeLastCounter(any())).called(1);
    });

    test('includes inactive products without barcodes (policy A)', () async {
      when(
        () => mockProductRepo.getAllProducts(),
      ).thenAnswer((_) async => [tProductWithBarcode, tInactiveProduct]);
      when(
        () => mockProductRepo.barcodeExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);
      when(
        () => mockProductRepo.bulkUpdateBarcodes(any()),
      ).thenAnswer((_) async {});

      final count = await batchGenerate(prefix: '200');
      expect(count, 1);
      final captured =
          verify(
                () => mockProductRepo.bulkUpdateBarcodes(captureAny()),
              ).captured.single
              as List<({String id, String barcode})>;
      expect(captured.single.id, tInactiveProduct.id);
    });

    test('skips products when no unique barcode can be generated', () async {
      when(
        () => mockProductRepo.getAllProducts(),
      ).thenAnswer((_) async => [tProduct]);
      when(
        () => mockProductRepo.barcodeExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => true);

      final count = await batchGenerate(prefix: '200');
      expect(count, 0);
      verifyNever(() => mockProductRepo.bulkUpdateBarcodes(any()));
    });

    test('persists counter to settings after batch generation', () async {
      when(
        () => mockProductRepo.getAllProducts(),
      ).thenAnswer((_) async => [tProductWithBarcode, tProduct]);
      when(
        () => mockProductRepo.barcodeExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);
      when(
        () => mockProductRepo.bulkUpdateBarcodes(any()),
      ).thenAnswer((_) async {});

      await batchGenerate(prefix: '200');

      verify(() => mockSettingsRepo.saveBarcodeLastCounter(any())).called(1);
    });
  });
}
