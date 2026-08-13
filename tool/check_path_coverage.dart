/// Parses `coverage/lcov.info` and reports line coverage after CI excludes.
///
/// **Exclude list must stay in sync with** `.github/workflows/ci.yml`
/// (`very_good_coverage` `exclude:`).
///
/// Usage:
/// ```bash
/// flutter test --coverage --exclude-tags stress
/// dart run tool/check_path_coverage.dart
/// dart run tool/check_path_coverage.dart --lcov coverage/lcov.info --fail \
///   --min-global=60 --min-sale-logic=80
/// ```
///
/// Buckets:
/// - **sale+domain**: `lib/features/sale/**` + `lib/core/domain/**` (full tree)
/// - **sale-logic**: sale `domain/` + sale `data/` + `lib/core/domain/**`
///   (money path without presentation chrome)
///
/// Exit codes:
/// - 0: report printed; thresholds met (or `--fail` not set / mins are 0)
/// - 1: missing lcov, parse error, or threshold failed with `--fail`
library;

import 'dart:io';

/// Mirrors CI `very_good_coverage` exclude globs (path suffixes / extensions).
const kCoverageExcludeExact = <String>[
  'lib/l10n/app_localizations.dart',
  'lib/l10n/app_localizations_en.dart',
  'lib/l10n/app_localizations_th.dart',
  'lib/core/di/injection.config.dart',
];

const kCoverageExcludeSuffixes = <String>[
  '.g.dart',
  '.gr.dart',
  '.freezed.dart',
];

const kSalePrefix = 'lib/features/sale/';
const kDomainPrefix = 'lib/core/domain/';

void main(List<String> args) {
  final opts = _parseArgs(args);
  final file = File(opts.lcovPath);
  if (!file.existsSync()) {
    stderr.writeln(
      'Error: ${opts.lcovPath} not found. '
      'Run `flutter test --coverage --exclude-tags stress` first.',
    );
    exit(1);
  }

  final records = parseLcov(file.readAsStringSync());
  final report = buildReport(records);

  _printReport(report, opts);

  if (!opts.fail) {
    exit(0);
  }

  final failures = <String>[];
  if (opts.minGlobal > 0 && report.global.pct < opts.minGlobal) {
    failures.add(
      'global ${report.global.pct.toStringAsFixed(2)}% '
      '< min ${opts.minGlobal}%',
    );
  }
  if (opts.minSaleDomain > 0 &&
      report.salePlusDomain.pct < opts.minSaleDomain) {
    failures.add(
      'sale+domain ${report.salePlusDomain.pct.toStringAsFixed(2)}% '
      '< min ${opts.minSaleDomain}%',
    );
  }
  if (opts.minSaleLogic > 0 && report.saleLogic.pct < opts.minSaleLogic) {
    failures.add(
      'sale-logic ${report.saleLogic.pct.toStringAsFixed(2)}% '
      '< min ${opts.minSaleLogic}%',
    );
  }
  if (opts.minSale > 0 && report.sale.pct < opts.minSale) {
    failures.add(
      'sale ${report.sale.pct.toStringAsFixed(2)}% < min ${opts.minSale}%',
    );
  }
  if (opts.minDomain > 0 && report.coreDomain.pct < opts.minDomain) {
    failures.add(
      'core/domain ${report.coreDomain.pct.toStringAsFixed(2)}% '
      '< min ${opts.minDomain}%',
    );
  }

  if (failures.isEmpty) {
    stdout.writeln('✅ Coverage thresholds met.');
    exit(0);
  }

  stderr.writeln('⚠️  Coverage thresholds failed:');
  for (final f in failures) {
    stderr.writeln('  - $f');
  }
  exit(1);
}

class _Opts {
  _Opts({
    required this.lcovPath,
    required this.fail,
    required this.minGlobal,
    required this.minSaleDomain,
    required this.minSaleLogic,
    required this.minSale,
    required this.minDomain,
  });

  final String lcovPath;
  final bool fail;
  final double minGlobal;
  final double minSaleDomain;
  final double minSaleLogic;
  final double minSale;
  final double minDomain;
}

