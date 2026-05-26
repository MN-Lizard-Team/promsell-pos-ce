import 'package:drift/native.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

AppDatabase createInMemoryDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
