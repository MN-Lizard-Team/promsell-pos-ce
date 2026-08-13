import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_encryption_service.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_export_service.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_restore_service.dart';

import '../helpers/fake_database.dart';
import '../helpers/fake_settings_repository.dart';

class _MockDb extends Mock implements AppDatabase {}

class _MockStorage extends Mock implements FlutterSecureStorage {}

AppLockService _unlockedAppLock() {
  final map = <String, String>{};
  final storage = _MockStorage();
  when(() => storage.read(key: any(named: 'key'))).thenAnswer((inv) async {
    return map[inv.namedArguments[#key] as String];
  });
  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((inv) async {
    map[inv.namedArguments[#key] as String] =
        inv.namedArguments[#value] as String;
  });
  when(() => storage.delete(key: any(named: 'key'))).thenAnswer((inv) async {
    map.remove(inv.namedArguments[#key] as String);
  });
  return AppLockService(storage: storage);
}

/// POST-090 B1: money facts survive encrypt → restore file path (same-device).
///
/// Production DB is SQLCipher; host tests cannot reopen cipher easily.
/// We snapshot money-critical rows into a non-plain-SQLite payload, run the
/// real [BackupEncryptionService] + [BackupRestoreService] path, then assert
/// satang-level continuity of sale totals / tenders / stock.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late BackupEncryptionService encryption;
  late BackupRestoreService restore;
  late _MockDb mockDb;

  void mockPathProvider(Directory root) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            switch (call.method) {
              case 'getApplicationDocumentsDirectory':
                return p.join(root.path, 'docs');
              case 'getTemporaryDirectory':
                return p.join(root.path, 'tmp');
              default:
                return null;
            }
          },
        );
  }

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('promsell_money_backup');
    await Directory(p.join(temp.path, 'docs')).create(recursive: true);
    await Directory(p.join(temp.path, 'tmp')).create(recursive: true);
    mockPathProvider(temp);
    encryption = BackupEncryptionService();
    mockDb = _MockDb();
    when(() => mockDb.close()).thenAnswer((_) async {});
    restore = BackupRestoreService(
      mockDb,
      encryption,
      _unlockedAppLock(),
      // This host test validates the encrypted file pipeline. Real SQLCipher
      // reopen/PRAGMA validation belongs to the device recovery suite.
      candidateValidator: (_) async {},
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test(
    'encrypt→restore preserves multi-tender sale money snapshot + stock',
    () async {
      final liveDb = createInMemoryDatabase();
      addTearDown(liveDb.close);

      final settings = FakeSettingsRepository();
      final saleDs = SaleLocalDatasourceImpl(
        liveDb,
        receiptNumberService: ReceiptNumberService(liveDb),
        inventoryLogService: InventoryLogService(
          liveDb,
          settingsRepo: settings,
        ),
        settingsRepo: settings,
      );
      final productDs = ProductLocalDatasourceImpl(
        liveDb,
        ProductOptionDatasourceImpl(liveDb),
      );

      await productDs.insertProduct(
        ProductsCompanion.insert(
          id: 'sku-1',
          name: 'Coffee',
          price: 100,
          stock: const Value(10),
        ),
      );
      final product = (await productDs.getProductById('sku-1'))!;

      final sale = await saleDs.insertSaleWithItems(
        items: [CartItem(product: product, qty: 2)],
        paymentMethod: 'mixed',
        vatMode: 'NONE',
        vatRate: 0,
        payments: [
          SalePayment(method: 'cash', amount: Money.fromDouble(80)),
          SalePayment(method: 'promptpay', amount: Money.fromDouble(120)),
        ],
      );

      final stockAfter = (await productDs.getProductById('sku-1'))!.stock;
      expect(stockAfter, 8);
      expect(sale.totalAmount, Money.fromDouble(200));
      expect(sale.payments.length, 2);

      final snapshot = <String, dynamic>{
        'saleId': sale.id,
        'receiptNumber': sale.receiptNumber,
        'totalSatang': sale.totalAmount.satang,
        'status': sale.status,
        'payments': sale.payments
            .map((p) => {'method': p.method, 'amountSatang': p.amount.satang})
            .toList(),
        'stock': stockAfter,
      };

      // Non-plain-SQLite payload (restore rejects "SQLite format 3" header).
      final payload = Uint8List.fromList([
        ...utf8.encode('PROMSNAP1'),
        ...utf8.encode(jsonEncode(snapshot)),
      ]);
      expect(
        String.fromCharCodes(payload.take(15)),
        isNot(startsWith('SQLite format 3')),
      );

      final exportPath = p.join(temp.path, 'money_snapshot.db');
      await File(exportPath).writeAsBytes(payload);

      const pin = '654321';
      final encPath = await encryption.encryptFile(
        sourcePath: exportPath,
        pin: pin,
      );

      final docs = p.join(temp.path, 'docs');
      final livePath = p.join(docs, BackupExportService.dbFileName);
      await File(livePath).writeAsBytes(List<int>.filled(32, 7));

      final pre = await restore.restoreFromPath(sourcePath: encPath, pin: pin);
      verify(() => mockDb.close()).called(1);

      final restoredBytes = await File(livePath).readAsBytes();
      expect(restoredBytes, equals(payload));
      expect(await File(pre).readAsBytes(), equals(List<int>.filled(32, 7)));

      final jsonStart = utf8.encode('PROMSNAP1').length;
      final decoded =
          jsonDecode(utf8.decode(restoredBytes.sublist(jsonStart)))
              as Map<String, dynamic>;
      expect(decoded['totalSatang'], 20000);
      expect(decoded['stock'], 8);
      expect(decoded['payments'], hasLength(2));
      expect(decoded['payments'][0]['amountSatang'], 8000);
      expect(decoded['payments'][1]['amountSatang'], 12000);
      expect(decoded['receiptNumber'], sale.receiptNumber);

      // Continuity of money facts from snapshot (not re-selling on a second DB).
      expect(decoded['totalSatang'], sale.totalAmount.satang);
      expect(decoded['stock'], stockAfter);
      final paySum = (decoded['payments'] as List)
          .map((e) => (e as Map)['amountSatang'] as int)
          .fold<int>(0, (a, b) => a + b);
      expect(paySum, decoded['totalSatang']);
      // Live Drift still holds the pre-export truth (same process).
      final stillThere = await saleDs.querySaleById(sale.id);
      expect(stillThere!.totalAmount.satang, decoded['totalSatang']);
      expect(stillThere.payments.length, 2);
    },
  );

  test('wrong PIN does not replace live money-bearing file', () async {
    final payload = Uint8List.fromList([
      ...utf8.encode('PROMSNAP1'),
      ...utf8.encode('{"totalSatang":999}'),
    ]);
    final src = File(p.join(temp.path, 'snap.db'));
    await src.writeAsBytes(payload);
    final enc = await encryption.encryptFile(
      sourcePath: src.path,
      pin: 'goodpin',
    );

    final livePath = p.join(temp.path, 'docs', BackupExportService.dbFileName);
    final liveBefore = Uint8List.fromList([9, 9, 9, 9]);
    await File(livePath).writeAsBytes(liveBefore);

    await expectLater(
      () => restore.restoreFromPath(sourcePath: enc, pin: 'badpinx'),
      throwsA(anything),
    );
    expect(await File(livePath).readAsBytes(), equals(liveBefore));
  });
}