_Opts _parseArgs(List<String> args) {
  var lcovPath = 'coverage/lcov.info';
  var fail = false;
  var minGlobal = 0.0;
  var minSaleDomain = 0.0;
  var minSaleLogic = 0.0;
  var minSale = 0.0;
  var minDomain = 0.0;

  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--fail') {
      fail = true;
    } else if (a == '--lcov' && i + 1 < args.length) {
      lcovPath = args[++i];
    } else if (a.startsWith('--lcov=')) {
      lcovPath = a.substring('--lcov='.length);
    } else if (a == '--min-global' && i + 1 < args.length) {
      minGlobal = double.parse(args[++i]);
    } else if (a.startsWith('--min-global=')) {
      minGlobal = double.parse(a.substring('--min-global='.length));
    } else if (a == '--min-sale-domain' && i + 1 < args.length) {
      minSaleDomain = double.parse(args[++i]);
    } else if (a.startsWith('--min-sale-domain=')) {
      minSaleDomain = double.parse(a.substring('--min-sale-domain='.length));
    } else if (a == '--min-sale-logic' && i + 1 < args.length) {
      minSaleLogic = double.parse(args[++i]);
    } else if (a.startsWith('--min-sale-logic=')) {
      minSaleLogic = double.parse(a.substring('--min-sale-logic='.length));
    } else if (a == '--min-sale' && i + 1 < args.length) {
      minSale = double.parse(args[++i]);
    } else if (a.startsWith('--min-sale=')) {
      minSale = double.parse(a.substring('--min-sale='.length));
    } else if (a == '--min-domain' && i + 1 < args.length) {
      minDomain = double.parse(args[++i]);
    } else if (a.startsWith('--min-domain=')) {
      minDomain = double.parse(a.substring('--min-domain='.length));
    } else if (a == '--help' || a == '-h') {
      stdout.writeln(
        'Usage: dart run tool/check_path_coverage.dart '
        '[--lcov path] [--fail] '
        '[--min-global=N] [--min-sale-domain=N] [--min-sale-logic=N] '
        '[--min-sale=N] [--min-domain=N]',
      );
      exit(0);
    } else {
      stderr.writeln('Unknown argument: $a');
      exit(1);
    }
  }

  return _Opts(
    lcovPath: lcovPath,
    fail: fail,
    minGlobal: minGlobal,
    minSaleDomain: minSaleDomain,
    minSaleLogic: minSaleLogic,
    minSale: minSale,
    minDomain: minDomain,
  );
}

class LcovFileRecord {
  LcovFileRecord({required this.path, required this.found, required this.hit});

  final String path;
  final int found;
  final int hit;
}

class CoverageBucket {
  CoverageBucket({required this.found, required this.hit});

  final int found;
  final int hit;

  double get pct => found == 0 ? 100.0 : (100.0 * hit / found);
}

class CoverageReport {
  CoverageReport({
    required this.global,
    required this.sale,
    required this.coreDomain,
    required this.salePlusDomain,
    required this.saleLogic,
    required this.saleDomain,
    required this.saleData,
    required this.salePresentation,
    required this.fileCountIncluded,
    required this.fileCountExcluded,
  });

  final CoverageBucket global;
  final CoverageBucket sale;
  final CoverageBucket coreDomain;
  final CoverageBucket salePlusDomain;

  /// sale domain + sale data + core/domain (money path without presentation).
  final CoverageBucket saleLogic;
  final CoverageBucket saleDomain;
  final CoverageBucket saleData;
  final CoverageBucket salePresentation;
  final int fileCountIncluded;
  final int fileCountExcluded;
}

