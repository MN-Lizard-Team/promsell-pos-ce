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
    when(() => mockSettingsRepo.save(any())).thenAnswer((_) async {});
    batchGenerate = BatchGenerateBarcodes(
      mockProductRepo,
      mockSettingsRepo,
      generator,
    );
  });

  group('BatchGenerateBarcodes', () {
    test('returns 0 when all products have barcodes', () async {
      when(
        () => mockProductRepo.getActiveProducts(),
      ).thenAnswer((_) async => [tProductWithBarcode]);

      final count = await batchGenerate(prefix: '200');
      expect(count, 0);
      verifyNever(() => mockProductRepo.bulkUpdateBarcodes(any()));
    });

    test('generates barcodes for products without one', () async {
      when(
        () => mockProductRepo.getActiveProducts(),
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
      verify(() => mockSettingsRepo.save(any())).called(1);
    });

    test('skips products when no unique barcode can be generated', () async {
      when(
        () => mockProductRepo.getActiveProducts(),
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

    test(
      'persists counter to settings after batch generation (Issue 2+3)',
      () async {
        when(
          () => mockProductRepo.getActiveProducts(),
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

        verify(() => mockSettingsRepo.save(any())).called(1);
      },
    );

    test('does not persist counter when no barcodes generated', () async {
      when(
        () => mockProductRepo.getActiveProducts(),
      ).thenAnswer((_) async => [tProductWithBarcode]);

      await batchGenerate(prefix: '200');

      verifyNever(() => mockSettingsRepo.save(any()));
    });
  });
}
