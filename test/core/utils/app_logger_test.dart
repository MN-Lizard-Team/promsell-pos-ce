import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

void main() {
  group('AppLogger', () {
    test('info does not throw', () {
      expect(() => AppLogger.info('test'), returnsNormally);
    });

    test('warning does not throw', () {
      expect(() => AppLogger.warning('test'), returnsNormally);
    });

    test('error does not throw', () {
      expect(() => AppLogger.error('test'), returnsNormally);
    });

    test('warning with error and stack does not throw', () {
      expect(
        () => AppLogger.warning(
          'test',
          error: Exception('e'),
          stack: StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('error with error and stack does not throw', () {
      expect(
        () => AppLogger.error(
          'test',
          error: Exception('e'),
          stack: StackTrace.current,
        ),
        returnsNormally,
      );
    });
  });
}
