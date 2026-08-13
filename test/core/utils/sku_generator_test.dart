import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/utils/sku_generator.dart';

void main() {
  late SkuGenerator generator;

  setUp(() {
    generator = SkuGenerator();
  });

  group('SkuGenerator', () {
    test('generates default SKU00001 from counter 0', () {
      generator.initCounter(0);
      expect(generator.generate(), 'SKU00001');
      expect(generator.currentCounter, 1);
    });

    test('uses default prefix when null or empty', () {
      generator.initCounter(0);
      expect(generator.generate(prefix: null), startsWith('SKU'));
      expect(generator.generate(prefix: ''), startsWith('SKU'));
      expect(generator.generate(prefix: '   '), startsWith('SKU'));
    });

    test('applies custom prefix uppercased', () {
      generator.initCounter(7);
      expect(generator.generate(prefix: 'cof'), 'COF00008');
    });

    test('strips non-alphanumeric from prefix', () {
      generator.initCounter(0);
      expect(generator.generate(prefix: 'ab-12!'), 'AB1200001');
    });

    test('falls back to SKU when prefix is only symbols', () {
      generator.initCounter(0);
      expect(generator.generate(prefix: '---'), 'SKU00001');
    });

    test('truncates long prefix to 8 chars', () {
      generator.initCounter(0);
      final sku = generator.generate(prefix: 'TOOLONGPREFIX');
      expect(sku.startsWith('TOOLONGP'), isTrue);
      expect(sku.length, 8 + 5);
    });

    test('pads sequence to 5 digits', () {
      generator.initCounter(41);
      expect(generator.generate(), 'SKU00042');
    });

    test('throws StateError when counter overflows at 100000', () {
      generator.initCounter(99999);
      expect(() => generator.generate(), throwsStateError);
    });

    test('initCounter wraps large values', () {
      generator.initCounter(100001);
      expect(generator.currentCounter, 1);
    });

    test('generates unique SKUs in succession', () {
      generator.initCounter(0);
      final skus = <String>{};
      for (var i = 0; i < 100; i++) {
        skus.add(generator.generate());
      }
      expect(skus.length, 100);
    });

    test('normalizePrefix is stable', () {
      expect(SkuGenerator.normalizePrefix(null), 'SKU');
      expect(SkuGenerator.normalizePrefix('p1'), 'P1');
      expect(SkuGenerator.normalizePrefix('x-y'), 'XY');
    });
  });
}
