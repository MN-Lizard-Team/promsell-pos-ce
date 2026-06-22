// ignore_for_file: avoid_print

/// Stress test seeder for Promsell POS CE.
///
/// Seeds the local database with configurable volumes of test data
/// to verify performance under production-scale loads.
///
/// Usage:
///   dart run tool/seed_db.dart [--products N] [--sales N] [--quick]
///
/// Targets (Phase 1 R5 spec):
///   - Products: 10,000
///   - Sales: 50,000 (with ~3 items each → 150,000 sale_items)
///   - Inventory logs: ~150,000
///
/// Success criteria:
///   - Product list load: < 1s
///   - History page load: < 1s
///   - Report aggregation (30 days): < 1s
///
/// This is a CLI stub — actual DB seeding runs via integration test:
///   flutter test test/tool/seed_integration_test.dart --timeout 300s
library;

void main(List<String> arguments) {
  var productCount = 10000;
  var salesCount = 50000;
  var quick = false;

  for (var i = 0; i < arguments.length; i++) {
    final arg = arguments[i];
    if (arg == '--quick') {
      quick = true;
    } else if (arg == '--products' && i + 1 < arguments.length) {
      productCount = int.tryParse(arguments[++i]) ?? productCount;
    } else if (arg == '--sales' && i + 1 < arguments.length) {
      salesCount = int.tryParse(arguments[++i]) ?? salesCount;
    } else if (arg == '--help' || arg == '-h') {
      _printUsage();
      return;
    }
  }

  if (quick) {
    productCount = 1000;
    salesCount = 5000;
  }

  print('🌱 Promsell POS CE — Stress Seeder');
  print('   Products: $productCount');
  print('   Sales: $salesCount');
  print('   Estimated sale_items: ${salesCount * 3}');
  print('');

  print('ℹ️  This is a CLI stub. To run the actual DB-connected seeder:');
  print('   flutter test test/tool/seed_integration_test.dart --timeout 300s');
  print('');
  print('   For quick mode (1k products, 5k sales):');
  print(
    '   flutter test test/tool/seed_integration_test.dart --timeout 120s -- -q',
  );
}

void _printUsage() {
  print('Usage: dart run tool/seed_db.dart [options]');
  print('');
  print('Options:');
  print('  --products N   Number of products to seed (default: 10000)');
  print('  --sales N      Number of sales to seed (default: 50000)');
  print('  --quick        Quick mode: 1k products, 5k sales');
  print('  -h, --help     Show this help message');
}
