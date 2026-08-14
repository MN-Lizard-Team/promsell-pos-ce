import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_domain_fence.dart' as fence;

void main() {
  group('findDomainImportViolations', () {
    test('detects Flutter, data, and presentation imports', () {
      const source = '''
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/product/data/services/image.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
''';

      final violations = fence.findDomainImportViolations(
        'lib/features/product/domain/usecases/example.dart',
        source,
      );

      expect(violations, hasLength(3));
      expect(violations.map((item) => item.rule), contains('Flutter import'));
      expect(
        violations.map((item) => item.rule),
        contains('feature data import'),
      );
      expect(
        violations.map((item) => item.rule),
        contains('feature presentation import'),
      );
    });

    test('resolves relative imports inside a domain file', () {
      final violations = fence.findDomainImportViolations(
        'lib/features/product/domain/usecases/example.dart',
        "import '../../data/services/image.dart';",
      );

      expect(violations, hasLength(1));
      expect(violations.single.uri, '../../data/services/image.dart');
    });

    test('ignores external and non-domain imports', () {
      final violations = fence.findDomainImportViolations(
        'lib/features/product/domain/usecases/example.dart',
        "import 'package:equatable/equatable.dart';\n"
            "import 'package:promsell_pos_ce/core/domain/money.dart';",
      );

      expect(violations, isEmpty);
      expect(
        fence.findDomainImportViolations(
          'lib/features/product/presentation/pages/example.dart',
          "import 'package:flutter/material.dart';",
        ),
        isEmpty,
      );
    });
  });

  group('parseAllowlist and validateDomainFence', () {
    test('parses path, reason, and expiry', () {
      final entries = fence.parseAllowlist(
        'lib/features/product/domain/example.dart | follow-up | 2026-10-31\n',
      );

      expect(entries, hasLength(1));
      expect(entries.single.path, 'lib/features/product/domain/example.dart');
      expect(entries.single.reason, 'follow-up');
      expect(entries.single.expiry, DateTime(2026, 10, 31));
    });

    test('requires violations to be allowlisted and unexpired', () {
      const source = "import 'package:flutter/material.dart';";
      final violations = fence.findDomainImportViolations(
        'lib/features/settings/domain/entities/settings.dart',
        source,
      );
      final entries = fence.parseAllowlist(
        'lib/features/settings/domain/entities/settings.dart | AH-1.4 | 2026-10-31\n',
      );

      expect(
        fence.validateDomainFence(
          violations,
          entries,
          now: DateTime(2026, 10, 30),
        ),
        isEmpty,
      );
      expect(
        fence.validateDomainFence(
          violations,
          entries,
          now: DateTime(2026, 11, 1),
        ),
        contains(startsWith('expired allowlist entry')),
      );
    });

    test('rejects stale allowlist entries', () {
      final entries = fence.parseAllowlist(
        'lib/features/product/domain/removed.dart | cleanup | 2026-10-31\n',
      );

      expect(
        fence.validateDomainFence(
          const [],
          entries,
          now: DateTime(2026, 10, 1),
        ),
        contains(startsWith('stale allowlist entry')),
      );
    });
  });
}
