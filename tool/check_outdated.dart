/// Checks `dart pub outdated --json` output for direct dependencies
/// that are behind by ≥ 1 major version.
///
/// Usage: `dart pub outdated --json > pub-outdated.json && dart run tool/check_outdated.dart`
///
/// Exit codes:
/// - 0: all direct dependencies are up to date or behind by < 1 major version
/// - 1: one or more direct dependencies are behind by ≥ 1 major version
library;

import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('pub-outdated.json');
  if (!file.existsSync()) {
    stderr.writeln(
      'Error: pub-outdated.json not found. Run `dart pub outdated --json > pub-outdated.json` first.',
    );
    exit(1);
  }

  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final packages = json['packages'] as List<dynamic>? ?? [];

  final directDeps = _loadDirectDependencies();
  final warnings = <String>[];

  for (final pkg in packages) {
    final map = pkg as Map<String, dynamic>;
    final name = map['package'] as String;
    if (!directDeps.contains(name)) continue;

    final current = map['current']?['version'] as String?;
    final upgradable = map['upgradable']?['version'] as String?;
    final resolvable = map['resolvable']?['version'] as String?;

    if (current == null) continue;

    final currentMajor = _parseMajor(current);
    final targetVersion = resolvable ?? upgradable;
    if (targetVersion == null) continue;

    final targetMajor = _parseMajor(targetVersion);
    if (targetMajor > currentMajor) {
      warnings.add(
        '  $name: current=$current → resolvable=$targetVersion '
        '(behind ${targetMajor - currentMajor} major version(s))',
      );
    }
  }

  if (warnings.isEmpty) {
    stdout.writeln(
      '✅ All direct dependencies are within 1 major version of latest.',
    );
    exit(0);
  } else {
    stderr.writeln('⚠️  Direct dependencies behind by ≥ 1 major version:');
    for (final w in warnings) {
      stderr.writeln(w);
    }
    stderr.writeln('');
    stderr.writeln(
      'Consider upgrading these dependencies to reduce security risk.',
    );
    exit(1);
  }
}

Set<String> _loadDirectDependencies() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) return {};

  final content = pubspec.readAsStringSync();
  final deps = <String>{};
  final depSection = RegExp(r'^dependencies:\s*$', multiLine: true);
  final devDepSection = RegExp(r'^dev_dependencies:\s*$', multiLine: true);
  final keyPattern = RegExp(r'^\s+(\S+):');

  final lines = content.split('\n');
  bool inDeps = false;
  bool inDevDeps = false;

  for (final line in lines) {
    if (depSection.hasMatch(line)) {
      inDeps = true;
      inDevDeps = false;
      continue;
    }
    if (devDepSection.hasMatch(line)) {
      inDevDeps = true;
      inDeps = false;
      continue;
    }
    if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t')) {
      inDeps = false;
      inDevDeps = false;
      continue;
    }
    if (inDeps && !inDevDeps) {
      final match = keyPattern.firstMatch(line);
      if (match != null) {
        deps.add(match.group(1)!);
      }
    }
  }

  return deps;
}

int _parseMajor(String version) {
  final parts = version.split('.');
  if (parts.isEmpty) return 0;
  final majorStr = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(majorStr) ?? 0;
}
