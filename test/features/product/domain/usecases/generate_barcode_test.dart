import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockProductRepository mockProductRepo;
  late MockSettingsRepository mockSettingsRepo;
  late Ean13Generator generator;
  late GenerateBarcode generateBarcode;

  setUpAll(() {
    registerFallbackValue(const Settings());
  });

  setUp(() {
    mockProductRepo = MockProductRepository();
    mockSettingsRepo = MockSettingsRepository();
    generator = Ean13Generator();
    generateBarcode = GenerateBarcode(
      mockProductRepo,
      mockSettingsRepo,
      generator,
    );

    when(
      () => mockSettingsRepo.load(),
    ).thenAnswer((_) async => const Settings());
    when(() => mockSettingsRepo.save(any())).thenAnswer((_) async {});
  });

  group('GenerateBarcode', () {
    test('returns a 13-digit barcode when no collision', () async {
      when(
        () => mockProductRepo.barcodeExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);

      final barcode = await generateBarcode(prefix: '200');
      expect(barcode.length, 13);
      expect(RegExp(r'^[0-9]{13}$').hasMatch(barcode), isTrue);
    });

    test('retries when collision detected', () async {
      var callCount = 0;
      when(
        () => mockProductRepo.barcodeExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        return callCount < 3;
      });

      final barcode = await generateBarcode(prefix: '200');
      expect(barcode.length, 13);
      expect(callCount, 3);
    });

    test('throws StateError after 10 collisions', () async {
      when(
        () => mockProductRepo.barcodeExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => true);

      expect(() => generateBarcode(prefix: '200'), throwsA(isA<StateError>()));
    });

    test('persists counter after successful generation', () async {
      when(
        () => mockProductRepo.barcodeExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);

      await generateBarcode(prefix: '200');

      verify(() => mockSettingsRepo.load()).called(2);
      verify(() => mockSettingsRepo.save(any())).called(1);
    });
  });
}
