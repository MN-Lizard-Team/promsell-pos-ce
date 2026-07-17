import 'package:csv/csv.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/csv_product_parser.dart';

class CsvProductParser {
  const CsvProductParser({this.maxDataRows = 2000});

  /// Max data rows (excluding header). Enforced before decoding all cells.
  final int maxDataRows;

  CsvImportResult parse(String csvContent) {
    try {
      // Strip UTF-8 BOM from Excel exports.
      var content = csvContent;
      if (content.isNotEmpty && content.codeUnitAt(0) == 0xFEFF) {
        content = content.substring(1);
      }

      final rows = Csv().decode(content);
      if (rows.isEmpty ||
          !rows.first.any((cell) => cell.toString().trim().isNotEmpty)) {
        return const CsvImportResult(rows: [], error: 'csvNoData');
      }

      if (rows.length - 1 > maxDataRows) {
        return const CsvImportResult(rows: [], error: 'csvTooManyRows');
      }

      final header = rows.first
          .map((value) => value.toString().trim().toLowerCase())
          .toList();
      final nameIndex = _findIndex(header, ['name', 'ชื่อ', 'ชื่อสินค้า']);
      final skuIndex = _findIndex(header, ['sku', 'รหัสสินค้า']);
      final barcodeIndex = _findIndex(header, ['barcode', 'บาร์โค้ด']);
      final priceIndex = _findIndex(header, ['price', 'ราคา', 'ราคาขาย']);
      final costIndex = _findIndex(header, ['cost', 'ต้นทุน']);
      final stockIndex = _findIndex(header, ['stock', 'สต็อก', 'คงเหลือ']);
      final categoryIndex = _findIndex(header, [
        'category',
        'หมวดหมู่',
        'category_name',
      ]);
      final trackStockIndex = _findIndex(header, [
        'track_stock',
        'trackstock',
        'ติดตามสต็อก',
        'นับสต็อก',
      ]);

      if (nameIndex == -1 || priceIndex == -1) {
        return const CsvImportResult(rows: [], error: 'csvInvalidFormat');
      }
      if (rows
          .skip(1)
          .every(
            (row) => !row.any((cell) => cell.toString().trim().isNotEmpty),
          )) {
        return const CsvImportResult(rows: [], error: 'csvNoData');
      }

      final products = <CsvProductRow>[];
      final rowErrors = <CsvImportRowError>[];
      for (var index = 1; index < rows.length; index++) {
        final row = rows[index];
        if (!row.any((cell) => cell.toString().trim().isNotEmpty)) continue;

        final sourceRow = index + 1;
        try {
          final name = _getCell(row, nameIndex).trim();
          final price = double.tryParse(_getCell(row, priceIndex).trim());
          final stockText = stockIndex >= 0
              ? _getCell(row, stockIndex).trim()
              : '';
          final stock = stockText.isEmpty ? 0 : int.tryParse(stockText);
          final costText = costIndex >= 0
              ? _getCell(row, costIndex).trim()
              : '';
          final cost = costText.isEmpty ? null : double.tryParse(costText);
          final barcode = barcodeIndex >= 0
              ? _nullIfEmpty(_getCell(row, barcodeIndex))
              : null;
          final trackStockText = trackStockIndex >= 0
              ? _getCell(row, trackStockIndex).trim().toLowerCase()
              : '';
          final trackStock = _parseTrackStock(trackStockText);

          if (price == null ||
              stock == null ||
              (costText.isNotEmpty && cost == null)) {
            throw ArgumentError('Invalid numeric value.');
          }
          if (cost != null && cost < 0) {
            throw ArgumentError('Cost cannot be negative.');
          }
          if (trackStock == null) {
            throw ArgumentError('track_stock must be true or false.');
          }
          Validators.productName(name);
          Validators.price(price);
          Validators.stock(stock);
          Validators.barcode(barcode);

          products.add(
            CsvProductRow(
              sourceRow: sourceRow,
              name: name,
              sku: skuIndex >= 0 ? _nullIfEmpty(_getCell(row, skuIndex)) : null,
              barcode: barcode,
              price: price,
              cost: cost,
              stock: stock,
              categoryName: categoryIndex >= 0
                  ? _nullIfEmpty(_getCell(row, categoryIndex))
                  : null,
              trackStock: trackStock,
            ),
          );
        } on ArgumentError catch (error) {
          rowErrors.add(
            CsvImportRowError(
              sourceRow: sourceRow,
              message: error.message.toString(),
            ),
          );
        }
      }

      return CsvImportResult(rows: products, rowErrors: rowErrors);
    } catch (_) {
      return const CsvImportResult(rows: [], error: 'csvImportError');
    }
  }

  int _findIndex(List<String> header, List<String> names) {
    for (final name in names) {
      final index = header.indexOf(name);
      if (index >= 0) return index;
    }
    return -1;
  }

  String _getCell(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) return '';
    return row[index].toString();
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool? _parseTrackStock(String value) {
    if (value.isEmpty || value == 'true' || value == '1' || value == 'yes') {
      return true;
    }
    if (value == 'false' || value == '0' || value == 'no') return false;
    return null;
  }
}
