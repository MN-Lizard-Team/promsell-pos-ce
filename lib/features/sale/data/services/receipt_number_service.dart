import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

@lazySingleton
class ReceiptNumberService {
  ReceiptNumberService(this._db);
  final AppDatabase _db;

  static const _keySequence = 'receiptSequence';
  static const _keySequenceDate = 'receiptSequenceDate';
  static const _keyDevicePrefix = 'devicePrefix';

  /// Generate the next receipt number.
  /// Format: `{YYMMDD}-{devicePrefix}-{seq:0000}`
  /// Example: `260527-A1-0001`
  ///
  /// **MUST be called inside the caller's transaction** to guarantee
  /// sequential uniqueness.
  Future<String> nextReceiptNumber() async {
    final now = DateTime.now();
    final dateKey = DateFormat('yyMMdd').format(now);
    final isoDate = DateFormat('yyyy-MM-dd').format(now);

    final lastDate = await _readSetting(_keySequenceDate);
    final lastSeq = int.tryParse(await _readSetting(_keySequence) ?? '0') ?? 0;
    final devicePrefix =
        await _readSetting(_keyDevicePrefix) ?? await _generateDevicePrefix();

    final newSeq = (lastDate == isoDate) ? lastSeq + 1 : 1;

    await _writeSetting(_keySequence, newSeq.toString());
    await _writeSetting(_keySequenceDate, isoDate);

    return '$dateKey-$devicePrefix-${newSeq.toString().padLeft(4, '0')}';
  }

  Future<String?> _readSetting(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeSetting(String key, String value) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<String> _generateDevicePrefix() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    final prefix = String.fromCharCodes(
      Iterable.generate(2, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
    );
    await _writeSetting(_keyDevicePrefix, prefix);
    return prefix;
  }
}
