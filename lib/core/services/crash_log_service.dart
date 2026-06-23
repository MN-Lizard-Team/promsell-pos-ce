import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

@LazySingleton()
class CrashLogService {
  CrashLogService() : _testDir = null;

  @visibleForTesting
  CrashLogService.forTesting(this._testDir);

  final Directory? _testDir;
  static const _maxFileSize = 1024 * 1024; // 1 MB
  static const _logDirName = 'crash_logs';
  static const _logFileName = 'crash_log.txt';

  // PII patterns to sanitize in exports
  static final _phonePattern = RegExp(r'\b0[689]\d{8}\b');
  static final _promptPayPattern = RegExp(
    r'(?:PromptPay|promptpay|prompt pay)[^\d]*\d{13}',
    caseSensitive: false,
  );
  static final _citizenIdPattern = RegExp(r'\b\d{1}-\d{4}-\d{5}-\d{2}-\d{1}\b');

  Future<Directory> _getLogDir() async {
    if (_testDir != null) {
      final dir = Directory('${_testDir.path}/$_logDirName');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_logDirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _getLogFile() async {
    final dir = await _getLogDir();
    return File('${dir.path}/$_logFileName');
  }

  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? context,
  }) async {
    try {
      final file = await _getLogFile();
      final size = await file.exists() ? await file.length() : 0;

      if (size >= _maxFileSize) {
        await _rotateLog(file);
      }

      final timestamp = DateTime.now().toIso8601String();
      final entry = StringBuffer()
        ..writeln('[$timestamp] [ERROR] ${context ?? 'uncaught'}')
        ..writeln('  $error');
      if (stack != null) {
        entry.writeln('  $stack');
      }
      entry.writeln('---');

      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      await file.writeAsString(entry.toString(), mode: FileMode.append);
    } catch (e) {
      AppLogger.warning('CrashLogService: failed to record error', error: e);
    }
  }

  Future<String?> exportLogs() async {
    try {
      final file = await _getLogFile();
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final sanitized = sanitizeExport(content);

      final dir = await _getLogDir();
      final exportName =
          'crash_export_${DateTime.now().millisecondsSinceEpoch}.txt';
      final exportFile = File('${dir.path}/$exportName');
      await exportFile.writeAsString(sanitized);
      return exportFile.path;
    } catch (e) {
      AppLogger.warning('CrashLogService: failed to export logs', error: e);
      return null;
    }
  }

  Future<void> clearLogs() async {
    try {
      final dir = await _getLogDir();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
    } catch (e) {
      AppLogger.warning('CrashLogService: failed to clear logs', error: e);
    }
  }

  Future<int> getLogSizeBytes() async {
    try {
      final file = await _getLogFile();
      if (!await file.exists()) return 0;
      return await file.length();
    } catch (_) {
      return 0;
    }
  }

  String sanitizeExport(String content) {
    return content
        .replaceAll(_phonePattern, '[PHONE]')
        .replaceAll(_promptPayPattern, '[PROMPTPAY_ID]')
        .replaceAll(_citizenIdPattern, '[CITIZEN_ID]');
  }

  Future<void> _rotateLog(File file) async {
    final rotated = File('${file.path}.old');
    if (await rotated.exists()) {
      await rotated.delete();
    }
    await file.rename(rotated.path);
  }
}
