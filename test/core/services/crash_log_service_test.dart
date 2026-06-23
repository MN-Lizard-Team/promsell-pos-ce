import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/services/crash_log_service.dart';

void main() {
  late CrashLogService service;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('crash_log_test_');
    service = CrashLogService.forTesting(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('CrashLogService', () {
    test('recordError writes to file', () async {
      await service.recordError(
        Exception('test error'),
        StackTrace.current,
        context: 'test',
      );

      final logFile = File('${tempDir.path}/crash_logs/crash_log.txt');
      expect(await logFile.exists(), isTrue);
      final content = await logFile.readAsString();
      expect(content, contains('test error'));
      expect(content, contains('[ERROR]'));
    });

    test('clearLogs removes log files', () async {
      await service.recordError(Exception('to be cleared'), StackTrace.current);

      final logFile = File('${tempDir.path}/crash_logs/crash_log.txt');
      expect(await logFile.exists(), isTrue);

      await service.clearLogs();

      expect(await logFile.exists(), isFalse);
    });

    test('getLogSizeBytes returns 0 when no logs', () async {
      expect(await service.getLogSizeBytes(), 0);
    });

    test('getLogSizeBytes returns size after recording', () async {
      await service.recordError(Exception('size test'), StackTrace.current);

      final size = await service.getLogSizeBytes();
      expect(size, greaterThan(0));
    });

    test('sanitizeExport strips phone numbers', () {
      final input = 'Call me at 0812345678';
      final result = service.sanitizeExport(input);
      expect(result, contains('[PHONE]'));
      expect(result, isNot(contains('0812345678')));
    });

    test('sanitizeExport strips 13-digit PromptPay IDs', () {
      final input = 'PromptPay ID: 1234567890123';
      final result = service.sanitizeExport(input);
      expect(result, contains('[PROMPTPAY_ID]'));
    });

    test('sanitizeExport strips citizen IDs', () {
      final input = 'ID: 1-2345-67890-12-3';
      final result = service.sanitizeExport(input);
      expect(result, contains('[CITIZEN_ID]'));
    });

    test('exportLogs returns path when logs exist', () async {
      await service.recordError(Exception('export test'), StackTrace.current);

      final path = await service.exportLogs();
      expect(path, isNotNull);
      final exported = File(path!);
      expect(await exported.exists(), isTrue);
      final content = await exported.readAsString();
      expect(content, contains('export test'));
    });

    test('exportLogs returns null when no logs', () async {
      final path = await service.exportLogs();
      expect(path, isNull);
    });
  });
}
