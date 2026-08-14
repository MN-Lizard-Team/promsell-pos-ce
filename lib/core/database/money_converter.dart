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

/// Prefers the dual-written satang value and falls back to legacy baht.
Money moneyFromSatangOrBaht(Money? satang, double baht) =>
    satang ?? Money.fromDouble(baht);

/// Nullable variant for optional legacy baht columns.
Money? nullableMoneyFromSatangOrBaht(Money? satang, double? baht) =>
    satang ?? (baht == null ? null : Money.fromDouble(baht));

/// Phase M (C2): Drift [TypeConverter] that persists [Money] as an INTEGER
/// satang column (1 THB = 100 satang).
///
/// Stored value is the integer satang amount (e.g. `9950` for ฿99.50).
/// This eliminates floating-point impedance between the domain `Money` (int
/// satang) and SQLite storage.
///
/// Nullable satang columns are wired to [NullableMoneySatangConverter] in
/// the Drift table definitions. Writers dual-write satang and legacy REAL
/// baht for compatibility. Readers prefer satang and fall back to REAL baht
/// for old rows where satang is NULL.
///
/// Usage for a future non-null satang column:
/// ```dart
/// IntColumn get priceSatang => integer().nullable().map(const NullableMoneySatangConverter())();
/// ```
class MoneySatangConverter extends TypeConverter<Money, int> {
  const MoneySatangConverter();

  @override
  Money fromSql(int fromDb) => Money.fromSatang(fromDb);

  @override
  int toSql(Money value) => value.satang;
}

/// Nullable variant for optional satang columns.
class NullableMoneySatangConverter extends TypeConverter<Money?, int?> {
  const NullableMoneySatangConverter();

  @override
  Money? fromSql(int? fromDb) =>
      fromDb == null ? null : Money.fromSatang(fromDb);

  @override
  int? toSql(Money? value) => value?.satang;
}
