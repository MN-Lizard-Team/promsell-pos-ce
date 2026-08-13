import 'package:promsell_pos_ce/features/settings/domain/entities/barcode_config.dart';

/// Shared parse helpers used by all per-entity settings mappers.
///
/// These mirror the original private helpers in `SettingsMapper` so that
/// behavior (defaults, edge cases) is preserved exactly.

/// Prefer [key], then optional [legacy]; empty uses [or].
String parseString(
  Map<String, String> map,
  String key, {
  String? legacy,
  String or = '',
}) {
  final v = map[key];
  if (v != null && v.isNotEmpty) return v;
  if (legacy != null) {
    final old = map[legacy];
    if (old != null && old.isNotEmpty) return old;
  }
  // Explicit empty canonical key wins over missing.
  if (map.containsKey(key)) return v ?? or;
  if (legacy != null && map.containsKey(legacy)) return map[legacy] ?? or;
  return or;
}

bool parseBool(String? raw, bool fallback) {
  if (raw == null || raw.trim().isEmpty) return fallback;
  final v = raw.trim().toLowerCase();
  if (v == 'true' || v == '1') return true;
  if (v == 'false' || v == '0') return false;
  return fallback;
}

int parseInt(String? raw, int fallback) {
  if (raw == null) return fallback;
  return int.tryParse(raw) ?? fallback;
}

double parseDouble(String? raw, double fallback) {
  if (raw == null) return fallback;
  return double.tryParse(raw) ?? fallback;
}

String? nullIfEmpty(String? value) {
  return (value == null || value.isEmpty) ? null : value;
}

List<String> parseFormatList(String? raw) {
  if (raw == null || raw.isEmpty) return BarcodeConfig.defaultAllFormats;
  final parsed = raw.split(',').where((e) => e.isNotEmpty).toList();
  return parsed.isEmpty ? BarcodeConfig.defaultAllFormats : parsed;
}

String parseThemeMode(String? raw) {
  if (raw == null || raw.isEmpty) return 'system';
  // Handle legacy integer index values (0=light, 1=dark, 2=system)
  switch (raw) {
    case '0':
      return 'light';
    case '1':
      return 'dark';
    case '2':
      return 'system';
  }
  // Already a valid name
  const valid = {'light', 'dark', 'system'};
  return valid.contains(raw) ? raw : 'system';
}
