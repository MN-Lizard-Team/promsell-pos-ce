import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/utils/sku_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_sku.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockProductRepository mockProductRepo;
  late MockSettingsRepository mockSettingsRepo;
  late SkuGenerator generator;
  late GenerateSku generateSku;

  setUpAll(() {
    registerFallbackValue(const Settings());
  });

  setUp(() {
    mockProductRepo = MockProductRepository();
    mockSettingsRepo = MockSettingsRepository();
    generator = SkuGenerator();
    generateSku = GenerateSku(mockProductRepo, mockSettingsRepo, generator);

    when(
      () => mockSettingsRepo.load(),
    ).thenAnswer((_) async => const Settings());
    when(
      () => mockSettingsRepo.saveSkuLastCounter(any()),
    ).thenAnswer((_) async {});
  });

  group('GenerateSku', () {
    test('returns sequential SKU when no collision', () async {
      when(
        () => mockProductRepo.skuExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);

      final sku = await generateSku();
      expect(sku, 'SKU00001');
      expect(RegExp(r'^[A-Z0-9]+$').hasMatch(sku), isTrue);
    });

    test('uses custom prefix', () async {
      when(
        () => mockProductRepo.skuExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);

      final sku = await generateSku(prefix: 'COF');
      expect(sku, startsWith('COF'));
      expect(sku.length, greaterThanOrEqualTo(8));
    });

    test('retries when collision detected', () async {
      var callCount = 0;
      when(
        () => mockProductRepo.skuExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        return callCount < 3;
      });

      final sku = await generateSku();
      expect(sku, isNotEmpty);
      expect(callCount, 3);
    });

    test('throws StateError after 10 collisions', () async {
      when(
        () => mockProductRepo.skuExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => true);

      await expectLater(() => generateSku(), throwsA(isA<StateError>()));
      verify(() => mockSettingsRepo.saveSkuLastCounter(any())).called(1);
    });

    test('persists counter after successful generation', () async {
      when(
        () => mockProductRepo.skuExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);

      await generateSku();

      verify(() => mockSettingsRepo.load()).called(1);
      verify(() => mockSettingsRepo.saveSkuLastCounter(any())).called(1);
    });

    test('forwards excludeId to skuExists', () async {
      when(
        () => mockProductRepo.skuExists(
          any(),
          excludeId: any(named: 'excludeId'),
        ),
      ).thenAnswer((_) async => false);

      await generateSku(excludeId: 'prod-1');

      verify(
        () => mockProductRepo.skuExists(any(), excludeId: 'prod-1'),
      ).called(1);
    });
  });
}
