# Core Modules API Reference

> Current release: **v0.9.2** · database schema: **v32** · package version: `0.9.2`

Public APIs for core domain modules, error system, and value objects.

---

## Money Value Object

**Location:** `lib/core/domain/money.dart`

### Purpose

Type-safe monetary value representation preventing floating-point precision errors. All monetary calculations use integer minor units (satang) internally.

### Why Not Double?

```dart
// Floating-point horror:
print(0.10 * 3);  // 0.30000000000000004

// Money safety:
final price = Money.fromDouble(0.10);
print(price * 3);  // Money(0.30)
```

### Creation

```dart
// From decimal Baht
final price = Money.fromDouble(299.50);  // ฿299.50
final cost = Money.fromDouble(150.00);

// Zero constant
final zero = Money.zero;
```

### Arithmetic

```dart
final subtotal = price * 3;                    // ฿898.50
final vat = subtotal * 0.07;                   // ฿62.90 (rounded half-up)
final discount = subtotal * 0.15;              // ฿134.78
final total = subtotal + vat - discount;       // ฿826.62

// Subtraction clamped at zero (prevents negative cart totals)
final change = payment - total;                // Never negative

// Unclamped subtraction for over-short calculations
final overShort = expected.subtractUnclamped(actual);  // Can be negative
```

### Comparison

```dart
if (total > Money.fromDouble(1000)) {
  // Apply bulk discount
}

if (balance.isZero) {
  // No outstanding balance
}

// Comparable interface
final sorted = [price3, price1, price2]..sort();
```

### Display

```dart
// String representation
print(price.toString());            // "Money(299.50)"

// Baht as double (display / REAL persistence boundary only — not domain math)
  final baht = price.value;           // 299.50
  print('฿${baht.toStringAsFixed(2)}');  // "฿299.50"

// Raw satang (for exact arithmetic)
final satang = price.satang;        // 29950
```

### Drift / persistence (v0.9.2)

Domain `Money` uses **integer satang** in memory. Schema v32 stores 32 nullable
`*_satang` columns across 10 money tables. Writers dual-write exact satang plus
legacy REAL baht for rollback compatibility; readers prefer satang and fall back
to REAL for pre-v32 rows. Percentage rates and percentage-valued discounts stay
REAL; conditional `AMOUNT` values also receive satang storage.

```dart
// lib/core/database/money_converter.dart
class Products extends Table {
  RealColumn get price => real()();
  RealColumn get cost => real().nullable()();
  IntColumn get priceSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
  IntColumn get costSatang =>
      integer().nullable().map(const NullableMoneySatangConverter())();
}

// Data-layer read boundary:
final price = moneyFromSatangOrBaht(row.priceSatang, row.price);
```

### Testing

6 unit tests in `test/core/domain/money_test.dart`:
- Arithmetic (addition, multiplication, subtraction)
- Comparison operators
- Rounding edge cases (half-up rule)
- Clamping behavior
- Equatable contract

---

## AppError System

**Location:** `lib/core/errors/app_error.dart`

### Purpose

Typed error hierarchy replacing string error messages. Enables exhaustive pattern matching and localized error display.

### Architecture

```dart
sealed class AppError extends Equatable {
  // Base sealed class — cannot be instantiated
  // All subtypes are final (cannot be extended)
}
```

### Error Types

#### ValidationError

**Use:** Input validation failures

```dart
const ValidationError(
  'Price must be greater than zero',
  field: 'price',
)
```

#### NotFoundError

**Use:** Entity not found in database

```dart
const NotFoundError(
  'Product',
  id: 'abc-123',
)
```

#### BusinessRuleError

**Use:** Business logic violations

```dart
const BusinessRuleError(
  'InsufficientStock',
  details: 'Only 5 units available',
)
```

#### DatabaseError

**Use:** Database operation failures

```dart
const DatabaseError(
  'Failed to insert sale',
  operation: 'insert',
)
```

#### NetworkError

**Use:** Network request failures (future use)

```dart
const NetworkError(
  statusCode: 404,
  message: 'API endpoint not found',
)
```

#### FileSystemError

**Use:** File I/O errors

```dart
const FileSystemError(
  'Cannot write backup file',
  path: '/storage/backup.db',
)
```

#### PermissionDeniedError

**Use:** Permission issues

```dart
const PermissionDeniedError('camera')
```

#### UnknownError

**Use:** Catch-all for unexpected errors

```dart
UnknownError(
  e.toString(),
  stackTrace: stackTrace,
)
```

### Usage in BLoC

