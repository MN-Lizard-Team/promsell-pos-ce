import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/tables/categories_table.dart';

@DataClassName('ProductData')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real()();
  RealColumn get cost => real().nullable()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get imageThumbnailPath => text().nullable()();
  TextColumn get barcodeImagePath => text().nullable()();
  BoolColumn get trackStock => boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
