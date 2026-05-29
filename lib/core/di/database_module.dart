import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

@module
abstract class DatabaseModule {
  @lazySingleton
  AppDatabase get appDatabase => AppDatabase();
}