/// Normalize SF path: backslashes → `/`, strip to `lib/...` when present.
String normalizeSourcePath(String sf) {
  var n = sf.replaceAll(r'\', '/');
  final idx = n.indexOf('lib/');
  if (idx >= 0) {
    n = n.substring(idx);
  }
  return n;
}

bool isExcludedPath(String normalized) {
  for (final suffix in kCoverageExcludeSuffixes) {
    if (normalized.endsWith(suffix)) return true;
  }
  for (final exact in kCoverageExcludeExact) {
    if (normalized == exact || normalized.endsWith('/$exact')) return true;
  }
  // injection.config.dart anywhere under lib/
  if (normalized.endsWith('injection.config.dart')) return true;
  return false;
}

List<LcovFileRecord> parseLcov(String contents) {
  final out = <LcovFileRecord>[];
  String? sf;
  var lf = 0;
  var lh = 0;

  for (final raw in contents.split('\n')) {
    final line = raw.trim();
    if (line.startsWith('SF:')) {
      sf = line.substring(3);
      lf = 0;
      lh = 0;
    } else if (line.startsWith('LF:')) {
      lf = int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      lh = int.parse(line.substring(3));
    } else if (line == 'end_of_record' && sf != null) {
      out.add(
        LcovFileRecord(path: normalizeSourcePath(sf), found: lf, hit: lh),
      );
      sf = null;
    }
  }
  return out;
}

CoverageReport buildReport(List<LcovFileRecord> records) {
  var gF = 0, gH = 0;
  var sF = 0, sH = 0;
  var dF = 0, dH = 0;
  var sdF = 0, sdH = 0;
  var logicF = 0, logicH = 0;
  var domF = 0, domH = 0;
  var dataF = 0, dataH = 0;
  var presF = 0, presH = 0;
  var included = 0;
  var excluded = 0;

  for (final r in records) {
    if (isExcludedPath(r.path)) {
      excluded++;
      continue;
    }
    included++;
    gF += r.found;
    gH += r.hit;

    final inSale = r.path.startsWith(kSalePrefix);
    final inDomain = r.path.startsWith(kDomainPrefix);

    if (inDomain) {
      logicF += r.found;
      logicH += r.hit;
    }

    if (inSale) {
      sF += r.found;
      sH += r.hit;
      sdF += r.found;
      sdH += r.hit;
      if (r.path.contains('/domain/')) {
        domF += r.found;
        domH += r.hit;
        logicF += r.found;
        logicH += r.hit;
      }
      if (r.path.contains('/data/')) {
        dataF += r.found;
        dataH += r.hit;
        logicF += r.found;
        logicH += r.hit;
      }
      if (r.path.contains('/presentation/')) {
        presF += r.found;
        presH += r.hit;
      }
    }
    if (inDomain) {
      dF += r.found;
      dH += r.hit;
      if (!inSale) {
        sdF += r.found;
        sdH += r.hit;
      }
    }
  }

  return CoverageReport(
    global: CoverageBucket(found: gF, hit: gH),
    sale: CoverageBucket(found: sF, hit: sH),
    coreDomain: CoverageBucket(found: dF, hit: dH),
    salePlusDomain: CoverageBucket(found: sdF, hit: sdH),
    saleLogic: CoverageBucket(found: logicF, hit: logicH),
    saleDomain: CoverageBucket(found: domF, hit: domH),
    saleData: CoverageBucket(found: dataF, hit: dataH),
    salePresentation: CoverageBucket(found: presF, hit: presH),
    fileCountIncluded: included,
    fileCountExcluded: excluded,
  );
}

void _printReport(CoverageReport r, _Opts opts) {
  String row(String name, CoverageBucket b) {
    final pct = b.found == 0 ? 'n/a' : '${b.pct.toStringAsFixed(2)}%';
    return '  ${name.padRight(22)} ${b.hit.toString().padLeft(6)}/'
        '${b.found.toString().padLeft(6)}  $pct';
  }

  stdout.writeln('Coverage path report (CI excludes applied)');
  stdout.writeln(
    '  files included=${r.fileCountIncluded} excluded=${r.fileCountExcluded}',
  );
  stdout.writeln(row('global', r.global));
  stdout.writeln(row('sale', r.sale));
  stdout.writeln(row('core/domain', r.coreDomain));
  stdout.writeln(row('sale+domain', r.salePlusDomain));
  stdout.writeln(row('sale-logic', r.saleLogic));
  stdout.writeln(row('sale/domain', r.saleDomain));
  stdout.writeln(row('sale/data', r.saleData));
  stdout.writeln(row('sale/presentation', r.salePresentation));
  if (opts.minGlobal > 0 ||
      opts.minSaleDomain > 0 ||
      opts.minSaleLogic > 0 ||
      opts.minSale > 0 ||
      opts.minDomain > 0) {
    stdout.writeln(
      '  thresholds: global>=${opts.minGlobal} '
      'sale+domain>=${opts.minSaleDomain} '
      'sale-logic>=${opts.minSaleLogic} '
      'sale>=${opts.minSale} domain>=${opts.minDomain} '
      'fail=${opts.fail}',
    );
  }
}
