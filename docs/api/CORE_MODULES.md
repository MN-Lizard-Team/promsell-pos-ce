# Core Modules API Reference

> Current release: **v0.9.3** · database schema: **v32** · package version: `0.9.3`

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

---

## Database & Reliability Services ([Unreleased])

Six services added in the unreleased scaling/lifecycle work for migration safety, WAL management, health
reporting, backup export, key recovery, and restore. All use injectable
registration.

---

### MigrationSafetyService

**Location:** `lib/core/database/migration_safety_service.dart`

#### Purpose

Pre-migration free-space preflight and migration status tracking. Detects
interrupted migrations on the next launch so the app can trigger recovery or
operator alert.

#### Registration

```dart
@LazySingleton()
class MigrationSafetyService {
  MigrationSafetyService(this._db);
  final AppDatabase _db;
}
```

#### Key types

```dart
enum MigrationStatus { idle, running, succeeded, failed }

class MigrationPreflightResult {
  final int freeBytes;
  final int requiredBytes;
  final bool canProceed;
  final String? reason;  // 'INSUFFICIENT_FREE_SPACE' | 'FREE_SPACE_UNKNOWN' | null
}
```

#### API

```dart
// Free-space preflight — requires ≥ 2× DB size (or 50 MB floor, whichever is larger).
Future<MigrationPreflightResult> checkFreeSpace();
Future<int> getSchemaVersion();

// Migration status tracking — writes migration_status.json to app docs dir.
Future<void> markMigrationStart({required int fromVersion, required int toVersion});
Future<void> markMigrationSuccess({required int fromVersion, required int toVersion});
Future<void> markMigrationFailure({required int fromVersion, required int toVersion, required String error});
Future<MigrationStatus> readMigrationStatus();
```

#### Constants

- `_freeSpaceMultiplier = 2` — free space must be ≥ 2× current DB file size
- `_minFreeSpaceBytes = 50 MB` — absolute floor even for tiny databases

---

### WalCheckpointService

**Location:** `lib/core/database/wal_checkpoint_service.dart`

#### Purpose

WAL checkpoint monitoring and execution. `PASSIVE` mode is safe during active
money transactions; `TRUNCATE` mode requires an exclusive lock (backup, export,
day-close).

#### Registration

```dart
@LazySingleton()
class WalCheckpointService {
  WalCheckpointService(this._db);
  final AppDatabase _db;
}
```

#### Key types

```dart
enum CheckpointMode { passive, full, restart, truncate }

class CheckpointResult {
  final CheckpointMode mode;
  final int busy;               // 1 if a reader was active
  final int logFrames;
  final int checkpointedFrames;
  final int walSizeBefore;
  final int walSizeAfter;
  final int elapsedMs;
  bool get wasBusy => busy == 1;
  bool get walTruncated => walSizeAfter == 0;
}
```

#### API

```dart
Future<int> getWalSize();        // WAL file size in bytes (0 if absent)
Future<int> getShmSize();        // SHM file size in bytes
Future<bool> shouldCheckpoint(); // WAL ≥ 10 MB threshold
Future<bool> needsTruncate();    // WAL ≥ 50 MB hard limit

Future<CheckpointResult> checkpoint({CheckpointMode mode = CheckpointMode.passive});
Future<CheckpointResult?> checkpointIfNeeded();  // passive if ≥ threshold
Future<CheckpointResult> forceTruncate();         // exclusive lock + TRUNCATE
```

#### Constants

- `walCheckpointThreshold = 10 MB` — triggers passive checkpoint
- `walHardLimit = 50 MB` — triggers forced truncate

---

### DatabaseHealthService

**Location:** `lib/core/database/database_health_service.dart`

#### Purpose

Collects database health metrics into a single report for day-close, settings
page, or operator diagnostics.

#### Registration

```dart
@LazySingleton()
class DatabaseHealthService {
  DatabaseHealthService(this._db, this._walService);
  final AppDatabase _db;
  final WalCheckpointService _walService;
}
```

#### Key type — DatabaseHealthReport

```dart
class DatabaseHealthReport {
  final int mainDbSize;
  final int walSize;
  final int shmSize;
  final int totalSize;          // main + WAL + SHM
  final int schemaVersion;      // PRAGMA user_version
  final bool integrityOk;       // PRAGMA integrity_check == 'ok'
  final int freeStorageBytes;   // -1 if unknown
  final bool walNeedsCheckpoint;
  final bool walNeedsTruncate;
  final DateTime generatedAt;

  double get totalSizeMb;
  double get walPercent;
  bool get approachingGuardrail => totalSize > 400 MB;
  bool get exceedsGuardrail => totalSize > 512 MB;
}
```

#### API

```dart
// checkIntegrity defaults to false — PRAGMA integrity_check can be slow on
// large databases. Enable for operator diagnostics.
Future<DatabaseHealthReport> generateReport({bool checkIntegrity = false});
```

---

### BackupExportService

**Location:** `lib/features/settings/data/services/backup_export_service.dart`

#### Purpose

Exports a consistent copy of the local SQLite DB for merchant backup, with
SHA-256 checksum metadata, optional AES-GCM encryption, size preflight, and
progress reporting.

#### Registration

```dart
@LazySingleton()
class BackupExportService {
  BackupExportService(this._db, this._encryption, this._appLock);
  final AppDatabase _db;
  final BackupEncryptionService _encryption;
  final AppLockService _appLock;
}
```

#### Key types