```dart
class ProductState extends Equatable {
  final List<Product> products;
  final AppError? error;
  
  const ProductState({
    this.products = const [],
    this.error,
  });
  
  ProductState.loading() : this(error: null);
  ProductState.failure(AppError error) : this(error: error);
}

// In BLoC event handler
try {
  final product = await repository.getById(id);
  emit(ProductState(products: [product]));
} on NotFoundException {
  emit(ProductState.failure(NotFoundError('Product', id: id)));
} on Exception catch (e) {
  emit(ProductState.failure(UnknownError(e.toString())));
}
```

### UI Pattern Matching

```dart
// In widget
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    if (state.error != null) {
      return switch (state.error!) {
        ValidationError(message: final msg) => Text('Validation: $msg'),
        NotFoundError(resource: final res) => Text('$res not found'),
        BusinessRuleError(rule: final rule) => Text('Rule: $rule'),
        DatabaseError() => Text('Database error occurred'),
        _ => Text('Unknown error'),
      };
    }
    // Success state...
  },
)
```

### Localization

Extension method provides localized messages:

```dart
extension AppErrorDisplay on AppError {
  String toDisplayMessage(AppLocalizations l10n) {
    return switch (this) {
      ValidationError(message: final msg) => msg,
      NotFoundError(resource: final res) => l10n.notFound(res),
      BusinessRuleError(rule: 'InsufficientStock') => l10n.insufficientStock,
      BusinessRuleError(rule: 'DuplicateBarcode') => l10n.duplicateBarcode,
      DatabaseError() => l10n.databaseError,
      NetworkError() => l10n.networkError,
      FileSystemError() => l10n.fileSystemError,
      PermissionDeniedError(permission: final p) => l10n.permissionDenied(p),
      UnknownError() => l10n.unknownError,
    };
  }
}

// Usage in widget
if (state.error != null) {
  AppSnackBar.error(
    context,
    state.error!.toDisplayMessage(context.l10n),
  );
}
```

### Migration from String Errors

**Before:**
```dart
class ProductState {
  final String? errorMessage;
}

emit(state.copyWith(errorMessage: 'Product not found'));
```

**After:**
```dart
class ProductState {
  final AppError? error;
}

emit(state.copyWith(error: NotFoundError('Product')));
```

### Testing

```dart
test('emits NotFoundError when product does not exist', () {
  final error = NotFoundError('Product', id: 'abc-123');
  
  expect(error.resource, 'Product');
  expect(error.id, 'abc-123');
  expect(error, isA<NotFoundError>());
});
```

---

## IdGenerator

**Location:** `lib/core/utils/id_generator.dart`

### Purpose

Centralized UUID generation for all entities.

### Usage

```dart
import 'package:promsell_pos_ce/core/utils/id_generator.dart';

final id = IdGenerator.newId();  // Returns UUIDv4 string
```

### Format

```dart
'a3c2f1e8-4d6b-4a9c-8f2e-1b3d5a7c9e0f'  // 36 characters
```

All database tables use TEXT primary keys with this format.

---

## Ean13Generator

**Location:** `lib/core/utils/ean13_generator.dart`

### Purpose

Generates EAN-13 compliant barcodes with Luhn check digit.

### Dependency Injection

```dart
@injectable  // Registered as instance, not singleton
class Ean13Generator {
  int _counter = 0;
  
  Future<void> initCounter(SettingsRepository repo) async { ... }
  String generate({String prefix = '200', String? excludeId}) { ... }
}
```

### Usage

```dart
// Inject via constructor
class GenerateBarcode {
  GenerateBarcode(this._generator, this._repository);
  
  final Ean13Generator _generator;
  final ProductRepository _repository;
  
  Future<String> call({String? excludeId}) async {
    await _generator.initCounter(_settingsRepo);
    
    for (int retry = 0; retry < 10; retry++) {
      final barcode = _generator.generate(
        prefix: '200',
        excludeId: excludeId,
      );
      
      final exists = await _repository.barcodeExists(barcode);
      if (!exists) return barcode;
    }
    
    throw Exception('Could not generate unique barcode');
  }
}
```

### Format

```
2 0 0 1 2 3 4 5 6 7 8 9 [C]
│ │ │ └───────┬───────┘  │
│ │ │         │          └─ Check digit (Luhn)
│ │ │         └─ Sequential counter (9 digits)
│ │ └─ Prefix padding
│ └─ GS1 prefix start
└─ Country code (200-299 = internal use)
```

### Testing

18 unit tests in `test/core/utils/ean13_generator_test.dart`:
- Check digit calculation
- Prefix padding
- Counter persistence
- Collision avoidance
- Batch generation

---

<sub>Promsell POS CE · v0.9.2 · Core Modules API</sub>
