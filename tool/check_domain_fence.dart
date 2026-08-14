import 'dart:io';

const defaultAllowlistPath = 'tool/domain_fence_allowlist.txt';

class DomainImportViolation {
  const DomainImportViolation({
    required this.path,
    required this.line,
    required this.uri,
    required this.rule,
  });

  final String path;
  final int line;
  final String uri;
  final String rule;

  @override
  String toString() => '$path:$line imports $uri ($rule)';
}

class DomainFenceAllowlistEntry {
  const DomainFenceAllowlistEntry({
    required this.path,
    required this.reason,
    required this.expiry,
  });

  final String path;
  final String reason;
  final DateTime expiry;
}

void main(List<String> args) {
  final allowlistPath = _parseAllowlistPath(args);
  final allowlistFile = File(allowlistPath);
  if (!allowlistFile.existsSync()) {
    stderr.writeln('Domain import fence failed: $allowlistPath not found.');
    exit(1);
  }

  final entries = _parseAllowlist(allowlistFile.readAsStringSync());
  final violations = scanDomainImports();
  final errors = validateDomainFence(
    violations,
    entries,
    now: DateTime.now().toUtc(),
  );

  if (errors.isNotEmpty) {
    stderr.writeln('Domain import fence failed:');
    for (final error in errors) {
      stderr.writeln('  - $error');
    }
    exit(1);
  }

  stdout.writeln(
    'Domain import fence passed: ${violations.length} violation(s) '
    'covered by ${entries.length} dated allowlist entr${entries.length == 1 ? 'y' : 'ies'}.',
  );
}

List<DomainImportViolation> scanDomainImports({
  String rootPath = 'lib/features',
}) {
  final root = Directory(rootPath);
  if (!root.existsSync()) {
    throw StateError('$rootPath does not exist');
  }

  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .expand((file) {
        final path = normalizeProjectPath(file.path);
        return findDomainImportViolations(path, file.readAsStringSync());
      })
      .toList();
}

List<DomainImportViolation> findDomainImportViolations(
  String sourcePath,
  String source,
) {
  final path = normalizeProjectPath(sourcePath);
  if (!isDomainSourcePath(path)) return const [];

  final violations = <DomainImportViolation>[];
  final lines = source.split('\n');
  final importPattern = RegExp(r'''^\s*import\s+['"]([^'"]+)['"]''');

  for (var index = 0; index < lines.length; index++) {
    final match = importPattern.firstMatch(lines[index]);
    if (match == null) continue;

    final uri = match.group(1)!;
    final rule = forbiddenImportRule(path, uri);
    if (rule != null) {
      violations.add(
        DomainImportViolation(
          path: path,
          line: index + 1,
          uri: uri,
          rule: rule,
        ),
      );
    }
  }

  return violations;
}

bool isDomainSourcePath(String path) {
  final normalized = normalizeProjectPath(path);
  return normalized.startsWith('lib/features/') &&
      normalized.contains('/domain/');
}

String? forbiddenImportRule(String sourcePath, String uri) {
  if (uri.startsWith('package:flutter/')) return 'Flutter import';

  final importedPath = resolveProjectImportPath(sourcePath, uri);
  if (importedPath == null || !importedPath.startsWith('lib/features/')) {
    return null;
  }

  if (importedPath.contains('/data/')) {
    return 'feature data import';
  }
  if (importedPath.contains('/presentation/')) {
    return 'feature presentation import';
  }
  return null;
}

String? resolveProjectImportPath(String sourcePath, String uri) {
  const packagePrefix = 'package:promsell_pos_ce/';
  if (uri.startsWith(packagePrefix)) {
    return normalizeProjectPath('lib/${uri.substring(packagePrefix.length)}');
  }
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return null;

  final sourceDirectory = sourcePath.substring(0, sourcePath.lastIndexOf('/'));
  return _normalizeSegments('$sourceDirectory/$uri'.split('/'));
}

String normalizeProjectPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final libIndex = normalized.indexOf('lib/');
  if (libIndex >= 0) return normalized.substring(libIndex);
  return normalized.startsWith('./') ? normalized.substring(2) : normalized;
}

List<DomainFenceAllowlistEntry> parseAllowlist(String contents) {
  return _parseAllowlist(contents);
}

List<String> validateDomainFence(
  List<DomainImportViolation> violations,
  List<DomainFenceAllowlistEntry> entries, {
  DateTime? now,
}) {
  final errors = <String>[];
  final entriesByPath = <String, DomainFenceAllowlistEntry>{};
  for (final entry in entries) {
    final path = normalizeProjectPath(entry.path);
    if (entriesByPath.containsKey(path)) {
      errors.add('duplicate allowlist path: $path');
    }
    entriesByPath[path] = entry;

    if (_isExpired(entry.expiry, now ?? DateTime.now().toUtc())) {
      errors.add('expired allowlist entry: $path (${_date(entry.expiry)})');
    }
  }

  final violationsByPath = <String, List<DomainImportViolation>>{};
  for (final violation in violations) {
    violationsByPath.putIfAbsent(violation.path, () => []).add(violation);
    if (!entriesByPath.containsKey(violation.path)) {
      errors.add('unallowlisted violation: $violation');
    }
  }

  for (final entry in entries) {
    final path = normalizeProjectPath(entry.path);
    if (!violationsByPath.containsKey(path)) {
      errors.add('stale allowlist entry: $path');
    }
  }

  return errors;
}

List<DomainFenceAllowlistEntry> _parseAllowlist(String contents) {
  final entries = <DomainFenceAllowlistEntry>[];
  for (var index = 0; index < contents.split('\n').length; index++) {
    final raw = contents.split('\n')[index].trim();
    if (raw.isEmpty || raw.startsWith('#')) continue;

    final fields = raw.split('|').map((field) => field.trim()).toList();
    if (fields.length != 3 || fields.any((field) => field.isEmpty)) {
      throw FormatException(
        'Invalid allowlist line ${index + 1}; expected path | reason | YYYY-MM-DD',
      );
    }

    final expiry = DateTime.tryParse(fields[2]);
    if (expiry == null) {
      throw FormatException(
        'Invalid allowlist expiry on line ${index + 1}: ${fields[2]}',
      );
    }

    entries.add(
      DomainFenceAllowlistEntry(
        path: normalizeProjectPath(fields[0]),
        reason: fields[1],
        expiry: expiry,
      ),
    );
  }
  return entries;
}

String _parseAllowlistPath(List<String> args) {
  for (var index = 0; index < args.length; index++) {
    if (args[index] == '--allowlist' && index + 1 < args.length) {
      return args[index + 1];
    }
    if (args[index].startsWith('--allowlist=')) {
      return args[index].substring('--allowlist='.length);
    }
  }
  return defaultAllowlistPath;
}

bool _isExpired(DateTime expiry, DateTime now) {
  final expiryDate = DateTime.utc(expiry.year, expiry.month, expiry.day);
  final today = DateTime.utc(now.year, now.month, now.day);
  return today.isAfter(expiryDate);
}

String _date(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _normalizeSegments(Iterable<String> segments) {
  final normalized = <String>[];
  for (final segment in segments) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (normalized.isNotEmpty && normalized.last != '..') {
        normalized.removeLast();
      } else {
        normalized.add(segment);
      }
      continue;
    }
    normalized.add(segment);
  }
  return normalized.join('/');
}
