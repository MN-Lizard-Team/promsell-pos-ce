import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_encryption_service.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_restore_service.dart';

class _MockDb extends Mock implements AppDatabase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late BackupRestoreService service;
  late _MockDb db;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('promsell_restore_test');
    db = _MockDb();
    when(() => db.close()).thenAnswer((_) async {});
    service = BackupRestoreService(db, BackupEncryptionService());
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('missing source throws SOURCE_MISSING', () async {
    expect(
      () => service.restoreFromPath(
        sourcePath: p.join(temp.path, 'nope.db'),
      ),
      throwsA(
        isA<StateError>().having((e) => e.message, 'm', 'SOURCE_MISSING'),
      ),
    );
  });

  test('enc without pin throws PIN_REQUIRED before path_provider', () async {
    final f = File(p.join(temp.path, 'x.enc'));
    await f.writeAsBytes(List.filled(64, 1));
    expect(
      () => service.restoreFromPath(sourcePath: f.path),
      throwsA(
        isA<StateError>().having((e) => e.message, 'm', 'PIN_REQUIRED'),
      ),
    );
  });
}
