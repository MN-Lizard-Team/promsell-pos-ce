import 'package:drift/drift.dart';

@DataClassName('AppSettingData')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};

  @override
  String get tableName => 'app_settings';
}
