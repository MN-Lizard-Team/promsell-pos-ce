import 'package:flutter_test/flutter_test.dart';

// Import via relative path — tool/ is not a package lib export.
import '../../tool/check_path_coverage.dart' as cov;

void main() {
  group('normalizeSourcePath', () {
    test('forward slashes unchanged when already lib/', () {
      expect(
        cov.normalizeSourcePath('lib/features/sale/x.dart'),
        'lib/features/sale/x.dart',
      );
    });

    test('windows backslashes and absolute prefix', () {
      expect(
        cov.normalizeSourcePath(r'D:\proj\lib\features\sale\foo.dart'),
        'lib/features/sale/foo.dart',
      );
    });
  });

  group('isExcludedPath', () {
    test('generated and l10n', () {
      expect(
        cov.isExcludedPath('lib/core/database/app_database.g.dart'),
        isTrue,
      );
      expect(cov.isExcludedPath('lib/l10n/app_localizations_en.dart'), isTrue);
      expect(cov.isExcludedPath('lib/core/di/injection.config.dart'), isTrue);
    });

    test('hand-written sale source not excluded', () {
      expect(
        cov.isExcludedPath('lib/features/sale/domain/money_path.dart'),
        isFalse,
      );
    });
  });

  group('parseLcov + buildReport', () {
    test('aggregates global sale and domain with excludes', () {
      const fixture = '''
SF:lib/features/sale/domain/a.dart
LF:10
LH:8
end_of_record
SF:lib/features/sale/presentation/b.dart
LF:20
LH:5
end_of_record
SF:lib/core/domain/money.dart
LF:10
LH:10
end_of_record
SF:lib/core/database/app_database.g.dart
LF:100
LH:1
end_of_record
SF:lib/features/product/x.dart
LF:10
LH:10
end_of_record
''';
      final records = cov.parseLcov(fixture);
      final report = cov.buildReport(records);

      // excluded .g.dart → product+sale+domain = 10+20+10 = 40 found
      expect(report.global.found, 50); // 10+20+10+10 product
      expect(report.global.hit, 33); // 8+5+10+10
      expect(report.sale.found, 30);
      expect(report.sale.hit, 13);
      expect(report.coreDomain.found, 10);
      expect(report.coreDomain.hit, 10);
      // sale + domain (no double count)
      expect(report.salePlusDomain.found, 40);
      expect(report.salePlusDomain.hit, 23);
      // sale-logic = sale/domain + core/domain (presentation excluded)
      expect(report.saleLogic.found, 20);
      expect(report.saleLogic.hit, 18);
      expect(report.saleDomain.found, 10);
      expect(report.salePresentation.found, 20);
      expect(report.fileCountExcluded, 1);
      expect(report.fileCountIncluded, 4);
    });
  });
}