```dart
class BackupMetadata {
  final int schemaVersion;
  final String appVersion;
  final String createdAt;
  final int dbSizeBytes;
  final String checksumSha256;
  final bool encrypted;

  Map<String, dynamic> toJson();
  factory BackupMetadata.fromJson(Map<String, dynamic> json);
  String encode();
  static BackupMetadata? tryDecode(String? content);
}

class BackupExportResult {
  final String filePath;
  final BackupMetadata metadata;
  final String? metadataPath;
}

enum BackupProgress { idle, checkpointing, copying, checksumming, encrypting, sharing, done }
```

#### API

```dart
// Full export with checksum, metadata, size preflight, and progress.
// Throws StateError('BACKUP_TOO_LARGE') if DB > 512 MB.
Future<BackupExportResult> exportWithMetadata({
  required bool encrypt,
  String? pin,
  required String shareSubject,
  String appVersion = 'unknown',
  void Function(BackupProgress stage)? onProgress,
});

// Export to files without sharing — testable without Flutter bindings.
Future<BackupExportResult> exportToFiles({
  required bool encrypt,
  String? pin,
  String appVersion = 'unknown',
  void Function(BackupProgress stage)? onProgress,
});

// Convenience — returns just the shared file path.
Future<String> exportAndShare({
  required bool encrypt,
  String? pin,
  required String shareSubject,
});
```

#### Constants

- `minPinLength = 6` — enforced when encryption is enabled
- `maxBackupBytes = 512 MB` — size preflight guardrail
- `metadataExtension = '.meta.json'`

---

### RecoveryKitService

**Location:** `lib/core/database/recovery_kit_service.dart`

#### Purpose

Exports and imports the SQLCipher key as a password-wrapped recovery kit
(`.promkey` format). The key is wrapped with AES-256-GCM using a PBKDF2-derived
key from the user's passphrase.

#### Registration

```dart
@LazySingleton()
class RecoveryKitService {
  RecoveryKitService();
}
```

#### Key types

```dart
class RecoveryKitExportResult {
  final String filePath;
  final RecoveryKitMetadata metadata;
}

class RecoveryKitMetadata {
  final int version;
  final String createdAt;
  final int kdfIterations;
}
```

#### API

```dart
// Exports the SQLCipher key as a password-wrapped recovery kit.
// Throws: SECRET_TOO_SHORT, NO_DB_KEY.
Future<RecoveryKitExportResult> exportKit({required String secret, String? outputPath});

// Imports a recovery kit and installs the key into secure storage.
// Throws: SECRET_TOO_SHORT, KIT_FILE_NOT_FOUND, KIT_CORRUPT,
//         KIT_VERSION_UNSUPPORTED, WRONG_SECRET, KEY_ALREADY_EXISTS.
Future<String> importKit({
  required String filePath,
  required String secret,
  bool replaceExisting = false,
});

Future<bool> hasKey();
Future<void> removeKey();
```

#### File format

```
[uint32 headerLength][JSON header][salt(16)][nonce(12)][ciphertext+GCM tag]
```

#### Constants

- `kRecoveryKitVersion = 1`
- `kRecoveryKitExtension = '.promkey'`
- `kRecoveryKitMinSecretLength = 8`
- PBKDF2 iterations: 100,000 (HMAC-SHA256)
- Salt: 16 bytes, Nonce: 12 bytes (96-bit GCM), Key: 32 bytes (256-bit)

---

### BackupRestoreService

**Location:** `lib/features/settings/data/services/backup_restore_service.dart`

#### Purpose

Same-device restore of a SQLCipher DB backup (optional AES-GCM PIN envelope).
Performs a staged file swap with rollback so the live DB is untouched until
validation and copy both succeed.

#### Registration

```dart
typedef CandidateValidator = Future<void> Function(String path);

@LazySingleton()
class BackupRestoreService {
  BackupRestoreService(
    this._db,
    this._encryption,
    this._appLock, {
    @ignoreParam CandidateValidator? candidateValidator,
    @ignoreParam this.skipSqlCipherHeaderCheck = false,
  });
}
```

> `@ignoreParam` on `candidateValidator` and `skipSqlCipherHeaderCheck` keeps
> them out of the injectable-generated factory so the DI graph only wires
> production dependencies.

#### API

```dart
// Restores sourcePath (.enc or .db). Returns the pre-restore backup path.
// Caller must restart the app process so Drift/GetIt reopen the DB cleanly.
// Throws: SOURCE_MISSING, BACKUP_TOO_LARGE, PIN_REQUIRED, PIN_TOO_SHORT,
//         PLAIN_SQLITE_UNSUPPORTED, INVALID_BACKUP, INVALID_BACKUP_SCHEMA,
//         INVALID_BACKUP_INTEGRITY.
Future<String> restoreFromPath({required String sourcePath, String? pin});

// Deletes leftover promsell_pos.pre_restore_*.db files after a successful
// DB open. Call after the app starts and the live DB opens successfully.
Future<int> cleanupPreRestoreBackups();
```

#### Constants

- `minPinLength = 6` (aligned with `BackupExportService.minPinLength`)
- `maxBackupBytes = 512 MB`

#### Test-only parameters

- `candidateValidator` — inject a custom validation function in tests
- `skipSqlCipherHeaderCheck` — skips the SQLCipher header check for tests
  using plain SQLite fixtures; production code must never set this

---

<sub>Promsell POS CE · v0.9.3 · Core Modules API</sub>
