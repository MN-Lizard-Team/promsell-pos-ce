import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

/// Drift [TypeConverter] that persists [Money] as a REAL (double) column.
///
/// Stored value is the decimal Baht amount (e.g. `99.50`), not satang.
/// This preserves backward compatibility with existing data in the database.
///
/// Usage in a Drift table:
/// ```dart
/// RealColumn get price => real().map(const MoneyConverter())();
/// ```
class MoneyConverter extends TypeConverter<Money, double> {
  const MoneyConverter();

  @override
  Money fromSql(double fromDb) => Money.fromDouble(fromDb);

  @override
  double toSql(Money value) => value.value;
}

/// Nullable variant for optional money columns (e.g. `cost`, `amountReceived`).
class NullableMoneyConverter extends TypeConverter<Money?, double?> {
  const NullableMoneyConverter();

  @override
  Money? fromSql(double? fromDb) =>
      fromDb == null ? null : Money.fromDouble(fromDb);

  @override
  double? toSql(Money? value) => value?.value;
}
